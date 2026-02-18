"""
File:        mix_columns_func.py
Author:      Kreesha
Created:     10/2025
Description: MixColumns step multiplies the block with a state matrix, introducing diffusion

"""

from .helper import _gmul

def mixcolumns(mcinput):

	"""
	Performs the MixColumns transformation on a 16-byte block.

	The MixColums step introduced further diffusion into into the AES cipher. 
	The AES operates internally in a column-major format, and here each column is multiplied with a fixed matrix:

	2     3     1     1

	1     2     3     1

	1     1     2     3

	3     1     1     2

	The multiplication is performed through our "_gmul()" function, a galois field multiplication operation 
	"""
	mcinput = list(mcinput)

	#Initialises the array where the output of the function will be stored
	mcoutput = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	
	# Each column is passed through an iteration of this loop, withindex [0], [4], [8], [12] starting off each column
	for i in (0, 4, 8, 12):  

		"""
		E.g. Column 1 of of the output product is computed:
		output[0]  =  2*input[0]   XOR   3*input[1]   XOR   1*input[2]   XOR   1*input[3]
		output[1]  =  1*input[0]   XOR   2*input[1]   XOR   3*input[2]   XOR   1*input[3]
		output[2]  =  1*input[0]   XOR   1*input[1]   XOR   2*input[2]   XOR   3*input[3]
		output[3]  =  3*input[0]   XOR   1*input[1]   XOR   1*input[2]   XOR   2*input[3]
        """
		
		mcoutput[i]      = _gmul(2, mcinput[i]) ^ _gmul(3, mcinput[i + 1]) ^ mcinput[i + 2] ^ mcinput[i + 3]
		mcoutput[i + 1]  = mcinput[i] ^ _gmul(2, mcinput[i + 1]) ^ _gmul(3, mcinput[i + 2]) ^ mcinput[i + 3]
		mcoutput[i + 2]  = mcinput[i] ^ mcinput[i + 1] ^ _gmul(2, mcinput[i + 2]) ^ _gmul(3, mcinput[i + 3])
		mcoutput[i + 3] = _gmul(3, mcinput[i]) ^ mcinput[i + 1] ^ mcinput[i + 2] ^ _gmul(2, mcinput[i + 3])
	
	return mcoutput
