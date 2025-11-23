import os, random, pytest
from model.aes128 import encrypt_block
from Crypto.Cipher import AES

def kat_vectors():
    key = bytes.fromhex("000102030405060708090a0b0c0d0e0f")
    pt  = bytes.fromhex("00112233445566778899aabbccddeeff")
    ct  = bytes.fromhex("69c4e0d86a7b0430d8cdb78070b4c55a")
    yield key, pt, ct

@pytest.mark.parametrize("key,pt,exp", list(kat_vectors()))
def test_model_kat(key, pt, exp):
    got = encrypt_block(key, pt)
    assert got == exp, f"KAT mismatch: {got.hex()} vs {exp.hex()}"

def _randbytes(rng: random.Random, n: int) -> bytes:
    return bytes(rng.getrandbits(8) for _ in range(n))

def test_model_matches_pycryptodome_random():
    seed   = int(os.getenv("SEED", "1"))
    trials = int(os.getenv("MODEL_TRIALS", "200"))
    rng = random.Random(seed)
    for i in range(trials):
        key = _randbytes(rng, 16)
        pt  = _randbytes(rng, 16)
        ref = encrypt_block(key, pt)
        lib = AES.new(key, AES.MODE_ECB).encrypt(pt)
        assert ref == lib, (
            f"[{i}] model!=lib\nKEY={key.hex()}\nPT ={pt.hex()}\n"
            f"REF={ref.hex()}\nLIB={lib.hex()}"
        )
