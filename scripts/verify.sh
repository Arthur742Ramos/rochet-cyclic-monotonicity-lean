#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
export LEAN_NUM_THREADS="${LEAN_NUM_THREADS:-2}"
mkdir -p evidence
lean_prefix=$(lake env lean --print-prefix)
export PATH="$lean_prefix/bin:$PATH"
execution_config=$(mktemp "${TMPDIR:-/tmp}/rochet-comparator.XXXXXX")
trap 'rm -f "$execution_config"' EXIT HUP INT TERM
python3 scripts/verification_config.py "$execution_config" > evidence/comparator-configuration.log 2>&1
python3 scripts/check_package.py
python3 scripts/verify_metadata.py > evidence/metadata-validation.log 2>&1
lake build Challenge > evidence/challenge-build.log 2>&1
lake build Solution > evidence/solution-build.log 2>&1
lake build > evidence/full-build.log 2>&1
lake env lean Audit.lean > evidence/axioms.log 2>&1
lake env lean ContractAudit.lean > evidence/contract-binders.log 2>&1
lake env lean --deps-json Challenge.lean > evidence/challenge-header.json 2>&1
lake env lean --src-deps Challenge.lean > evidence/challenge-source-deps.log 2>&1
python3 scripts/check_package.py --axioms
case "$(uname -s)" in
  Darwin) lake comparator --config "$execution_config" --inadvisably-no-sandbox > evidence/comparator.log 2>&1 ;;
  *) lake comparator --config "$execution_config" > evidence/comparator.log 2>&1 ;;
esac
python3 - <<'PY'
from pathlib import Path
log = Path('evidence/comparator.log').read_text()
assert 'Your solution is okay!' in log
for kernel in ('Lean default', 'nanoda', 'con-ron'):
    assert f'{kernel} kernel accepts the solution' in log, kernel
PY
cat evidence/comparator.log
