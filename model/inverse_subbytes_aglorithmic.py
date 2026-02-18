"""
File:        inverse_subbytes_aglorithmic.py
Author:      Kaung Tun
Created:     10/2025
Description: 
    AES Inverse SubBytes implementation using algorithmic calculation.

"""

from .helper import block_to_state, state_to_block, _g_pow_254, State 
from typing import List             

def _inv_affine_transform(b: int) -> int:
    """
    Applies the inverse affine transformation.
    """
    d = 0x05 # constant for inverse affine transform
    bits = [(b >> i) & 1 for i in range(8)]

    r0 = bits[2] ^ bits[5] ^ bits[7]
    r1 = bits[3] ^ bits[6] ^ bits[0]
    r2 = bits[4] ^ bits[7] ^ bits[1]
    r3 = bits[5] ^ bits[0] ^ bits[2]
    r4 = bits[6] ^ bits[1] ^ bits[3]
    r5 = bits[7] ^ bits[2] ^ bits[4]
    r6 = bits[0] ^ bits[3] ^ bits[5]
    r7 = bits[1] ^ bits[4] ^ bits[6]
    
    result_bits = [r0, r1, r2, r3, r4, r5, r6, r7]
    
    result_byte = 0
    for i in range(8):
        result_byte |= (result_bits[i] << i)
        
    return result_byte ^ d


def _inv_s_box(b: int) -> int:
    """
    Calculates the inverse S-box value for a byte algorithmically.
    """
    s_prime = _inv_affine_transform(b)
    return _g_pow_254(s_prime)

def inv_sub_bytes(state: State) -> State:
    """
    Applies the algorithmic inverse S-box to each byte.
    """
    return [[_inv_s_box(b) for b in row] for row in state]

def inv_sub_bytes_block(block: bytes) -> bytes:
    """
    Applies the Inverse SubBytes operation to a 16-byte block.
    
    Args:
        block: A 16-byte input block.
        
    Returns:
        block: A 16-byte block after the InvSubBytes transformation.
    """
    # 1. Convert the 16-byte block to a 4x4 state
    state = block_to_state(block)
    
    # 2. Apply the Inverse SubBytes operation to the state
    sub_state = inv_sub_bytes(state)
    
    # 3. Convert the 4x4 state back to a 16-element list
    sub_block_list = state_to_block(sub_state)
    
    # 4. Convert the list of ints into a bytes object
    return bytes(sub_block_list)
