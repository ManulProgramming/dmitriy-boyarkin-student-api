#!/usr/bin/env bash
# =============================================================================
# personalize.sh - re-brand this whole project for another student.
#
# Replaces the current student's name, group, e-mail and GitHub user in
#   * file CONTENTS   (Java package, Dockerfile, Compose, Jenkinsfile, scripts, docs, logs ...)
#   * file and directory NAMES   (<Old>_<Name>_system_report.sh -> First_Last_system_report.sh,
#                                 src/main/java/com/<oldslug> -> com/<newslug>)
#   * Git: user.name / user.email, branch names, release tag, remote URL, and
#     optionally the COMMIT HISTORY (--rewrite-history).
#
# Usage:
#   ./scripts/personalize.sh --name "First Last" [--group IT-2301] [--email me@uni.kz]
#                            [--github-user my-login] [--rewrite-history] [--commit-pending]
#                            [--dry-run] [--yes]
#
# The order of the two words is kept exactly as typed (First_Last in file names).
# Current values are stored in .personalization so the script can be re-run.
# =============================================================================
set -euo pipefail
export LC_ALL=C.UTF-8 2>/dev/null || true

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

# ---------------------------------------------------------------- helpers ---
esc_re()  { printf '%s' "$1" | sed -e 's#[][\.*^$|/&]#\\&#g'; }
esc_rep() { printf '%s' "$1" | sed -e 's#[\\|&]#\\&#g'; }

rewrite_name() { printf '%s' "$1" | sed -f "$SEDA" | sed -f "$SEDB"; }

# Apply the replacement rules to all text files and to all file/dir names under $1
rewrite_tree() {
  ( cd "$1"
    while IFS= read -r -d '' f; do
      if grep -Iq . "$f" 2>/dev/null; then sed -i -f "$SEDA" "$f"; sed -i -f "$SEDB" "$f"; fi
    done < <(find . -type f -not -path './.git/*' -not -path './build/*' -not -path './.gradle/*' -print0)
    local paths=() p base dirn nb
    mapfile -d '' paths < <(find . -mindepth 1 -depth -not -path './.git' -not -path './.git/*' -print0)
    for p in "${paths[@]}"; do
      base="$(basename "$p")"; dirn="$(dirname "$p")"
      nb="$(rewrite_name "$base")"
      if [ "$nb" != "$base" ]; then mv -- "$p" "$dirn/$nb"; fi
    done )
}

# Internal mode: called by git filter-branch for every historical commit
if [ "${PERSONALIZE_INTERNAL:-}" = "1" ]; then rewrite_tree .; exit 0; fi

die()  { echo "ERROR: $*" >&2; exit 1; }
usage(){ sed -n '2,19p' "$SELF" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

ascii() {   # transliterate to plain ASCII letters/digits
  local out; out="$(printf '%s' "$1" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || true)"
  [[ -n "$out" && "$out" != *'?'* ]] || die "Cannot transliterate '$1' to Latin letters. Please type the name with Latin letters."
  out="$(printf '%s' "$out" | tr -cd 'A-Za-z0-9')"; [ -n "$out" ] || die "Empty name after transliteration"
  printf '%s' "$out"
}
cap() { local s="${1,,}"; printf '%s' "${s^}"; }

# ---------------------------------------------------------------- args ------
NAME=""; GROUP=""; EMAIL=""; GH=""; REWRITE=0; DRY=0; YES=0; AUTOC=0
while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2;;
    --group) GROUP="${2:-}"; shift 2;;
    --email) EMAIL="${2:-}"; shift 2;;
    --github-user) GH="${2:-}"; shift 2;;
    --rewrite-history) REWRITE=1; shift;;
    --commit-pending) AUTOC=1; shift;;
    --dry-run) DRY=1; shift;;
    --yes|-y) YES=1; shift;;
    -h|--help) usage 0;;
    *) echo "Unknown option: $1" >&2; usage 1;;
  esac
done
[ -n "$NAME" ] || { echo "Missing --name" >&2; usage 1; }

