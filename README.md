# team-claude-setup

Instalador interno para configurar Claude Desktop en macOS con dos cosas
opcionales, instalables por separado o juntas:

1. **Perfiles múltiples** (`Claude Work` / `Claude Personal` / los que
   necesites) — varias ventanas/instancias aisladas con login y MCPs
   independientes, usando el proyecto de terceros
   [claude-fix](https://github.com/sarhej/claude-fix) (no es de Anthropic;
   este repo solo lo descarga y ejecuta, no lo redistribuye).
2. **notebooklm-py** — CLI + servidor MCP no oficial para NotebookLM /
   Gemini Notebook ([teng-lin/notebooklm-py](https://github.com/teng-lin/notebooklm-py)),
   registrado a nivel de usuario para que esté disponible en cualquier
   proyecto/chat de Claude Code, sin repetir la instalación cada vez.

Requiere macOS y [Homebrew](https://brew.sh) instalado.

## Uso rápido

```bash
git clone <esta-url-de-repo>
cd team-claude-setup
chmod +x install.sh scripts/**/*.sh
./install.sh
```

O sin menú interactivo:

```bash
./install.sh --profiles      # solo perfiles múltiples
./install.sh --notebooklm    # solo notebooklm-py
./install.sh --all           # ambos
```

## Qué hace cada parte

### Perfiles múltiples (`scripts/claude-profiles/`)

- `install-claude-profiles.sh`: descarga `claude-fix` en vivo desde su
  fuente oficial y crea los launchers (`~/Applications/Claude <Perfil>.app`).
  No modifica ni re-firma el binario de Claude — abre `Claude.app` varias
  veces con distinto `--user-data-dir`.
- `claude-login-mode.sh`: cuando tienes más de un perfil abierto, un login
  o una conexión OAuth de un MCP (Gmail, Slack, Jira, etc.) puede volver a
  la ventana equivocada. Este script cierra temporalmente los demás
  perfiles, te deja autenticar en el que quieres, y los reabre al terminar.
  Uso: `~/Applications/claude-login-mode.sh "Claude Work"`.

### notebooklm-py (`scripts/notebooklm/`)

- `install-notebooklm.sh`: instala `uv`, el paquete `notebooklm-py[browser,mcp]`,
  y Chromium (para el login por navegador). Es idempotente — puedes
  volver a correrlo sin duplicar nada.
- `register-notebooklm-mcp.sh`: registra el servidor MCP **a nivel de
  usuario** (disponible en cualquier chat/proyecto, no solo uno). Usa
  `claude mcp add` si tienes el CLI instalado; si no, edita
  `~/.claude.json` directamente con backup automático.
  **No uses el diálogo "Agregar conector personalizado" de
  Settings → Conectores para esto** — ese formulario solo acepta
  servidores MCP remotos por HTTPS, no un binario local.

Cada persona debe correr `notebooklm login` con su propia cuenta de
Google — nadie lo hace por otro, y el archivo de sesión resultante
(`~/.notebooklm/profiles/default/storage_state.json`) es personal y no se
comparte ni se sube a este repo.

### `prompts/setup-notebooklm-mcp.md`

Un prompt listo para pegar en un chat de Claude Code, por si alguien
prefiere que el propio Claude corra los pasos en lugar del script bash
(incluye las mismas validaciones y precauciones).

## Notas de seguridad

- Nada aquí toca el binario firmado de Claude Desktop.
- Nada aquí introduce credenciales de nadie — todo login lo hace cada
  persona en su propia ventana/navegador.
- `register-notebooklm-mcp.sh` siempre hace backup de `~/.claude.json`
  antes de tocarlo.
- `claude-fix` es un proyecto de terceros no afiliado a Anthropic; revisa
  su código en https://github.com/sarhej/claude-fix antes de correrlo si
  tu equipo maneja datos sensibles.
