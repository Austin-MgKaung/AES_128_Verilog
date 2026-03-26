import os, random
import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from model.aes128 import encrypt_block, decrypt_block

def b2i(b: bytes) -> int: return int.from_bytes(b, "big")
def i2b(x: int) -> bytes: return x.to_bytes(16, "big")

async def _reset(dut):
    dut.start.value   = 0
    dut.key.value     = 0
    dut.block_in.value = 0
    dut.rst.value     = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

async def _run_decrypt(dut, key: bytes, ct: bytes) -> bytes:
    """Drive one ciphertext through the DUT and return the plaintext."""
    dut.key.value      = b2i(key)
    dut.block_in.value = b2i(ct)
    dut.start.value    = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    for _ in range(2000):
        await RisingEdge(dut.clk)
        if int(dut.done.value):
            return i2b(int(dut.block_out.value))
    assert False, "Timed out waiting for 'done'"


@cocotb.test()
async def dec_known_answer_test(dut):
    """NIST FIPS-197 KAT: decrypt the known ciphertext, expect the known plaintext."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    key = bytes.fromhex("000102030405060708090a0b0c0d0e0f")
    ct  = bytes.fromhex("69c4e0d86a7b0430d8cdb78070b4c55a")   # FIPS-197 C.1
    exp = bytes.fromhex("00112233445566778899aabbccddeeff")

    got = await _run_decrypt(dut, key, ct)
    assert got == exp, f"KAT mismatch\nEXP={exp.hex()}\nGOT={got.hex()}"


@cocotb.test()
async def dec_encrypt_then_decrypt(dut):
    """Encrypt 20 random blocks with the Python model, then decrypt each
    with the RTL and verify we recover the original plaintext."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    random.seed(int(os.getenv("SEED", "42")))
    N = int(os.getenv("TRIALS", "20"))

    for i in range(N):
        key = bytes(random.getrandbits(8) for _ in range(16))
        pt  = bytes(random.getrandbits(8) for _ in range(16))
        ct  = encrypt_block(key, pt)          # software model → ciphertext

        got = await _run_decrypt(dut, key, ct)  # RTL decrypt → plaintext
        assert got == pt, (
            f"[{i}] RTL decrypt mismatch\n"
            f"KEY={key.hex()}\nCT ={ct.hex()}\n"
            f"EXP={pt.hex()}\nGOT={got.hex()}"
        )


@cocotb.test()
async def dec_model_matches_rtl(dut):
    """Cross-check: decrypt_block (Python) and DUT must produce identical output
    for the same ciphertext, without going via encrypt first."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    random.seed(int(os.getenv("SEED", "7")))
    N = int(os.getenv("TRIALS", "20"))

    for i in range(N):
        key = bytes(random.getrandbits(8) for _ in range(16))
        ct  = bytes(random.getrandbits(8) for _ in range(16))
        exp = decrypt_block(key, ct)           # Python golden model

        got = await _run_decrypt(dut, key, ct)
        assert got == exp, (
            f"[{i}] model != RTL\n"
            f"KEY={key.hex()}\nCT ={ct.hex()}\n"
            f"EXP={exp.hex()}\nGOT={got.hex()}"
        )
