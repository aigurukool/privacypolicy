# One-time setup of the video editing toolchain on Windows.
# Run from this folder in PowerShell:  powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1
$ErrorActionPreference = "Stop"

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Host "Installing FFmpeg, yt-dlp and Node.js..."
foreach ($id in "Gyan.FFmpeg", "yt-dlp.yt-dlp", "OpenJS.NodeJS.LTS") {
  winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
}
Refresh-Path

Write-Host "Installing HyperFrames..."
npm install -g hyperframes@0.8.186
Refresh-Path
hyperframes browser ensure

$skillDest = Join-Path $HOME ".claude\skills\video-editor"
Write-Host "Copying skill to $skillDest..."
New-Item -ItemType Directory -Force -Path $skillDest | Out-Null
Copy-Item -Path (Join-Path $PSScriptRoot "*") -Destination $skillDest -Recurse -Force

$broll = Join-Path $HOME "Videos\B-Roll Library"
New-Item -ItemType Directory -Force -Path $broll | Out-Null
[Environment]::SetEnvironmentVariable("BROLL_DIR", $broll, "User")
Write-Host "B-roll library: $broll"

Write-Host ""
ffmpeg -version | Select-Object -First 1
yt-dlp --version
hyperframes --version
Write-Host "Done. Restart Claude Desktop so it picks up the new tools."
