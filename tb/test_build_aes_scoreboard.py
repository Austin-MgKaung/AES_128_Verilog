from cocotb_test.simulator import run
from pathlib import Path
import os, shutil, glob

ROOT  = Path(__file__).resolve().parents[1]
RTL   = ROOT / "rtl"
BUILD = ROOT / "build" / "sim_scoreboard"
COV   = BUILD / "coverage_scoreboard.dat"
# We will accept either format; this is our preferred destination name(s)
VCD_OUT = BUILD / "test_aes_scoreboard.vcd"
FST_OUT = BUILD / "test_aes_scoreboard.fst"

def _collect_rtl():
    return sorted([str(p) for ext in ("*.sv", "*.v") for p in RTL.rglob(ext)])

def _first_existing(paths):
    for p in paths:
        if Path(p).exists():
            return Path(p)
    return None

def _harvest_artifacts():
    """
    Copy waves (VCD or FST) and coverage.dat from sim_build/* if they're not
    already present in BUILD.
    """
    sim_build = ROOT / "sim_build"

    # coverage
    if not COV.exists():
        candidates = [BUILD / "coverage.dat",
                      sim_build / "coverage.dat",
                      *_glob(sim_build, "*.dat")]
        src = _first_existing(candidates)
        if src:
            COV.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, COV)

    # waves: prefer VCD, else FST
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

def _glob(base: Path, pattern: str):
    return [Path(p) for p in glob.glob(str(base / pattern))]

def test_aes_rtl_scoreboard():
    if BUILD.exists():
        shutil.rmtree(BUILD)
    BUILD.mkdir(parents=True, exist_ok=True)

    # Best-effort to ensure tracing is enabled
    os.environ.setdefault("VERILATOR_TRACE", "1")
    # prefer VCD; harmless if ignored on some versions
    os.environ.setdefault("VERILATOR_TRACE_FORMAT", "vcd")

    # Ask Verilator to write coverage here; if ignored, we’ll harvest from sim_build/
    sim_args = [f"+verilator+coverage+file+{COV}"]

    run(
        verilog_sources=_collect_rtl(),
        toplevel="aes128_encrypt",
        module="tb.test_aes_scoreboard",
        sim="verilator",             # force Verilator
        waves=False,                 # don't inject --trace-fst; we manage tracing
        includes=[str(RTL)],
        timescale="1ns/1ps",
        sim_args=sim_args,
        force_compile=True,
        python_search=[str(ROOT)],
    )

    # Collect whatever the simulator produced
    _harvest_artifacts()

    # Final checks: accept either VCD or FST
    has_wave = VCD_OUT.exists() or FST_OUT.exists()
    assert has_wave, (
        f"No wave found.\n"
        f" Looked for {VCD_OUT.name} or {FST_OUT.name} in {BUILD}, "
        f"and scanned {ROOT/'sim_build'} for *.vcd/*.fst to copy."
    )
    assert COV.exists(), (
        f"No coverage .dat found at {COV}. "
        f"If Verilator ignored +verilator+coverage+file, we tried to copy from sim_build/*.dat."
    )
