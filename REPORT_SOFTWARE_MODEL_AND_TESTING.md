# AES-128 Software Model and Testing Report

## Overview

The AES-128 project uses a Python software model as a reference implementation to verify a Verilog hardware design. The Python model (`model/aes128.py`) implements the complete AES-128 encryption and decryption algorithms and serves as the "golden reference" for testing. All hardware tests compare their outputs against this model to ensure correctness. The entire system is automated through GitHub Actions, which runs tests automatically on every code commit to maintain quality and catch bugs early.

## The Software Model

The Python software model is a complete implementation of the AES-128 encryption standard. It provides two main functions: `encrypt_block(key, plaintext)` which takes a 16-byte key and 16-byte plaintext and returns encrypted ciphertext, and `decrypt_block(key, ciphertext)` which reverses the process. The model works by performing a series of transformations on the data across 10 main rounds plus an initial and final round.

For encryption, each round applies four operations in sequence. SubBytes replaces each byte using an AES lookup table, ShiftRows rotates bytes within the rows of a 4x4 matrix, MixColumns performs matrix multiplication in Galois Field arithmetic, and AddRoundKey XORs the data with a derived round key. The final round skips the MixColumns step. Decryption reverses this process using inverse operations that undo each transformation in reverse order.

The model begins by expanding the original 16-byte key into 11 separate round keys using a key schedule algorithm. This derivation process ensures each round operates with a different key material, adding security and diffusion. The Python implementation is organized into modular components: `key_expansion_func_enhanced.py` handles key derivation, `subbytes_LUT.py` performs byte substitution, `shift_rows_func.py` handles row rotations, `mix_columns_func_LUT.py` performs matrix operations, and `helper.py` provides the standard S-box tables and constants defined by the AES specification.

## Golden Model Concept

The Python model serves as a "golden model" — a proven-correct reference that hardware implementations are tested against. This is the standard approach in hardware verification because it's far simpler to verify correctness by comparison than by attempting to verify the design against a complex specification directly. The process is straightforward: if we encrypt the same plaintext with the same key using both the Python model and the RTL hardware design, they must produce identical outputs. If they don't match, the RTL has a bug.

This approach works because the Python model is thoroughly vetted against known standards. It's first verified against the NIST FIPS-197 specification using known answer tests, then validated against the PyCryptodome library, a widely-used cryptographic library that is assumed to be correct. Once the Python model passes all these validation tests, it becomes a reliable reference. Any difference between the model's output and the hardware output definitively indicates a hardware bug, making debugging straightforward and efficient.

## Testing Strategy

Testing happens at multiple levels. The first level validates the Python model itself by running it against known test vectors and comparing results to the PyCryptodome library. This uses pytest and can be run with `python -m pytest tb/test_model_vs_lib.py`. The test suite includes a known answer test (KAT) from the NIST standard, which is a fixed test vector with a known correct result, plus 100+ random test vectors to exercise the algorithm with diverse inputs and catch any edge-case bugs.

The second level tests the hardware RTL implementation using cocotb, which is a testbench framework that drives hardware simulations. The cocotb testbenches generate stimulus (test vectors), apply them to the RTL design running in the Verilator simulator, capture the outputs, and compare them to the Python model's outputs using a scoreboard. If the RTL output matches the model, the test passes; if not, the test fails and reports the mismatch. This directly verifies that the hardware implementation is functionally correct.

The testing framework also collects coverage metrics to show which parts of the design were exercised by the tests. This helps identify untested code paths and ensures comprehensive testing. Coverage includes line coverage (which statements were executed), branch coverage (which conditional paths were taken), and functional coverage (which high-level operations were performed). The combined coverage data gives confidence that the design is thoroughly tested, not just that some tests pass.

## Test Execution and Comparison

