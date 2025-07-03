# PROFORK Windows YouTube TV Installer (Admin Required)
# VERSION=r3

# ---------------------------
# Elevation check
# ---------------------------
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Relaunching with admin rights..."
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"& {&'$PSCommandPath'}`"" -Verb RunAs
    exit
}

# ---------------------------
# Configuration
# ---------------------------
$AppName     = "YouTube TV"
$FolderName  = "yttv"
$BaseDir     = "${env:ProgramFiles(x86)}\pro"
$InstallPath = "$BaseDir\$FolderName"
$ZipURL      = "https://github.com/matthewruzzi/Nativefier-YouTube-on-TV-for-Desktop/releases/latest/download/YouTubeonTV-win32-x64.zip"
$ZipFile     = "$env:TEMP\$FolderName.zip"
$ExeName     = "YouTube on TV.exe"
$ShortcutPath= "$env:PUBLIC\Desktop\$AppName.lnk"

# ---------------------------
# Display install notice
# ---------------------------
function Show-InstallNotice {
    $lines = @(
        "╔════════════════════════════════════════════════════╗",
        "║            PROFORK - YOUTUBE TV INSTALLER         ║",
        "╠════════════════════════════════════════════════════╣",
        "║  This will install 'YouTube TV' into:             ║",
        "║     C:\Program Files (x86)\pro\yttv               ║",
        "║                                                  ║",
        "║  A desktop shortcut will be created.              ║",
        "║  A Start Menu entry will also be added.           ║",
        "║                                                  ║",
        "║  Downloaded from:                                 ║",
        "║   github.com/matthewruzzi/...                     ║",
        "║   installer by github.com/profork/profork         ║",
        "╚════════════════════════════════════════════════════╝"
    )

    foreach ($line in $lines) {
        Write-Host $line -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
    }

    Write-Host ""
    Start-Sleep -Seconds 1
}
Show-InstallNotice

# ---------------------------
# Show loading dots
# ---------------------------
Write-Host "`nPreparing environment..." -NoNewline
for ($i = 0; $i -lt 10; $i++) {
    Write-Host "." -NoNewline
    Start-Sleep -Milliseconds 100
}
Write-Host "`n"

# ---------------------------
# Create install directory
# ---------------------------
New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null

# ---------------------------
# Download and extract ZIP
# ---------------------------
Write-Host "Downloading package..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $ZipURL -OutFile $ZipFile -UseBasicParsing

Write-Host "Extracting to: $InstallPath" -ForegroundColor Yellow
Expand-Archive -Path $ZipFile -DestinationPath $InstallPath -Force

# Flatten if ZIP unpacks into subfolder
$subfolder = Get-ChildItem -Path $InstallPath -Directory | Select-Object -First 1
if ($subfolder) {
    Move-Item -Path (Join-Path $subfolder.FullName '*') -Destination $InstallPath -Force
    Remove-Item "$($subfolder.FullName)" -Recurse -Force
}

Remove-Item $ZipFile -Force

# ---------------------------
# Create desktop shortcut
# ---------------------------
if (Test-Path $ShortcutPath) { Remove-Item $ShortcutPath -Force }
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "$InstallPath\$ExeName"
$Shortcut.WorkingDirectory = "$InstallPath"
$Shortcut.IconLocation = "$InstallPath\$ExeName"
$Shortcut.Save()

# ---------------------------
# Optional: Add to Start Menu
# ---------------------------
Copy-Item $ShortcutPath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$AppName.lnk" -Force

# ---------------------------
# Finish
# ---------------------------
Write-Host "`n✅ $AppName installed successfully to:" -ForegroundColor Green
Write-Host "   $InstallPath"
Write-Host "`n📌 A shortcut has been added to the desktop and Start Menu."
Write-Host "`nEnjoy!"
