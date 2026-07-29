#!/usr/bin/env bash
set -uo pipefail

# Watches a BibTeX file and auto-commits/pushes only when new @entries are added.
#
# Uses inotifywait (event-driven, zero CPU) when available; falls back to polling.
#   Install inotify-tools:  sudo apt install inotify-tools
#
# Usage:
#   scripts/auto-commit-bib.sh [relative/path/to/file.bib]
# Default file: references/publications/posts/ciencia-abierta.bib
#
# For permanent background use, install the systemd user service:
#   scripts/install-bib-watcher.sh

BIB_PATH_INPUT="${1:-references/publications/posts/ciencia-abierta.bib}"
POLL_SECONDS="${POLL_SECONDS:-5}"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-2}"

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is not installed or not in PATH." >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "Error: this script must be run inside a git repository." >&2
  exit 1
fi

cd "${REPO_ROOT}"

if [[ "${BIB_PATH_INPUT}" = /* ]]; then
  ABS_BIB_PATH="${BIB_PATH_INPUT}"
  REL_BIB_PATH="$(realpath --relative-to="${REPO_ROOT}" "${ABS_BIB_PATH}" 2>/dev/null || true)"
else
  REL_BIB_PATH="${BIB_PATH_INPUT}"
  ABS_BIB_PATH="${REPO_ROOT}/${REL_BIB_PATH}"
fi

if [[ -z "${REL_BIB_PATH}" ]] || [[ ! -f "${ABS_BIB_PATH}" ]]; then
  echo "Error: BibTeX file not found: ${BIB_PATH_INPUT}" >&2
  exit 1
fi

if [[ ! -w "${ABS_BIB_PATH}" ]]; then
  echo "Warning: file is not writable: ${ABS_BIB_PATH}" >&2
fi

if [[ -z "$(git config user.name || true)" ]] || [[ -z "$(git config user.email || true)" ]]; then
  echo "Error: git user.name and/or user.email are not configured." >&2
  echo "Set them with:" >&2
  echo "  git config user.name \"Your Name\"" >&2
  echo "  git config user.email \"you@example.com\"" >&2
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "${CURRENT_BRANCH}" == "HEAD" ]]; then
  echo "Error: detached HEAD is not supported for auto-push." >&2
  exit 1
fi

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

commit_if_new_entries() {
  if git diff --quiet -- "${REL_BIB_PATH}"; then
    return
  fi

  added_entries="$(git --no-pager diff --unified=0 -- "${REL_BIB_PATH}" | grep -cE '^\+@' || true)"

  if [[ "${added_entries}" -eq 0 ]]; then
    log "Change detected but no new @entry lines — skipping commit."
    return
  fi

  git add -- "${REL_BIB_PATH}"
  commit_time="$(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  commit_msg="chore(bib): add ${added_entries} reference(s) (${commit_time})"

  if git commit -m "${commit_msg}"; then
    log "Committed: ${commit_msg}"
  else
    log "ERROR: commit failed; changes left staged for manual review."
    return
  fi

  if git push origin "${CURRENT_BRANCH}"; then
    log "Pushed to origin/${CURRENT_BRANCH}"
  else
    log "ERROR: push failed (remote may be ahead). Pull/rebase manually and restart."
  fi
}

wait_for_change() {
  if command -v inotifywait >/dev/null 2>&1; then
    # Event-driven: blocks until the file is closed after a write (zero CPU)
    inotifywait -qq -e close_write "${ABS_BIB_PATH}"
  else
    # Polling fallback
    local last="$(stat -c %Y "${ABS_BIB_PATH}")"
    while true; do
      sleep "${POLL_SECONDS}"
      local current="$(stat -c %Y "${ABS_BIB_PATH}")"
      [[ "${current}" != "${last}" ]] && return
    done
  fi
}

if command -v inotifywait >/dev/null 2>&1; then
  log "Watching ${REL_BIB_PATH} via inotifywait (event-driven)"
else
  log "Watching ${REL_BIB_PATH} via polling every ${POLL_SECONDS}s"
  log "  (install inotify-tools for zero-CPU event-driven watching)"
fi
log "Auto-pushing to origin/${CURRENT_BRANCH}"

while true; do
  wait_for_change
  sleep "${DEBOUNCE_SECONDS}"  # debounce: wait for Zotero to finish writing
  commit_if_new_entries
done
