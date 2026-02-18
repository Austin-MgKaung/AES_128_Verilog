"""
File:        inverse_mix_columns.py
Author:      Kreesha
Created:     10/2025
Description: The AES inverse MixColumns transformation applies a fixed matrix multiplication over GF(2^8)
    to each column of the state during decryption. It reverses the diffusion effect of the MixColumns transofrmation.

"""

from model.helper import _gmul, State

def inv_mixcolumns(mcinput):
	mcinput = list(mcinput)
	mcoutput = [0] * 16

	"""
	Performs multiplication in the Galois Field GF(2^8) using the AES polynomial m(x) = x^8 + x^4 + x^3 + x + 1 (or 0x11B)[cite: 297].

	The AES operates internally in a column-major format, and here each column is multiplied with a fixed matrix:

	14     11     13     9

	9     14     11     13

	13     9     14     11

	11     13     9     14
	"""

	# Each column is processed, with index [0], [4], [8], [12] starting off each column
	for i in (0, 4, 8, 12):
		a0 = mcinput[i]
		a1 = mcinput[i + 1]
		a2 = mcinput[i + 2]
		a3 = mcinput[i + 3]

		# Multipy each item by the inverse MixColumns matrix
		mcoutput[i]     = _gmul(14, a0) ^ _gmul(11, a1) ^ _gmul(13, a2) ^ _gmul(9, a3)
		mcoutput[i + 1] = _gmul(9,  a0) ^ _gmul(14, a1) ^ _gmul(11, a2) ^ _gmul(13, a3)
		mcoutput[i + 2] = _gmul(13, a0) ^ _gmul(9,  a1) ^ _gmul(14, a2) ^ _gmul(11, a3)
		mcoutput[i + 3] = _gmul(11, a0) ^ _gmul(13, a1) ^ _gmul(9,  a2) ^ _gmul(14, a3)

	return mcoutput
