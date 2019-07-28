#!/bin/bash
# Fedora Install Script post KDE Spin Installation
# Version 1.0 Developed by Abhisek.
# Modified and Overhauled by Sam (c) 2019
# Version 1.1

# Check If Root
if [[ ${EUID} -eq 0 ]]; then
  echo "Is root. Processing script ......."
else
  echo "Not root, this script must be run as root"
  exit 1
fi

# Copy config Files
# Added vcprompt directly, without GIT at this time, because we cannot mirror from GIT and the project will not be updated. Safe to just copy over.

if [[ -e config/.bashrc* ]]; then
    cp -f config/.bashrc* /home/sam/
    cp -f vcprompt /usr/bin/vcprompt
    chmod 755 /usr/bin/vcprompt
    chmod a+x /usr/bin/vcprompt
else
    echo "BASH configs missing"
    source .bashrc
fi
if [[ -e config/zshrc ]]; then
    cp -f config/zshrc /home/sam/.zshrc
else
    echo "ZSH config missing"
fi
if [[ -e config/Xresources ]]; then
    cp -f config/Xresources /home/sam/.Xresources
else 
    echo "XRESOURCE config missing"
fi
if [[ -e config/dnf.conf ]]; then
    cp -f config/dnf.conf /etc/dnf/
else
    echo "DNF config missing"
fi

clear
echo "Starting Font Installation........"
sleep 3

# Font installation
# 1) Google Fonts
# 2) MS Core Fonts
# 3) Patched Nerd Fonts
# 4) OSX Complete Fonts
# 5) Font Awesome

