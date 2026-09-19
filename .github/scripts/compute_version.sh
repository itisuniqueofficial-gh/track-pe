#!/usr/bin/env bash
#
# Track Pe version engine.
#
# Determines the next semantic version from conventional-commit history since
# the latest v*.*.* tag, and a monotonic Android versionCode from the commit
# count. GitHub is the source of truth — pubspec.yaml is NOT edited per release.
#
# Bump policy (see docs/RELEASES.md):
#   BREAKING CHANGE / <type>!:   -> MAJOR
#   feat:                        -> MINOR
#   fix:                         -> PATCH
#   anything else, but new commits exist, FORCE_LEVEL=auto -> PATCH (fallback)
#   no new commits (auto)        -> no release
#
# Env:
#   FORCE_LEVEL = auto|patch|minor|major   (default: auto)
#
# Outputs (to $GITHUB_OUTPUT, or stdout when run locally):
#   release, bump, version, tag, version_code
set -euo pipefail

FORCE_LEVEL="${FORCE_LEVEL:-auto}"
OUT="${GITHUB_OUTPUT:-/dev/stdout}"

emit() { echo "$1=$2" >> "$OUT"; }

# Latest semantic version tag (highest), if any.
LATEST_TAG="$(git tag --list 'v[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | head -n1 || true)"

if [ -z "${LATEST_TAG}" ]; then
  BASE="0.0.0"
  RANGE=""
else
  BASE="${LATEST_TAG#v}"
  RANGE="${LATEST_TAG}..HEAD"
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "${BASE}"

if [ -n "${RANGE}" ]; then
  LOG="$(git log --format='%B' "${RANGE}" || true)"
  NEW_COMMITS="$(git rev-list --count "${RANGE}" 2>/dev/null || echo 0)"
else
  LOG="$(git log --format='%B' || true)"
  NEW_COMMITS="$(git rev-list --count HEAD 2>/dev/null || echo 0)"
fi

BUMP="none"
if grep -qiE '(^|[[:space:]])BREAKING CHANGE' <<< "${LOG}" \
   || grep -qE '^[a-zA-Z]+(\([^)]+\))?!:' <<< "${LOG}"; then
  BUMP="major"
elif grep -qE '^feat(\([^)]+\))?:' <<< "${LOG}"; then
  BUMP="minor"
elif grep -qE '^fix(\([^)]+\))?:' <<< "${LOG}"; then
  BUMP="patch"
fi

case "${FORCE_LEVEL}" in
  patch|minor|major)
    BUMP="${FORCE_LEVEL}"
    ;;
  auto)
    # Deterministic fallback: new commits with no conventional signal -> patch.
    if [ "${BUMP}" = "none" ] && [ "${NEW_COMMITS}" -gt 0 ]; then
      BUMP="patch"
    fi
    ;;
  *)
    echo "Unknown FORCE_LEVEL='${FORCE_LEVEL}'" >&2
    exit 1
    ;;
esac

if [ "${BUMP}" = "none" ]; then
  emit release "false"
  echo "No releasable commits since ${LATEST_TAG:-<none>} (FORCE_LEVEL=${FORCE_LEVEL})."
  exit 0
fi

case "${BUMP}" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

NEXT="${MAJOR}.${MINOR}.${PATCH}"
# Monotonic, deterministic Android versionCode from full commit count.
VERSION_CODE="$(git rev-list --count HEAD)"

emit release "true"
emit bump "${BUMP}"
emit version "${NEXT}"
emit tag "v${NEXT}"
emit version_code "${VERSION_CODE}"

echo "Computed v${NEXT} (bump=${BUMP}, versionCode=${VERSION_CODE}) from base ${BASE}."
