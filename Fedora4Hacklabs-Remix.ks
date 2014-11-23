### Fedora 4 HackLabs Remix ###

# Maintainer: Ismael@Olea.org

# Based on
#	/usr/share/spin-kickstarts/custom/qa-test-day.ks
#	/usr/share/spin-kickstarts/fedora-livedvd-robotics.ks
#	/usr/share/spin-kickstarts/fedora-livedvd-electronic-lab.ks

%include /usr/share/spin-kickstarts/fedora-live-base.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks

## Packages
%packages

# branding:
-fedora-logos
-fedora-release
-fedora-release-notes
generic-release
generic-logos
generic-release-notes
fedora-remix-logos

# Start with GNOME
@gnome-desktop

# Remove Anaconda, this image is not intended for installation (we modify the
# image a lot, removing lots of software and changing some system defaults).
# TCs/RCs are intended for installation instead. Of course you can put the
# installer back for a specific Test Day, if needed, but make sure to communicate
# well to people that it is intended for testing purposes, not for real usage.
-@anaconda-tools
-anaconda

# Strip as many packages as possible, so that our testers don't need to download
# large ISOs. Only leave those packages that are generally useful for Test Days.
# Test Day organizers can adjust the kickstart and add specific packages they
# need for a particular Test Day.
-@libreoffice
-@printing
-aisleriot
-authconfig
-brasero*
-cheese
-colord
-colord-gtk
-deja-dup
-evolution
-evolution-ews
-fedora-release-notes
-firewall-config
-firstboot
-gnome-backgrounds
-gnome-boxes
-gnome-color-manager
-gnome-clocks
-gnome-contacts
-gnome-dictionary
-gnome-documents
-gnome-font-viewer
-gnome-getting-started-docs
-gnome-icon-theme-extras
-gnome-initial-setup
-gnome-photos
-gucharmap
-initial-setup
-libsane-hpaio
-nautilus-sendto
-orca
-realmd
-rhythmbox
-sane-backends*
-shotwell
-simple-scan
-system-config-*
-tmpwatch
-transmission-gtk
-vinagre
-yum-langpacks
-abiword
-@games
-gimp
-gimp-libs
-gimp-data-extras
-kdebluetooth
-kbluetooth
-rdesktop

# Remove extra gnome-y things
-@graphical-internet
-@games
-@sound-and-video

# Drop the Java plugin
-icedtea-web

# Drop things that pull in perl
-linux-atm

# No printing
-foomatic-db-ppds
-foomatic

# Dictionaries are big
-aspell-*
-hunspell-*
-man-pages*
-words

# Help and art can be big, too
-gnome-user-docs
-evolution-help
-desktop-backgrounds-basic
-*backgrounds-extras

# Legacy cmdline things we don't want
-krb5-auth-dialog
-krb5-workstation
-pam_krb5
-quota
-nano
-dos2unix
-finger
-ftp
-jwhois
-mtr
-pinfo
-rsh
-nfs-utils
-ypbind
-yp-tools
-rpcbind
-acpid
-ntsysv

# Drop some system-config things
-system-config-boot
-system-config-language
-system-config-network
-system-config-rootpassword
-system-config-services
-policycoreutils-gui



# Add favorite power-user tools
mc
vim
nano
wget
joe

# Add dependencies for the welcome screen
# (this makes it run also on non-GNOME systems)
gjs
firefox

# Electronic lab:
@electronic-lab

# Support for the Milkymist hardware community
@milkymist


# Electronic uses this office packages but I remove them
-dia
-vym
-libreoffice-*
-planner
-graphviz


# debugging tools
make
gdb
valgrind
kdbg
wireshark-gnome
qemu


# EDA/CAD department
perl-Test-Pod
perl-Test-Pod-Coverage

# Robotic Lab:
@robotics-suite
pcl-devel
player-devel
stage-devel
mrpt-devel

# Add version control packages
git
mercurial

# 3D printing tools
@3d-printing

# Child software
minetest
scratch

%end


## LiveCD environment adjustments
%post

# The following changes are executed only during LiveCD boot and wouldn't affect
# the installed system. This image is not intended for installation, but you
# never know what your users might do.

# "EOF" is quoted so that variables are not expanded. Search for "here-document"
# in man bash.
cat >> /etc/rc.d/init.d/livesys << "EOF"


# disable screensaver locking
cat >> /usr/share/glib-2.0/schemas/org.gnome.desktop.screensaver.gschema.override << FOE
[org.gnome.desktop.screensaver]
lock-enabled=false
FOE

# and hide the lock screen option
cat >> /usr/share/glib-2.0/schemas/org.gnome.desktop.lockdown.gschema.override << FOE
[org.gnome.desktop.lockdown]
disable-lock-screen=true
FOE

# disable updates plugin
cat >> /usr/share/glib-2.0/schemas/org.gnome.settings-daemon.plugins.updates.gschema.override << FOE
[org.gnome.settings-daemon.plugins.updates]
active=false
FOE

# make the installer show up
if [ -f /usr/share/applications/liveinst.desktop ]; then
  # Show harddisk install in shell dash
  sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop ""
  # need to move it to anaconda.desktop to make shell happy
  mv /usr/share/applications/liveinst.desktop /usr/share/applications/anaconda.desktop

  cat >> /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override << FOE
[org.gnome.shell]
favorite-apps=['firefox.desktop', 'arduino.desktop', 'gnome-terminal.desktop','nautilus.desktop']
FOE

fi

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up auto-login
cat > /etc/gdm/custom.conf << FOE
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=liveuser
FOE

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

sed -i -e ‘s/Generic release/Fedora 4 HackLabs Remix/g’ /etc/fedora-release /etc/issue


EOF

%end
