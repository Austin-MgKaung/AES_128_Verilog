"""
model/aes128.py

Student TODO:
    Implement AES-128 encryption and decryption for a single 16-byte block.

You should already have a working software model from Milestone 1.
Copy your implementation of `encrypt_block` and `decrypt_block` into this file.

Both functions must:
  - Take a 16-byte key (`bytes`)
  - Take/return a 16-byte block (`bytes`)
  - Implement standard AES-128 in ECB mode, single block only.
"""

from __future__ import annotations
from model.helper import block_to_state, state_to_block, SBOX, RCON, __print
from model.inverse_shift_rows import inv_shift_rows
from model.inverse_mix_columns import inv_mixcolumns
def key_expansion_algorithm(key: bytes) -> bytes:
    """Expand AES key into round keys."""
    if len(key) != 16:
        raise ValueError("Key must be 16 bytes for AES-128")
    
    w = list(key)
    
    for i in range(4, 44):
        temp = [w[i-1]]
        
        if i % 4 == 0:
            # RotWord
            temp = temp[1:] + temp[:1]
            # SubWord
            temp = [SBOX[b] for b in temp]
            # XOR with Rcon
            temp[0] ^= RCON[i//4]
        
        w.append(w[i-4] ^ temp[0])
        if i+1 < 44 and len(w) < 44:
            w.append(w[i-3] ^ (temp[1] if len(temp) > 1 else 0))
        if i+2 < 44 and len(w) < 44:
            w.append(w[i-2] ^ (temp[2] if len(temp) > 2 else 0))
        if i+3 < 44 and len(w) < 44:
            w.append(w[i-1] ^ (temp[3] if len(temp) > 3 else 0))
    
    return bytes(w[:176])

def get_round_key(key_expanded: bytes, round_num: int) -> bytes:
    """Extract round key from expanded key."""
    offset = round_num * 16
    return key_expanded[offset:offset+16]

def add_round_key(state: bytes, round_key: bytes) -> bytes:
    """XOR state with round key."""
    return bytes(a ^ b for a, b in zip(state, round_key))

def shift_rows(state: bytes) -> bytes:
    """AES ShiftRows transformation."""
    rows = [
        [state[0], state[4], state[8],  state[12]],
        [state[1], state[5], state[9],  state[13]],
        [state[2], state[6], state[10], state[14]],
        [state[3], state[7], state[11], state[15]]
    ]
    # Shift rows
    rows[1] = rows[1][1:] + rows[1][:1]
    rows[2] = rows[2][2:] + rows[2][:2]
    rows[3] = rows[3][3:] + rows[3][:3]
    
    return bytes([
        rows[0][0], rows[1][0], rows[2][0], rows[3][0],
        rows[0][1], rows[1][1], rows[2][1], rows[3][1],
        rows[0][2], rows[1][2], rows[2][2], rows[3][2],
        rows[0][3], rows[1][3], rows[2][3], rows[3][3]
    ])

def ag_sub_bytes_block(state: bytes) -> bytes:
    """Apply S-box to all bytes."""
    return bytes(SBOX[b] for b in state)

def ag_inv_sub_bytes_block(state: bytes) -> bytes:
    """Apply inverse S-box to all bytes."""
    INV_SBOX = tuple(SBOX.index(i) for i in range(256))
    return bytes(INV_SBOX[b] for b in state)

def mixcolumns(state: bytes) -> bytes:
    """AES MixColumns transformation."""
    def gmul(a, b):
        """Galois field multiplication."""
        p = 0
        for _ in range(8):
            if b & 1:
                p ^= a
            hi_bit_set = a & 0x80
            a <<= 1
            if hi_bit_set:
                a ^= 0x1b
            b >>= 1
        return p & 0xff
    
    output = [0] * 16
    for i in (0, 4, 8, 12):
        a0, a1, a2, a3 = state[i], state[i+1], state[i+2], state[i+3]
        output[i]     = gmul(0x02, a0) ^ gmul(0x03, a1) ^ a2 ^ a3
        output[i+1]   = a0 ^ gmul(0x02, a1) ^ gmul(0x03, a2) ^ a3
        output[i+2]   = a0 ^ a1 ^ gmul(0x02, a2) ^ gmul(0x03, a3)
        output[i+3]   = gmul(0x03, a0) ^ a1 ^ a2 ^ gmul(0x02, a3)
    
    return bytes(output)
def encrypt_block(key: bytes, pt: bytes) -> bytes:
    """
    Encrypt one 16-byte block with a 16-byte AES-128 key.
    Return: 16-byte ciphertext.
    """
      # --- Basic checks ---
    if len(pt) != 16:
        raise ValueError("Plaintext must be 16 bytes long.")
    if len(key) not in (16, 24, 32):
        raise ValueError("Key must be 16, 24, or 32 bytes (AES-128/192/256).")

    # --- Derive number of rounds from key length (only change needed for 192/256) ---
    if len(key) == 16:
        Nr = 10   # AES-128
    elif len(key) == 24:
        Nr = 12   # AES-192
    else:
        Nr = 14   # AES-256

    key_expanded = key_expansion_algorithm(key)

    # Initial round key addition (Round 0)
    initialInput = add_round_key(pt, get_round_key(key_expanded, 0))

    # Rounds 1 to Nr-1 
    for roundNumber in range(Nr - 1):
        
        __print(first,f"\n Round {roundNumber + 1} Start: ")

        # SubBytes  --->  Performs algorithmic calculation of the S-box using Inverse Galois field multiplication
        subBytesOutput = ag_sub_bytes_block(initialInput)
        __print(first,"SubBytes output:", ", ".join(f"{x:02X}" for x in subBytesOutput))
        # ShiftRows --->  Performs left shift on the 2nd, 3rd and 4th row of the subBytes output
        shiftRowsOutput = shift_rows(subBytesOutput)
        __print(first,"ShiftRows output:", ", ".join(f"{x:02X}" for x in shiftRowsOutput))

        # MixColumns  --->  Performs matrix multiplication using galois field multiplication on each column and a specific matrix
        mixColumnsOutput = mixcolumns(shiftRowsOutput)
        __print(first,"MixColumns output:", ", ".join(f"{x:02X}" for x in mixColumnsOutput))
        # AddRoundKey  --->  Accesses the relevant round key and XORs it to the MixColumns output
        roundKey = get_round_key(key_expanded, roundNumber + 1)

        addRoundKeyOutput = add_round_key(mixColumnsOutput, roundKey)
        __print(first,"AddRoundKey output:", ", ".join(f"{x:02X}" for x in addRoundKeyOutput))
        __print(first,f"\n Round {roundNumber + 1} completed successfuly")

        # Assigns the AddRoundKey output as the new input for the start of the next round
        initialInput = addRoundKeyOutput

    # Final Round (Round Nr): SubBytes, ShiftRows, AddRoundKey (no MixColumns)
    __print(first,f"\n Final Round (Round {Nr}) Start: ")
    finalSubBytes = ag_sub_bytes_block(initialInput)
    __print(first,"Final SubBytes output:", ", ".join(f"{x:02X}" for x in finalSubBytes))

    finalShiftRows = shift_rows(finalSubBytes)
    __print(first,"Final ShiftRows output:", ", ".join(f"{x:02X}" for x in finalShiftRows))

    finalKey = get_round_key(key_expanded, Nr)

    cipherText = add_round_key(finalShiftRows, finalKey)
    __print(first,"Encrypted Output:", ", ".join(f"{x:02X}" for x in cipherText))

    return cipherText
    # For now, we raise to let tests SKIP this part in CI.
    raise NotImplementedError("Implement AES-128 block encryption here")
    # Convert plaintext and key to state


def decrypt_block(key: bytes, ct: bytes) -> bytes:
    """
    Decrypt one 16-byte block with AES-128/192/256 depending on key length.
    Return: 16-byte plaintext.
    """
    # --- Basic checks ---
    if len(ct) != 16:
        raise ValueError("Ciphertext must be 16 bytes long.")
    if len(key) not in (16, 24, 32):
        raise ValueError("Key must be 16, 24, or 32 bytes (AES-128/192/256).")

    # --- Derive number of rounds from key length ---
    if len(key) == 16:
        Nr = 10   # AES-128
    elif len(key) == 24:
        Nr = 12   # AES-192
    else:
        Nr = 14   # AES-256

    key_expanded = key_expansion_aglorithm(key)

    # Initial AddRoundKey with the LAST round key (Round Nr)
    initialInput = add_round_key(ct, get_round_key(key_expanded, Nr))
    #__print(first,f"\n Initial AddRoundKey (Round {Nr}) applied.")

    # Rounds Nr-1 down to 1:
    for roundNumber in range(Nr - 1, 0, -1):

        #__print(first,f"\n Round {roundNumber} Start (decryption): ")

        # InvShiftRows ---> right shifts rows (inverse of ShiftRows)
        invShiftRowsOutput = inv_shift_rows(initialInput)
        #__print(first,"InvShiftRows output:", ", ".join(f"{x:02X}" for x in invShiftRowsOutput))
        # InvSubBytes ---> applies inverse S-box (your algorithmic inverse)
        invSubBytesOutput = ag_inv_sub_bytes_block(invShiftRowsOutput)
        #__print(first,"InvSubBytes output:", ", ".join(f"{x:02X}" for x in invSubBytesOutput))

        # AddRoundKey ---> XOR with the round key for this round
        roundKey = get_round_key(key_expanded, roundNumber)

        addRoundKeyOutput = add_round_key(invSubBytesOutput, roundKey)
        #__print(first,"AddRoundKey output:", ", ".join(f"{x:02X}" for x in addRoundKeyOutput))

        # InvMixColumns ---> inverse column mix (skipped only in final round)
        invMixColumnsOutput = inv_mixcolumns(addRoundKeyOutput)
        #__print(first,"InvMixColumns output:", ", ".join(f"{x:02X}" for x in invMixColumnsOutput))

        #__print(first,f"\n Round {roundNumber} completed successfully")

        # Next input for the following (earlier) round
        initialInput = invMixColumnsOutput

    # Final Round (Round 0): InvShiftRows, InvSubBytes, AddRoundKey(0) — no InvMixColumns
   # __print(first,f"\n Final Round (Round 0) Start (decryption): ")   
    finalInvShiftRows = inv_shift_rows(initialInput)
    #__print(first,"Final InvShiftRows output:", ", ".join(f"{x:02X}" for x in finalInvShiftRows))

    finalInvSubBytes = ag_inv_sub_bytes_block(finalInvShiftRows)
    #__print(first,"Final InvSubBytes output:", ", ".join(f"{x:02X}" for x in finalInvSubBytes))

    finalKey = get_round_key(key_expanded, 0)

    plainText = add_round_key(finalInvSubBytes, finalKey)
    #__print(first,"Decrypted Output:", ", ".join(f"{x:02X}" for x in plainText))

    return plainText
    
    raise NotImplementedError("Implement AES-128 block encryption here")
