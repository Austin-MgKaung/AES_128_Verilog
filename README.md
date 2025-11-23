# AES-128 Verification Template (cocotb + Verilog)

This repository is a teaching template for an AES-128 block cipher core.

By the time you use this template you should already have completed **Milestone 1**:

- A working AES-128 software model in Python that supports both:
  - `encrypt_block(key, pt)`
  - `decrypt_block(key, ct)`
- That model passes basic tests against a known-good library.

With this template (**Milestone 2 and beyond**), you will:

1. Port / integrate your existing software model into `model/aes128.py`.
2. Implement the AES-128 encryptor RTL core in Verilog (`rtl/aes128_encrypt.v`).
3. Extend the RTL and tests as needed for decryption / top-level integration.
4. Add or extend tests in `tb/` to verify:
   - Software encryption + decryption vs the library.
   - RTL encryption and decryption vs your software model.
5. Use waveform viewers (Surfer or GTKWave) to debug your RTL.
6. Use linting (Verible and Verilator `lint-only`) to keep your RTL clean.
7. Commit and push regularly; GitHub Classroom CI will run a subset of these tests automatically.

This repo is designed to work both locally and with **GitHub Classroom + GitHub Actions CI**.

---

## Repository layout

```text
.
├── model/         # Software AES-128 reference model (Python)
├── rtl/           # AES-128 RTL encryptor implementation (Verilog)
├── tb/            # cocotb testbenches and pytest wrappers
├── scripts/       # (optional) synthesis or utility scripts
├── build/         # Test output (waves, coverage, reports) - generated
├── requirements.txt
├── conftest.py    # pytest + cocotb-test integration hooks
└── pytest.ini     # pytest configuration
```

- See `model/README.md` for model details.
- See `rtl/README.md` for RTL expectations.
- See `tb/README.md` for tests & coverage.

---

## What you are expected to do (students)

### 1. Software model (already done in Milestone 1)

You should already have a correct AES-128 model.

In this repo you must:

- Copy / adapt your Milestone 1 solution into `model/aes128.py` so that it provides:

  ```python
  def encrypt_block(key: bytes, pt: bytes) -> bytes:
      ...

  def decrypt_block(key: bytes, ct: bytes) -> bytes:
      ...
  ```

- Make sure the behaviour is unchanged:
  - 16-byte key, 16-byte block only.
  - Correct AES-128 encryption and decryption (ECB, single block).
- Adjust only as needed to fit the provided function signatures and package structure.

> **Important:** The RTL tests use your Python model as the golden reference.  
> If you break the model, RTL tests will also fail.

---

### 2. RTL implementation (encryption core)

You will implement the AES-128 encryptor in Verilog:

- File: `rtl/aes128_encrypt.v`
- Module name: `aes128_encrypt`

The module interface is:

```verilog
module aes128_encrypt (
    input  wire         clk,
    input  wire         rst,         // synchronous, active high
    input  wire         start,       // 1-cycle pulse when IDLE
    input  wire [127:0] key,
    input  wire [127:0] block_in,
    output wire         done,        // 1-cycle pulse when block_out valid
    output reg  [127:0] block_out
);
```

Your job is to implement AES-128 encryption so that:

- When `start` is pulsed high for one clock in the IDLE state:
  - The core latches `key` and `block_in`.
  - It begins computing the AES-128 encryption.
- After a fixed latency:
  - `done` goes high for one clock.
  - `block_out` holds the correct ciphertext for that cycle.
- The core then returns to IDLE ready for another `start`.

Similarly, later extensions may add a separate decryptor or a combined top core; this template is set up for the encryptor as your starting point.

---

### 3. Tests and verification

You will:

- Use the existing tests to verify:
  - Software encryption vs the library.
  - RTL encryption vs your software model.
- Add **decryption-specific tests**.

Concretely:

- **Software-only tests:**
  - `tb/test_model_vs_lib.py` (already checks encryption).
  - Add a new test file for decryption.

- **RTL tests (encryption):**
  - `tb/test_build_aes.py` runs `tb/test_aes.py` via cocotb-test.
  - `tb/test_build_aes_scoreboard.py` runs `tb/test_aes_scoreboard.py` (env + coverage).
  - Add corresponding tests for decryption when you extend the RTL.

You should run these tests frequently while developing and debugging.

---

## Prerequisites

You need:

- Git
- Python **3.10+** (3.11 recommended)
- `pip` (Python package manager)
- Verilator (for RTL tests)
- A waveform viewer:
  - **Surfer** (recommended), or
  - **GTKWave**

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y     python3 python3-venv python3-pip     git     verilator     gtkwave

git clone <your-assignment-repo-url>.git aes-assignment
cd aes-assignment

python3 -m venv .venv
source .venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt
```

For Surfer on Linux, follow the installation instructions from your instructor or the Surfer documentation.

### macOS (Homebrew)

```bash
brew install python git verilator gtkwave surfer

git clone <your-assignment-repo-url>.git aes-assignment
cd aes-assignment

python3 -m venv .venv
source .venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt
```

### Windows (recommended: WSL2)

The easiest way is to use WSL2 with Ubuntu. Inside Ubuntu, follow the **Linux** instructions above.

---

## Python environment setup

On all platforms (Linux/macOS/WSL):

```bash
python3 -m venv .venv
source .venv/bin/activate    # Windows PowerShell in WSL: .venv\Scripts\Activate.ps1

pip install --upgrade pip
pip install -r requirements.txt
```

Always make sure your virtual environment is **activated** before running tests.

---

## Running tests

### 1. Software model tests

After copying your Milestone 1 model into `model/aes128.py`:

```bash
python -m pytest -vv -rA tb/test_model_vs_lib.py
```

This will run known-answer tests for encryption and compare your `encrypt_block` against `Crypto.Cipher.AES` for many random inputs.

---

### 2. RTL encryption tests

When `rtl/aes128_encrypt.v` has a basic implementation:

```bash
python -m pytest -vv -rA tb/test_build_aes.py
```

---

### 3. RTL scoreboard + coverage tests

For deeper testing on the encryption path:

```bash
python -m pytest -vv -rA tb/test_build_aes_scoreboard.py
```

---

## Linting your Verilog

### Verilator `lint-only`

```bash
verilator --lint-only -Wall rtl/aes128_encrypt.v
```

### Verible (optional)

```bash
verible-verilog-lint   --rules_config=.rules.verible_lint   --waiver_files=.verible.waiver   rtl/aes128_encrypt.v
```

---

## Viewing waveforms

Waveforms are generated as `.vcd` or `.fst` files under `build/` or `sim_build/`.

**GTKWave:**

```bash
gtkwave path/to/wave.vcd
```

**Surfer:**

```bash
surfer path/to/wave.vcd
```
