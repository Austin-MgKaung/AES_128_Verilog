# tb/test_aes_stream.py
# Cocotb tests for aes128_encrypt_stream
# Interface: valid_in / valid_out  (NO start/done)
# Latency: 10 cycles (10 rounds × 1 stage each)
# II = 1 — a new block can be sent every cycle

import os, random
import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from model.aes128 import encrypt_block

def b2i(b: bytes) -> int: return int.from_bytes(b, "big")
def i2b(x: int) -> bytes: return x.to_bytes(16, "big")

LATENCY = 10   # pipeline depth in clock cycles

async def _reset(dut):
    dut.valid_in.value  = 0
    dut.key.value       = 0
    dut.block_in.value  = 0
    dut.rst.value       = 1
    for _ in range(4):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)


@cocotb.test()
async def stream_kat(dut):
    """NIST KAT: send one block, wait LATENCY cycles, check valid_out + block_out."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    key = bytes.fromhex("000102030405060708090a0b0c0d0e0f")
    pt  = bytes.fromhex("00112233445566778899aabbccddeeff")
    exp = bytes.fromhex("69c4e0d86a7b0430d8cdb78070b4c55a")

    # Send one block
    dut.key.value      = b2i(key)
    dut.block_in.value = b2i(pt)
    dut.valid_in.value = 1
    await RisingEdge(dut.clk)
    dut.valid_in.value = 0

    # Wait for valid_out
    for _ in range(LATENCY + 5):
        await RisingEdge(dut.clk)
        if int(dut.valid_out.value):
            got = i2b(int(dut.block_out.value))
            assert got == exp, f"KAT FAIL\nEXP={exp.hex()}\nGOT={got.hex()}"
            return

    assert False, f"valid_out never fired within {LATENCY+5} cycles"


@cocotb.test()
async def stream_back_to_back(dut):
    """Send N blocks back-to-back (II=1), collect all outputs, verify order."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    random.seed(int(os.getenv("SEED", "1")))
    N = int(os.getenv("TRIALS", "20"))

    key = bytes.fromhex("000102030405060708090a0b0c0d0e0f")

    # Build input list
    inputs = [bytes(random.getrandbits(8) for _ in range(16)) for _ in range(N)]
    expected = [encrypt_block(key, pt) for pt in inputs]
    outputs = []

    dut.key.value = b2i(key)

    # Drive all N blocks back-to-back
    for pt in inputs:
        dut.block_in.value = b2i(pt)
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)

    dut.valid_in.value = 0

    # Drain: collect N outputs as valid_out fires
    for _ in range(N + LATENCY + 5):
        await RisingEdge(dut.clk)
        if int(dut.valid_out.value):
            outputs.append(i2b(int(dut.block_out.value)))
        if len(outputs) == N:
            break

    assert len(outputs) == N, f"Expected {N} outputs, got {len(outputs)}"
    for i, (got, exp) in enumerate(zip(outputs, expected)):
        assert got == exp, (
            f"[{i}] mismatch\nEXP={exp.hex()}\nGOT={got.hex()}"
        )


@cocotb.test()
async def stream_random_model(dut):
    """Random keys and plaintexts — stream RTL must match Python model."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await _reset(dut)

    random.seed(int(os.getenv("SEED", "3")))
    N = int(os.getenv("TRIALS", "20"))

    inputs  = [(bytes(random.getrandbits(8) for _ in range(16)),
                bytes(random.getrandbits(8) for _ in range(16))) for _ in range(N)]
    expected = [encrypt_block(k, p) for k, p in inputs]
    outputs  = []

    # Send one at a time (key changes per block so II=1 bulk not safe here)
    for key, pt in inputs:
        dut.key.value      = b2i(key)
        dut.block_in.value = b2i(pt)
        dut.valid_in.value = 1
        await RisingEdge(dut.clk)
        dut.valid_in.value = 0

        # Wait for this block's output
        for _ in range(LATENCY + 5):
            await RisingEdge(dut.clk)
            if int(dut.valid_out.value):
                outputs.append(i2b(int(dut.block_out.value)))
                break

    assert len(outputs) == N
    for i, (got, exp) in enumerate(zip(outputs, expected)):
        assert got == exp, f"[{i}] EXP={exp.hex()} GOT={got.hex()}"
