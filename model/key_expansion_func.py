"""
File:        key_expansion_func.py
Author:      Aditya 
Created:     10/2025
Description: AES-128 key creation implementation. A 16-byte cipher key is expanded
             into 176 bytes of round keys for 10 rounds of transformation.
"""

from .helper import SBOX,RCON
from .subbytes_aglorithmic import sub_word_aglorithmic
from typing import Final, List

__all__ = ["key_expansion", "get_round_key"]

# Constants
KEY_LEN: Final[int] = 16  # 128 bits = 16 bytes
EXPANDED_KEY_LEN: Final[int] = 176  # 44 words * 4 bytes = 176 bytes (11 round keys)
NUM_ROUNDS: Final[int] = 10
NUM_ROUND_KEYS: Final[int] = NUM_ROUNDS + 1  # 11 round keys (0-10)
Nk: Final[int] = 4  # Number of 32-bit words in the key (128 / 32 = 4)
Nb: Final[int] = 4  # Number of columns in the state (always 4 for AES)
Nr: Final[int] = NUM_ROUNDS  # Number of rounds (10 for AES-128)


def _sub_word(word: List[int]) -> List[int]:
    """
    Applies the AES S-box substitution to each byte in a 4-byte word.
    (This is the 'SubWord' operation from the AES key schedule).
    
    Args:
        word: A 1D list of 4 integers (bytes), e.g., [0x01, 0xCA, 0x53, 0xAD]

    Returns:
        A new 1D list of 4 substituted bytes.
    """
    return [SBOX[b] for b in word]

def _rot_word(word: List[int]) -> List[int]:
    """
    Rotate a 4-byte word left by one byte (circular left shift).
    This adds "diffusion" - spreading the influence of each byte.
    
    How it works:
    - Takes a 4-byte word [a0, a1, a2, a3]
    - Shifts everything left by 1 position
    - The first byte wraps around to the end
    - Returns [a1, a2, a3, a0]
    
    Example:
        Input:  [0xAA, 0xBB, 0xCC, 0xDD]
        Output: [0xBB, 0xCC, 0xDD, 0xAA]
    
    Implementation detail:
        word[1:] gets all elements except first: [a1, a2, a3]
        word[:1] gets only the first element: [a0]
        Concatenating them gives: [a1, a2, a3, a0]
    
    Args:
        word: List of 4 bytes
    
    Returns:
        Rotated list of 4 bytes
    """
    return word[1:] + word[:1]

