import sys
from pathlib import Path
# Add repo root to Python path so 'model' package is found
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


# tb/test_model_vs_lib.py
import os, random, pytest
from Crypto.Cipher import AES

# Student model under test
from model.aes128 import encrypt_block,decrypt_block

# NIST FIPS-197 AES-128 Known Answer Test (KAT)
# key = 000102...0f, pt = 001122...ff
KAT_PT  = bytes([0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,
                 0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff])
KAT_KEY_128 = bytes(range(16))
KAT_CT_128  = bytes.fromhex("69c4e0d86a7b0430d8cdb78070b4c55a")


def lib_encrypt_block(key: bytes, pt: bytes) -> bytes:
    return AES.new(key, AES.MODE_ECB).encrypt(pt)

def test_kat_library_encrypt():
    """Smoke: library itself produces the NIST KAT."""
    assert lib_encrypt_block(KAT_KEY_128, KAT_PT) == KAT_CT_128

def test_model_matches_library_kat_encrypt():
    """Compare  model to library on the KAT."""
    try:
        got_1 = encrypt_block(KAT_KEY_128, KAT_PT)
    
    except NotImplementedError:
        pytest.skip(" model not implemented yet")
    assert got_1 == KAT_CT_128, f"Model KAT mismatch: got {got_1.hex()}, exp {KAT_CT_128.hex()}"
    


def test_model_matches_library_random_encrypt(n=100):
    """Random vectors: model vs library (runs only if model implemented)."""
    try:
         # ensure import ok
        _ = encrypt_block
    except Exception:
        pytest.skip("model import failed")

    # If the model is still a stub, this will raise and we skip
    try:
        for _ in range(n):
            key_128 = random.randbytes(16) if hasattr(random, "randbytes") else bytes([random.randrange(256) for _ in range(16)])
            pt  = random.randbytes(16) if hasattr(random, "randbytes") else bytes([random.randrange(256) for _ in range(16)])

            exp_128 = lib_encrypt_block(key_128, pt)
            
            try:
                got_1 = encrypt_block(key_128, pt)
                
            except NotImplementedError:
                pytest.skip("Student model not implemented yet")
            assert got_1 == exp_128, f"Mismatch\nKEY={key_128.hex()}\nPT ={pt.hex()}\nEXP={exp_128.hex()}\nGOT={got_1.hex()}"
        
    except NotImplementedError:
        pytest.skip("Student model not implemented yet") 


def lib_decrypt_block(key: bytes, ct: bytes) -> bytes:
    return AES.new(key, AES.MODE_ECB).decrypt(ct)

def test_kat_library_decrypt():
    """Smoke test: ensure the library itself correctly decrypts the NIST KAT."""
    assert lib_decrypt_block(KAT_KEY_128, KAT_CT_128) == KAT_PT
    

def test_model_matches_library_kat_decrypt():
    """Compare our model to library on the KAT."""
    try:
        got_1 = decrypt_block(KAT_KEY_128, KAT_CT_128)
       

    except NameError:
        pytest.skip("Our 'decrypt_block' function not found or not imported")
    except NotImplementedError:
        pytest.skip("Our 'decrypt_block' not implemented yet")

    assert got_1 == KAT_PT, f"Model KAT mismatch: got {got_1.hex()}, exp {KAT_PT.hex()}"
    
  

def test_model_matches_library_random_decrypt(n=100):
    """
    1. Generate a random key and plaintext (pt).
    2. Use the *trusted library* to encrypt pt -> ct.
    3. Use the *ours model* to decrypt ct -> got.
    4. Assert that got == pt.
    """
    try:
        # Check that the function exists before looping
        _ = decrypt_block

    except NameError:
        pytest.skip("'decrypt_block' function not found or not imported")
    except Exception:
        pytest.skip(" model import failed")

    # If the model is a stub, this will raise and we skip
    try:
        for _ in range(n):
            # Generate random data
            key_128 = random.randbytes(16) if hasattr(random, "randbytes") else bytes([random.randrange(256) for _ in range(16)])
            
            pt  = random.randbytes(16) if hasattr(random, "randbytes") else bytes([random.randrange(256) for _ in range(16)])
            
            # Encrypt with trusted library
            ct_1 = lib_encrypt_block(key_128, pt)
            

            
            # Decrypt with our decrypt  model
            try:
                got_1 = decrypt_block(key_128, ct_1)
                
                
                
            except NotImplementedError:
                pytest.skip("'decrypt_block' not implemented yet")
                
            # Assert original plaintext equals decrypted text
            assert got_1 == pt, f"Round-trip Mismatch\nKEY={key_128.hex()}\nPT ={pt.hex()}\nCT ={ct_1.hex()}\nGOT={got_1.hex()}"
           
            
    except NotImplementedError:
        pytest.skip("'decrypt_block' not implemented yet")
