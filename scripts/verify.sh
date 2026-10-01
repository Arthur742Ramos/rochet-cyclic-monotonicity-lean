#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
export LEAN_NUM_THREADS="${LEAN_NUM_THREADS:-2}"
mkdir -p evidence
lean_prefix=$(lake env lean --print-prefix)
export PATH="$lean_prefix/bin:$PATH"
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
  Darwin) lake comparator --config comparator.json --inadvisably-no-sandbox > evidence/comparator.log 2>&1 ;;
  *) lake comparator --config comparator.json > evidence/comparator.log 2>&1 ;;
esac
cat evidence/comparator.log
