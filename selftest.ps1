<#  Ari'el Codex — Self-Test Launcher (PowerShell)
    Usage:
      .\selftest.ps1 -ServerHost 127.0.0.1 -ServerPort 8000 -ShowVerbose
#>

[CmdletBinding()]
param(
  [string] $ServerHost = "127.0.0.1",
  [int]    $ServerPort = 8000,
  [double] $TimeoutSec = 10,
  [switch] $ShowVerbose
)

$ErrorActionPreference = "Stop"

# Move to this script's folder so relative paths work.
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $here

# Prefer venv python if present; fallback to system python.
$VenvPython = Join-Path $here "ariel\.venv\Scripts\python.exe"
if (Test-Path $VenvPython) {
  $PY = $VenvPython
} else {
  Write-Host "[info] .\ariel\.venv not found — using system python" -ForegroundColor Yellow
  $PY = "python"
}

# Confirm Python works
try {
  & $PY -V | Out-Null
} catch {
  Write-Host ("[error] Could not invoke Python at: {0}" -f $PY) -ForegroundColor Red
  Write-Host "        Ensure ariel\.venv exists or install Python and add it to PATH." -ForegroundColor Red
  exit 1
}

# Build args (updated self-test handles /insight/emotion AND /chat)
$ArgsList = @(
  "ariel_selftest.py",
  "--host",    $ServerHost,
  "--port",    $ServerPort,
  "--timeout", $TimeoutSec
)
if ($ShowVerbose.IsPresent) { $ArgsList += "--verbose" }

Write-Host ("[run] {0} {1}" -f $PY, ($ArgsList -join " ")) -ForegroundColor Cyan

# Directly invoke python; let PowerShell stream output.
& $PY @ArgsList
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
  Write-Host "`n[ok] Self-test passed." -ForegroundColor Green
} else {
  Write-Host ("`n[fail] Self-test failed with exit code {0}." -f $exitCode) -ForegroundColor Red
}
exit $exitCode
