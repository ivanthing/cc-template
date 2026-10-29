#!/usr/bin/env bash
# Static integrity checks for the .claude/ workflow: names, references, frontmatter,
# settings and the format hook. Needs bash, perl and jq; no network. Run from anywhere.
set -uo pipefail

cd "$(dirname "$0")/.."
fail=0
bad() { echo "  $*"; fail=1; }
mdfind() { find "$@" -name node_modules -prune -o -name '*.md' -print 2>/dev/null | grep -v '^.claude/VENDORED.md$'; }
# pg <perl-regex> <files...>: print file:line for every match
pg() { local re=$1; shift; [ $# -gt 0 ] || return 0; RE="$re" perl -ne 'print "$ARGV:$.: $_" if /$ENV{RE}/; close ARGV if eof' "$@"; }

CLAUDE_MD=$(mdfind .claude)                     # skills, commands, agents, references
ALL_MD=$(mdfind .claude CLAUDE.md README.md docs src)
# Workflow docs that name commands; user-written docs (README, docs/) may mention URL paths.
CMD_DOCS=$(ls .claude/commands/*.md .claude/skills/{start-feature,open-pr,prove-it-works,to-tickets}/SKILL.md .github/pull_request_template.md 2>/dev/null)
HAVE=$( (ls .claude/skills; ls .claude/agents .claude/commands | sed -n 's/\.md$//p') | sort -u)
# Claude Code built-ins referenced on purpose.
BUILTINS="clear compact context code-review plan review verify run-skill-generator install-github-app sandbox loop init mcp model"

echo "== stale names (renamed or removed in the skills upgrade)"
out=$(pg '(?<![\w./-])/(lfg|grill)(?![\w-])|agent-skills:|planner agent|planner\.md|test-runner|docs-explorer|prd-to-issues|docs/PRD\.md|docs/constraints\.md|setup-matt-pocock-skills|docs/agents/|`tech-debt`|improve-arch' $CLAUDE_MD CLAUDE.md README.md
      pg '(?<![\w./-])/(plan|review)(?![\w-])' $CLAUDE_MD CLAUDE.md | grep -v '^README.md:')
[ -z "$out" ] || bad "$out" "
  hint: /plan and /review are /plan-tasks and /review-code here; the other names no longer exist."

echo "== slash commands resolve"
# In CLAUDE.md only the workflow lines (the tier table and /start-feature) name commands.
for f in CLAUDE.md $CMD_DOCS; do
  for n in $(perl -ne 'next if $ARGV eq "CLAUDE.md" && !/→|start-feature/; print "$1\n" while /`\/([a-z][a-z-]*)(?:[` ]|\[)/g' "$f" | sort -u); do
    echo "$HAVE" | grep -qx "$n" || [[ " $BUILTINS " == *" $n "* ]] ||
      bad "$f: /$n  (hint: add a command or skill, or add a built-in to BUILTINS in this script)"
  done
done

echo "== skill and agent references resolve"
for f in $CLAUDE_MD; do
  for n in $(perl -ne '
      while (/`([a-z][a-z0-9-]+)` (?:skill|persona|agent)(?! \(if installed\))/g) { print "$1\n" }
      while (/[Ii]nvoke (?:the )?`?([a-z][a-z0-9]*(?:-[a-z0-9]+){2,}+)`?(?! \(if installed\))/g) { print "$1\n" }
    ' "$f" | sort -u); do
    echo "$HAVE" | grep -qx "$n" || bad "$f: $n  (hint: add it, or write \"$n (if installed)\" for an optional skill)"
  done
done

echo "== reference paths and @imports resolve"
for f in $ALL_MD; do d=$(dirname "$f")
  for r in $(grep -oE '(\.\./)+references/[A-Za-z0-9_-]+\.md' "$f" | sort -u); do [ -f "$d/$r" ] || bad "$f -> $r"; done
  for r in $(perl -ne 'print "$1\n" while /(?<![\w.\/-])(references\/[\w-]+\.md)/g' "$f" | sort -u); do [ -f "$d/$r" ] || bad "$f -> $r"; done
  for r in $(perl -ne 'print "$1\n" while /(\.claude\/references\/[\w-]+\.md)/g' "$f" | sort -u); do [ -f "$r" ] || bad "$f -> $r"; done
done
for r in $(perl -ne 'print "$1\n" while /(?<!\S)@([\w.\/-]+\.md)/g' CLAUDE.md); do
  [ -f "$r" ] || bad "CLAUDE.md imports @$r, which does not exist"
done

echo "== frontmatter and duplicate names"
for f in .claude/skills/*/SKILL.md .claude/agents/*.md; do
  fm=$(tr -d '\r' < "$f" | awk 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {done=1; exit} NR>1 {print} END {if (!done) print "\001unclosed"}')
  case "$fm" in *$'\001unclosed'*) bad "$f: frontmatter missing or not closed with ---"; continue ;; esac
  echo "$fm" | grep -qE '^description: *[^ ]' || bad "$f: empty or missing description"
  n=$(echo "$fm" | sed -n 's/^name: *//p' | head -1 | tr -d "\"'")
  case "$f" in .claude/skills/*)
    [ -z "$n" ] || [ "$n" = "$(basename "$(dirname "$f")")" ] || bad "$f: name '$n' doesn't match its directory" ;;
  esac
done
dups=$( (ls .claude/skills; ls .claude/commands | sed 's/\.md$//') | sort | uniq -d)
[ -z "$dups" ] || bad "skill and command share a name: $dups"

echo "== settings, scripts and the format hook"
if jq empty .claude/settings.json; then
  jq -r '(.permissions.allow // [])[], (.permissions.deny // [])[]' .claude/settings.json |
    grep -vE '^[A-Za-z]+(\(.+\))?$' | sed 's/^/  malformed permission rule: /' | grep . && fail=1
else
  bad "invalid .claude/settings.json"
fi
for s in scripts/*.sh; do bash -n "$s" || bad "syntax error: $s"; done

# Only the template's own format hook is exercised; custom hooks are left alone.
fmt=$(jq -c '[(.hooks.PostToolUse // [])[] | . as $g | (.hooks // [])[]
  | select(.type == "command" and (.command | test("prettier"))) | {matcher: ($g.matcher // ""), command}] | first // empty' .claude/settings.json 2>/dev/null)
if [ -z "$fmt" ]; then
  echo "  (no prettier format hook; skipped)"
else
  m=$(jq -r .matcher <<<"$fmt"); cmd=$(jq -r .command <<<"$fmt")
  for t in Edit Write; do [[ "|$m|" == *"|$t|"* ]] || bad "format hook matcher '$m' doesn't cover $t"; done
  stub=$(mktemp -d)
  printf '#!/bin/sh\necho "$*" >> "%s/log"\n' "$stub" > "$stub/npx"; chmod +x "$stub/npx"
  expect() { # expect <stdin> <npx calls joined by ;>
    : > "$stub/log"
    printf '%s' "$1" | PATH="$stub:$PATH" CLAUDE_PROJECT_DIR="$PWD" bash -c "$cmd" >/dev/null 2>&1 ||
      bad "format hook exits non-zero on: $1"
    local got; got=$(tr '\n' ';' < "$stub/log")
    [ "$got" = "$2" ] || bad "format hook on $1 ran '$got', want '$2'"
  }
  expect '{"tool_input":{"file_path":"/x/a b/ü.ts"}}' '--no-install eslint --fix /x/a b/ü.ts;--no-install prettier --write /x/a b/ü.ts;'
  expect '{"tool_input":{"file_path":"/x/r.md"}}' '--no-install prettier --write /x/r.md;'
  expect '{"tool_input":{"file_path":"/x/.claude/s.md"}}' ''
  expect '{}' ''
  expect 'not json' ''
  rm -rf "$stub"
fi

echo "RESULT: $([ "$fail" = 0 ] && echo PASS || echo FAIL)"
exit "$fail"