When a test runs, it goes through a simple but powerful comparison process. For a given test vector (a 16-byte key and 16-byte plaintext), the model encrypts the data and produces a ciphertext. The RTL design, running in the simulator with the same key and plaintext, also produces a ciphertext. The scoreboard compares these two ciphertexts byte-by-byte. If every byte matches, the test passes for that vector. If any byte differs, the test fails and reports exactly which vector caused the mismatch, along with the expected and actual values, making debugging straightforward.

The model also supports decryption testing in the same way. The RTL decryption design is tested by comparing its outputs against the Python model's decryption outputs. Additionally, since decryption should reverse encryption, if encrypting a plaintext and then decrypting the resulting ciphertext returns the original plaintext, this provides another level of verification. The combination of forward tests (model vs RTL), reverse tests (decrypt of encrypt equals original), and random test vectors creates a robust verification system.

## GitHub Actions Continuous Integration

The entire testing process is automated through GitHub Actions, which runs whenever code is pushed to the repository. The automation pipeline consists of three main stages. First, a linter (Verible) checks the Verilog RTL code for syntax errors and style violations, ensuring code quality. This stage is quick and catches obvious issues immediately.

Second, the software tests run, executing the test suite that validates the Python model against known-good references. This stage installs Python 3.11, pulls in all dependencies from requirements.txt (including PyCryptodome and cocotb), and runs pytest on the model validation tests. If the model itself has bugs or has been broken, these tests will fail and alert the developer before any hardware testing begins. This prevents wasted time testing hardware against an incorrect reference.

Third, the hardware tests run, which build the RTL with the Verilator simulator and execute cocotb testbenches. This stage is more time-consuming because it includes compilation and simulation. It runs multiple test suites including functional tests and coverage-driven tests. The CI pipeline collects code coverage metrics and generates HTML reports showing which lines of code were covered by tests. All artifacts (coverage reports, waveforms in VCD format, test logs) are uploaded to GitHub so developers can download and inspect them.

The CI system uses smart caching to speed up repeated runs. Python packages are cached across runs if the requirements.txt hasn't changed, saving several minutes per pipeline execution. The pipeline also uses concurrency control so that if a developer pushes a new commit before the previous one finishes testing, the old test run is cancelled, saving CI resources and reducing feedback latency.

## How It All Works Together

The complete system creates a reliable verification flow. A developer writes or modifies Verilog RTL code and commits it to GitHub. GitHub Actions automatically triggers the CI pipeline, which runs linting, then Python model tests, then hardware RTL tests. At each stage, if something fails, the pipeline stops and the developer gets immediate feedback through GitHub's interface, showing which test failed and providing access to logs and artifacts for debugging.

If the software model tests fail, it means the Python reference implementation has been broken, and needs to be fixed before moving forward. If the RTL tests fail after software tests pass, it means the hardware implementation has a bug and needs debugging. The developer can examine the waveforms generated during simulation, review the test failure details showing exactly which vectors failed, and compare the expected output (from the model) to the actual output (from the RTL) to identify the issue.

This approach is efficient because once the Python model is verified as correct (which only needs to happen once), it provides a reliable reference for all subsequent hardware testing. The comparison-based approach is much simpler than trying to verify hardware against a specification manually. Developers get rapid feedback — the entire CI pipeline typically completes in 20-30 minutes — allowing quick iteration and bug fixes. The automation ensures that every commit is tested, preventing regressions and building confidence in the design.

## Summary

The AES-128 verification system combines a thoroughly-validated Python software model with automated multi-level testing and continuous integration. The model serves as a golden reference against which all hardware testing is performed. Test vectors are generated and applied to both the model and the RTL design, with outputs compared to verify correctness. Coverage metrics ensure comprehensive testing. The entire process is automated through GitHub Actions, providing rapid feedback and high confidence in the design quality. This approach is industry-standard for hardware verification because it's both effective at catching bugs and efficient to implement and maintain.

---

**Report Generated**: March 26, 2026  
**Project**: AES-128 MENG Verification Template  
**Status**: Active Development with Continuous Integration
