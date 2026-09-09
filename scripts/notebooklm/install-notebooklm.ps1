<#
.SYNOPSIS
    Instala notebooklm-py (CLI + servidor MCP) en Windows.

.DESCRIPTION
    Equivalente Windows de install-notebooklm.sh. notebooklm-py
    (https://github.com/teng-lin/notebooklm-py) es Python puro + Playwright,
    así que sí funciona nativamente en Windows — lo único que cambiaba era
    el instalador (brew no existe aquí). Usa el instalador oficial de uv
    para Windows (https://astral.sh/uv/install.ps1) en vez de un gestor de
    paquetes de terceros.
#>
$ErrorActionPreference = 'Stop'

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

Write-Host "==> Verificando uv..."
if (-not (Test-Command 'uv')) {
    Write-Host "    Instalando uv (instalador oficial: https://astral.sh/uv/install.ps1)..."
    powershell -ExecutionPolicy ByPass -Command "irm https://astral.sh/uv/install.ps1 | iex"
    # El instalador agrega uv al PATH del usuario; refrescamos la sesión actual.
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
} else {
    Write-Host "    Ya está instalado."
}

Write-Host "==> Instalando notebooklm-py con soporte de navegador y MCP..."
uv tool install --reinstall "notebooklm-py[browser,mcp]"

Write-Host "==> Descargando Chromium para el login por navegador (~170MB)..."
$toolDir = (uv tool dir).Trim()
$playwright = Join-Path $toolDir "notebooklm-py\Scripts\playwright.exe"
if (-not (Test-Path -LiteralPath $playwright)) {
    throw "No encuentro playwright.exe en $playwright"
}
& $playwright install chromium

Write-Host @"

notebooklm-py instalado.

Próximos pasos (hazlos tú mismo, no un tercero por ti):
  1. Abre una terminal NUEVA (para que el PATH se actualice)
  2. notebooklm login          # tu propia cuenta de Google
  3. notebooklm list           # probar que funciona

Para registrar el servidor MCP (disponible en cualquier chat de Claude Code),
corre después: .\register-notebooklm-mcp.ps1
"@
