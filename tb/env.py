# tb/env.py
from dataclasses import dataclass
from typing import Optional
import cocotb
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb.queue import Queue  # cocotb's asyncio queue

# Transaction container
@dataclass
class AESTrans:
    key: bytes         # 16 bytes
    pt:  bytes         # 16 bytes
    expect: Optional[bytes] = None  # SW model result

def _bytes_to_int_be(b: bytes) -> int:
    return int.from_bytes(b, "big")

class Driver:
    def __init__(self, dut):
        self.dut = dut
        self._busy = False

    async def reset(self, cycles: int = 2):
        # Synchronous, active-high reset as in top.v
        self.dut.start.value = 0
        self.dut.key.value = 0
        self.dut.block_in.value = 0
        self.dut.rst.value = 1
        for _ in range(max(1, cycles)):
            await RisingEdge(self.dut.clk)
        self.dut.rst.value = 0
        await RisingEdge(self.dut.clk)
        self._busy = False

    async def send(self, tr: AESTrans, spacing: int = 0):
        # If something is in flight, wait for done first
        if self._busy:
            await RisingEdge(self.dut.done)

        # Drive inputs and pulse start for a single clock
        self.dut.key.value = _bytes_to_int_be(tr.key)
        self.dut.block_in.value = _bytes_to_int_be(tr.pt)
        self.dut.start.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.start.value = 0
        self._busy = True

        # Optional idle spacing (still while previous block is computing)
        for _ in range(max(0, spacing)):
            await RisingEdge(self.dut.clk)

class OutputMonitor:
    """Samples block_out on done↑ and pushes 16B results onto a queue."""
    def __init__(self, dut):
        self.dut = dut
        self.queue: Queue[bytes] = Queue()

    async def run(self):
        while True:
            await RisingEdge(self.dut.done)
            await ReadOnly()
            val = int(self.dut.block_out.value)
            self.queue.put_nowait(val.to_bytes(16, "big"))

class Scoreboard:
    """FIFO scoreboard comparing observed outputs vs. expected bytes."""
    def __init__(self, dut, outmon: OutputMonitor):
        self.dut = dut
        self.outmon = outmon
        self.expected: list[bytes] = []
        self.idx = 0

    def push_expected(self, bs: bytes):
        assert isinstance(bs, (bytes, bytearray)) and len(bs) == 16
        self.expected.append(bytes(bs))

    async def start(self):
        while True:
            got = await self.outmon.queue.get()
            assert self.expected, f"[{self.idx}] Got output with empty expected queue"
            exp = self.expected.pop(0)
            assert got == exp, (
                f"[{self.idx}] Mismatch\n"
                f"EXP={exp.hex()}\n"
                f"GOT={got.hex()}"
            )
            self.idx += 1
