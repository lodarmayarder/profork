#!/bin/bash
echo
echo "-----------------------------------------"
echo "RUNNING ADDITIONAL BATOCERA CONTY PATCHES"
echo "-----------------------------------------"
echo
#--------------------------------------------------------------------------------------------
# prepare/preload
#	echo -e "\n\n\nfixing nvidia ld.so.cache"
#		rm /usr/bin/prepare 2>/dev/null
#		rm /usr/bin/preload 2>/dev/null
#			wget -q --tries=30 -O /usr/bin/prepare "https://github.com/profork/profork/raw/master/steam/build/prepare.sh"
#				dos2unix /usr/bin/prepare 2>/dev/null 
#					cp /usr/bin/prepare /usr/bin/preload 2>/dev/null
#--------------------------------------------------------------------------------------------
fix for nvidia lutris
	echo -e "\n\n\nfixing lutris"
		mkdir -p /opt 2>/dev/null 
		rm -rf /opt/lutris 2>/dev/null
		cd /opt
			git clone https://github.com/lutris/lutris
			sed -i 's,os.geteuid() == 0,os.geteuid() == 888,g' /opt/lutris/lutris/gui/application.py 2>/dev/null
			cp $(which lutris) /usr/bin/lutris-git 2>/dev/null
			rm $(which lutris) 2>/dev/null
			  wget -q --tries=30 --no-check-certificate --no-cache --no-cookies -O /usr/bin/lutris https://github.com/profork/profork/raw/master/steam/build/lutris.sh
				  dos2unix /usr/bin/lutris 2>/dev/null
#--------------------------------------------------------------------------------------------
# add ~/.bashrc&profile env
	echo -e "\n\n\nfixing .bashrc and .profile"
		rm ~/.bashrc
			echo '#!/bin/bash' >> ~/.bashrc
			echo 'ulimit -H -n 819200 && ulimit -S -n 819200 && sysctl -w fs.inotify.max_user_watches=8192000 vm.max_map_count=2147483642 fs.file-max=8192000 >/dev/null 2>&1' >> ~/.bashrc
			echo 'export XDG_CURRENT_DESKTOP=XFCE' >> ~/.bashrc
			echo 'export DESKTOP_SESSION=XFCE' >> ~/.bashrc
			echo 'export DISPLAY=:0.0' >> ~/.bashrc
			echo 'export GDK_SCALE=1' >> ~/.bashrc
			echo 'export USER=root' >> ~/.bashrc
				dos2unix ~/.bashrc 2>/dev/null
#--------------------------------------------------------------------------------------------
# add fakeid
	f=/usr/bin/fakeid
		echo '#!/bin/bash' >> "$f"
		echo 'echo 888' >> "$f"
			dos2unix "$f" 2>/dev/null
			chmod 777 "$f" 2>/dev/null
#--------------------------------------------------------------------------------------------
# fix for winestaging bork
	echo -e "\n\n\nfixing paths for wine staging"
		rm -rf /lib32 2>/dev/null
		rm -rf /share 2>/dev/null
			ln -sf /usr/lib32 /lib32
			ln -sf /usr/share /share
#--------------------------------------------------------------------------------------------
# fix borked faudio repo
	echo -e "\n\n\nfixing faudio staging"
		yes "Y" | pacman -S gstreamer
		yes "Y" | pacman -S faudio
			cd /tmp/
				f=/tmp/lib32faudio.pkg.tar.zst
				#link=https://builds.garudalinux.org/repos/chaotic-aur/x86_64/lib32-faudio-tkg-git-24.02.r0.g38e9da7-1-x86_64.pkg.tar.zst
				link=https://github.com/profork/profork/raw/master/steam/build/lib32-faudio-tkg-git.pkg.tar.zst
					wget -q --show-progress --tries=30 -O "$f" "$link"
					yes "Y" | pacman -U "$f" --overwrite='*' && rm "$f"
			cd ~/
#--------------------------------------------------------------------------------------------
# add tabby 
	echo -e "\n\n\nadding tabby"
		cd /tmp/ 
			f=/tmp/tabby.pacman
			link=https://github.com/Eugeny/tabby/releases/download/v1.0.205/tabby-1.0.205-linux-x64.pacman
				wget -q --show-progress --tries=30 -O "$f" "$link" 
					yes "Y" | pacman -U "$f" --overwrite='*' && rm "$f"
		cd ~/
#--------------------------------------------------------------------------------------------
# add nativefier
	echo -e "\n\n\nadding nativefier"
		if [[ "$(which node)" != "" ]] && [[ "$(which npm)" != "" ]]; then
			npm install -g nativefier
		fi
