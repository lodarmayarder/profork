# PROFORK Windows YouTube TV Installer (Admin Required)
# VERSION=r3a (ASCII Safe)

# --- Check for admin rights ---
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Relaunching with admin rights..."
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"& {&'$PSCommandPath'}`"" -Verb RunAs
    exit
}

# --- Configuration ---
$AppName     = "YouTube TV"
$FolderName  = "yttv"
$BaseDir     = "${env:ProgramFiles(x86)}\pro"
$InstallPath = "$BaseDir\$FolderName"
$ZipURL      = "https://github.com/matthewruzzi/Nativefier-YouTube-on-TV-for-Desktop/releases/latest/download/YouTubeonTV-win32-x64.zip"
$ZipFile     = "$env:TEMP\$FolderName.zip"
$ExeName     = "YouTube on TV.exe"
$ShortcutPath= "$env:PUBLIC\Desktop\$AppName.lnk"

# --- Installation notice ---
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " PROFORK - YouTube TV Installer" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "This will install YouTube TV to:" -ForegroundColor Gray
Write-Host "  $InstallPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "A shortcut will be added to the Desktop and Start Menu." -ForegroundColor Gray
Write-Host "Downloading from:" -ForegroundColor Gray
Write-Host "  $ZipURL" -ForegroundColor DarkGray
Write-Host "Scripted by github.com/profork/profork" -ForegroundColor DarkGray
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# --- Show loading dots ---
Write-Host "Preparing environment..." -NoNewline
for ($i = 0; $i -lt 10; $i++) {
    Write-Host "." -NoNewline
    Start-Sleep -Milliseconds 100
}
Write-Host "`n"

# --- Create install directory ---
New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null

# --- Download and extract ---
Write-Host "Downloading ZIP..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $ZipURL -OutFile $ZipFile -UseBasicParsing

Write-Host "Extracting files..." -ForegroundColor Yellow
Expand-Archive -Path $ZipFile -DestinationPath $InstallPath -Force

# --- Flatten subfolder if needed ---
$subfolder = Get-ChildItem -Path $InstallPath -Directory | Select-Object -First 1
if ($subfolder) {
    Move-Item -Path (Join-Path $subfolder.FullName '*') -Destination $InstallPath -Force
    Remove-Item "$($subfolder.FullName)" -Recurse -Force
}
Remove-Item $ZipFile -Force

# --- Create desktop shortcut ---
if (Test-Path $ShortcutPath) { Remove-Item $ShortcutPath -Force }
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "$InstallPath\$ExeName"
$Shortcut.WorkingDirectory = "$InstallPath"
$Shortcut.IconLocation = "$InstallPath\$ExeName"
$Shortcut.Save()

# --- Add to Start Menu ---
Copy-Item $ShortcutPath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$AppName.lnk" -Force

# --- Finish ---
Write-Host "`nYouTube TV has been installed to:" -ForegroundColor Green
Write-Host "$InstallPath"
Write-Host "`nShortcut added to Desktop and Start Menu." -ForegroundColor Green
Write-Host "Done." -ForegroundColor Green
