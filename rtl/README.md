# `rtl/` — AES-128 RTL Encryptor (Verilog)

This directory holds the hardware implementation of the AES-128 encryptor core in Verilog.

You will implement and verify the AES-128 **encryption path** in hardware.

---

## Files

- `aes128_encrypt.v`  
  The AES-128 encryptor core used by all cocotb tests.

  Module name and interface:

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

---

## Behaviour

- On reset (`rst = 1`): internal state is cleared, `done` is low.
- When in IDLE and `start` is pulsed high for one clock:
  - Latch `key` and `block_in`.
  - Begin AES-128 encryption.
- After a fixed number of cycles:
  - `done` is high for one clock.
  - `block_out` holds the final ciphertext during that cycle.
- Then return to IDLE.

---

## Testing the RTL

Assuming Verilator and Python deps are installed and your venv is active:

```bash
python -m pytest -vv -rA tb/test_build_aes.py
python -m pytest -vv -rA tb/test_build_aes_scoreboard.py
```

Waveforms are written to `build/` or `sim_build/` as `.vcd` or `.fst`.
