# tb/coverage_points.py
from cocotb_coverage.coverage import CoverPoint, CoverCross, coverage_db
import os

def _pattern_class(b: bytes) -> str:
    if all(x == 0x00 for x in b): return "zero"
    if all(x == 0xFF for x in b): return "ones"
    if b == bytes(range(16)):     return "inc"
    if len(set(b)) <= 2:          return "low_entropy"
    return "random"

@CoverPoint("aes.key_pattern", xf=_pattern_class, bins=["zero","ones","inc","low_entropy","random"])
def cov_key(key: bytes): pass

@CoverPoint("aes.pt_pattern", xf=_pattern_class, bins=["zero","ones","inc","low_entropy","random"])
def cov_pt(pt: bytes): pass

@CoverPoint("aes.spacing", xf=lambda s: s, bins=list(range(0,5)))
def cov_spacing(spacing: int): pass

@CoverCross("aes.key_x_pt", items=["aes.key_pattern","aes.pt_pattern"])
def cov_cross(key: bytes, pt: bytes): pass

def sample_all(key: bytes, pt: bytes, spacing: int):
    cov_key(key); cov_pt(pt); cov_spacing(spacing); cov_cross(key, pt)

def export_yaml(path: str):
    parent = os.path.dirname(path) or "."
    os.makedirs(parent, exist_ok=True)   # ensure folder exists
    coverage_db.export_to_yaml(filename=path)