ROOT="$(cd "$(dirname "$SELF")/.." && pwd)"
[ -f "$ROOT/.personalization" ] || die "$ROOT/.personalization not found - run from the project"
# shellcheck disable=SC1091
. "$ROOT/.personalization"

# ------------------------------------------------------------ validation ----
[[ "$NAME" =~ ^[[:alpha:]\'-]+\ [[:alpha:]\'-]+$ ]] || die "--name must be exactly two words, e.g. --name \"Aruzhan Nurlanova\""
[ -z "$GROUP" ] || [[ "$GROUP" =~ ^[A-Za-z0-9._-]+$ ]] || die "--group may contain only letters, digits, . _ -"
[ -z "$GH" ]    || [[ "$GH" =~ ^[A-Za-z0-9-]+$ ]]       || die "--github-user may contain only letters, digits and -"
[ -z "$EMAIL" ] || [[ "$EMAIL" =~ ^[^[:space:]@\|\&\\]+@[^[:space:]@\|\&\\]+$ ]] || die "invalid --email"

N_FIRST_D="${NAME%% *}"; N_LAST_D="${NAME#* }"
nf="$(ascii "$N_FIRST_D")"; nl="$(ascii "$N_LAST_D")"
NF_T="$(cap "$nf")"; NL_T="$(cap "$nl")"; NF_L="${nf,,}"; NL_L="${nl,,}"
[[ "$NF_L$NL_L" =~ ^[a-z] ]] || die "name must start with a letter"
NEW_GROUP="${GROUP:-$P_GROUP}"
NEW_EMAIL="${EMAIL:-$NF_L.$NL_L@example.com}"
NEW_GH="${GH:-$P_GH}"
NEW_INI="${NF_T:0:1}${NL_T:0:1}"

OF_T="$(cap "$P_FIRST")"; OL_T="$(cap "$P_LAST")"; OF_L="${P_FIRST,,}"; OL_L="${P_LAST,,}"
OLD_INI="${OF_T:0:1}${OL_T:0:1}"

# ------------------------------------------------------- replacement rules --
SEDA="$(mktemp)"; SEDB="$(mktemp)"; COPY="$(mktemp)"
trap 'rm -f "$SEDA" "$SEDB" "$COPY"' EXIT
n=0
rule() {  # rule <old-literal> <new-literal>
  [ -n "$1" ] && [ "$1" != "$2" ] || return 0
  n=$((n+1))
  echo "s|$(esc_re "$1")|@@P${n}@@|g" >> "$SEDA"; echo "s|@@P${n}@@|$(esc_rep "$2")|g" >> "$SEDB"
}
# Order matters: long/compound forms first, single words last.
rule "$P_EMAIL" "$NEW_EMAIL"
rule "$P_GH"    "$NEW_GH"
rule "$P_GROUP" "$NEW_GROUP"
rule "$OF_T $OL_T"       "$N_FIRST_D $N_LAST_D"          # display name
rule "${OF_T}_${OL_T}"   "${NF_T}_${NL_T}"               # file names, Jenkins job
rule "${OF_L}_${OL_L}"   "${NF_L}_${NL_L}"               # volume, network, database
rule "${OF_L}-${OL_L}"   "${NF_L}-${NL_L}"               # repo, image, branches, tag
rule "${OF_L}.${OL_L}"   "${NF_L}.${NL_L}"               # e-mail style
rule "${OF_L}${OL_L}"    "${NF_L}${NL_L}"                # Java package / group id
rule "$OF_T" "$N_FIRST_D"; rule "$OL_T" "$N_LAST_D"      # single words
rule "$OF_L" "$NF_L";      rule "$OL_L" "$NL_L"
rule "${OF_L^^}_${OL_L^^}" "${NF_L^^}_${NL_L^^}"         # upper-case forms (constants, test input)
rule "${OF_L^^}" "${NF_L^^}"; rule "${OL_L^^}" "${NL_L^^}"
if [ "$OLD_INI" != "$NEW_INI" ]; then                    # student-code prefix, e.g. DB-2026-001
  n=$((n+1)); echo "s|\\b${OLD_INI}-|@@P${n}@@|g" >> "$SEDA"; echo "s|@@P${n}@@|${NEW_INI}-|g" >> "$SEDB"
fi
[ -s "$SEDA" ] || { echo "Nothing to do: values are already ${P_FIRST} ${P_LAST} / ${P_GROUP}."; exit 0; }

# --------------------------------------------------------------- summary ----
echo "Current : ${P_FIRST} ${P_LAST} | group ${P_GROUP} | ${P_EMAIL} | github ${P_GH}"
echo "New     : ${N_FIRST_D} ${N_LAST_D} | group ${NEW_GROUP} | ${NEW_EMAIL} | github ${NEW_GH}"
echo "Examples: ${NF_T}_${NL_T}_system_report.sh, ${NF_L}-${NL_L}-student-api:v1.0-${NF_L}-${NL_L}, package com.${NF_L}${NL_L}, code ${NEW_INI}-2026-001"
[ "$REWRITE" = 1 ] && echo "Mode    : REWRITE GIT HISTORY (commit hashes change; force-push needed if already pushed)"

if [ "$DRY" = 1 ]; then
  echo; echo "== DRY RUN: files whose content would change =="
  ( cd "$ROOT"; find . -type f -not -path './.git/*' -print0 | while IFS= read -r -d '' f; do
      grep -Iq . "$f" 2>/dev/null || continue
      if ! sed -f "$SEDA" "$f" | sed -f "$SEDB" | cmp -s - "$f"; then echo "  $f"; fi
    done )
  echo "== DRY RUN: paths that would be renamed =="
  ( cd "$ROOT"; find . -mindepth 1 -not -path './.git' -not -path './.git/*' -print | while IFS= read -r p; do
      b="$(basename "$p")"; nb="$(rewrite_name "$b")"; [ "$b" = "$nb" ] || echo "  $p -> $nb"
    done )
  exit 0
fi

if [ "$YES" != 1 ] && [ -t 0 ]; then read -r -p "Proceed? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }; fi

# ------------------------------------------------------------------ Git -----
HAVE_GIT=0; [ -d "$ROOT/.git" ] && HAVE_GIT=1
gitc() { git -C "$ROOT" "$@"; }
OLD_NAME_D="${P_FIRST} ${P_LAST}"
TAGS_BEFORE=""; [ $HAVE_GIT = 1 ] && TAGS_BEFORE="$(gitc tag -l)"

if [ $HAVE_GIT = 1 ] && [ "$REWRITE" = 1 ]; then
  if ! gitc diff --quiet || ! gitc diff --cached --quiet; then
    if [ "$AUTOC" = 1 ]; then
      gitc add -u; gitc commit -q -m "chore: save pending changes before personalization"
      echo "Committed pending changes."
    else
      echo "ERROR: git sees uncommitted changes in tracked files:" >&2
      gitc status --short --untracked-files=no >&2
      echo "--- details (first lines) ---" >&2
      gitc diff --stat | tail -n 8 >&2
      cat >&2 <<HINT

How to fix (pick one):
  1. Keep the changes:        git add -u && git commit -m "my changes"      (or rerun with --commit-pending)
  2. Park them:               git stash                                      (git stash pop afterwards)
  3. Throw them away:         git restore .
  4. Only file-mode changes (diff shows "old mode 100755 / new mode 100644", typical after unzipping):
                              git config core.fileMode false   then rerun
  5. Only line-ending changes (Windows, CRLF):
                              git config core.autocrlf false && git restore .   then rerun
HINT
      exit 1
    fi
  fi
  cp "$SELF" "$COPY"
  export F_OLD_NAME="$OLD_NAME_D" F_NEW_NAME="$N_FIRST_D $N_LAST_D" F_NEW_EMAIL="$NEW_EMAIL"
  ENVF='for w in AUTHOR COMMITTER; do eval "cur=\$GIT_${w}_NAME"; if [ "$cur" = "$F_OLD_NAME" ]; then export GIT_${w}_NAME="$F_NEW_NAME"; export GIT_${w}_EMAIL="$F_NEW_EMAIL"; fi; done'
  echo "Rewriting history (this can take a minute) ..."
  ( cd "$ROOT"
    FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f \
      --env-filter "$ENVF" \
      --msg-filter "sed -f '$SEDA' | sed -f '$SEDB'" \
      --tree-filter "PERSONALIZE_INTERNAL=1 SEDA='$SEDA' SEDB='$SEDB' bash '$COPY'" \
      --tag-name-filter cat -- --all >/dev/null 2>&1 ) || die "git filter-branch failed"
  gitc for-each-ref --format='%(refname)' refs/original/ | xargs -r -n1 git -C "$ROOT" update-ref -d
  gitc reflog expire --expire=now --all; gitc gc --prune=now -q
fi

# working tree: tracked files (non-rewrite mode) plus ignored/untracked ones (logs ...)
export SEDA SEDB
rewrite_tree "$ROOT"

cat > "$ROOT/.personalization" <<EOF
# Current personalisation values. Maintained by scripts/personalize.sh - do not edit by hand.
P_FIRST='${N_FIRST_D}'
P_LAST='${N_LAST_D}'
P_GROUP='${NEW_GROUP}'
P_EMAIL='${NEW_EMAIL}'
P_GH='${NEW_GH}'
EOF

if [ $HAVE_GIT = 1 ]; then
  gitc config user.name "${N_FIRST_D} ${N_LAST_D}"; gitc config user.email "$NEW_EMAIL"
  if gitc remote get-url origin >/dev/null 2>&1; then
    gitc remote set-url origin "$(rewrite_name "$(gitc remote get-url origin)")"
  fi
  if [ "$REWRITE" != 1 ]; then
    gitc add -A
    gitc diff --cached --quiet || gitc commit -q -m "chore: personalize project for ${N_FIRST_D} ${N_LAST_D} (${NEW_GROUP})"
  elif ! gitc diff --quiet || [ -n "$(gitc status --porcelain)" ]; then
    gitc add -A; gitc commit -q -m "chore: record personalization for ${N_FIRST_D} ${N_LAST_D} (${NEW_GROUP})"
  fi
  # branches
  for b in $(gitc for-each-ref --format='%(refname:short)' refs/heads); do
    nb="$(rewrite_name "$b")"; [ "$nb" = "$b" ] || gitc branch -m "$b" "$nb"
  done
  # tags (annotated, recreated with the new name)
  for t in $TAGS_BEFORE; do
    nt="$(rewrite_name "$t")"
    if [ "$nt" != "$t" ]; then
      if [ "$REWRITE" = 1 ]; then target="$(gitc rev-parse "$t^{commit}")"; else target="HEAD"; fi
      gitc tag -a "$nt" -m "Release ${nt} - ${N_FIRST_D} ${N_LAST_D} Student API" "$target"
      gitc tag -d "$t" >/dev/null
    fi
  done
fi

# ------------------------------------------------------- leftover check -----
echo; echo "Checking for leftovers of the old name ..."
LEFT="$(cd "$ROOT" && grep -rIniE "${OF_L}|${OL_L}" . --exclude-dir=.git --exclude-dir=build --exclude-dir=.gradle 2>/dev/null || true)"
LEFT_PATHS="$(cd "$ROOT" && find . -not -path './.git/*' -iname "*${OF_L}*" -o -not -path './.git/*' -iname "*${OL_L}*" 2>/dev/null || true)"
if [ -z "$LEFT$LEFT_PATHS" ]; then echo "  none - project is fully personalized."
else echo "$LEFT" | head -n 15; echo "$LEFT_PATHS" | head -n 15; echo "  (review the above - a new name that contains the old one will show here legitimately)"; fi
echo; echo "Done. Next: git log --oneline --graph --all ; git remote -v ; git tag -l"
[ $HAVE_GIT = 1 ] && [ "$REWRITE" != 1 ] && echo "Note: earlier commits still carry the old name. Use --rewrite-history on a fresh clone if that is not acceptable."
exit 0
