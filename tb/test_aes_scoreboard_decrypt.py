# tb/test_aes_scoreboard_decrypt.py
from pathlib import Path
from datetime import datetime
import os, random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from tb.env import Driver, OutputMonitor, Scoreboard, AESTrans
from tb.coverage_points import sample_all, export_yaml
from model.aes128 import encrypt_block, decrypt_block

def rand_bytes(n=16): return bytes(random.getrandbits(8) for _ in range(n))


@cocotb.test()
async def dec_known_answers(dut):
    """KATs through the env: feed known ciphertexts, expect known plaintexts."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    drv    = Driver(dut)
    outmon = OutputMonitor(dut)
    scb    = Scoreboard(dut, outmon)
    cocotb.start_soon(outmon.run())
    cocotb.start_soon(scb.start())
    await drv.reset()

    # Each tuple: (key_hex, ciphertext_hex, expected_plaintext_hex)
    vecs = [
        # FIPS-197 C.1 (reverse direction)
        ("000102030405060708090a0b0c0d0e0f",
         "69c4e0d86a7b0430d8cdb78070b4c55a",
         "00112233445566778899aabbccddeeff"),
        # Zero key, zero plaintext round-trip
        ("00000000000000000000000000000000",
         "66e94bd4ef8a2c3b884cfa59ca342b2e",
         "00000000000000000000000000000000"),
    ]

    for k_hex, ct_hex, pt_hex in vecs:
        k  = bytes.fromhex(k_hex)
        ct = bytes.fromhex(ct_hex)
        pt = bytes.fromhex(pt_hex)
        scb.push_expected(pt)
        await drv.send(AESTrans(key=k, pt=ct, expect=pt), spacing=0)

    for _ in range(300):
        await RisingEdge(dut.clk)
    assert scb.expected == [], f"Leftover expected items: {len(scb.expected)}"


@cocotb.test()
async def dec_random_scoreboard(dut):
    """Constrained-random decrypt: encrypt in software, decrypt in RTL,
    verify plaintext matches original. Also collects functional coverage."""
    random.seed(int(os.getenv("SEED", "1")))
    N = int(os.getenv("N_RANDOM", "50"))

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    drv    = Driver(dut)
    outmon = OutputMonitor(dut)
    scb    = Scoreboard(dut, outmon)
    cocotb.start_soon(outmon.run())
    cocotb.start_soon(scb.start())
    await drv.reset()

    patterns = [
        bytes(16),            # all zeros
        bytes([0xFF] * 16),   # all ones
        bytes(range(16)),     # incrementing
        rand_bytes(16),       # random
    ]

    for i in range(N):
        key     = random.choice(patterns)
        pt      = random.choice(patterns)
        spacing = random.randint(0, 4)

        # Produce ciphertext in software, then decrypt in hardware
        ct  = encrypt_block(key, pt)
        sample_all(key, pt, spacing)   # reuse same coverage points as encrypt
        scb.push_expected(pt)
        await drv.send(AESTrans(key=key, pt=ct, expect=pt), spacing=spacing)

    for _ in range(1000):
        await RisingEdge(dut.clk)

    out   = Path("build/coverage/functional")
    out.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    export_yaml(str(out / f"{stamp}_dec_random_scoreboard.yaml"))

    assert scb.expected == [], f"Leftover expected items: {len(scb.expected)}"
