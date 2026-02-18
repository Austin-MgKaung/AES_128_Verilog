"""
File:        key_expansion_func_enhanced.py
Author:      Kaung Tun, Adi, Wilf
Created:     11/2025
Description: 
    AES Key Expansion implementation supporting 128, 192, and 256-bit keys.
    This module provides functions to expand the cipher key into round keys
    used in each round of AES encryption/decryption.

"""

from .helper import SBOX,RCON
from .subbytes_aglorithmic import sub_word_aglorithmic
from typing import Final, List

__all__ = ["key_expansion", "get_round_key"]

# Constants
Nb = 4  # AES block width in words (fixed number of columns)

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

def _nr_from_keylen(key_len: int) -> int:
    if key_len == 16:   # 128-bit
        return 10
    if key_len == 24:   # 192-bit
        return 12
    if key_len == 32:   # 256-bit
        return 14
    raise ValueError("AES supports 128/192/256-bit keys only (16/24/32 bytes).")


def key_expansion(key: bytes) -> bytes:
    key_len = len(key)
    Nk = key_len // 4
    Nr = _nr_from_keylen(key_len)
    words_total = Nb * (Nr + 1)  # 44, 52, or 60 words
    w: List[List[int]] = []

    # Seed first Nk words from the key
    for i in range(Nk):
        w.append([key[4*i], key[4*i + 1], key[4*i + 2], key[4*i + 3]])

    # Generate remaining words
    for i in range(Nk, words_total):
        temp = w[i - 1][:]

        if i % Nk == 0:
            temp = _rot_word(temp)
            temp = _sub_word(temp)
            temp[0] ^= RCON[i // Nk]
        elif Nk == 8 and i % Nk == 4:
            # AES-256 extra SubWord every 4 words within each 8-word block
            temp = _sub_word(temp)

        new_word = [w[i - Nk][j] ^ temp[j] for j in range(4)]
        w.append(new_word)

    # Flatten to bytes
    out = bytearray()
    for word in w:
        out.extend(word)
    return bytes(out)

def key_expansion_aglorithmic(key: bytes) -> bytes:
    key_len = len(key)
    Nk = key_len // 4
    Nr = _nr_from_keylen(key_len)
    words_total = Nb * (Nr + 1)  # 44, 52, or 60 words
    w: List[List[int]] = []

    # Seed first Nk words from the key
    for i in range(Nk):
        w.append([key[4*i], key[4*i + 1], key[4*i + 2], key[4*i + 3]])

    # Generate remaining words
    for i in range(Nk, words_total):
        temp = w[i - 1][:]

        if i % Nk == 0:
            temp = _rot_word(temp)
            temp = sub_word_aglorithmic(temp)
            temp[0] ^= RCON[i // Nk]
        elif Nk == 8 and i % Nk == 4:
            # AES-256 extra SubWord every 4 words within each 8-word block
            temp = sub_word_aglorithmic(temp)

        new_word = [w[i - Nk][j] ^ temp[j] for j in range(4)]
        w.append(new_word)

    # Flatten to bytes
    out = bytearray()
    for word in w:
        out.extend(word)
    return bytes(out)

def get_round_key(expanded_key: bytes, round_num: int) -> bytes:
    # Infer Nr from total length: len = 16*(Nr+1)
    if len(expanded_key) % 16 != 0:
        raise ValueError("Invalid expanded key length.")
    Nr_plus_1 = len(expanded_key) // 16
    Nr = Nr_plus_1 - 1
    if not (0 <= round_num <= Nr):
        raise ValueError(f"Round number must be 0..{Nr} (got {round_num}).")
    start = round_num * 16
    return expanded_key[start:start + 16]

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
