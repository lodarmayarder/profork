$temp = "$env:TEMP\yttv-installer.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/profork/profork/master/youtubetv/yttv.ps1" -OutFile $temp -UseBasicParsing
Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$temp`""