#--------------------------------------------------------------------------------------------
# add fightcade2
#	echo -e "\n\n\nadding fightcade2..."
#	pacman -R fightcade2 2>/dev/null
#		link="https://www.fightcade.com/download/linux"
#		p=/opt/fightcade2
#		t=/tmp/fc2
#		f="$t/file"
#			rm -rf $p $t 2>/dev/null
#			mkdir -p $p $t 2>/dev/null
#			cd $t
#			wget -q --show-progress --tries=30 -O "$f" "$link"
#			tar -xf "$f"
#			cd ${PWD}/*/
#			cp -r ${PWD}/* $p/
#			cd $p 
#			rm -rf $t
#				if [[ -f "${p}"/Fightcade2.sh ]]; 
#					then
#					ln -sf "${p}"/Fightcade2.sh /usr/bin/fightcade 2>/dev/null
#					echo "added fightcade2 latest realease"
#				fi
#--------------------------------------------------------------------------------------------
## Add VacuumTube AppImage (latest release)
link=$(curl -s https://api.github.com/repos/shy1132/VacuumTube/releases/latest \
        | jq -r '.assets[]
                  | select(.name|test("x86_64.*\\.AppImage$"))
                  | .browser_download_url' \
        | head -n1)

if [[ -z $link ]]; then
  echo "❌  No x86-64 AppImage found in latest release."
  exit 1
fi

echo "Downloading VacuumTube from: $link"
wget --tries=50 --no-check-certificate --no-cache --no-cookies \
     -O /usr/bin/vacuumtube "$link"
chmod +x /usr/bin/vacuumtube
echo "✅  VacuumTube installed to /usr/bin/vacuumtube"


#------------------------------------------------------------------------------------
# Install/upgrade XStreamingDesktop AppImage (latest release)
#
set -euo pipefail

REPO="Geocld/XStreamingDesktop"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  PAT='(x86_64.*\.AppImage$|\.AppImage$)' ;;   # repo ships a generic AppImage
  aarch64) PAT='(arm64.*\.AppImage$|aarch64.*\.AppImage$|\.AppImage$)' ;;
  *)       echo "❌ Unsupported arch: $ARCH" ; exit 2 ;;
esac

