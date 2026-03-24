#!/bin/bash
# run-evals.sh — Eval orchestrator for design-system-skill
# Usage: bash evals/run-evals.sh [case-name]

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CASES_DIR="$SKILL_DIR/evals/cases"
RESULTS_DIR="$SKILL_DIR/evals/results"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$RESULTS_DIR"

printf "\ndesign-system-skill Eval Suite\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "Skill:      %s/SKILL.md\n" "$SKILL_DIR"
printf "References: ~/.claude/skills/figma-token-foundation.md\n"
printf "            ~/.claude/skills/research-figma-molecule-architecture.md\n"
printf "            ~/.claude/skills/research-responsive-adaptive-design.md\n"
printf "            ~/.claude/skills/research-visual-harmony-composition.md\n"
printf "            ~/.claude/skills/figma-ds-modernization.md\n"
printf "            ~/.claude/skills/research-layout-composition.md\n\n"

TOTAL=0

check_references() {
  local missing=0
  for ref in \
    "$HOME/.claude/skills/figma-token-foundation.md" \
    "$HOME/.claude/skills/research-figma-molecule-architecture.md" \
    "$HOME/.claude/skills/research-responsive-adaptive-design.md" \
    "$HOME/.claude/skills/research-visual-harmony-composition.md" \
    "$HOME/.claude/skills/figma-ds-modernization.md" \
    "$HOME/.claude/skills/research-layout-composition.md"; do
    if [ ! -f "$ref" ]; then
      printf "  MISSING reference: %s\n" "$ref"
      missing=$((missing+1))
    fi
  done
  if [ "$missing" -gt 0 ]; then
    printf "\nWARN: %d reference file(s) missing. Skill will fail to load deep knowledge.\n\n" "$missing"
  else
    printf "  All 6 reference files present.\n\n"
  fi
}

run_case() {
  local case_file="$1"
  local case_name
  case_name=$(basename "$case_file" .md)
  local type
  type=$(grep "^\*\*Type\*\*:" "$case_file" | cut -d: -f2 | tr -d ' ')
  local criteria
  criteria=$(grep -c "\- \[ \]" "$case_file")

  printf "  [%s] %s — %d pass criteria\n" "$type" "$case_name" "$criteria"
  TOTAL=$((TOTAL+1))
}

printf "Reference check:\n"
check_references

printf "Cases:\n"
if [ -n "$1" ]; then
  case_file="$CASES_DIR/$1.md"
  [ -f "$case_file" ] || { printf "Case not found: %s\n" "$1"; exit 1; }
  run_case "$case_file"
else
  for case_file in "$CASES_DIR"/*.md; do
    [ -f "$case_file" ] && run_case "$case_file"
  done
fi

printf "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "Cases: %d\n" "$TOTAL"
printf "\nNote: Full eval requires an active Figma Desktop session with Console plugin.\n"
printf "Automated eval not yet supported for MCP-dependent skills.\n"
printf "Results dir: %s/%s/\n" "$RESULTS_DIR" "$TIMESTAMP"
