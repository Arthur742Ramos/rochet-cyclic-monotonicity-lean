"""Static package checks and exact selected-declaration axiom audit."""
import argparse
import json
import re
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser()
parser.add_argument("--axioms", action="store_true")
args = parser.parse_args()
config = json.loads((ROOT / "comparator.json").read_text())
assert config["definition_names"] == [], "This package has no definition holes"
assert config["challenge_module"] == "Challenge"
assert config["solution_module"] == "Solution"
allowed = set(config["permitted_axioms"])
assert allowed == {"propext", "Classical.choice", "Quot.sound"}
challenge = (ROOT / "Challenge.lean").read_text()
assert len(challenge.encode()) < 32768 and len(challenge.splitlines()) < 300
imports = re.findall(r"^(?:public )?import (\S+)", challenge, re.M)
assert imports and all(n.startswith("Mathlib.") for n in imports)
assert re.search(r"^module$", challenge, re.M)
for name in config["theorem_names"]:
    short = name.removeprefix("Rochet.")
    assert name.startswith("Rochet.")
    for file in ["Challenge.lean", "Solution.lean"]:
        assert re.search(r"^theorem " + re.escape(short) + r"\b", (ROOT / file).read_text(), re.M), (file, name)
for file in list(ROOT.glob("*.lean")) + list((ROOT / "Rochet").glob("*.lean")):
    text = file.read_text()
    text = re.sub(r"/-[\s\S]*?-/", "", text)
    text = re.sub(r"--[^\n]*", "", text)
    assert not re.search(r"\b(sorry|admit|native_decide|unsafe)\b|^\s*axiom\s", text, re.M), file
manifest = json.loads((ROOT / "lake-manifest.json").read_text())
for p in manifest["packages"]:
    assert p["type"] == "git" and re.fullmatch(r"[a-f0-9]{40}", p["rev"]), p
lakefile = tomllib.loads((ROOT / "lakefile.toml").read_text())
assert not (ROOT / "lakefile.lean").exists()
assert lakefile["require"][0]["rev"] == "065356127b1dc0016f66b7283ce0ce2c4055aa55"
assert (ROOT / "lean-toolchain").read_text().strip() == "leanprover/lean4:v4.35.0-rc2"
mathlib_tc = ROOT / ".lake/packages/mathlib/lean-toolchain"
if mathlib_tc.exists():
    assert mathlib_tc.read_text().strip() == (ROOT / "lean-toolchain").read_text().strip()
if args.axioms:
    log = (ROOT / "evidence/axioms.log").read_text()
    records = dict(re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]", log))
    for name in config["theorem_names"]:
        assert name in records, f"Missing axiom record: {name}"
        used = {x.strip() for x in records[name].split(",") if x.strip()}
        assert used <= allowed, (name, used - allowed)
    deps = (ROOT / "evidence/challenge-source-deps.log").read_text()
    assert "Rochet/" not in deps and "Solution.lean" not in deps
print(f"Package checks passed: {len(config['theorem_names'])} selected theorems; zero definition holes")
