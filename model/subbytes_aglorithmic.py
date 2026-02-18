"""
File:        subbytes_aglorithmic.py
Author:      Kaung Tun
Created:     10/2025
Description: 
    AES SubBytes implementation using algorithmic S-box calculation.

"""

from .helper import block_to_state, state_to_block, _g_pow_254, State
from typing import List             


def _affine_transform(b: int) -> int:
    """
    Applies the forward affine transformation (for SubBytes).
    """
    c = 0x63
    bits = [(b >> i) & 1 for i in range(8)]
    
    r0 = bits[0] ^ bits[4] ^ bits[5] ^ bits[6] ^ bits[7]
    r1 = bits[1] ^ bits[5] ^ bits[6] ^ bits[7] ^ bits[0]
    r2 = bits[2] ^ bits[6] ^ bits[7] ^ bits[0] ^ bits[1]
    r3 = bits[3] ^ bits[7] ^ bits[0] ^ bits[1] ^ bits[2]
    r4 = bits[4] ^ bits[0] ^ bits[1] ^ bits[2] ^ bits[3]
    r5 = bits[5] ^ bits[1] ^ bits[2] ^ bits[3] ^ bits[4]
    r6 = bits[6] ^ bits[2] ^ bits[3] ^ bits[4] ^ bits[5]
    r7 = bits[7] ^ bits[3] ^ bits[4] ^ bits[5] ^ bits[6]
    
    result_bits = [r0, r1, r2, r3, r4, r5, r6, r7]
    
    result_byte = 0
    for i in range(8):
        result_byte |= (result_bits[i] << i)
        
    return result_byte ^ c

def _s_box(b: int) -> int:
    """
    Calculates the S-box value for a byte algorithmically.
    """
    inv = _g_pow_254(b)
    return _affine_transform(inv)

def sub_word_aglorithmic(word: List[int]) -> List[int]:
    """
    Applies the algorithmic S-box to each byte in a 4-byte word
    This is the 'SubWord' operation from the AES key schedule 
    """
    return [_s_box(b) for b in word]

    
def sub_bytes(state: State) -> State:
    """
    Applies the algorithmic S-box to each byte of the state.
    (Operates on the state matrix)
    """
    return [[_s_box(b) for b in row] for row in state]

def sub_bytes_block(block: bytes) -> bytes:
    """
    Applies the SubBytes operation to a 16-byte block.
    
    Args:
        block: A 16-byte (128-bit) input block.
        
    Returns:
        A 16-byte (128-bit) block after the SubBytes transformation.
    """
    # 1. Convert the 16-byte block (iterable of ints) to a 4x4 state
    state = block_to_state(block)
    
    # 2. Apply the SubBytes operation to the state
    sub_state = sub_bytes(state)
    
    # 3. Convert the 4x4 state back to a 16-element list of ints
    sub_block_list = state_to_block(sub_state)
    
    # 4. Convert the list of ints into a bytes object
    return bytes(sub_block_list)
