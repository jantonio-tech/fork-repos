#!/usr/bin/env bash
#
# install-claude-profiles.sh
#
# Instala perfiles múltiples de Claude Desktop (ventanas/instancias aisladas,
# ej. "Claude Work" / "Claude Personal") usando el proyecto de terceros
# "claude-fix" (https://github.com/sarhej/claude-fix). No es un producto de
# Anthropic; es un launcher que abre Claude.app varias veces con distintos
# --user-data-dir, sin parchear ni re-firmar el binario.
#
# Este script solo descarga y ejecuta la última versión de claude-fix desde
# su fuente oficial (no la vendorizamos aquí porque no publica una licencia
# explícita) y luego copia el script complementario claude-login-mode.sh
# (propio de este repo) a ~/Applications para que quede a mano.
#
# Uso:
#   ./install-claude-profiles.sh                 # interactivo, crea el que falte
#   ./install-claude-profiles.sh Work Personal    # crea estos perfiles
#
set -euo pipefail

CLAUDE_FIX_URL="https://raw.githubusercontent.com/sarhej/claude-fix/main/make_claude_launchers.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Descargando claude-fix (perfiles múltiples de Claude Desktop)..."
echo "    Fuente: https://github.com/sarhej/claude-fix (proyecto de terceros, no oficial de Anthropic)"

TMP_SCRIPT="$(mktemp -t claude-fix-launchers)"
curl -fsSL "$CLAUDE_FIX_URL" -o "$TMP_SCRIPT"
chmod +x "$TMP_SCRIPT"

echo "==> Ejecutando (elige los perfiles que necesites, ej: Work, Personal)..."
bash "$TMP_SCRIPT" create --desktop "$@"

rm -f "$TMP_SCRIPT"

echo "==> Instalando script auxiliar de login (evita el conflicto de OAuth callback"
echo "    cuando tienes varios perfiles abiertos a la vez)..."
mkdir -p "$HOME/Applications"
cp "$HERE/claude-login-mode.sh" "$HOME/Applications/claude-login-mode.sh"
chmod +x "$HOME/Applications/claude-login-mode.sh"

cat <<'EOF'

Listo. Perfiles creados en ~/Applications (y accesos en el Escritorio).

Para autenticar UN perfil a la vez sin que el callback de login/OAuth se
confunda con otra ventana abierta, usa:

    ~/Applications/claude-login-mode.sh --list
    ~/Applications/claude-login-mode.sh "Claude Work"

Esto cierra temporalmente los demás perfiles, te deja autenticar en paz, y
los vuelve a abrir cuando terminas.
EOF
