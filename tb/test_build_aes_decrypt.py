from cocotb_test.simulator import run
from pathlib import Path
import shutil

ROOT  = Path(__file__).resolve().parents[1]
RTL   = ROOT / "rtl"
BUILD = ROOT / "build" / "sim_decrypt_verilator"

def _collect_rtl():
    return sorted([str(p) for ext in ("*.sv", "*.v") for p in RTL.rglob(ext)])

def test_aes_decrypt_rtl():
    if BUILD.exists():
        shutil.rmtree(BUILD)
    BUILD.mkdir(parents=True, exist_ok=True)

    run(
        verilog_sources=_collect_rtl(),
        toplevel="aes128_decrypt",
        module="tb.test_aes_decrypt",
        toplevel_lang="verilog",
        sim="verilator",
        includes=[str(RTL)],
        timescale="1ns/1ps",
        waves=True,
        extra_args=["--coverage"],
        sim_args=["+verilator+coverage+file+build/coverage_decrypt.dat", "--trace"],
        build_dir=str(BUILD),
        force_compile=True,
        python_search=[str(ROOT)],
    )
