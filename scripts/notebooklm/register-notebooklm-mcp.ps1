<#
.SYNOPSIS
    Registra el servidor MCP de notebooklm-py a nivel de usuario en Windows.

.DESCRIPTION
    Equivalente Windows de register-notebooklm-mcp.sh. Usa el CLI `claude`
    si existe; si no, edita %USERPROFILE%\.claude.json directamente (con
    backup automático) — lo que necesita la app de escritorio cuando no
    tienes el CLI instalado.

    NO uses el diálogo "Agregar conector personalizado" de Settings ->
    Conectores para esto: ese formulario solo acepta servidores MCP remotos
    por HTTPS, no un binario local por stdio.
#>
$ErrorActionPreference = 'Stop'

$toolDir = (uv tool dir).Trim()
$bin = Join-Path $toolDir "notebooklm-py\Scripts\notebooklm-mcp.exe"

if (-not (Test-Path -LiteralPath $bin)) {
    Write-Error "No encuentro $bin. Corre primero install-notebooklm.ps1."
    exit 1
}

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "==> Detecté el CLI 'claude'. Registrando con 'claude mcp add'..."
    claude mcp add notebooklm --scope user -- "$bin"
    Write-Host "Listo. Corre 'claude mcp list' para confirmar."
    exit 0
}

Write-Host "==> No hay CLI 'claude' (usas la app de escritorio). Editando ~\.claude.json..."

$config = Join-Path $env:USERPROFILE ".claude.json"
if (-not (Test-Path -LiteralPath $config)) {
    Write-Error "No existe $config. Abre Claude Desktop al menos una vez antes de correr esto."
    exit 1
}

$backup = "$config.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
Copy-Item -LiteralPath $config -Destination $backup
Write-Host "    Backup guardado en: $backup"

$data = Get-Content -LiteralPath $config -Raw | ConvertFrom-Json

if (-not $data.mcpServers) {
    $data | Add-Member -MemberType NoteProperty -Name mcpServers -Value ([pscustomobject]@{})
}

$entry = [pscustomobject]@{
    type    = "stdio"
    command = $bin
    args    = @()
    env     = [pscustomobject]@{}
}

if ($data.mcpServers.PSObject.Properties.Name -contains "notebooklm") {
    $data.mcpServers.notebooklm = $entry
} else {
    $data.mcpServers | Add-Member -MemberType NoteProperty -Name notebooklm -Value $entry
}

($data | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath $config -Encoding UTF8

Write-Host "mcpServers.notebooklm registrado:"
$entry | ConvertTo-Json | Write-Host

Write-Host @"

Listo. Cierra y vuelve a abrir Claude Desktop (o abre un chat nuevo) para
que cargue la configuración — el proceso actual no la relee en caliente.

Esta configuración vive en disco (~\.claude.json), así que sobrevive a
reinicios de Windows y de la app sin que haya que repetir este paso.
"@