def key_expansion(key: bytes) -> bytes:
    """
    Expand a 16-byte AES-128 key into 176 bytes (11 round keys).
    
    This implements the AES key schedule algorithm from FIPS-197.
    The expanded key can be split into 11 round keys of 16 bytes each.
    
    Args:
        key: The 16-byte (128-bit) cipher key
    
    Returns:
        176 bytes containing all 11 round keys in sequence
    
    Raises:
        ValueError: If key is not exactly 16 bytes
    
    Example:
        >>> master_key = bytes(range(16))
        >>> expanded = key_expansion(master_key)
        >>> len(expanded)
        176
        >>> round_0_key = expanded[0:16]
        >>> round_10_key = expanded[160:176]
    """
    # Validate input: must be exactly 16 bytes for AES-128
    if len(key) != KEY_LEN:
        raise ValueError(f"Key must be {KEY_LEN} bytes (got {len(key)})")
    
    # STEP 1: Initialize the word array 'w' with the original key
    # We work with "words" (4-byte chunks) instead of individual bytes
    # This matches the AES specification and makes the algorithm clearer
    # AES-128 needs 44 words total (4 initial + 40 generated = 176 bytes)
    w = []
    
    # The first Nk words (Nk=4 for AES-128) are just the original key split into words
    # Key bytes:    [k0, k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, k11, k12, k13, k14, k15]
    # Becomes words: w[0]=[k0,k1,k2,k3], w[1]=[k4,k5,k6,k7], w[2]=[k8,k9,k10,k11], w[3]=[k12,k13,k14,k15]
    for i in range(Nk):  # i = 0, 1, 2, 3
        w.append([key[4*i], key[4*i + 1], key[4*i + 2], key[4*i + 3]])
    
    # STEP 2: Generate the remaining 40 words (words 4-43)
    # Total needed: Nb * (Nr + 1) = 4 * (10 + 1) = 44 words
    # We already have 4, so generate 40 more (indices 4 through 43)
    for i in range(Nk, Nb * (Nr + 1)):  # i = 4, 5, 6, ..., 43
        # Start with a copy of the previous word
        # [:] creates a copy so we don't modify the original
        temp = w[i - 1][:]
        
        # SPECIAL PROCESSING: Every Nk-th word (i.e., when i is divisible by 4)
        # For AES-128, this happens at positions: 4, 8, 12, 16, 20, 24, 28, 32, 36, 40
        # These mark the start of each new round key
        if i % Nk == 0:
            # Step 2a: Rotate the word left by 1 byte
            # Example: [0xAA, 0xBB, 0xCC, 0xDD] -> [0xBB, 0xCC, 0xDD, 0xAA]
            temp = _rot_word(temp)
            
            # Step 2b: Apply S-box substitution to each byte
            # This adds non-linearity to make the key schedule resistant to attacks
            temp = _sub_word(temp)
            
            # Step 2c: XOR the first byte with the round constant
            # Round constants prevent symmetry and related-key attacks
            # i // Nk gives us the round number (1, 2, 3, ..., 10)
            # Example: if i=4, then i//4=1, so we use RCON[1]=0x01
            temp[0] ^= RCON[i // Nk]
        
        # CORE OPERATION: XOR with the word from Nk positions back
        # Each new word is the XOR of:
        #   1. The processed temp word (from above)
        #   2. The word from Nk (4) positions earlier
        # This creates a "cascade" effect where each word depends on previous words
        # Example: w[4] = temp XOR w[0], w[5] = temp XOR w[1], etc.
        new_word = [w[i - Nk][j] ^ temp[j] for j in range(4)]
        w.append(new_word)
    
    # STEP 3: Flatten the 44 words into a single 176-byte array
    # Convert from: [[b0,b1,b2,b3], [b4,b5,b6,b7], ...]
    # To:           [b0,b1,b2,b3,b4,b5,b6,b7,...]
    expanded_key = []
    for word in w:
        expanded_key.extend(word)  # .extend() adds all bytes from the word
    
    # Convert list to immutable bytes object and return
    return bytes(expanded_key)


def get_round_key(expanded_key: bytes, round_num: int) -> bytes:
    """
    Extract a specific 16-byte round key from the expanded key.
    
    This is a simple slicing operation - the expanded key is just all 11 round keys
    concatenated together, so we extract the appropriate 16-byte chunk.
    
    Layout of expanded_key (176 bytes):
        Bytes 0-15:    Round 0 key
        Bytes 16-31:   Round 1 key
        Bytes 32-47:   Round 2 key
        ...
        Bytes 160-175: Round 10 key
    
    Formula: Round N starts at byte position (N * 16)
    
    Args:
        expanded_key: The 176-byte expanded key from key_expansion()
        round_num: Round number (0-10 for AES-128)
    
    Returns:
        16-byte round key for the specified round
    
    Raises:
        ValueError: If expanded_key is not 176 bytes or round_num is out of range
    
    """
    # Validate the expanded key length
    if len(expanded_key) != EXPANDED_KEY_LEN:
        raise ValueError(f"Expanded key must be {EXPANDED_KEY_LEN} bytes (got {len(expanded_key)})")
    
    # Validate the round number (AES-128 has rounds 0-10)
    if not (0 <= round_num <= NUM_ROUNDS):
        raise ValueError(f"Round number must be 0-{NUM_ROUNDS} (got {round_num})")
    
    # Calculate the starting position and extract 16 bytes
    start = round_num * 16
    end = start + 16
    return expanded_key[start:end]

def add_round_key(data: bytes, round_key: bytes) -> bytes:
    """
    XOR a 16-byte state with a 16-byte round key.

    Args:
        data: State as 16 bytes (AES block).
        round_key: Round key as 16 bytes (from key expansion).

    Returns:
        16-byte result of byte-wise XOR between data and round_key.
    """
    return bytes(data_byte ^ key_byte for data_byte, key_byte in zip(data, round_key))
