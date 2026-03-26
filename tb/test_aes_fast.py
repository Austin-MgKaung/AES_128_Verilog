# tb/test_aes_fast.py
# Cocotb tests for aes128_encrypt_fast
# Same start/done interface as original.
# Each round has 2 internal stages so latency is ~22 cycles (threshold in RTL).

import os, random
import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from model.aes128 import encrypt_block

def b2i(b: bytes) -> int: return int.from_bytes(b, "big")
def i2b(x: int) -> bytes: return x.to_bytes(16, "big")

async def _reset(dut):
    dut.start.value    = 0
    dut.key.value      = 0
    dut.block_in.value = 0
    dut.rst.value      = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

async def _run(dut, key: bytes, pt: bytes) -> bytes:
    dut.key.value      = b2i(key)
    dut.block_in.value = b2i(pt)
    dut.start.value    = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0
    for _ in range(2000):
        await RisingEdge(dut.clk)
        if int(dut.done.value):
            return i2b(int(dut.block_out.value))
    assert False, "Timed out — done never asserted"


@cocotb.test()
async def fast_kat(dut):
    """NIST FIPS-197 KAT through aes128_encrypt_fast."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    key = bytes.fromhex("000102030405060708090a0b0c0d0e0f")
    pt  = bytes.fromhex("00112233445566778899aabbccddeeff")
    exp = bytes.fromhex("69c4e0d86a7b0430d8cdb78070b4c55a")

    got = await _run(dut, key, pt)
    assert got == exp, f"KAT FAIL\nEXP={exp.hex()}\nGOT={got.hex()}"


@cocotb.test()
async def fast_random(dut):
    """Random vectors — fast RTL must match Python model."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    random.seed(int(os.getenv("SEED", "1")))
    N = int(os.getenv("TRIALS", "20"))

    for i in range(N):
        key = bytes(random.getrandbits(8) for _ in range(16))
        pt  = bytes(random.getrandbits(8) for _ in range(16))
        exp = encrypt_block(key, pt)
        got = await _run(dut, key, pt)
        assert got == exp, (
            f"[{i}] FAIL\nKEY={key.hex()}\nPT={pt.hex()}\n"
            f"EXP={exp.hex()}\nGOT={got.hex()}"
        )
