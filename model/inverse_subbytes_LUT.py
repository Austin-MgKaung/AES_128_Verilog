"""
File:        inverse_subbytes_LUT.py
Author:      Kaung Tun
Created:     10/2025    
Description: 
    AES Inverse SubBytes implementation using lookup table (LUT).

"""

from .helper import block_to_state, state_to_block,INV_SBOX

def inv_sub_bytes(state):
    """
    Apply inverse S-box to every byte of a 4x4 AES state (column-major).
    """
    return [[INV_SBOX[b] for b in col] for col in state]

def inv_sub_bytes_block(block: bytes) -> bytes:
    """
    Apply InvSubBytes to a 16-byte block via state mapping
    """
    i_state = block_to_state(block)
    o_state = inv_sub_bytes(i_state)
    return bytes(state_to_block(o_state))
