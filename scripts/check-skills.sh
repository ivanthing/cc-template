#!/usr/bin/env bash
# Static integrity checks for the .claude/ workflow: names, references, frontmatter,
# settings and hooks. Needs bash, perl and jq; no network. Run from anywhere.
set -uo pipefail

cd "$(dirname "$0")/.."
fail=0
bad() { echo "  $*"; fail=1; }
MD=$(find .claude CLAUDE.md README.md docs src -name '*.md' 2>/dev/null | grep -v '^.claude/VENDORED.md$')
# pg <perl-regex>: print file:line for every match across $MD
pg() { RE="$1" perl -ne 'print "$ARGV:$.: $_" if /$ENV{RE}/; close ARGV if eof' $MD; }

HAVE=$( (ls .claude/skills; ls .claude/agents .claude/commands | sed -n 's/\.md$//p') | sort -u)
# Claude Code built-ins this repo mentions on purpose.
BUILTINS="clear compact context code-review plan review verify run-skill-generator install-github-app sandbox loop"
# Scaffold-authored docs; vendored prose (see .claude/VENDORED.md) also names hypothetical commands.
OWN=$(ls CLAUDE.md README.md docs/*.md .claude/commands/handoff.md .claude/skills/{start-feature,open-pr,prove-it-works,to-tickets}/SKILL.md)

echo "== stale names"
out=$(pg '(?<![\w./-])/(lfg|grill)(?![\w-])|agent-skills:|planner agent|planner\.md|test-runner|docs-explorer|prd-to-issues|docs/PRD\.md|docs/constraints\.md|setup-matt-pocock-skills|docs/agents/|tech-debt|improve-arch'
      pg '(?<![\w./-])/(plan|review)(?![\w-])' | grep -v '^README.md:.*Claude Code built-ins')
[ -z "$out" ] || bad "$out"

echo "== slash commands resolve"
for f in $OWN; do
  for n in $(perl -ne 'print "$1\n" while /`\/([a-z][a-z-]*)(?:[` ]|\[)/g' "$f" | sort -u); do
    echo "$HAVE" | grep -qx "$n" || [[ " $BUILTINS " == *" $n "* ]] || bad "$f: /$n"
  done
done

echo "== skill and agent references resolve"
for f in $MD; do
  for n in $(perl -ne '
      while (/`([a-z][a-z0-9-]+)` (?:skill|persona|agent)(?! \(if installed\))/g) { print "$1\n" }
      while (/[Ii]nvoke (?:the )?`?([a-z][a-z0-9]*(?:-[a-z0-9]+){2,}+)`?(?! \(if installed\))/g) { print "$1\n" }
    ' "$f" | sort -u); do
    echo "$HAVE" | grep -qx "$n" || bad "$f: $n"
  done
done

echo "== reference paths resolve"
for f in $MD; do d=$(dirname "$f")
  for r in $(grep -oE '(\.\./)+references/[A-Za-z0-9_-]+\.md' "$f" | sort -u); do [ -f "$d/$r" ] || bad "$f -> $r"; done
  for r in $(perl -ne 'print "$1\n" while /(?<![\w.\/-])(references\/[\w-]+\.md)/g' "$f" | sort -u); do [ -f "$d/$r" ] || bad "$f -> $r"; done
  for r in $(perl -ne 'print "$1\n" while /(\.claude\/references\/[\w-]+\.md)/g' "$f" | sort -u); do [ -f "$r" ] || bad "$f -> $r"; done
done

echo "== frontmatter and duplicate names"
for f in .claude/skills/*/SKILL.md .claude/agents/*.md; do
  head -1 "$f" | grep -q '^---$' || bad "no frontmatter: $f"
  grep -q '^description:' "$f" || bad "no description: $f"
done
for f in .claude/skills/*/SKILL.md; do
  n=$(sed -n 's/^name: *//p' "$f" | head -1)
  [ "$n" = "$(basename "$(dirname "$f")")" ] || bad "name mismatch: $f ($n)"
done
dups=$( (ls .claude/skills; ls .claude/commands | sed 's/\.md$//') | sort | uniq -d)
[ -z "$dups" ] || bad "skill and command share a name: $dups"

echo "== settings, scripts and hooks"
jq empty .claude/settings.json || bad "invalid .claude/settings.json"
for s in scripts/*.sh; do bash -n "$s" || bad "syntax error: $s"; done
jq -r '.hooks[][].hooks[].command' .claude/settings.json | while IFS= read -r cmd; do
  for input in '{"tool_input":{"file_path":"/tmp/a b/ü.md"}}' '{}' 'not json'; do
    printf '%s' "$input" | PATH="/usr/bin:/bin:$(dirname "$(command -v jq)")" bash -c "$cmd" >/dev/null 2>&1 ||
      { echo "  hook exits non-zero on: $input"; exit 1; }
  done
done || fail=1

echo "RESULT: $([ "$fail" = 0 ] && echo PASS || echo FAIL)"
exit "$fail"
