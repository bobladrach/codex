<#  Test-Ariel.ps1 — Ari'el Codex quick check (classic PowerShell friendly)
    What it does:
      • GET /health
      • (Optionally) ensure offline mode to avoid LLM timeouts
      • POST /insight/emotion with {"text": "..."} (alias to /chat)
      • Prints top emotions + PASS/FAIL

    Usage:
      .\Test-Ariel.ps1
      .\Test-Ariel.ps1 -ServerHost 127.0.0.1 -ServerPort 8000 -TimeoutSec 10 -UseOnline
#>

[CmdletBinding()]
param(
  [string] $ServerHost = "127.0.0.1",
  [int]    $ServerPort = 8000,
  [double] $TimeoutSec = 10,
  [switch] $UseOnline,
  [string] $Message = "Please reflect my mood in 3 words."
)

$ErrorActionPreference = "Stop"

function Write-Info($msg)  { Write-Host $msg -ForegroundColor Cyan }
function Write-OK($msg)    { Write-Host $msg -ForegroundColor Green }
function Write-Warn($msg)  { Write-Host $msg -ForegroundColor Yellow }
function Write-Err($msg)   { Write-Host $msg -ForegroundColor Red }

$base = ("http://{0}:{1}" -f $ServerHost, $ServerPort)

# --- 1) Health ---------------------------------------------------------------
Write-Info ("[1/3] GET {0}/health" -f $base)
try {
  $h = Invoke-WebRequest -Uri ($base + "/health") -TimeoutSec $TimeoutSec
  $hjson = $h.Content | ConvertFrom-Json
  if (-not $hjson.ok) { throw "ok=false" }
  Write-OK ("health: 200; build={0}; model={1}; online_mode={2}" -f $hjson.build, $hjson.model, $hjson.online_mode)
} catch {
  Write-Err ("health failed: {0}" -f $_.Exception.Message)
  exit 1
}

# --- 2) Ensure offline (unless -UseOnline set) ------------------------------
if (-not $UseOnline.IsPresent) {
  try {
    if ($hjson.online_mode -eq $true) {
      Write-Info "[2/3] POST /toggle_llm (turn offline to avoid timeouts)"
      Invoke-WebRequest -Method POST -Uri ($base + "/toggle_llm") -TimeoutSec $TimeoutSec | Out-Null
      $h2 = (Invoke-WebRequest -Uri ($base + "/health") -TimeoutSec $TimeoutSec).Content | ConvertFrom-Json
      Write-OK ("online_mode -> {0}" -f $h2.online_mode)
    } else {
      Write-Info "[2/3] Already offline; skipping toggle"
    }
  } catch {
    Write-Warn ("toggle_llm check failed: {0}" -f $_.Exception.Message)
  }
} else {
  Write-Info "[2/3] Staying in online mode by request"
}

# --- 3) Emotion alias → /insight/emotion ------------------------------------
Write-Info ("[3/3] POST {0}/insight/emotion" -f $base)
$body = @{ text = $Message } | ConvertTo-Json
try {
  $resp = Invoke-WebRequest -Method POST -Uri ($base + "/insight/emotion") -Body $body -ContentType 'application/json' -TimeoutSec $TimeoutSec
  $j = $resp.Content | ConvertFrom-Json
} catch {
  Write-Err ("emotion alias failed: {0}" -f $_.Exception.Message)
  exit 1
}

# Find emotions in either top-level or memory_token
$em = $null
if ($j.top_emotions) {
  $em = $j.top_emotions
} elseif ($j.memory_token -and $j.memory_token.top_emotions) {
  $em = $j.memory_token.top_emotions
}

if (-not $em) {
  Write-Warn "No 'top_emotions' found in response. Raw preview:"
  $preview = $resp.Content.Substring(0, [Math]::Min(220, $resp.Content.Length))
  Write-Host $preview
  exit 1
}

Write-OK "Top emotions:"
foreach ($e in $em) {
  # handle both {label, score} and {label, value}
  $score = if ($e.score -ne $null) { $e.score } else { $e.value }
  Write-Host ("  {0,-10} {1:N2}" -f $e.label, [double]$score)
}

Write-OK "`nPASS"
exit 0
