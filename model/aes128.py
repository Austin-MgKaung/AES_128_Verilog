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

    key_expanded = key_expansion_aglorithmic(key)

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

    key_expanded = key_expansion_aglorithmic(key)

    # Initial AddRoundKey with the LAST round key (Round Nr)
    initialInput = add_round_key(ct, get_round_key(key_expanded, Nr))
    __print(first,f"\n Initial AddRoundKey (Round {Nr}) applied.")

    # Rounds Nr-1 down to 1:
    for roundNumber in range(Nr - 1, 0, -1):

        __print(first,f"\n Round {roundNumber} Start (decryption): ")

        # InvShiftRows ---> right shifts rows (inverse of ShiftRows)
        invShiftRowsOutput = inv_shift_rows(initialInput)
        __print(first,"InvShiftRows output:", ", ".join(f"{x:02X}" for x in invShiftRowsOutput))
        # InvSubBytes ---> applies inverse S-box (your algorithmic inverse)
        invSubBytesOutput = ag_inv_sub_bytes_block(invShiftRowsOutput)
        __print(first,"InvSubBytes output:", ", ".join(f"{x:02X}" for x in invSubBytesOutput))

        # AddRoundKey ---> XOR with the round key for this round
        roundKey = get_round_key(key_expanded, roundNumber)

        addRoundKeyOutput = add_round_key(invSubBytesOutput, roundKey)
        __print(first,"AddRoundKey output:", ", ".join(f"{x:02X}" for x in addRoundKeyOutput))

        # InvMixColumns ---> inverse column mix (skipped only in final round)
        invMixColumnsOutput = inv_mixcolumns(addRoundKeyOutput)
        __print(first,"InvMixColumns output:", ", ".join(f"{x:02X}" for x in invMixColumnsOutput))

        __print(first,f"\n Round {roundNumber} completed successfully")

        # Next input for the following (earlier) round
        initialInput = invMixColumnsOutput

    # Final Round (Round 0): InvShiftRows, InvSubBytes, AddRoundKey(0) — no InvMixColumns
    __print(first,f"\n Final Round (Round 0) Start (decryption): ")   
    finalInvShiftRows = inv_shift_rows(initialInput)
    __print(first,"Final InvShiftRows output:", ", ".join(f"{x:02X}" for x in finalInvShiftRows))

    finalInvSubBytes = ag_inv_sub_bytes_block(finalInvShiftRows)
    __print(first,"Final InvSubBytes output:", ", ".join(f"{x:02X}" for x in finalInvSubBytes))

    finalKey = get_round_key(key_expanded, 0)

    plainText = add_round_key(finalInvSubBytes, finalKey)
    __print(first,"Decrypted Output:", ", ".join(f"{x:02X}" for x in plainText))

    return plainText
    
    raise NotImplementedError("Implement AES-128 block encryption here")
