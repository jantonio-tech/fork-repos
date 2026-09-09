# team-claude-setup

Instalador interno para configurar Claude Desktop con dos cosas opcionales,
instalables por separado o juntas, en **macOS** o **Windows**:

1. **Perfiles múltiples** (`Work` / `Personal` / los que necesites) — varias
   ventanas/instancias aisladas con login y MCPs independientes.
2. **notebooklm-py** — CLI + servidor MCP no oficial para NotebookLM /
   Gemini Notebook ([teng-lin/notebooklm-py](https://github.com/teng-lin/notebooklm-py)),
   registrado a nivel de usuario para que esté disponible en cualquier
   proyecto/chat de Claude Code, sin repetir la instalación cada vez.

## Árbol de decisión

```
                        git clone + entrar al repo
                                   │
                    ┌──────────────┴──────────────┐
                    │                              │
                 macOS                          Windows
                    │                              │
              ./install.sh                    .\install.ps1
                    │                              │
        ┌───────────┼───────────┐        ┌─────────┼─────────┐
        │           │           │        │         │         │
   --profiles  --notebooklm  --all   -Profiles -Notebooklm  -All
        │           │           │        │         │         │
   claude-fix   notebooklm-py  ambos  Claude-Code- notebooklm-py  ambos
   (macOS)      + MCP                 Desktop-      + MCP
                                       Switcher
                                       (Windows)
```

Ambas plataformas soportan las tres opciones. La diferencia es **qué
herramienta de terceros** hace los perfiles múltiples por debajo — el
mecanismo (`--user-data-dir` por perfil) es el mismo en los dos sistemas.

Requiere:
- **macOS**: [Homebrew](https://brew.sh)
- **Windows**: PowerShell (incluido en Windows 10/11)

## Uso rápido

**macOS:**
```bash
git clone <esta-url-de-repo>
cd team-claude-setup
chmod +x install.sh scripts/**/*.sh
./install.sh                 # menú interactivo
./install.sh --profiles      # solo perfiles múltiples
./install.sh --notebooklm    # solo notebooklm-py
./install.sh --all           # ambos
```

**Windows (PowerShell):**
```powershell
git clone <esta-url-de-repo>
cd team-claude-setup
.\install.ps1                # menú interactivo
.\install.ps1 -Profiles      # solo perfiles múltiples
.\install.ps1 -Notebooklm    # solo notebooklm-py
.\install.ps1 -All           # ambos
```

## Qué hace cada parte

### Perfiles múltiples — macOS (`scripts/claude-profiles/`)

- `install-claude-profiles.sh`: descarga [claude-fix](https://github.com/sarhej/claude-fix)
  en vivo desde su fuente oficial (proyecto de terceros, no vendorizado
  porque no publica licencia) y crea los launchers
  (`~/Applications/Claude <Perfil>.app`). No modifica ni re-firma el
  binario de Claude — abre `Claude.app` varias veces con distinto
  `--user-data-dir`.
- `claude-login-mode.sh`: cuando tienes más de un perfil abierto, un login
  o una conexión OAuth de un MCP (Gmail, Slack, Jira, etc.) puede volver a
  la ventana equivocada. Este script cierra temporalmente los demás
  perfiles, te deja autenticar en el que quieres, y los reabre al terminar.
  Uso: `~/Applications/claude-login-mode.sh "Claude Work"`.

### Perfiles múltiples — Windows (`scripts/claude-profiles-windows/`)

- `install-claude-profiles.ps1`: usa [Claude-Code-Desktop-Switcher](https://github.com/PriyanshuGeTRekT/Claude-Code-Desktop-Switcher)
  (MIT), **vendorizado** en `vendor/Claude-Code-Desktop-Switcher/` porque
  su licencia sí lo permite. Auditado línea por línea antes de incluirlo:
  sin llamadas de red, sin acceso a cookies/credenciales existentes, solo
  lanza `Claude.exe` con `--user-data-dir` por perfil (mismo mecanismo que
  `claude-fix` en macOS) y una GUI WinForms para gestionar los perfiles.
  Guarda su estado en `%LOCALAPPDATA%\ClaudeProfiles`.
  - Otros candidatos de Windows evaluados (`GiovanniTrevisan/claude-multi-account`,
    también limpio en la auditoría) quedaron fuera por decisión del equipo,
    no por un problema encontrado — se puede reconsiderar si se prefiere
    la versión compilada con identidad propia en la barra de tareas.
  - **No se incluyeron** el resto de repos de "Windows multi-profile"
    encontrados en GitHub (`claude-strayshot`, `claude-dual-desktop`,
    `claude-switch`, `claude-api-key-switcher`, etc.) — todos con 0-5
    estrellas y sin auditar. No los uses sin revisar su código primero.

### notebooklm-py (`scripts/notebooklm/`)

Mismo flujo en ambos sistemas operativos (`install-notebooklm.sh` /
`install-notebooklm.ps1` y `register-notebooklm-mcp.sh` / `.ps1`):

- Instala `uv` (macOS: vía Homebrew; Windows: instalador oficial de
  [astral.sh/uv](https://astral.sh/uv/install.ps1)), el paquete
  `notebooklm-py[browser,mcp]`, y Chromium (para el login por navegador).
  Idempotente — se puede volver a correr sin duplicar nada.
- `register-notebooklm-mcp.*`: registra el servidor MCP **a nivel de
  usuario** (disponible en cualquier chat/proyecto, no solo uno). Usa
  `claude mcp add` si tienes el CLI instalado; si no, edita
  `~/.claude.json` (macOS) o `%USERPROFILE%\.claude.json` (Windows)
  directamente, con backup automático.
  **No uses el diálogo "Agregar conector personalizado" de
  Settings → Conectores para esto** — ese formulario solo acepta
  servidores MCP remotos por HTTPS, no un binario local.

Cada persona debe correr `notebooklm login` con su propia cuenta de
Google — nadie lo hace por otro, y el archivo de sesión resultante
(`~/.notebooklm/profiles/default/storage_state.json`) es personal y no se
comparte ni se sube a este repo.

### `prompts/setup-notebooklm-mcp.md`

Un prompt listo para pegar en un chat de Claude Code, por si alguien
prefiere que el propio Claude corra los pasos en lugar de los scripts
(incluye las mismas validaciones y precauciones). Escrito pensando en
macOS; para Windows habría que adaptar las rutas/comandos que menciona.

## Notas de seguridad

- Nada aquí toca el binario firmado de Claude Desktop, en ninguna de las
  dos plataformas.
- Nada aquí introduce credenciales de nadie — todo login lo hace cada
  persona en su propia ventana/navegador.
- `register-notebooklm-mcp.*` siempre hace backup del `.claude.json` antes
  de tocarlo.
- `claude-fix` (macOS) y `Claude-Code-Desktop-Switcher` (Windows) son
  proyectos de terceros no afiliados a Anthropic. El segundo fue auditado
  línea por línea antes de incluirse en este repo (ver commit history);
  el primero se descarga en vivo en cada instalación, así que revisa su
  código periódicamente si tu equipo maneja datos sensibles.
