"""
File:        mix_columns_func_LUT.py
Author:      Kreesha
Created:     11/2025
Description: MixColumns using precomputed lookup tables, instead of a Galois operation

"""

from .helper import GFM2, GFM3

def mixcolumns_lut(mcinput: bytes) -> bytes:
    mcoutput = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    """
    Only two lookup tables from helper.py are used, increasing operation speed massively:

    GFM2[x], GFM3[x],

    These hold the product of each corresponding bit from 1 to 256's multiplication by 2 and 3 in GF(2^8).
    Although GFM1[x] is a part of the state matrix, GFM1[x] = x, so is omitted
    """

    # Each item in the block once-again processed in a column-major order
    for i in (0, 4, 8, 12):  
        mcoutput[i]      = GFM2[mcinput[i]] ^ GFM3[mcinput[i+1]] ^ mcinput[i+2] ^ mcinput[i + 3]
        mcoutput[i + 1]  = mcinput[i] ^ GFM2[mcinput[i+1]] ^ GFM3[mcinput[i+2]] ^ mcinput[i + 3]
        mcoutput[i + 2]  = mcinput[i] ^ mcinput[i + 1] ^ GFM2[mcinput[i+2]] ^ GFM3[mcinput[i+3]]
        mcoutput[i + 3] = GFM3[mcinput[i]] ^ mcinput[i + 1] ^ mcinput[i + 2] ^ GFM2[mcinput[i+3]]

    return mcoutput
