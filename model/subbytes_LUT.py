"""
File:        subbytes_LUT.py
Author:      Kaung Tun
Created:     10/2025
Description: 
    AES SubBytes implementation using lookup table (LUT).

"""

from .helper import block_to_state, state_to_block, SBOX

def sub_bytes(state):
    """
    Apply S-box to every byte of a 4x4 AES state (column-major).
    """
    return [[SBOX[b] for b in col] for col in state]

def sub_bytes_block(block: bytes) -> bytes:
    """
    Apply SubBytes to a 16-byte block via state mapping .
    """
    i_state = block_to_state(block)
    o_state = sub_bytes(i_state)
    return bytes(state_to_block(o_state))
