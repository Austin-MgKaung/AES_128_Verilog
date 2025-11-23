import os, random
import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from model.aes128 import encrypt_block

def b2i(b: bytes) -> int: return int.from_bytes(b, "big")
def i2b(x: int) -> bytes: return x.to_bytes(16, "big")

async def _reset(dut):
    dut.start.value = 0
    dut.key.value = 0
    dut.block_in.value = 0
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

@cocotb.test()
async def aes_known_answer_test(dut):
    """NIST FIPS-197 AES-128 KAT: key=000102..0f, pt=001122..ff"""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    key = bytes.fromhex("000102030405060708090a0b0c0d0e0f")
    pt  = bytes.fromhex("00112233445566778899aabbccddeeff")
    exp = encrypt_block(key, pt)

    dut.key.value = b2i(key)
    dut.block_in.value = b2i(pt)
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    # wait for done
    for _ in range(2000):
        await RisingEdge(dut.clk)
        if int(dut.done.value):
            got = i2b(int(dut.block_out.value))
            assert got == exp, f"Mismatch\nEXP={exp.hex()}\nGOT={got.hex()}"
            return
    assert False, "Timed out waiting for 'done'"

@cocotb.test()
async def aes_random_sanity(dut):
    random.seed(int(os.getenv("SEED", "1")))
    N = int(os.getenv("TRIALS", "20"))
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    for i in range(N):
        key = bytes(random.getrandbits(8) for _ in range(16))
        pt  = bytes(random.getrandbits(8) for _ in range(16))
        exp = encrypt_block(key, pt)

        dut.key.value = b2i(key)
        dut.block_in.value = b2i(pt)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0

        # wait for done
        timeout = 3000
        while timeout > 0 and int(dut.done.value) == 0:
            await RisingEdge(dut.clk)
            timeout -= 1
        assert int(dut.done.value) == 1, f"[{i}] no 'done' within budget"

        got = i2b(int(dut.block_out.value))
        assert got == exp, f"[{i}] mismatch\nEXP={exp.hex()}\nGOT={got.hex()}"
