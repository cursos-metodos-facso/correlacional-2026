#!/usr/bin/env bash
set -euo pipefail

# Installs (or reinstalls) the bib-watcher as a systemd user service so it
# starts automatically on login and restarts on failure.
#
# Usage:  scripts/install-bib-watcher.sh [relative/path/to/file.bib]
# Default bib: references/publications/posts/ciencia-abierta.bib

BIB_REL_PATH="${1:-references/publications/posts/ciencia-abierta.bib}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVICE_NAME="bib-watcher-cienciasocialabierta2026"
SERVICE_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${SERVICE_DIR}/${SERVICE_NAME}.service"
TEMPLATE="${REPO_ROOT}/scripts/bib-watcher.service"

echo "==> Repo root : ${REPO_ROOT}"
echo "==> BibTeX    : ${BIB_REL_PATH}"
echo "==> Service   : ${SERVICE_FILE}"

# Validate bib file exists
if [[ ! -f "${REPO_ROOT}/${BIB_REL_PATH}" ]]; then
  echo "Error: bib file not found: ${REPO_ROOT}/${BIB_REL_PATH}" >&2
  exit 1
fi

# Validate git is configured
if [[ -z "$(git -C "${REPO_ROOT}" config user.name || true)" ]]; then
  echo "Error: git user.name is not set. Run: git config user.name \"Your Name\"" >&2
  exit 1
fi

# Ensure systemd user directory exists
mkdir -p "${SERVICE_DIR}"

# Write service file with real paths substituted
sed \
  -e "s|REPO_ROOT|${REPO_ROOT}|g" \
  -e "s|BIB_REL_PATH|${BIB_REL_PATH}|g" \
  "${TEMPLATE}" > "${SERVICE_FILE}"

echo "==> Service file written."

# Reload systemd user daemon and enable/start the service
systemctl --user daemon-reload
systemctl --user enable --now "${SERVICE_NAME}.service"

echo ""
echo "Done! Useful commands:"
echo "  Status  :  systemctl --user status ${SERVICE_NAME}"
echo "  Logs    :  journalctl --user -u ${SERVICE_NAME} -f"
echo "  Stop    :  systemctl --user stop ${SERVICE_NAME}"
echo "  Disable :  systemctl --user disable --now ${SERVICE_NAME}"
