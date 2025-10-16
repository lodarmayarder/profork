## For ROCKNIX-Apps -- go to https://github.com/profork/ROCKNIX-apps




NOTE for V42 -- Due to python rewrites by batocera devs Custom ES system launchers need a video mode resolution manually set in system settings as blank values are no longer tolerated via the python configgen launchers for custom settings running .sh files.
E.G.: set like below to your resolution instead of using "auto"
<img width="1431" height="123" alt="image" src="https://github.com/user-attachments/assets/4b8af628-11ec-47c4-8fd5-6861147559a1" />

🚀Recents:
* PolyMC Launcher added to Arch Container
* Added Java 21 to Java runtime installer
* PCSX2-Custom Latest build added for All versions of Batocera (x86_64)--Note: The other PS2plus entry is the legacy version from Batocera.pro that only works on v40 and lower before python rewrites
* SMB Remastered (Linux x86_64) added to Standalone app section
* Minor Bugfixes
* Spaghettikart Installer added to x86_64 Standalone app section (aarch64 can use portmaster)
* Changed Youtube-TV to Vacuumtube (Adblock+more options - x86-64/aarch64)
* Fixed/Changed Youtube Music to new URL (x86-64/aarch64)
* Added Steam aarch64/ARM64 runimage (6-8gb recommended minimum)
* Firefox added for aarch64
* Added Docker+Containers for aarch64
* Added 4K Geforce Now installer to Multi-app container as addon (AMD Only)
* Added Emudeck Store Homebrew and Reg-Linux Homebrew Rom installer (x86_64 and aarch64)
* Arch XFCE desktop (runimage) -- Launches from ports -- Added to Standalone apps (x86_64 and aarch64) -- Pacman, Chaotic-AUR work fine inside. No Overlay mods. Not a vnc/remote docker session.
   <img width="1916" height="1048" alt="image" src="https://github.com/user-attachments/assets/045079b1-bc09-4c95-ab8f-e4beab0c67bc" />


# Installer/Menu via Terminal/SSH
```
curl -L bit.ly/profork0 | bash
```






# Arch Multi-App Container via ES



| Application                    | Description                                |
|--------------------------------|--------------------------------------------|
| **Boilr**                      | Steam third-party app add tool            |
| **Bottles**                    | Wine/Proton GUI Launcher                  |
| **Brave**                      | Privacy-focused web browser               |
| **Chiaki**                     | Open-source PS4/5 Remote Play client      |
| **Emudeck Addon**              | Emulator/Rom manager for Steam/ES-DE      |
| **FileManager-PCManFM**        | Lightweight file manager                  |
| **Filezilla**                  | FTP, FTPS, and SFTP client                |
| **Firefox**                    | Open-source web browser                   |
| **Flatpak-Config**             | Configure and manage Flatpak inside container  |
| **Geforce Now**                | Nvidia's cloud gaming platform            |
| **Google-Chrome**              | Popular web browser by Google             |
| **Greenlight**                 | Xbox Remote Play/Xcloud client            |
| **Heroic Game Launcher**       | Alternative Epic Games Store, GOG, Amazon Games, launcher     |
| **Lutris**                     | Open-source gaming platform               |
| **Microsoft-Edge**             | Web browser by Microsoft                  |
| **Moonlight**                  | Game streaming client      |
| **Minecraft-Bedrock**          | Cross-platform Minecraft version          |
| **OBS Studio**                 | Open-source streaming and recording tool  |
| **Parsec**                     | Game streaming client                     |
| **Peazip**                     | File archiver and compressor              |
|  **Protonup-Qt**                | Install and manage Proton-GE builds      |
| **Smplayer**                   | Media player with codecs                  |
| **Spotify**                    | Music streaming platform                  |
| **Steam Diagnostic**           | Diagnostic tools for Steam                |
| **Steam**                      | Popular gaming platform                   |
| **SteamTinker Launch (settings)** | Advanced Steam game tweaks and mods    |
| **Shadps4**                    | PS4 Emulator                              |
| **Sunshine**                   | Streamer Host for Moonlight Clients       |
| **Terminal-Tabby**             | Modern, feature-rich terminal emulator    |
| **TigerVNC**                   | VNC server and client                     |
| **VLC**                        | Open-source media player                  |
| **WebApps Addon**              | Add your own Natifivfied Electron or Chrome apps to ES | 
| **WineGUI**                    | GUI tools for Wine configuration          |