if [[ -e restricted-fonts.tar.xz ]]; then
    tar xf restricted-fonts.tar.xz -C /usr/share/fonts/
    tar xf NerdFonts.tar.xz -C /usr/share/fonts/
    cp -fr fontawesome* /usr/share/fonts/
    for d in /usr/share/fonts/*; do (cd "$d" && mkfontscale && mkfontdir ); done
    fc-cache -f
    fc-cache-64 -f
else
    echo "Font files missing"
fi

# Grub Config & Themeing
# Echo disabled temporarily as we are not sure of how it might react with the mac boot frame buffer.
# Perform direct copy of a working config

if [[ -e grub-themes.tar.xz ]]; then
    tar xf grub-themes.tar.xz -C /boot/grub2/themes/
    #echo -e "\nGRUB_GFXMODE=3840x2160x32,2560x1440x32,1920x1080x32,1366x768x32,auto\nGRUB_GFXPAYLOAD_LINUX=keep\nGRUB_THEME=\"/boot/grub2/themes/blur/theme.txt\"\nGRUB_INIT_TUNE=\"480 440 1\"\n" >>  /etc/default/grub
else
    echo "Grub themes missing"
fi
#sed -i '/GRUB_DISABLE_SUBMENU/ s/^/#/;/GRUB_TERMINAL_OUTPUT/ s/^/#/' /etc/default/grub
cp -f grub /etc/default/grub
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

clear
echo "Start System Upgrade and Complete Package Installs....."
sleep 3

# Systemic Updates
dnf clean all
dnf update --refresh -y

# Remove Unneeded KDE Programs
dnf remove *akonadi* calligra* kmail* ktorrent* konqueror* dragon* juk* falkon* kontact* akregator* subscription* -y

# Enable RPM Fusion
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

# Enable RPM Fusion Tainted for bc43, specifically :
sudo dnf install rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted -y

dnf update --refresh -y

# Broadcom Stuff, for MacBot : Please comment out if not required. Install only after RPM Fusion. 
# Not available in default repos.
dnf install broadcom-wl b43-firmware -y

# All Userland Packages
dnf install @editors @c-development @development-tools terminus-fonts* @libreoffice git wget fish mpd feh ruby-devel docker filezilla docker-compose aria2 audacious arc-theme cava ncmpcpp neovim cmatrix chromium syncthing-gtk latte-dock gimp tilix w3m ranger qalculate-kde keepassxc freshplayerplugin redshift nodejs numlockx spectre-meltdown-checker inxi hwinfo testdisk pv fuse-exfat exfat-utils apfs-fuse hfsplus-tools cowsay fortune-mod conky ddrescue hddtemp hdparm smartmontools gparted arj lzip lzop ncompress rzip sharutils unace unrar p7zip chrome-remote-desktop htop neofetch lua-socket lua-json speedtest-cli android-tools global zsh clamtk vlc smplayer mpv smplayer-themes darktable rawtherapee obs-studio audacity bluecurve-cursor-theme papirus-icon-theme numix-icon-theme-circle numix-gtk-theme breeze-cursor-theme breeze-gtk sound-theme-acoustic deepin-sound-theme libreoffice-icon-theme-papirus adwaita-qt5 qbittorrent stellarium wireshark duply flatpak -y

# Fedora DataScience Layers
# https://fedoramagazine.org/jupyter-and-data-science-in-fedora/
# 
dnf install R https://download1.rstudio.org/desktop/centos7/x86_64/rstudio-1.2.1335-x86_64.rpm python3-notebook mathjax sscg python3-seaborn python3-lxml python3-basemap python3-scikit-image python3-scikit-learn python3-sympy python3-dask+dataframe python3-nltk -y

# Copr and Remote Packages
dnf copr enable taw/Riot -y
dnf copr enable luminoso/Signal-Desktop -y
rpm --import https://dl.google.com/linux/linux_signing_key.pub
rpm --import https://zoom.us/linux/download/pubkey
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

dnf update --refresh -y

# Skype, VS Code, Team Viewer, Signal, Riot, Zoom and Google Chrome.
dnf install code https://repo.skype.com/latest/skypeforlinux-64.rpm -y
dnf install https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm -y
dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -y
dnf install https://zoom.us/client/latest/zoom_x86_64.rpm -y
dnf install telegram-desktop signal-desktop riot -y

# Games and Other Misc Stuff
dnf install kalzium kstars parley marble kgeography artikulate -y
dnf install krita scribus kdenlive kgpg kate spectacle quiterss  --refresh -y

# Nvidia Only
# dnf install xorg-x11-drv-nvidia akmod-nvidia xorg-x11-drv-nvidia-cuda vdpauinfo libva-vdpau-driver libva-utils vulkan -y

clear
echo "Installating FlatApp Packages......"
sleep 3

# Flathub Shop Enable
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Flatpacks
# Some might have packages, but self contained is better, as these are released by companies who have no direct support for Fedora Linux rpms.
# Flatpack is the safest bet.
# Sublime is added, because it is just a fallback from VCode. Faster than ATOM.

flatpak install flathub com.spotify.Client com.discordapp.Discord com.getpostman.Postman org.gnome.FeedReader com.github.marktext.marktext com.sublimetext.three -y

# Copy Desktop Shortcuts
# cp *.desktop /etc/xdg/autostart/

# Nvidia only
# cp 20-nvidia.conf /etc/X11/xorg.conf.d/

clear
echo "Copying some small sysconfig files and enabling service core....."
sleep 3

# Touchpad Stuff 
# Copy to both the places.
cp 40-libinput.conf /etc/X11/xorg.conf.d/
cp 40-libinput.conf /usr/share/X11/xorg.conf.d/

# Android Tools for Udev policies which need to be copied for adb and fastboot to work.
cp 51-android.rules /etc/udev/rules.d/

# Enable HDD Temp Service
systemctl enable hddtemp.service
systemctl start hddtemp.service

clear
echo "Check Security of System....."
sleep 2

# Sec Dev Check. Optional, but helpful, if you run it periodically.
spectre-meltdown-checker

clear
echo "Done, Please Reboot System.....Enjoy!"
sleep 5
