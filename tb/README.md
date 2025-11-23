# `tb/` — Testbenches, Wrappers, and Coverage

This directory contains:

- cocotb testbenches (e.g. `test_aes.py`, `test_aes_scoreboard.py`)
- pytest wrappers that integrate `cocotb-test` and Verilator (e.g. `test_build_aes.py`)
- Scoreboard and functional coverage infrastructure

You normally do **not** modify these files unless the assignment explicitly asks you to add new tests.

---

## Key entry points

- `test_model_vs_lib.py`  
  - Tests the Python model (`encrypt_block`) against `Crypto.Cipher.AES`.

- `test_aes.py`  
  - Basic cocotb testbench driving `aes128_encrypt` (encryption only).

- `test_aes_scoreboard.py`  
  - Uses `env.py` (Driver, Monitor, Scoreboard) and `coverage_points.py` for random and coverage-driven tests.

- `test_build_aes.py`  
  - Pytest wrapper that builds RTL with Verilator and runs `test_aes`.

- `test_build_aes_scoreboard.py`  
  - Pytest wrapper that builds RTL with Verilator and runs `test_aes_scoreboard`.

---

## Running tests

From the repository root, with your virtual environment active:

```bash
python -m pytest -vv -rA tb/test_model_vs_lib.py
python -m pytest -vv -rA tb/test_build_aes.py
python -m pytest -vv -rA tb/test_build_aes_scoreboard.py
```
