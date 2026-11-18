# push_fiji.ps1 - Copy Fiji to multiple workstations using robocopy from local machine
#




# Get targets: try workstations.txt, otherwise prompt for comma-separated names
$workstationsFile = Join-Path $PSScriptRoot 'workstations.txt'
if (Test-Path $workstationsFile) {
    $targets = Get-Content $workstationsFile | Where-Object { $_ -and ($_ -notmatch '^\s*#') } | ForEach-Object { $_.Trim() }
} else {
    $userInput = Read-Host "Enter workstation names (comma-separated)"
    $targets = $userInput.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
}

if (-not $targets) {
    Write-Host "No targets specified." -ForegroundColor Yellow
    exit 1
}

$incomplete = @()

$pixiCache = "C:\ProgramData\pixi-cache"
$uvCache = "C:\ProgramData\pixi-cache\uv-cache"

$cred = Get-Credential
foreach ($computer in $targets) {
        Invoke-Command -ComputerName $computer -Credential $cred -ArgumentList $pixiCache, $uvCache -ScriptBlock {
            param($pixiCache, $uvCache)

            if (-not (Test-Path $uvCache)) {
                New-Item -Path $uvCache -ItemType Directory | Out-Null
            }
            [System.Environment]::SetEnvironmentVariable('PIXI_CACHE_DIR', $pixiCache, 'Machine')
            [System.Environment]::SetEnvironmentVariable('UV_CACHE_DIR', $uvCache, 'Machine')

            icacls $pixiCache /grant "Users:(OI)(CI)M" /T /Q
            }
}


Write-Host "\nDone." -ForegroundColor Cyan
