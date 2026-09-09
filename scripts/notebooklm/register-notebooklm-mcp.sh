#!/usr/bin/env bash
#
# register-notebooklm-mcp.sh
#
# Registra el servidor MCP de notebooklm-py a nivel de usuario, para que
# esté disponible en cualquier proyecto/chat de Claude Code (no solo el
# directorio actual). Usa el CLI `claude` si existe; si no, edita
# ~/.claude.json directamente (con backup automático), que es lo que
# necesita la app de escritorio de Claude cuando no tienes el CLI instalado.
#
# NO uses el diálogo "Agregar conector personalizado" de Settings ->
# Conectores para esto: ese formulario solo acepta servidores MCP remotos
# por HTTPS, no un binario local por stdio.
#
set -euo pipefail

BIN="$HOME/.local/bin/notebooklm-mcp"

if [ ! -x "$BIN" ]; then
  echo "ERROR: no encuentro $BIN. Corre primero install-notebooklm.sh." >&2
  exit 1
fi

if command -v claude >/dev/null 2>&1; then
  echo "==> Detecté el CLI 'claude'. Registrando con 'claude mcp add'..."
  claude mcp add notebooklm --scope user -- "$BIN"
  echo "Listo. Corre 'claude mcp list' para confirmar."
  exit 0
fi

echo "==> No hay CLI 'claude' (usas la app de escritorio). Editando ~/.claude.json..."

CONFIG="$HOME/.claude.json"
if [ ! -f "$CONFIG" ]; then
  echo "ERROR: no existe $CONFIG. Abre Claude Desktop al menos una vez antes de correr esto." >&2
  exit 1
fi

BACKUP="$CONFIG.bak-$(date +%Y%m%d%H%M%S)"
cp "$CONFIG" "$BACKUP"
echo "    Backup guardado en: $BACKUP"

python3 - "$CONFIG" "$BIN" <<'PYEOF'
import json
import sys

config_path, bin_path = sys.argv[1], sys.argv[2]

with open(config_path) as f:
    data = json.load(f)

data.setdefault("mcpServers", {})
data["mcpServers"]["notebooklm"] = {
    "type": "stdio",
    "command": bin_path,
    "args": [],
    "env": {},
}

with open(config_path, "w") as f:
    json.dump(data, f, indent=2)

print("mcpServers.notebooklm registrado:")
print(json.dumps(data["mcpServers"]["notebooklm"], indent=2))
PYEOF

cat <<'EOF'

Listo. Cierra y vuelve a abrir Claude Desktop (o abre un chat nuevo) para
que cargue la configuración — el proceso actual no la relee en caliente.

Esta configuración vive en disco (~/.claude.json), así que sobrevive a
reinicios de la Mac y de la app sin que haya que repetir este paso.
EOF
