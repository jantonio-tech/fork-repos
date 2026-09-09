<#
.SYNOPSIS
    Punto de entrada único del repo para Windows.

.EXAMPLE
    .\install.ps1                 # menú interactivo
    .\install.ps1 -Profiles       # solo perfiles múltiples de Claude Desktop
    .\install.ps1 -Notebooklm     # solo notebooklm-py + registro MCP
    .\install.ps1 -All            # ambos
#>
param(
    [switch]$Profiles,
    [switch]$Notebooklm,
    [switch]$All
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

function Install-Profiles {
    Write-Host "=== Perfiles múltiples de Claude Desktop (Claude-Code-Desktop-Switcher) ===" -ForegroundColor Cyan
    & (Join-Path $here "scripts\claude-profiles-windows\install-claude-profiles.ps1") -Install
}

function Install-Notebooklm {
    Write-Host "=== notebooklm-py (CLI + MCP) ===" -ForegroundColor Cyan
    & (Join-Path $here "scripts\notebooklm\install-notebooklm.ps1")
    Write-Host ""
    $ans = Read-Host "¿Ya hiciste 'notebooklm login'? Registrar el servidor MCP ahora? [Y/n]"
    if ($ans -eq '' -or $ans -match '^[Yy]') {
        & (Join-Path $here "scripts\notebooklm\register-notebooklm-mcp.ps1")
    } else {
        Write-Host "  Saltado. Corre luego: scripts\notebooklm\register-notebooklm-mcp.ps1"
    }
}

if ($Profiles)   { Install-Profiles; return }
if ($Notebooklm) { Install-Notebooklm; return }
if ($All)        { Install-Profiles; Install-Notebooklm; return }

Write-Host "¿Qué quieres instalar?"
Write-Host "  1) Perfiles múltiples de Claude Desktop (varias cuentas/ventanas)"
Write-Host "  2) Conexión notebooklm-py (MCP para NotebookLM / Gemini Notebook)"
Write-Host "  3) Ambos"
$choice = Read-Host "Elige un número"
switch ($choice) {
    '1' { Install-Profiles }
    '2' { Install-Notebooklm }
    '3' { Install-Profiles; Install-Notebooklm }
    default { Write-Error "Opción inválida." }
}
