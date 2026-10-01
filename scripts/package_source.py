"""Create a deterministic source-only archive from an audited project snapshot."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEST = ROOT.parent / "deliverables"
DEST.mkdir(exist_ok=True)
core = sorted({
    ".gitignore", "LICENSE", "NOTICE", "README.md", "formalization.yaml",
    "comparator.json", "lean-toolchain", "lakefile.toml", "lake-manifest.json",
    *(p.relative_to(ROOT).as_posix() for p in ROOT.glob("*.lean")),
    *(p.relative_to(ROOT).as_posix() for p in (ROOT / "Rochet").glob("*.lean")),
    *(p.relative_to(ROOT).as_posix() for p in (ROOT / "scripts").glob("*.py")),
    *(p.relative_to(ROOT).as_posix() for p in (ROOT / "scripts").glob("*.sh")),
})
evidence = [
    "initial-checkpoint.md", "mathematical-contract-review.md",
    "final-source-review.md", "final-prose-review.md", "final-status.md",
    "challenge-build.log", "solution-build.log", "full-build.log", "axioms.log",
    "contract-binders.log", "challenge-header.json", "challenge-source-deps.log",
    "metadata-validation.log", "comparator.log", "verification.log",
    "validation-manifest.json",
]
files = core + ["evidence/" + n for n in evidence]
manifest = json.loads((ROOT / "evidence/validation-manifest.json").read_text())
for name, expected in manifest["tested_files_sha256"].items():
    actual = hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
    assert actual == expected, f"Changed after validation: {name}"
assert set(core) <= set(manifest["tested_files_sha256"]), "Manifest must cover every core file"
snapshot = {}
for name in sorted(files):
    path = ROOT / name
    assert path.is_file() and not path.is_symlink(), name
    snapshot[name] = path.read_bytes()
checksums = "".join(hashlib.sha256(blob).hexdigest() + "  " + name + "\n"
                    for name, blob in snapshot.items())
snapshot["SHA256SUMS"] = checksums.encode()
archive = DEST / "rochet-cyclic-monotonicity-lean-source.tar.gz"
with archive.open("wb") as output:
    with gzip.GzipFile(filename="", mode="wb", fileobj=output, mtime=0) as compressed:
        with tarfile.open(fileobj=compressed, mode="w", format=tarfile.PAX_FORMAT) as tar:
            for name, blob in sorted(snapshot.items()):
                entry = tarfile.TarInfo(ROOT.name + "/" + name)
                entry.size = len(blob)
                entry.mode = 0o755 if name.endswith(".sh") else 0o644
                entry.uid = entry.gid = entry.mtime = 0
                tar.addfile(entry, io.BytesIO(blob))
# Verify the delivered archive contains only the expected source/evidence files
# and that every archived byte matches this final snapshot.
with tarfile.open(archive, "r:gz") as tar:
    assert len(tar.getmembers()) == len(snapshot)
    for entry in tar.getmembers():
        assert entry.isfile() and entry.name.startswith(ROOT.name + "/")
        name = entry.name[len(ROOT.name) + 1:]
        assert tar.extractfile(entry).read() == snapshot[name], name
checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
(DEST / (archive.name + ".sha256")).write_text(checksum + "  " + archive.name + "\n")
print("Archive:", archive)
print("Files:", len(snapshot))
print("Bytes:", archive.stat().st_size)
print("SHA256:", checksum)
print("Archive content and byte-for-byte snapshot validation: PASS")
