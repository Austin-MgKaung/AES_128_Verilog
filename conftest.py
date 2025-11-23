# conftest.py — VCD in sim_build/ (default)
import cocotb_test.simulator as sim

print(f"[conftest] loaded: {__file__}")

_orig_run = sim.run

def _run_with_defaults(*args, **kwargs):
    # ✅ Use the correct key
    kwargs.setdefault("sim", "verilator")

    # Disable cocotb-test's FST injection
    kwargs["waves"] = False

    # Strip any leftover --trace-fst someone might pass
    for key in ("extra_args", "compile_args"):
        arr = [f for f in list(kwargs.get(key, [])) if not f.startswith("--trace-fst")]
        kwargs[key] = arr

    # Compile-time: enable coverage + VCD tracing
    for key, flags in (("compile_args", ["--coverage", "--trace", "--trace-structs"]),
                       ("extra_args",   ["--coverage", "--trace", "--trace-structs"])):
        arr = list(kwargs.get(key, []))
        for f in flags:
            if f not in arr:
                arr.append(f)
        kwargs[key] = arr

    # Run-time: turn tracing on (creates dump.vcd in sim_build/)
    sa = list(kwargs.get("sim_args", []))
    if "--trace" not in sa:
        sa.append("--trace")
    kwargs["sim_args"] = sa

    # Do NOT force build_dir; cocotb-test defaults to sim_build/
    return _orig_run(*args, **kwargs)

sim.run = _run_with_defaults
