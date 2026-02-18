"""
File:        shift_rows_func.py
Author:      Pranav
Created:     10/2025
Description: AES ShiftRows transformation implementation, a circular left shift on each row.

"""

def shift_rows(state):

    """
    The AES ShiftRows step performs a cyclical left shift on each row of the block by
    a fixed value every row, introducing the diffusion into the transformation.
    """
    
    if len(state) != 16:
        raise ValueError("State must contain 16 bytes.")
    
    s = list(state)

    # Unpack into rows 
    rows = [
        [s[0], s[4], s[8],  s[12]],  # row 0
        [s[1], s[5], s[9],  s[13]],  # row 1
        [s[2], s[6], s[10], s[14]],  # row 2
        [s[3], s[7], s[11], s[15]],  # row 3
    ]
    
    """
    LEFT rotation:
    
    Row 0 ---> no shift
    Row 1 ---> shift left by 1
    Row 2 ---> shift left by 2
    Row 3 ---> shift left by 3
    """
    for r in range(1, 4):
        rows[r] = rows[r][r:] + rows[r][:r]

    # Pack rows back to column order for the next step: MixColumns
    return [
        rows[0][0], rows[1][0], rows[2][0], rows[3][0],
        rows[0][1], rows[1][1], rows[2][1], rows[3][1],
        rows[0][2], rows[1][2], rows[2][2], rows[3][2],
        rows[0][3], rows[1][3], rows[2][3], rows[3][3],
    ]
