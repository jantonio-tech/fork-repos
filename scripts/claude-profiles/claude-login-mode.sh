#!/bin/bash
#
# claude-login-mode.sh
#
# Ayuda a autenticar (login de cuenta, o conectar un MCP con OAuth) en UN
# perfil de Claude Desktop generado por claude-fix, cuando tienes varios
# perfiles corriendo al mismo tiempo.
#
# Por qué existe: los launchers de claude-fix abren el mismo Claude.app con
# distintos --user-data-dir. Para macOS todas las instancias comparten el
# mismo bundle ID, así que un callback OAuth (claude://...) que abre el
# navegador puede volver a la instancia equivocada si hay más de una corriendo.
# Este script cierra temporalmente las demás, te deja autenticar en paz, y
# las vuelve a abrir cuando terminas.
#
# No modifica, parchea, ni re-firma Claude.app. Solo abre y cierra procesos
# que tú normalmente abrirías y cerrarías a mano.
#
# Uso:
#   ./claude-login-mode.sh                 # interactivo: elige qué perfil autenticar
#   ./claude-login-mode.sh "Claude Work"   # ve directo a ese perfil
#   ./claude-login-mode.sh --list          # lista perfiles detectados
#
set -euo pipefail

APPS="$HOME/Applications"
MARKER_FILE="Contents/Resources/claude-fix-generated"
BIN_PATH="Contents/MacOS/Claude"

# ---------- utilidades ----------

err() { echo "ERROR: $*" >&2; }

require_macos() {
  if [ "$(uname -s)" != "Darwin" ]; then
    err "Este script solo corre en macOS."
    exit 1
  fi
}

# Encuentra el Claude.app "real" (no un launcher generado), igual que hace
# claude-fix: primero rutas estándar, luego Launch Services / Spotlight.
find_real_claude_app() {
  local candidates=(
    "/Applications/Claude.app"
    "$HOME/Applications/Claude.app"
  )
  local c
  for c in "${candidates[@]}"; do
    if [ -d "$c" ] && [ -x "$c/$BIN_PATH" ]; then
      printf '%s' "$c"
      return 0
    fi
  done
  local found
  found=$(mdfind "kMDItemCFBundleIdentifier == 'com.anthropic.claudefordesktop'" 2>/dev/null | head -n1 || true)
  if [ -n "$found" ] && [ -x "$found/$BIN_PATH" ]; then
    printf '%s' "$found"
    return 0
  fi
  return 1
}

# Lista los .app en ~/Applications que claude-fix generó (tienen el marcador).
list_generated_profiles() {
  shopt -s nullglob
  local app
  for app in "$APPS/Claude "*.app; do
    [ -e "$app" ] || continue
    [ -f "$app/$MARKER_FILE" ] || continue
    printf '%s\n' "$app"
  done
  shopt -u nullglob
}

profile_label() {
  local app="$1"
  basename "$app" .app
}

# PIDs de procesos Claude corriendo, mapeados a su --user-data-dir (o "default").
running_claude_pids() {
  # Salida: "pid<TAB>data-dir-o-default"
  ps -axo pid=,command= 2>/dev/null | awk -v real="$BIN_PATH" '
    index($0, "Claude.app/" real) {
      key = "default"
      for (i = 2; i <= NF; i++) {
        if ($i ~ /^--user-data-dir=/) {
          split($i, parts, "=")
          key = parts[2]
        }
      }
      print $1 "\t" key
    }'
}

# Dado un data-dir (o vacío para "default"), devuelve el PID corriendo con ese dir, si hay.
pid_for_data_dir() {
  local want="${1:-default}"
  running_claude_pids | awk -F'\t' -v w="$want" '$2 == w { print $1; exit }'
}

# data-dir que le corresponde a un launcher, leyendo el marcador que
# claude-fix escribió (data-dir=...).
data_dir_for_app() {
  local app="$1"
  local marker="$app/$MARKER_FILE"
  awk -F= '$1 == "data-dir" { print $2 }' "$marker" 2>/dev/null
}

quit_pid_gracefully() {
  local pid="$1"
  local label="$2"
  echo "  cerrando: $label (pid $pid)"
  kill -TERM "$pid" 2>/dev/null || true
  local i
  for ((i = 0; i < 20; i++)); do
    kill -0 "$pid" 2>/dev/null || return 0
    sleep 0.2
  done
  # Si sigue vivo tras ~4s, no insistimos con -9: puede tener un diálogo
  # de guardar/confirmar abierto. Se lo dejamos al usuario.
  if kill -0 "$pid" 2>/dev/null; then
    err "No se pudo cerrar '$label' (pid $pid) a tiempo. Ciérralo manualmente si sigue interfiriendo."
  fi
}