# Demo of multi-app arch container Desktop Mode by Arcadematicas
https://www.youtube.com/watch?v=C_-Ij5ADUPw
 


# Standalone Apps*
*(Note: NVIDIA users can Use multiapp arch container for Lutris, Bottles, Minecraft-Bedrock)

| Application                           | Description                                                   |
|---------------------------------------|---------------------------------------------------------------|
| **2SHIP2HARKINIAN**                   | Open-Source port of Majora's Mask Engine                     |
| **7ZIP**                              | File archiver with a high compression ratio                  |
| **AETHERSX2**                         | PS2 Emulator for ARM DEVICES (HIGH-END)
| **ALTUS**                             | Desktop client for Google Meet and messaging services        |
| **AMAZON-LUNA**                       | Amazon's cloud gaming service (ARM64 Available)              |
| **ANTIMICROX**                        | Gamepad mapping and customization tool                       |
| **APPLEWIN/WINE**                     | Apple II emulator                                            |
| **ARCADE-MANAGER**                    | ROM management Tool                                          |
| **ARCH-XFCE-DESKTOP-MODE**            | Full Arch container in Runimage -- Launches from Ports (ARM64 Available)    |
| **ATOM**                              | Hackable text editor for developers                          |
| **BALENA-ETCHER**                     | Flash OS images to USB drives and SD cards                   |
| **BLENDER**                           | Open-source 3D modeling and animation tool                   |
| **BOTTLES/AMD-INTEL-GPUS-ONLY**       | Manage and run Windows apps using Wine/proton                |
| **BRAVE**                             | Privacy-focused web browser                                  |
| **CHIAKI-NG**                         | Open-source PS4/PS5 Remote Play client (ARM64 also available) |
| **CHROME**                            | Popular web browser by Google                                |
| **CHROMIUM**                          | Chromium Web Browser (ARM64 Only)                            |
| **CLONE HERO**                        | Guitar/Music Game                                            |
| **CPU-X**                             | System profiling and monitoring application                  |
| **DISCORD**                           | Voice, video, and text chat app                              |
| **EDGE**                              | Web browser by Microsoft                                     |
| **ENDLESS-SKY**                       | Free open-world space exploration game                       |
| **FERDIUM**                           | Messaging app with support for multiple platforms            |
| **FILEZILLA**                         | FTP, FTPS, and SFTP client                                   |
| **FIREFOX**                           | Open-source web browser (ARM64 available)                    |
| **FOOBAR2000**                        | Lightweight and customizable audio player                    |
| **GEFORCENOW**                        | Nvidia's cloud gaming service                                |
| **GIMP**                              | GNU Image editor                                             |
| **GREENLIGHT**                        | Xbox and Xcloud Remote Play Streamer (ARM64 Available)        |
| **HANDBRAKE**                        |  Video transcoding tool
| **HARD-INFO**                         | System information and benchmark tool                        |
| **HYPER**                             | Modern, extensible terminal emulator                        |
| **JAVA-RUNTIME**                      | Java runtime environment                                     |
| **KDENLIVE**                          | Open-source video editing software                           |
| **KITTY**                             | Fast and feature-rich terminal emulator                     |
| **KSNIP**                             | Screenshot tool with annotation features                     |
| **KRITA**                             | Professional digital painting and illustration software      |
| **LIBREWOLF**                         | Librewolf Web Browser (ARM64 Also Available)                           |
| **LUANTI**                            | a.k.a. Minetest - Open source voxel Game engine (free minecraft clone) |
| **LUDUSAVI**                          | Save game manager and backup tool                           |
| **LUTRIS/AMD-INTEL-GPUS-ONLY**        | Open-source gaming platform                                  |
| **MEDIAELCH**                         | Media manager for movies and TV shows                       |
| **MINECRAFT-BEDROCK-EDITION**         | **USE Multiapp Arch container**                              |
| **MINECRAFT-JAVA-EDITION**            | Java-based version of Minecraft                             |
| **MOONLIGHT**                         | Open-source game streaming client for Sunshine/Geforce streaming  |
| **MPV**                               | Lightweight media player                                     |
| **MULTIMC-LAUNCHER**                  | Custom launcher for Minecraft mod versions                   |
| **MUSEEKS**                           | Lightweight and cross-platform music player                 |
| **NVTOP**                             | Real-time GPU usage monitoring tool                         |
| **ODIO**                              | Free streamimg music app                                    |
| **OLIVE**                             | Open-source video editing tool                              |
| **OPENGOAL Launcher**                 | PC Engine for Jax n' Daxter/Jak2/Jak3   
| **OPERA**                             | Web browser with integrated VPN and ad blocker              |
| **PARSEC**                            | Parsec Streaming
| **PCSX2 CUSTOM**                      | Latest version of PCSX2 for All versions of Batocera x86_64 |
| **PEAZIP**                            | File archiver and compression utility                       |
| **PLEXAMP**                           | Music player for Plex users                                 |
| **PROTONUP-QT**                       | Manage Proton-GE builds for Linux gaming                    |
| **PS2MINUS/Works Up to v40**          | Older v1.6 (wx) version of the PCSX2 emulator for older machines  |
| **PS2PLUS/Works Up to v40**           | Latest version of the PCSX2 emulator                        |
| **PS3PLUS/Works Up to v40**           | Latest version of RPCS3 PlayStation 3 emulator              |
| **PS4**                               | ShadPS4 Emulator for v40+                                  |
| **QBITTORRENT**                       | Torrent Client                                             |
| **SAYONARA**                          | Lightweight music player                                   |
| **SHIP-OF-HARKINIAN**                 | Open-source port of Ocarina of Time Engine                 |
| **SHEEPSHAVER**                       | PowerPC Mac emulator                                       |
| **SMPLAYER**                          | Media player with built-in codecs                          |
| **SPAGHETTIKART**                     | Open source prot of Mario Kart 64 Engine                   |
| **STARSHIP**                          | Open Source port of Starfox 64 Engine
| **STEAM**                             | Valve's Popular gaming platform                            |
| **STRAWBERRY-MUSIC-PLAYER**           | Music player with support for large libraries              |
| **SUBLIME-TEXT**                      | Text editor for code, markup, and prose                    |
| **SUNSHINE** (flatpak ver in tools menu)      | Open-source game streaming software                        |
| **TABBY**                             | Modern, highly configurable terminal emulator              |
| **SUPER MARIO BROS. REMASTERED**       | Open source Remastered version of SMB                      |
| **TELEGRAM**                          | Messaging app                                              |
| **TOTAL-COMMANDER**                   | File manager with advanced features                        |
| **UNLEASHED-RECOMP**                  | Sonic Unleashed engine for PC                               |
| **VIVALDI**                           | Customizable web browser                                   |
| **VLC**                               | Open-source media player                                   |
| **WHATSAPP**                          | Messaging app                                              |
| **WIIUPLUS/NEWEST-CEMU/Works Up to v40**     | Wii U emulator                                      |      
| **XCLOUD**                            | Electron based Xcloud client (Gamepad Navigatable) (ARM64 Available  |
| **X-MINECRAFT-LAUNCHER**              | Minecraft Launcher (EXPERIMENTAL/ARM64)                   |
| **WPS-OFFICE**                        | Office suite                                              |
| **YOUTUBE-MUSIC**                     | Streaming app for YouTube Music (ARM64 also available)     |
| **YOUTUBE-TV**                        | Streaming app for Youtube with TV UI (ARM64 also available)  |


# Docker Applications

| Application                                | Description                                                   |
|--------------------------------------------|---------------------------------------------------------------|
| **ANDROID/BLISS-OS/DOCKER/QEMU**           | Android-based Bliss OS running in Docker (no audio/GPU acceleration support)|
| **CASAOS/DOCKER**                          | CasaOS (Docker App GUI Front-End & Installer in docker (Recommended Version)|                       
| **CASAOS/CONTAINER/DEBIAN/XFCE**           | CasaOS container with a Debian XFCE desktop environment       |
| **EMBY-SERVER/DOCKER**                     | Media server for managing and streaming personal media        |
| **JELLYFIN-SERVER/DOCKER**                 | Open-source media server for streaming and organizing media   |
| **LINUX-DESKTOPS-VNC/RDP/DOCKER**          | Dockerized Linux desktops with WebVNC or RDP access          |
| **LINUX-QEMU-VMs**                         | Linux VMS via Web VNC                                        |
| **NETBOOT-XYZ-SERVER/DOCKER**              | Netboot.xyz server for network-based booting                 |
| **NEXTCLOUD-SERVER/DOCKER**                | Private cloud server for file storage and sharing            |
| **PLEX-SERVER/DOCKER**                     | Popular media server for streaming and managing personal media |
| **DOCKER/PODMAN/PORTAINER**                | Tools for managing containers, including Docker, Podman, and Portainer |
| **WINDOWS-VMS/DOCKER**                     | Docker-based Windows virtual machines accessible via RDP and VNC    |
| **SYSTEMTOOLS-WETTY-GLANCES-FILEMANAGER**  | System tools container including Wetty, Glances, and a file manager |
| **UMBRELOS/DOCKER**                        | UmbrelOS (Docker App GUI Front-End installer) in Docker|





# How to Remove:  
1. Arch container - Run the uninstaller in the arch menu.  Data folders like `/userdata/system/.local/share/Steam` are not deleted and need to be done separately. Their locations vary.
2. Standalone Apps - delete the corresponding folder in `/userdata/system/pro` and .sh file in ports folder if applicable. The F1 icon should disappear after rebooting. App Data folder locations in `/userdata/system` vary.
3. CasaOS XFCE Debian container - delete the batocera-casaos file and casaos folder in `/userdata/system` and remove launcher editing out from `/userdata/system/custom.sh`
4. Docker apps - just use portainer gui or docker cli to remove individual docker containers or to remove completely: Remove batocera-containers by editing out from custom.sh in `/userdata/system`. Reboot.  Delete the `/userdata/system/batocera-containers` `/userdata/system/container` and `/userdata/system/var/lib/containers` and `conatinerd`  Data folders can also be deleted manually like the casaos or umbrel folder in `/userdata/system`.

## 📌 Batocera and Third-Party Add-ons: What You Should Know  

Batocera’s own wiki provides guides on system customization, yet **recent versions now detect and flag users who install third-party add-ons.**  

If you use this repo, **your Batocera version may display additional markers in the version string**:  
- **"P"** – If the `/userdata/system/pro` folder exists (this repo).  
- **"C"** – If `custom.sh` is modified.  
- **"U"** – If third-party EmulationStation add-on custom systems are installed.  
- **"O"** – If the Overlay is modified.





⚠️ **This may affect support** – Batocera developers have stated they "cannot support modified systems," **even if an issue is unrelated to add-ons.**  

While customization has always been part of open-source philosophy, **users should be aware of these changes in how Batocera handles third-party modifications.**  
This repository is designed to **provide additional functionality for those who wish to expand their system beyond Batocera's default setup.**  

---
### 🔧 Built for Tinkerers — Not a Helpdesk
Feel free to explore the tools, scripts, and extras — they’re here for people who like getting their hands dirty.
If you’ve ever opened a terminal on purpose, you’ll be just fine.

Not chasing stars. Not feeding the YouTube hype train.
No sponsored drama. No secret menus -- but a little humor. Just functional stuff that works.

Don’t expect a helpdesk, and please, no feature wishlists.
This is a project by and for people who fix their own problems — and maybe even enjoy doing so.

If that’s your vibe — welcome. Dual Installs with the other addon site are not recommended as conflicts can occur.

AND: Please PI SBC users, don't expect a magical script to make PS2 work on your potato 🍟. 
(well, at Least Orange PI 5 RK3588 users can use Rocknix with libmali support.😉) 

---
### 🤔 What About Security?  

This repository follows standard open-source principles—**all scripts are fully accessible, modifiable, and auditable by users.**  

- **Transparency:** Every script is available for review before running.  
- **Customization:** Users have full control over modifications to their system.  
- **Fixes:** Some scripts exist to address long-standing Batocera issues that would otherwise remain unresolved.  

While Batocera developers have **expressed concerns about third-party scripts**, open-source software is about **choice, not restriction.**  
  

---

## 🙌 Thanks

Thanks to **Uureel/batocera.pro** for much of the original scripting foundation — and for giving me the opportunity to collaborate early on by contributing to his repo. Many of the features, scripts, and launchers found in this project were first developed or refined during that shared effort.

Also big thanks to **Kron4ek/Conty** for the **Conty (Arch) container**, and to **IVAN-HC**, **PKG-Forge**, and **Srevinsaju** for their AppImage builds that made integration smoother.

Standalone apps typically list Origin via install scripts. See upstream software source regarding any other licenses.


---

**Disclaimer:** This repository is an independent project and is not affiliated with or endorsed by Batocera. All opinions expressed here are based on publicly available information and personal experience.

© 2023–2025 Profork/Cliffy (trashbus99) — All rights reserved under custom licensing terms.
GPLv3 license revoked for unauthorized forks per Section 8. See LICENSE.md
