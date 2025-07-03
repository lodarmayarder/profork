# PROFORK Windows YouTube TV Installer (Admin Required)
# VERSION=r2

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

# --- Create install directory ---
New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null

# --- Download and extract ---
Invoke-WebRequest -Uri $ZipURL -OutFile $ZipFile -UseBasicParsing
Expand-Archive -Path $ZipFile -DestinationPath $InstallPath -Force
Remove-Item $ZipFile

# --- Create desktop shortcut ---
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "$InstallPath\$ExeName"
$Shortcut.WorkingDirectory = "$InstallPath"
$Shortcut.IconLocation = "$InstallPath\$ExeName"
$Shortcut.Save()

Write-Host "$AppName installed to: $InstallPath" -ForegroundColor Green
Write-Host "Shortcut created on Desktop."

# --- Optional: Add to Start Menu ---
 Copy-Item $ShortcutPath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$AppName.lnk"

# --- Optional: Add to Startup ---
# Copy-Item $ShortcutPath "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$AppName.lnk"
