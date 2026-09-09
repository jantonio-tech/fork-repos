<#
.SYNOPSIS
    Instala el selector de perfiles múltiples de Claude Desktop para Windows.

.DESCRIPTION
    Vendoriza (copia local) "Claude Code Desktop Switcher"
    (https://github.com/PriyanshuGeTRekT/Claude-Code-Desktop-Switcher, MIT,
    ver vendor/Claude-Code-Desktop-Switcher/LICENSE) — un script PowerShell
    auditado que lanza Claude.exe con --user-data-dir por perfil, igual
    técnica que claude-fix usa en macOS. No modifica ni re-firma Claude.exe,
    no hace llamadas de red, no lee credenciales ni cookies existentes.

.EXAMPLE
    .\install-claude-profiles.ps1
    .\install-claude-profiles.ps1 -Install    # además crea accesos directos
#>
param([switch]$Install)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$switcher = Join-Path $here 'vendor\Claude-Code-Desktop-Switcher\ClaudeSwitcher.ps1'

if (-not (Test-Path -LiteralPath $switcher)) {
    throw "No encuentro $switcher. Verifica que el repo se clonó completo."
}

Write-Host "==> Selector de perfiles de Claude Desktop (Windows)"
Write-Host "    Fuente vendorizada: PriyanshuGeTRekT/Claude-Code-Desktop-Switcher (MIT)"
Write-Host "    https://github.com/PriyanshuGeTRekT/Claude-Code-Desktop-Switcher"
Write-Host ""

if ($Install) {
    & $switcher -Install
    Write-Host "Acceso directo creado en el Escritorio y en el Menú Inicio."
} else {
    & $switcher
}

Write-Host ""
Write-Host "Uso normal (sin este instalador):"
Write-Host "  powershell -File `"$switcher`"              # abre la ventana con GUI"
Write-Host "  powershell -File `"$switcher`" -List         # lista perfiles y su estado"
Write-Host "  powershell -File `"$switcher`" -Launch Work   # abre un perfil directo"
