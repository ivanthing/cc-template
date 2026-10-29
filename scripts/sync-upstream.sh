#!/usr/bin/env bash
# Re-vendor upstream skills at the SHAs pinned in .claude/VENDORED.md.
# Applies the mechanical local changes automatically; semantic edits listed in
# VENDORED.md are overwritten and show up in the final diff for manual re-apply.
# To upgrade: bump a *_SHA line in VENDORED.md, run this, review the diff.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
C="$ROOT/.claude"
pin() { sed -n "s/^$1=//p" "$C/VENDORED.md"; }
ADDY_SHA=$(pin ADDY_SHA)

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
fetch() { git clone -q "$1" "$TMP/$2" && git -C "$TMP/$2" checkout -q "$3"; }
fetch https://github.com/addyosmani/agent-skills.git addy "$ADDY_SHA"

ADDY_SKILLS=(
  spec-driven-development planning-and-task-breakdown incremental-implementation
  test-driven-development debugging-and-error-recovery doubt-driven-development
  code-review-and-quality code-simplification security-and-hardening
  performance-optimization shipping-and-launch git-workflow-and-versioning
  constraint-driven-development source-driven-development frontend-ui-engineering
  documentation-and-adrs
)
ADDY_COMMANDS=(build code-simplify constraints plan review ship spec test)
ADDY_AGENTS=(code-reviewer security-auditor test-engineer)
# Renamed to avoid built-ins: /plan enters plan mode, /review aliases /code-review.
rename_cmd() { case "$1" in plan) echo plan-tasks ;; review) echo review-code ;; *) echo "$1" ;; esac; }

mkdir -p "$C/skills" "$C/agents" "$C/commands"
FILES=()
for s in "${ADDY_SKILLS[@]}"; do
  rm -rf "$C/skills/$s"
  cp -R "$TMP/addy/skills/$s" "$C/skills/$s"
done
rm -rf "$C/references"
cp -R "$TMP/addy/references" "$C/references"
for a in "${ADDY_AGENTS[@]}"; do
  cp "$TMP/addy/agents/$a.md" "$C/agents/$a.md"
  FILES+=("$C/agents/$a.md")
done
CMD_FILES=()
for c in "${ADDY_COMMANDS[@]}"; do
  dest="$C/commands/$(rename_cmd "$c").md"
  cp "$TMP/addy/.claude/commands/$c.md" "$dest"
  FILES+=("$dest")
  CMD_FILES+=("$dest")
done
for d in "${ADDY_SKILLS[@]/#/$C/skills/}" "$C/references"; do
  while IFS= read -r f; do FILES+=("$f"); done < <(find "$d" -type f)
done

# Change 1: drop the plugin namespace. Change 2: follow the command renames.
perl -pi -e '
  s/agent-skills://g;
  s{(?<![\w./-])/review(?![\w-])}{/review-code}g;
  s{(?<![\w./-])/plan(?![\w-])}{/plan-tasks}g;
  s{ See \[docs/agents\.md\]\(\.\./docs/agents\.md\)\.}{}g;
' "${FILES[@]}"
# Commands cite references/ from the repo root; here they live under .claude/.
perl -pi -e 's{(?<![\w./-])references/}{.claude/references/}g' "${CMD_FILES[@]}"

# Change 3: mark skills that exist upstream but are not vendored as optional.
for n in $(ls "$TMP/addy/skills"); do
  [[ " ${ADDY_SKILLS[*]} " == *" $n "* ]] && continue
  N="$n" perl -pi -e '
    my $n = quotemeta $ENV{N};
    s{(?<![\w/`-])(`?)($n)\1(?![\w/`-])(?! \(if installed\))}{$1$2$1 (if installed)}g;
  ' "${FILES[@]}"
done

echo "Re-vendored addy@${ADDY_SHA:0:7}."
echo "Re-apply any semantic edits listed in .claude/VENDORED.md that the diff below reverts."
git -C "$ROOT" --no-pager diff --stat -- .claude
git -C "$ROOT" --no-pager diff -- .claude
