# Prompt para instalar desde team-claude-setup

Copia y pega esto tal cual en un chat de Claude Code (terminal, app de escritorio, o VS Code):

---

Quiero que instales las herramientas de nuestro repo interno
`https://github.com/jantonio-tech/fork-repos` (perfiles múltiples de Claude
Desktop y/o la conexión MCP con NotebookLM). Sigue estos pasos, verificando
en cada uno antes de continuar, y sin asumir nada que puedas comprobar con
un comando:

1. **Detecta mi sistema operativo** (macOS o Windows) — el repo tiene un
   instalador distinto para cada uno (`install.sh` vs `install.ps1`), no
   uses el equivocado.

2. **Clona el repo** en un directorio razonable (pregúntame dónde si no es
   obvio, no lo pongas dentro de otro proyecto sin avisarme):
   `git clone https://github.com/jantonio-tech/fork-repos.git`

   Si el repo es privado y no tienes acceso, dime que necesito agregarte
   como colaborador o darte un token, no intentes rodear eso.

3. **Pregúntame qué quiero instalar** antes de correr nada, mostrando las
   3 opciones tal cual las expone el instalador:
   - Perfiles múltiples de Claude Desktop (varias cuentas/ventanas)
   - Conexión notebooklm-py (MCP para NotebookLM / Gemini Notebook)
   - Ambos

4. **Corre el instalador correspondiente a mi SO**:
   - macOS: `chmod +x install.sh scripts/**/*.sh && ./install.sh [--profiles|--notebooklm|--all]`
   - Windows (PowerShell): `.\install.ps1 [-Profiles|-Notebooklm|-All]`

5. **NO hagas login por mí en ningún paso.** Ni el login de `notebooklm
   login` (cuenta de Google) ni la autenticación de cada perfil de Claude
   Desktop (cuenta de Anthropic). Dime exactamente qué comando correr o qué
   ventana abrir, y pídeme que lo haga yo mismo.

6. **Si instalas la conexión MCP de notebooklm**, verifica al final:
   - Que el registro haya quedado a **nivel de usuario** (no solo en un
     `.mcp.json` de este proyecto), para que esté disponible en cualquier
     chat/proyecto, no solo en el que estás usando ahora.
   - Que exista un backup del `.claude.json` que se haya modificado.
   - Dime explícitamente que debo cerrar y volver a abrir Claude Desktop
     (o abrir un chat nuevo) para que cargue la configuración.
   - **No uses el diálogo "Agregar conector personalizado" de
     Settings → Conectores** — ese formulario solo acepta servidores MCP
     remotos por HTTPS, no un binario local por stdio.

7. **Si instalas perfiles múltiples**, al terminar dime:
   - Dónde quedaron los accesos directos/launchers.
   - Cómo autenticar cada perfil sin que el login de uno interfiera con
     otro que esté abierto (en macOS: `claude-login-mode.sh`; en Windows:
     el propio switcher tiene su GUI para esto).

8. **Confírmame persistencia**: toda esta configuración vive en disco
   (archivos de perfil, `.claude.json`), así que sobrevive a reinicios de
   la máquina y de la app — no hace falta reinstalar nada después de
   reiniciar, solo volver a autenticar si una sesión expiró.

9. Al terminar, dame un resumen: qué se instaló, qué archivos se tocaron
   (con sus backups si aplica), y qué pasos me faltan a mí (logins,
   reiniciar la app).

---

**Notas para quien lo comparta:**
- Cada persona hace sus propios logins (Google para NotebookLM, Anthropic
  para cada perfil de Claude) — nunca los hace un tercero por ella.
- La parte de "perfiles múltiples" usa herramientas de terceros ya
  auditadas por nuestro equipo (ver README del repo) — no agregues otras
  sin pasar por el mismo proceso de revisión.
- Si el repo se vuelve privado en el futuro, cada quien necesita que se le
  dé acceso como colaborador antes de poder clonarlo.