open_profile() {
  local app="$1"
  echo "  abriendo: $(profile_label "$app")"
  open -n -a "$app"
}

open_default_claude() {
  local claude_app="$1"
  echo "  abriendo: Claude (perfil por defecto)"
  open -n -a "$claude_app"
}

pause_for_user() {
  echo
  echo ">>> Termina el login / la conexión del MCP en la ventana que se abrió."
  echo ">>> Cuando hayas terminado, vuelve aquí y presiona Enter..."
  read -r _ </dev/tty
}

# ---------- flujo principal ----------

main() {
  require_macos

  if [ "${1:-}" = "--list" ]; then
    echo "Perfiles generados por claude-fix en $APPS:"
    local app found=0
    while IFS= read -r app; do
      found=1
      echo "  - $(profile_label "$app")"
    done < <(list_generated_profiles)
    [ "$found" = "1" ] || echo "  (ninguno encontrado)"
    return 0
  fi

  local claude_app
  if ! claude_app=$(find_real_claude_app); then
    err "No encontré Claude.app instalado. Instálalo desde https://claude.ai/download"
    exit 1
  fi

  local -a profiles=()
  local app
  while IFS= read -r app; do
    profiles+=("$app")
  done < <(list_generated_profiles)

  if [ "${#profiles[@]}" -eq 0 ]; then
    err "No encontré perfiles generados por claude-fix en $APPS."
    err "Corre primero make_claude_launchers.sh para crearlos."
    exit 1
  fi

  # Elegir el perfil objetivo: por argumento, o por menú interactivo.
  local target=""
  if [ "${1:-}" != "" ]; then
    local want="$1"
    for app in "${profiles[@]}"; do
      if [ "$(profile_label "$app")" = "$want" ] || [ "$(profile_label "$app")" = "Claude $want" ]; then
        target="$app"
        break
      fi
    done
    if [ -z "$target" ]; then
      err "No encontré el perfil '$want'. Usa --list para ver los disponibles."
      exit 1
    fi
  else
    echo "¿Qué perfil quieres autenticar (login de cuenta o conectar un MCP)?"
    local i=1
    for app in "${profiles[@]}"; do
      echo "  $i) $(profile_label "$app")"
      i=$((i + 1))
    done
    echo "  0) el Claude normal (perfil por defecto, sin --user-data-dir)"
    printf "Elige un número: "
    local choice
    read -r choice </dev/tty
    if [ "$choice" = "0" ]; then
      target="__default__"
    elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#profiles[@]}" ] 2>/dev/null; then
      target="${profiles[$((choice - 1))]}"
    else
      err "Opción inválida."
      exit 1
    fi
  fi

  # Detectar qué está corriendo ahora mismo.
  echo
  echo "Revisando instancias de Claude abiertas..."
  local -a to_reopen_apps=()      # rutas .app a reabrir al final
  local -a to_reopen_labels=()    # etiquetas legibles, mismo índice
  local reopen_default=0

  local pid data_dir
  for app in "${profiles[@]}"; do
    if [ "$app" = "$target" ]; then
      continue
    fi
    data_dir=$(data_dir_for_app "$app")
    pid=$(pid_for_data_dir "$data_dir")
    if [ -n "$pid" ]; then
      quit_pid_gracefully "$pid" "$(profile_label "$app")"
      to_reopen_apps+=("$app")
      to_reopen_labels+=("$(profile_label "$app")")
    fi
  done

  # También el Claude "default" (sin --user-data-dir), si no es el objetivo.
  if [ "$target" != "__default__" ]; then
    pid=$(pid_for_data_dir "default")
    if [ -n "$pid" ]; then
      quit_pid_gracefully "$pid" "Claude (perfil por defecto)"
      reopen_default=1
    fi
  fi

  # Abrir solo el objetivo.
  echo
  echo "Abriendo el perfil a autenticar..."
  if [ "$target" = "__default__" ]; then
    open_default_claude "$claude_app"
  else
    open_profile "$target"
  fi

  pause_for_user

  # Reabrir lo que cerramos.
  if [ "${#to_reopen_apps[@]}" -gt 0 ] || [ "$reopen_default" = "1" ]; then
    echo
    echo "Reabriendo los perfiles que estaban corriendo antes..."
    local j
    for ((j = 0; j < ${#to_reopen_apps[@]}; j++)); do
      open_profile "${to_reopen_apps[$j]}"
    done
    if [ "$reopen_default" = "1" ]; then
      open_default_claude "$claude_app"
    fi
  fi

  echo
  echo "Listo."
}

main "$@"
