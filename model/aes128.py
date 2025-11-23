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
    Encrypt a 16-byte plaintext block using AES-128.

    Args:
        key: 16-byte AES-128 key.
        pt:  16-byte plaintext block.

    Returns:
        16-byte ciphertext block.

    You MUST implement this using your own AES-128 code from Milestone 1.
    Do NOT call external crypto libraries here.

    This function is used as the golden reference for RTL tests.
    """
    # TODO: copy your Milestone 1 encryption implementation here.
    raise NotImplementedError(
        "encrypt_block() not implemented. "
        "Copy your Milestone 1 AES-128 encryption code into model/aes128.py."
    )


def decrypt_block(key: bytes, ct: bytes) -> bytes:
    """
    Decrypt a 16-byte ciphertext block using AES-128.

    Args:
        key: 16-byte AES-128 key.
        ct:  16-byte ciphertext block.

    Returns:
        16-byte plaintext block.

    You MUST implement this using your own AES-128 code from Milestone 1.
    Do NOT call external crypto libraries here.
    """
    # TODO: copy your Milestone 1 decryption implementation here.
    raise NotImplementedError(
        "decrypt_block() not implemented. "
        "Copy your Milestone 1 AES-128 decryption code into model/aes128.py."
    )
