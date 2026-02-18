"""
File:        inverse_mix_columns_LUT.py
Author:      Kreesha
Created:     10/2025
Description: Implementation of the AES Inverse MixColumns using lookup tables (LUTs), replacing finite-field multiplications 

"""

from model.helper import GFM9, GFM11, GFM13, GFM14

def inv_mixcolumns_lut(mcinput):
    mcinput = list(mcinput)
    mcoutput = [0] * 16

    """
    Instead of calculating the GF(2^8) multiplication at runtime, four lookup tables:

    GFM9[x], GFM11[x], GFM13[x], GFM14[x]

    which hold the product of each corresponding bit from 1 to 256's multiplication by 9, 11, 13, and 14 in GF(2^8).
    """

    # Process each item in the block once-again in a column-major order
    for i in (0, 4, 8, 12):
        a0 = mcinput[i]
        a1 = mcinput[i + 1]
        a2 = mcinput[i + 2]
        a3 = mcinput[i + 3]

        # Refers to the LUTs in the helper.py files, increasing the speed of the MixColumns step 
        mcoutput[i]     = GFM14[a0] ^ GFM11[a1] ^ GFM13[a2] ^ GFM9[a3]
        mcoutput[i + 1] = GFM9[a0]  ^ GFM14[a1] ^ GFM11[a2] ^ GFM13[a3]
        mcoutput[i + 2] = GFM13[a0] ^ GFM9[a1]  ^ GFM14[a2] ^ GFM11[a3]
        mcoutput[i + 3] = GFM11[a0] ^ GFM13[a1] ^ GFM9[a2]  ^ GFM14[a3]
      
    return mcoutput
