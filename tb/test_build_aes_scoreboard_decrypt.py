from cocotb_test.simulator import run
from pathlib import Path
import os, shutil, glob

ROOT  = Path(__file__).resolve().parents[1]
RTL   = ROOT / "rtl"
BUILD = ROOT / "build" / "sim_scoreboard_decrypt"
COV   = BUILD / "coverage_scoreboard_decrypt.dat"
VCD_OUT = BUILD / "test_aes_scoreboard_decrypt.vcd"
FST_OUT = BUILD / "test_aes_scoreboard_decrypt.fst"

def _collect_rtl():
    return sorted([str(p) for ext in ("*.sv", "*.v") for p in RTL.rglob(ext)])

def _first_existing(paths):
    for p in paths:
        if Path(p).exists():
            return Path(p)
    return None

def _glob(base: Path, pattern: str):
    return [Path(p) for p in glob.glob(str(base / pattern))]

def _harvest_artifacts():
    sim_build = ROOT / "sim_build"

    if not COV.exists():
        candidates = [BUILD / "coverage.dat",
                      sim_build / "coverage.dat",
                      *_glob(sim_build, "*.dat")]
        src = _first_existing(candidates)
        if src:
            COV.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, COV)

    if not VCD_OUT.exists() and not FST_OUT.exists():
        wave_src = _first_existing([
            BUILD / "dump.vcd",
            sim_build / "dump.vcd",
            *_glob(sim_build, "*.vcd"),
            *_glob(sim_build, "*.fst"),
        ])
        if wave_src:
            BUILD.mkdir(parents=True, exist_ok=True)
            if wave_src.suffix == ".vcd":
                shutil.copy2(wave_src, VCD_OUT)
            else:
                shutil.copy2(wave_src, FST_OUT)

def test_aes_decrypt_rtl_scoreboard():
    if BUILD.exists():
        shutil.rmtree(BUILD)
    BUILD.mkdir(parents=True, exist_ok=True)

    os.environ.setdefault("VERILATOR_TRACE", "1")
    os.environ.setdefault("VERILATOR_TRACE_FORMAT", "vcd")

    run(
        verilog_sources=_collect_rtl(),
        toplevel="aes128_decrypt",
        module="tb.test_aes_scoreboard_decrypt",
        sim="verilator",
        waves=False,
        includes=[str(RTL)],
        timescale="1ns/1ps",
        sim_args=[f"+verilator+coverage+file+{COV}"],
        force_compile=True,
        python_search=[str(ROOT)],
    )

    _harvest_artifacts()

    has_wave = VCD_OUT.exists() or FST_OUT.exists()
    assert has_wave, (
        f"No wave found.\n"
        f" Looked for {VCD_OUT.name} or {FST_OUT.name} in {BUILD}."
    )
    assert COV.exists(), (
        f"No coverage .dat found at {COV}."
    )