asset=$(curl -fsSL "$API_URL" \
          | jq -r --arg re "$PAT" '.assets[]
                   | select(.name | test($re))
                   | .browser_download_url' \
          | head -n1)

if [[ -z $asset ]]; then
  echo "❌ No AppImage for $ARCH found in the latest release."
  exit 1
fi

echo "⬇️  Downloading XStreamingDesktop from: $asset"
install -Dm755 <(curl -fsSL --retry 5 "$asset") /usr/bin/xstreaming
echo "✅  XStreamingDesktop installed to /usr/bin/xstreaming"


#--------------------------------------------------------------------------------------------

# Install xcloud 
#
set -euo pipefail

ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
  echo "❌  xloud  distributes only an x86-64 AppImage. Unsupported arch: $ARCH"
  exit 2
fi

URL="https://github.com/marzeq/xbox-cloud-gaming-electron/releases/download/1.0.20/xbox-cloud-gaming-electron_1.0.20.AppImage"

echo "⬇️  Downloading Xcloud from: $URL"
install -Dm755 <(curl -fsSL --retry 5 "$URL") /usr/bin/xcloud
echo "✅  Xcloud installed to /usr/bin/xcloud"




#--------------------------------------------------------------------------------------------

# Install Sheepshaver 
#
set -euo pipefail

ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
  echo "❌  xloud  distributes only an x86-64 AppImage. Unsupported arch: $ARCH"
  exit 2
fi

URL="https://github.com/Korkman/macemu-appimage-builder/releases/download/continuous/SheepShaver-x86_64.AppImage"

echo "⬇️  Downloading sheepshaver from: $URL"
install -Dm755 <(curl -fsSL --retry 5 "$URL") /usr/bin/sheepshaver
echo "✅  sheepshaver installed to /usr/bin/sheepshaver"

#-------------------------------------------------------------------------------------------
# Install Sheepshaver 
#
set -euo pipefail

ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
  echo "❌  xloud  distributes only an x86-64 AppImage. Unsupported arch: $ARCH"
  exit 2
fi

URL="https://github.com/Korkman/macemu-appimage-builder/releases/download/continuous/BasiliskII-x86_64.AppImage"

echo "⬇️  Downloading sheepshaver from: $URL"
install -Dm755 <(curl -fsSL --retry 5 "$URL") /usr/bin/basillisk2
echo "✅  Basilisk II installed to /usr/bin/basillisk2"

https://github.com/Korkman/macemu-appimage-builder/releases/download/continuous/BasiliskII-x86_64.AppImage

#----------------------------------------------------------------------------------------

# run additional rootpatches/fixes
	echo -e "\n\n\nfixing root apps"
		sed -i 's,/opt/google/chrome/google-chrome,/opt/google/chrome/google-chrome --no-sandbox --test-type,g' /usr/bin/google-chrome-stable 2>/dev/null
		sed -i 's,/opt/spotify/spotify,/opt/spotify/spotify --no-sandbox --test-type,g' /usr/bin/spotify 2>/dev/null
		sed -i '/<description>.*<\/description>/d' /etc/fonts/fonts.conf 2>/dev/null
		sed -i '/<description>.*<\/description>/d' /etc/fonts/conf.d/* 2>/dev/null
			cd /usr/lib
			rm $(find /usr/lib | grep nvidia) 2>/dev/null
			cd /usr/lib32 
			rm $(find /usr/lib32 | grep nvidia) 2>/dev/null
			find . -path ./python\* -prune -o -type f -name \*nvidia\* -exec rm {} +
   				yes "Y" | pacman -S libnvidia-container nvidia-container-toolkit --overwrite='*'
					useradd -r -d /var/lib/libvirt -s /bin/false libvirt-qemu
					usermod -a -G kvm libvirt-qemu
#--------------------------------------------------------------------------------------------
# fix samba collisions 
	echo -e "\n\n\nfixing samba"
		rm /usr/bin/samba* 2>/dev/null
		rm /usr/bin/smb* 2>/dev/null
		rm -rf ~/build 2>/dev/null
#--------------------------------------------------------------------------------------------
# purge baloo 
	echo -e "\n\n\npurging baloo"
		rm /bin/baloo* 2>/dev/null &
		rm /usr/bin/baloo* 2>/dev/null &
		rm /usr/lib/baloo* 2>/dev/null &
		rm -rf  /usr/include/KF6/Baloo 2>/dev/null &
		rm $(which baloo_file_extractor) 2>/dev/null &
		rm -rf /etc/xdg/autostart/baloo* 2>/dev/null &
		rm -rf /var/lib/pacman/local/baloo* 2>/dev/null &
		rm -rf $(find /usr/lib | grep baloo) 2>/dev/null &
		rm $(find /usr/share/doc | grep baloo) 2>/dev/null &
		rm $(find /usr/share/locale | grep baloo) 2>/dev/null &
		rm -rf /usr/share/qlogging-categories6/baloo* 2>/dev/null &
		rm -rf /usr/share/dbus-1/interfaces/org.kde.baloo* 2>/dev/null &
			wait
#--------------------------------------------------------------------------------------------
# add appimage greenlight version due to borked yay builder
	#echo -e "\n\n\nadding greenlight"
	#	link=$(curl -s https://api.github.com/repos/unknownskl/greenlight/releases/latest | jq -r ".assets[] | select(.name | endswith(\".AppImage\")) | .browser_download_url" | grep AppImage)
	#		wget --tries=50 --no-check-certificate --no-cache --no-cookies -O "/usr/bin/greenlight-beta" "$link"
	#			chmod 777 /usr/bin/greenlight-beta 2>/dev/null
	#				ln -sf /usr/bin/greenlight-beta /usr/bin/greenlight 2>/dev/null
#--------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------
echo -e "\n\n\nAdding basic Pacman support"

# layout
install -d -m 755 /opt/pacman/lib/{local,sync}
install -d -m 755 /opt/pacman/cache
install -d -m 700 /opt/pacman/gnupg

# config + key-rings
cp -a /etc/pacman.conf  /opt/pacman/
cp -a /etc/pacman.d     /opt/pacman/
sed -i \
  -e 's|^DBPath.*|DBPath   = /opt/pacman/lib|' \
  -e 's|^CacheDir.*|CacheDir = /opt/pacman/cache|' \
  -e 's|^LogFile.*|LogFile  = /opt/pacman/pacman.log|' \
  -e 's|^GPGDir.*|GPGDir   = /opt/pacman/gnupg|' \
  /opt/pacman/pacman.conf

# pacman binary shuffle
if [ ! -f /usr/bin/realpacman ]; then
    mv "$(command -v pacman)" /usr/bin/realpacman
fi

cat >/usr/bin/pacman <<'EOF'
#!/bin/bash
exec /usr/bin/realpacman \
     --config   /opt/pacman/pacman.conf \
     --dbpath   /opt/pacman/lib        \
     --cachedir /opt/pacman/cache      \
     --gpgdir   /opt/pacman/gnupg      \
     "$@"
EOF
chmod +x /usr/bin/pacman
rm -f /opt/pacman/lib/db.lck

echo "Pacman patch applied successfully."

#--------------------------------------------------------------------------------------------

#--------------------------------------------------------------------# --------------------------------------------------------------------------------------------

#------------------------

# rootpatch makepkg
	sed -i 's,EUID == 0,EUID == 8888,g' $(which makepkg) 2>/dev/null
#--------------------------------------------------------------------------------------------
	rm $f 2>/dev/null
	rm $h 2>/dev/null
		ldconfig
			echo
			echo
			echo "--------"
			echo "  DONE"
			echo "--------"
			echo
			echo
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------
exit 0
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
#
# obsolete:
function libc-dthash-patch() {
	echo "fixing libc dthash"
	ver=$(ldd --version | head -n1 | rev | awk '{print $1}' | rev)
	echo -e "\n\nPREPARING LIBC $ver DT_HASH FIX FOR STEAM...\n\n"
	# prepare libc patcher
	f=/tmp/fixlibc
	rm $f 2>/dev/null
	echo '#!/bin/bash' >> $f
	echo "ver=$ver" >> $f
	echo 'mkdir ~/build 2>/dev/null && rm -rf ~/build/glibc && cd ~/build' >> $f
	echo 'git clone https://sourceware.org/git/glibc.git ~/build/glibc' >> $f
	echo 'cd ~/build/glibc' >> $f
	echo "git checkout glibc-$ver" >> $f
	echo 'mkdir ~/build/glibc/build && cd ~/build/glibc/build' >> $f
	echo 'echo -e "\n\nCONFIGURING...\n\n"' >> $f
	echo 'unset LD_LIBRARY_PATH' >> $f
	echo 'export CFLAGS="$CFLAGS -O3 -fno-stack-protector -fno-PIC -D_FORTIFY_SOURCE=0"' >> $f
	echo 'export LDFLAGS="$LDFLAGS -Wl,--hash-style=both -Wl,-z,norelro"' >> $f
	echo 'export LDFLAGS_so="-Wl,--hash-style=both -Wl,-z,norelro"' >> $f
	echo 'export LDFLAGS_rtld="-Wl,--hash-style=both -Wl,-z,norelro"' >> $f
	echo '../configure \' >> $f
	echo '    --prefix=/usr \' >> $f
	echo '    --with-headers=/usr/include \' >> $f
	echo '    --with-bugurl=https://bugs.archlinux.org/ \' >> $f
	echo '    --enable-bind-now \' >> $f
	echo '    --enable-cet \' >> $f
	echo '    --enable-kernel=4.4 \' >> $f
	echo '    --enable-multi-arch \' >> $f
	echo '    --disable-stack-protector \' >> $f
	echo '    --enable-systemtap \' >> $f
	echo '    --disable-crypt \' >> $f
	echo '    --disable-profile \' >> $f
	echo '    --disable-werror \' >> $f
	echo '    --libdir=/usr/lib \' >> $f
	echo '    --libexecdir=/usr/lib' >> $f
	echo 'echo -e "\n\nCOMPILING...\n\n"' >> $f
	echo "make -j$(nproc) 1>/dev/null 2>/dev/null" >> $f
	echo 'echo -e "\n\nINSTALLING...\n\n"' >> $f
	echo 'sudo make install 1>/dev/null 2>/dev/null' >> $f
	echo 'cd ~/' >> $f
	echo 'rm -rf ~/build/glibc' >> $f
	# run libc patcher
	dos2unix $f 2>/dev/null
	chmod 777 $f 2>/dev/null
	/tmp/fixlibc
		# confirm libc patch status
		echo "checking libc patch"
		h=/tmp/hash && rm $h 2>/dev/null
		readelf -d /usr/lib/libc.so.6 | grep 'HASH' >> $h
			function checklibcpatch() {
				if [[ "$(cat $h | grep '(HASH)')" != "" ]] && [[ "$(cat $h | grep '(GNU_HASH)')" != "" ]]; then
					echo
					echo "LIBC DT_HASH PATCHED OK!"
					echo
				else
					echo
					echo "LIBC DT_HASH PATCH FAILED..."
					echo	
				fi
			}
			checklibcpatch
}
#--------------------------------------------------------------------------------------------
#libc-dthash-patch 
#--------------------------------------------------------------------------------------------
