# tb/test_aes_scoreboard.py
from pathlib import Path
from datetime import datetime

import os, random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from tb.env import Driver, OutputMonitor, Scoreboard, AESTrans
from tb.coverage_points import sample_all, export_yaml
from model.aes128 import encrypt_block

def rand_bytes(n=16): return bytes(random.getrandbits(8) for _ in range(n))

@cocotb.test()
async def aes_known_answers(dut):
    """KATs through the env (self-checking)."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    drv = Driver(dut)
    outmon = OutputMonitor(dut)
    scb = Scoreboard(dut, outmon)
    cocotb.start_soon(outmon.run())
    cocotb.start_soon(scb.start())
    await drv.reset()

    vecs = [
        ("000102030405060708090a0b0c0d0e0f", "00112233445566778899aabbccddeeff"),
        ("00000000000000000000000000000000", "00000000000000000000000000000000"),
    ]
    for k_hex, p_hex in vecs:
        k = bytes.fromhex(k_hex); p = bytes.fromhex(p_hex)
        e = encrypt_block(k, p)
        scb.push_expected(e)
        await drv.send(AESTrans(k, p, e), spacing=0)

    # drain a little and let scoreboard consume
    for _ in range(300):
        await RisingEdge(dut.clk)
    assert scb.expected == [], f"Leftover expected items: {len(scb.expected)}"

@cocotb.test()
async def aes_random_scoreboard(dut):
    """Constrained-random with scoreboard + functional coverage."""
    random.seed(int(os.getenv("SEED", "1")))
    N = int(os.getenv("N_RANDOM", "50"))
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    drv = Driver(dut)
    outmon = OutputMonitor(dut)
    scb = Scoreboard(dut, outmon)
    cocotb.start_soon(outmon.run())
    cocotb.start_soon(scb.start())
    await drv.reset()

    patterns = [
        bytes(16),                     # zeros
        bytes([0xFF] * 16),            # ones
        bytes(range(16)),              # inc
        rand_bytes(16),                # random
    ]

    for i in range(N):
        key = random.choice(patterns)
        pt  = random.choice(patterns)
        spacing = random.randint(0, 4)
        exp = encrypt_block(key, pt)
        sample_all(key, pt, spacing)
        scb.push_expected(exp)
        await drv.send(AESTrans(key, pt, exp), spacing=spacing)

    # let outputs drain
    for _ in range(1000):
        await RisingEdge(dut.clk)

    # export functional coverage
    out = Path("build/coverage/functional")
    out.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    export_yaml(str(out / f"{stamp}_aes_random_scoreboard.yaml"))
    assert scb.expected == [], f"Leftover expected items: {len(scb.expected)}"
