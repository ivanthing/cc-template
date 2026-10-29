#!/usr/bin/env bash
# Re-vendor upstream skills at the SHAs pinned in .claude/VENDORED.md.
# Applies the mechanical local changes automatically; semantic edits listed in
# VENDORED.md are overwritten and show up in the final diff for manual re-apply.
# To upgrade: bump a *_SHA line in VENDORED.md, run this, review the diff.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
C="$ROOT/.claude"
die() { echo "sync-upstream: $*" >&2; exit 1; }

[ -z "$(git -C "$ROOT" status --porcelain -- .claude)" ] ||
  die ".claude/ has uncommitted changes; commit or stash them first"

pin() { tr -d '\r' < "$C/VENDORED.md" | sed -n "s/^$1=//p"; }
ADDY_SHA=$(pin ADDY_SHA)
MATT_SHA=$(pin MATT_SHA)
for sha in "$ADDY_SHA" "$MATT_SHA"; do
  [[ $sha =~ ^[0-9a-f]{40}$ ]] || die "pins in VENDORED.md must be one full 40-hex SHA each, got '$sha'"
done

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
MATT_SKILLS=(productivity/grill-me productivity/grilling engineering/to-tickets engineering/pr)
# Renamed to avoid built-ins: /plan enters plan mode, /review aliases /code-review.
rename_cmd() { case "$1" in plan) echo plan-tasks ;; review) echo review-code ;; *) echo "$1" ;; esac; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
fetch() { git clone -q "$1" "$TMP/$2" && git -C "$TMP/$2" checkout -q "$3"; }
fetch https://github.com/addyosmani/agent-skills.git addy "$ADDY_SHA"
fetch https://github.com/mattpocock/skills.git matt "$MATT_SHA"

# Fail before deleting anything if upstream moved or removed a vendored path.
for s in "${ADDY_SKILLS[@]}"; do [ -d "$TMP/addy/skills/$s" ] || die "upstream addy is missing skills/$s"; done
[ -d "$TMP/addy/references" ] || die "upstream addy is missing references/"
for a in "${ADDY_AGENTS[@]}"; do [ -f "$TMP/addy/agents/$a.md" ] || die "upstream addy is missing agents/$a.md"; done
for c in "${ADDY_COMMANDS[@]}"; do [ -f "$TMP/addy/.claude/commands/$c.md" ] || die "upstream addy is missing .claude/commands/$c.md"; done
for s in "${MATT_SKILLS[@]}"; do [ -d "$TMP/matt/skills/$s" ] || die "upstream matt is missing skills/$s"; done

# Vendored content becomes agent instructions: markdown only, no links or dotfiles.
sanitize() {
  find "$@" \( -type l -o -name '.*' \) -print -exec rm -rf {} + 2>/dev/null || true
  local bad
  bad=$(find "$@" -type f ! -name '*.md')
  [ -z "$bad" ] || die "non-markdown files in vendored content: $bad"
}

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
sanitize "${ADDY_SKILLS[@]/#/$C/skills/}" "$C/references"
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
for dir in "$TMP"/addy/skills/*/; do
  n=$(basename "$dir")
  [[ " ${ADDY_SKILLS[*]} " == *" $n "* ]] && continue
  N="$n" perl -pi -e '
    my $n = quotemeta $ENV{N};
    s{(?<![\w/`-])(`?)($n)\1(?![\w/`-])(?! \(if installed\))}{$1$2$1 (if installed)}g;
  ' "${FILES[@]}"
done

MATT_FILES=()
for s in "${MATT_SKILLS[@]}"; do
  n=$(basename "$s")
  rm -rf "$C/skills/$n"
  cp -R "$TMP/matt/skills/$s" "$C/skills/$n"
  rm -rf "$C/skills/$n/agents" # Codex-only metadata
  sanitize "$C/skills/$n"
  while IFS= read -r f; do MATT_FILES+=("$f"); done < <(find "$C/skills/$n" -type f)
done
# This repo keeps no glossary by default.
perl -pi -e 's{`GLOSSARY\.md`(?! \(if present\))}{`GLOSSARY.md` (if present)}g' "${MATT_FILES[@]}"

echo "Re-vendored addy@${ADDY_SHA:0:7} matt@${MATT_SHA:0:7}."
echo "Re-apply any semantic edits listed in .claude/VENDORED.md that the diff below reverts."
git -C "$ROOT" add -N -- .claude # show new upstream files in the diff
git -C "$ROOT" --no-pager diff --text --stat -- .claude
git -C "$ROOT" --no-pager diff --text -- .claude
