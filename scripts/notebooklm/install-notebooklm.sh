#!/usr/bin/env bash
#
# install-notebooklm.sh
#
# Instala notebooklm-py (https://github.com/teng-lin/notebooklm-py) —
# CLI + servidor MCP no oficial para NotebookLM / Gemini Notebook — en macOS.
# Idempotente: no reinstala lo que ya esté presente.
#
set -euo pipefail

echo "==> Verificando Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew no está instalado. Instálalo primero desde https://brew.sh y vuelve a correr este script."
  exit 1
fi

echo "==> Instalando uv (gestor de entornos Python aislados)..."
brew install uv

echo "==> Instalando notebooklm-py con soporte de navegador y MCP..."
uv tool install --reinstall "notebooklm-py[browser,mcp]"

echo "==> Agregando ~/.local/bin al PATH de tu shell..."
uv tool update-shell

echo "==> Descargando Chromium para el login por navegador (~170MB)..."
"$(uv tool dir)/notebooklm-py/bin/playwright" install chromium

cat <<'EOF'

notebooklm-py instalado.

Próximos pasos (hazlos tú mismo, no un tercero por ti):
  1. Abre una terminal nueva (o corre: source ~/.zshenv)
  2. notebooklm login          # tu propia cuenta de Google
  3. notebooklm list           # probar que funciona

Para registrar el servidor MCP (disponible en cualquier chat de Claude Code),
corre después: ./register-notebooklm-mcp.sh
EOF
