# Prompt para configurar notebooklm-py como servidor MCP

Copia y pega esto tal cual en un chat de Claude Code (terminal, app de escritorio, o VS Code):

---

Quiero que instales y configures `notebooklm-py` (https://github.com/teng-lin/notebooklm-py)
como servidor MCP disponible en TODOS mis proyectos/chats, no solo en el actual, y que
sobreviva a reinicios de la app/terminal. Sigue estos pasos, verificando en cada uno
antes de continuar, y sin asumir nada que puedas comprobar con un comando:

1. **Detectar entorno**: revisa si existen `brew`, `uv`, `pipx` y la versión de `python3`.
   El paquete requiere Python 3.10+; si el Python del sistema es más viejo, usa `uv`
   (gestiona su propio Python) en vez de instalar globalmente.

2. **Instalar `uv`** si no existe: `brew install uv` (o el instalador oficial si no hay
   Homebrew). No reinstales si ya está.

3. **Instalar el paquete** con soporte de navegador y MCP:
   `uv tool install "notebooklm-py[browser,mcp]"`
   Si ya está instalado pero le falta el extra `mcp` (falla `notebooklm-mcp --help` con
   `ModuleNotFoundError: fastmcp`), reinstala con `--reinstall`.

4. **Arreglar el PATH**: `uv tool update-shell`. Verifica corriendo
   `notebooklm --version` en una shell nueva (exportando
   `PATH="$HOME/.local/bin:$PATH"` si hace falta para esta sesión).

5. **Descargar Chromium** (necesario para el login por navegador, ~170MB):
   encuentra el playwright del venv de la tool (`uv tool dir` + `/notebooklm-py/bin/playwright`)
   y corre `playwright install chromium`.

6. **NO hagas login por mí.** Dime exactamente el comando (`notebooklm login`) y pídeme
   que lo corra yo mismo en mi terminal — es un login interactivo con mi cuenta de
   Google y no debes introducir credenciales.

7. **Registrar el servidor MCP a nivel de usuario** (para que esté disponible en
   cualquier proyecto, no solo en el directorio actual):
   - Si tengo el CLI `claude` instalado: `claude mcp add notebooklm --scope user -- "$HOME/.local/bin/notebooklm-mcp"`
   - Si NO tengo el CLI `claude` (uso la app de escritorio / Cowork sin terminal de
     `claude`), entonces:
     a. Haz un backup de `~/.claude.json` (copia con timestamp) antes de tocarlo.
     b. Léelo, agrega (sin borrar nada existente) la clave de nivel superior
        `mcpServers.notebooklm` con:
        ```json
        {
          "type": "stdio",
          "command": "/RUTA/A/tu/home/.local/bin/notebooklm-mcp",
          "args": [],
          "env": {}
        }
        ```
     c. Muéstrame el JSON resultante de esa clave para que yo confirme que se ve bien.
   - **No uses el diálogo "Agregar conector personalizado" de Settings → Conectores**:
     ese es solo para servidores MCP remotos con URL HTTPS, no sirve para un binario
     local por stdio.

8. **Validar que quedó disponible en cualquier chat**:
   - Verifica que la ruta usada en `command` sea absoluta y correcta (`which notebooklm-mcp`
     o la ruta de `uv tool dir`).
   - Confírmame que edité el archivo de configuración de **usuario** (no uno de
     `.mcp.json` a nivel de proyecto), ya que solo el de usuario aplica a todos los
     proyectos.
   - Dime explícitamente: "Cierra y vuelve a abrir la app (o abre un chat nuevo) para
     que cargue la configuración." Esto es necesario porque el proceso actual no relee
     el archivo en caliente.

9. **Confirmar persistencia tras reinicio**:
   - Esta configuración vive en un archivo en disco (`~/.claude.json`), no en memoria
     ni en un proceso en segundo plano — por lo tanto sobrevive a reinicios de la Mac,
     cierres de la app, y apagones, sin que yo tenga que volver a instalar nada.
   - Lo único que se pierde al reiniciar la máquina (no la app) es la sesión de login
     de NotebookLM si expira — en ese caso solo hace falta correr `notebooklm login`
     de nuevo, no reinstalar el paquete.

10. Al terminar, dame un resumen: qué se instaló, qué archivo se modificó (con su
    backup), y qué pasos me faltan a mí (login, reiniciar la app).

---

**Notas para quien lo comparta:**
- Cada persona debe requerir tener [Homebrew](https://brew.sh) instalado antes.
- Cada persona hace su propio login con su propia cuenta de Google — la sesión
  autenticada (`~/.notebooklm/profiles/default/storage_state.json`) es local y
  personal, nunca se comparte.
- Si alguien ya usó el script `install-notebooklm-py.sh` que te compartí antes, este
  prompt cubre lo mismo más el registro MCP a nivel de usuario y sus validaciones.
