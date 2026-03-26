# Branch: throughput-stream
# Tests: aes128_encrypt_stream  (no FSM, valid_in/valid_out, 1-stage rounds)
from cocotb_test.simulator import run
from pathlib import Path
import shutil

ROOT  = Path(__file__).resolve().parents[1]
RTL   = ROOT / "rtl"
BUILD = ROOT / "build" / "sim_aes_stream"

def _collect_rtl():
    return sorted([str(p) for ext in ("*.sv", "*.v") for p in RTL.rglob(ext)])

def test_aes_stream_rtl():
    if BUILD.exists():
        shutil.rmtree(BUILD)
    BUILD.mkdir(parents=True, exist_ok=True)

    run(
        verilog_sources=_collect_rtl(),
        toplevel="aes128_encrypt_stream",
        module="tb.test_aes_stream",
        toplevel_lang="verilog",
        sim="verilator",
        includes=[str(RTL)],
        timescale="1ns/1ps",
        waves=True,
        extra_args=["--coverage"],
        sim_args=["+verilator+coverage+file+build/coverage_stream.dat", "--trace"],
        build_dir=str(BUILD),
        force_compile=True,
        python_search=[str(ROOT)],
    )
