"""Run the pinned official Palomar metadata and repository source checks."""
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PIN = "65f0154ed776cd26c224254aa57b379137f28b0d"
parser = argparse.ArgumentParser()
parser.add_argument("--palomar-dir", type=Path,
    default=Path(os.environ.get("PALOMAR_SUBMISSION_DIR", ROOT.parent / "review-sources/PalomarSubmission")))
args = parser.parse_args()
contract = args.palomar_dir.resolve()
if not (contract / "scripts/submission_contract.py").is_file():
    parser.error("Set PALOMAR_SUBMISSION_DIR to a PalomarSubmission checkout at " + PIN)
actual = subprocess.check_output(["git", "-C", str(contract), "rev-parse", "HEAD"], text=True).strip()
if actual != PIN:
    parser.error(f"Expected reviewed PalomarSubmission {PIN}, found {actual}")
sys.path.insert(0, str(contract))
from scripts.submission_contract import load_formalization_metadata, normalized_provenance
from scripts.source_requirements import inspect_lean_sources
from scripts.verify_submission import load_comparator_config

config = load_comparator_config(ROOT / "comparator.json")
metadata = load_formalization_metadata(ROOT / "formalization.yaml")
provenance = normalized_provenance(metadata)
scan, issues = inspect_lean_sources(ROOT)
if issues:
    for issue in issues:
        print(str(issue), file=sys.stderr)
    raise SystemExit(1)
minimum = json.loads((contract / "toolchains.json").read_text())["minimum"]
assert (ROOT / "lean-toolchain").read_text().strip() == "leanprover/lean4:" + minimum
assert metadata["project"]["license"] == "BSD-3-Clause"
print("Official Palomar metadata validator: PASS")
print("Official Palomar comparator configuration validator: PASS")
print("Official Palomar source requirements: PASS")
print("Contract revision:", actual)
print("Current minimum:", minimum)
print("Source scan:", json.dumps(scan, sort_keys=True))
print("Authors:", json.dumps(metadata["project"]["authors"], ensure_ascii=False))
print("Classification:", json.dumps(metadata["classification"], sort_keys=True))
print("License declaration: BSD-3-Clause; original upstream license retained byte-for-byte")
print("This is a local metadata/source scan, not hosted preparation or verification.")
