#!/usr/bin/env bash
#
# install.sh — punto de entrada único del repo.
#
# Uso:
#   ./install.sh                 # menú interactivo
#   ./install.sh --profiles      # solo perfiles múltiples de Claude Desktop
#   ./install.sh --notebooklm    # solo notebooklm-py + registro MCP
#   ./install.sh --all           # ambos
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Este script (install.sh) es para macOS."
  echo "¿Estás en Windows? Usa en su lugar, desde PowerShell:"
  echo "    .\\install.ps1"
  exit 1
fi

do_profiles() {
  echo "=== Perfiles múltiples de Claude Desktop (claude-fix) ==="
  bash "$HERE/scripts/claude-profiles/install-claude-profiles.sh"
}

do_notebooklm() {
  echo "=== notebooklm-py (CLI + MCP) ==="
  bash "$HERE/scripts/notebooklm/install-notebooklm.sh"
  echo
  echo "¿Ya hiciste 'notebooklm login'? El registro del servidor MCP puede"
  echo "correrse antes o después del login, pero el login lo debes hacer tú."
  read -r -p "Registrar el servidor MCP ahora? [Y/n] " ans </dev/tty || ans="Y"
  case "${ans:-Y}" in
    [nN]*) echo "  Saltado. Corre luego: scripts/notebooklm/register-notebooklm-mcp.sh" ;;
    *) bash "$HERE/scripts/notebooklm/register-notebooklm-mcp.sh" ;;
  esac
}

case "${1:-}" in
  --profiles) do_profiles ;;
  --notebooklm) do_notebooklm ;;
  --all) do_profiles; do_notebooklm ;;
  "")
    echo "¿Qué quieres instalar?"
    echo "  1) Perfiles múltiples de Claude Desktop (varias cuentas/ventanas)"
    echo "  2) Conexión notebooklm-py (MCP para NotebookLM / Gemini Notebook)"
    echo "  3) Ambos"
    printf "Elige un número: "
    read -r choice </dev/tty
    case "$choice" in
      1) do_profiles ;;
      2) do_notebooklm ;;
      3) do_profiles; do_notebooklm ;;
      *) echo "Opción inválida." >&2; exit 1 ;;
    esac
    ;;
  *)
    echo "Uso: $0 [--profiles|--notebooklm|--all]" >&2
    exit 1
    ;;
esac
