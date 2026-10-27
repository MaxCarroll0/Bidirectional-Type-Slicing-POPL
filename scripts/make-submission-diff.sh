#!/usr/bin/env bash
# Build a latexdiff markup of the paper against the July 2026 POPL submission.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

# ab3b716 "Finalize paper revisions" is the last commit before the 9 July 2026
# AoE deadline, and so is the state that was submitted.
baseline="${SUBMISSION_REF:-ab3b716}"
out="${OUT:-$repo/export/main-diff-vs-submission.pdf}"

need() { command -v "$1" >/dev/null || { echo "error: $1 not on PATH; run inside 'nix develop'" >&2; exit 1; }; }
need latexdiff
need latexmk

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/old" "$work/new"
git archive "$baseline" | tar -x -C "$work/old"
git archive --worktree-attributes HEAD | tar -x -C "$work/new"
# latexdiff reads the working tree, not HEAD, so uncommitted edits show up too.
for f in *.tex refs.bib .latexmkrc; do [ -e "$f" ] && cp -f "$f" "$work/new/"; done
cp -r media "$work/new/" 2>/dev/null || true
cp -r vendor "$work/new/" 2>/dev/null || true
cp -r media "$work/old/" 2>/dev/null || true
cp -r vendor "$work/old/" 2>/dev/null || true

latexdiff --flatten --encoding=utf8 \
  --append-safecmd="edited,hatraSelfCite,priorDissertationSelfCite" \
  "$work/old/main.tex" "$work/new/main.tex" > "$work/new/main-diff.tex"

cd "$work/new"
latexmk -interaction=nonstopmode -pdf -lualatex main-diff.tex >/dev/null 2>&1 || true
[ -f main-diff.pdf ] || { echo "error: latexmk produced no PDF; see $work/new/main-diff.log" >&2; trap - EXIT; exit 1; }

mkdir -p "$(dirname "$out")"
install -m 644 main-diff.pdf "$out"
echo "wrote $out  (baseline $baseline: $(cd "$repo" && git log -1 --format='%h %ad %s' --date=short "$baseline"))"
