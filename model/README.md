# `model/` — Software AES-128 Reference Model

This directory contains the software model of AES-128, used as a golden reference for verifying your RTL implementation.

By **Milestone 1** you should already have a working AES-128 model that supports both encryption and decryption.

In this template you will:

1. Port that model into `aes128.py`.
2. Make sure it matches the required function signatures and packaging.
3. Use it as the reference for RTL verification.

---

## Files

- `aes128.py`  
  Contains the AES-128 reference model. You must provide:

  ```python
  def encrypt_block(key: bytes, pt: bytes) -> bytes:
      ...

  def decrypt_block(key: bytes, ct: bytes) -> bytes:
      ...
  ```

- `__init__.py`  
  Makes `model` a Python package so tests can do:

  ```python
  from model.aes128 import encrypt_block, decrypt_block
  ```

---

## Student responsibilities

1. **Bring in your Milestone 1 model:**
   - Paste or adapt your `encrypt_block` and `decrypt_block` implementations into `aes128.py`.
   - Ensure they still accept and return 16-byte `bytes` objects only.
   - Ensure any helper functions you used are also copied or reimplemented as needed.

2. **Keep behaviour and correctness:**
   - `encrypt_block(key, pt)` must match AES-128 encryption (ECB, single block).
   - `decrypt_block(key, ct)` must be its inverse so that:

     ```python
     decrypt_block(key, encrypt_block(key, pt)) == pt
     ```

3. **Keep it self-contained:**
   - Do **not** call external crypto libraries inside `encrypt_block` / `decrypt_block`.

Your RTL will be checked against this model. If you break the model, RTL tests will fail too.
