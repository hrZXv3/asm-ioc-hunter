#!/usr/bin/env bash
cd "$(dirname "$0")/.." || exit 1
BIN=./ioc-hunter
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
check() {
  if eval "$2"; then echo "  OK   $1"; pass=$((pass+1)); else echo "  FAIL $1"; fail=$((fail+1)); fi
}

out=$($BIN scan samples/incident.log)
check "scan : 9 alertes"                 '[[ $(grep -c "^\[ALERTE\]" <<<"$out") -eq 9 ]]'
check "scan : mimikatz trouve"           'grep -q "^\[ALERTE\] mimikatz" <<<"$out"'
check "scan : reverse shell trouve"      'grep -q "^\[ALERTE\] /dev/tcp/" <<<"$out"'
check "scan : ligne propre ignoree"      '! grep -q "rien de suspect" <<<"$out"'

: > "$T/vide"
out=$($BIN scan "$T/vide"); rc=$?
check "fichier vide : aucune alerte"     '[[ $rc -eq 0 && -z "$out" ]]'

$BIN scan "$T/inexistant" >/dev/null; rc=$?
check "fichier inexistant -> code 2"     '[[ $rc -eq 2 ]]'
$BIN >/dev/null; rc=$?
check "sans argument -> code 1"          '[[ $rc -eq 1 ]]'
$BIN foo samples/incident.log >/dev/null; rc=$?
check "mode inconnu -> code 1"           '[[ $rc -eq 1 ]]'

check "xor decode la config C2"          '$BIN xor samples/payload.bin | grep -aq "c2=http://198.51.100.77"'
check "xor deux fois = original"         '$BIN xor samples/payload.bin > "$T/d" && $BIN xor "$T/d" | cmp -s - samples/payload.bin'

echo; echo "$pass reussis, $fail echoues"; [[ $fail -eq 0 ]]
