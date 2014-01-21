#!/bin/bash
date
declare -x SCRIPTPATH="${0}"
echo "SCRIPTPATH="$SCRIPTPATH
declare -x RUNDIRECTORY="${0%%/*}"
declare -x SCRIPTNAME="${0##*/}"
echo "SCRIPTNAME="$SCRIPTNAME
if [ "$RUNDIRECTORY" == "$SCRIPTNAME" ]; then
   RUNDIRECTORY="."
fi
echo "RUNDIRECTORY="$RUNDIRECTORY

. $(pwd)/conf.sh
#sh mounted.sh; sh time_host.sh; sh wpa_supplicant.sh
#run 19th line: #sh install.sh 19
if [ ${1} -gt 0 ];then
 o=`eval "sed '${1}q;d' ${SCRIPTPATH}"`
 p=`echo $o | sed -e "s@\\${part}@${part}@g" -e "s@\\${distro}@${distro}@g" -e "s@\\${arch}@${arch}@g" -e "s@\\${indate}@${indate}@g" -e "s@\\${proj}@${proj}@g" -e "s@\\${backup}@${backup}@g" -e "s@\\${KERNEL_VERSION}@${KERNEL_VERSION}@g" -e "s@\\${projname}@${projname}@g"`
 yn "${p}"
 eval "time (${p})";
 if [ $beeper -eq 1 ]; then echo -e '\a'; sleep 1; echo -e '\a'; sleep 1; echo -e '\a'; fi
fi
exit
#http://wooledge.org:8000/BashFAQ
#http://www.unixguide.net/unix/sedoneliner.shtml
#without eval redirects > won't run.
#yes no
#http://ubuntuforums.org/showpost.php?s=bea64430aa1fc9be6972519ecf2f7d21&p=7808849&postcount=9
#http://tldp.org/LDP/abs/html/exit-status.html

#bell
##modprobe pcspkr

#while is for case, when you have mounted more then one time, or faster umount -l, fuser -mv /mnt/${distro}; kill -9 <pid>
#while [ `mount | grep ${distro} | wc -l` -gt 0 ] ; do umount -l /mnt/${distro}/dev; umount /mnt/${distro}/{dev,proc,sys,,mnt/usb}; done

#sleep 3 needed for detach
#sometimes only reboot or umount -l /mnt/point will help. even fuser or lsof might not help, when they can't see some kernel processes http://forums.gentoo.org/viewtopic-t-528830.html
##umount -l /mnt/${distro}/dev; sleep 3; umount /mnt/${distro}/{dev,proc,sys,var/cache/paludis/distfiles,mnt/storage,}; sh mounted.sh

##mkfs.btrfs -L ${distro} /dev/${part}
# -c for badblocks
##mkfs.ext3 -L ${distro} /dev/${part}
mkfs.ext4 -L ${distro} /dev/${part}

#if dir doesn't exist, create; if dir exists mount;
[ ! -d /mnt/${distro} ] && mkdir /mnt/${distro}; [ -d /mnt/${distro} ] && mount -L ${distro} /mnt/${distro} && mount | grep ${distro}

#http://dev.exherbo.org/stages/
cd ${proj}/temp && wget http://dev.exherbo.org/stages/exherbo-${arch}-current.tar.xz

#sha1sum is generally outdated
cd ${proj}/temp && wget http://dev.exherbo.org/stages/sha1sum
cd ${proj}/temp && LC_ALL=C sha1sum -c sha1sum 2>/dev/null | grep "exherbo-${arch}-current.tar.xz: OK"; cd -

#`cd /mnt/${distro} && unxz -c ${proj}/temp/exherbo-${arch}-current.tar.xz | tar xpfv -`
#new tar support xz
tar -vpxaf ${proj}/temp/exherbo-${arch}-current.tar.xz -C /mnt/${distro}

cp -L ${proj}/Warsaw /mnt/${distro}/etc/localtime


##cp ${proj}/conf/etc/fstab /mnt/${distro}/etc && cp ${proj}/conf/etc/conf.d/clock /mnt/${distro}/etc/conf.d/ && cp -L /mnt/${distro}/usr/share/zoneinfo/Europe/Warsaw /mnt/${distro}/etc/localtime && cp ${proj}/conf/etc/paludis/bashrc-${arch} /mnt/${distro}/etc/paludis/bashrc

#if not exist create and mount, else mount
##[ ! -d /mnt/${distro}/mnt/storage ] && mkdir /mnt/${distro}/mnt/storage; [ -d /mnt/${distro}/mnt/storage ] && mount -o bind /mnt/storage /mnt/${distro}/mnt/storage; mount | grep bind
[ ! -d /mnt/${distro}/mnt/${projname} ] && mkdir /mnt/${distro}/mnt/${projname}; [ -d /mnt/${distro}/mnt/${projname} ] && mount -o bind /mnt/${projname} /mnt/${distro}/mnt/${projname} && mount | grep bind

##mount -o bind ${proj}/temp/distfiles /mnt/${distro}/var/cache/paludis/distfiles
#rsync -vaHW ${proj}/temp/distfiles/ /mnt/exherbo/var/cache/paludis/distfiles

#set hostname
#http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=1&chap=8
##vim /etc/conf.d/hostname
#set domainname dns_domain_lo="homenetwork"
##vim /etc/conf.d/net


#error:
#grep: writing output: Invalid argument
#but etc/mtab is written

#for rechroot
mount -o rbind /dev /mnt/${distro}/dev/ && mount -o bind /sys /mnt/${distro}/sys/ && mount -t proc none /mnt/${distro}/proc/ && cp -L /etc/resolv.conf /mnt/${distro}/etc/resolv.conf && grep -v rootfs /proc/mounts > /mnt/${distro}/etc/mtab; mount | grep ${distro}

##chroot /mnt/${distro} /bin/bash
env -i TERM=$TERM SHELL=/bin/bash HOME=$HOME chroot /mnt/${distro} /bin/bash

# chrooted #####################################################################
date

#by hand
#. /etc/profile #doesn't work inside vmware
source /etc/profile
export PS1="(chroot) $PS1"

#by hand
cd /etc/paludis && vim bashrc && vim *conf

#paludis changed its config files, so it's irrelevant
##sh ${proj}/locale.sh

#glib failed to update, chrooted from sysrescuecd, use ubuntu live
##unset path

passwd

#http://comments.gmane.org/gmane.linux.distributions.exherbo.devel/1225
#Impossible to install Exherbo amd64 with the latest stage on Virtualbox
#and
# === Completed ebuild phase killold
#execv failed (errno:1 Operation not permitted)
echo "dev-libs/glib build_options: -recommended_tests" >> /etc/paludis/options.conf
env PALUDIS_DO_NOTHING_SANDBOXY=1 cave resolve sydbox -x
#not in install guide
#eclectic env update

#do not sync before cave resolve -x paludis
#40 min
#i got error: x86_64-pc-linux-gnu-g++: Internal error: Killed (program cc1plus)
#solved by 1GB RAM for VMWare Machine with sysrescuecd running
env PALUDIS_DO_NOTHING_SANDBOXY=1 cave resolve -x1 paludis
cave sync

eclectic config interactive

#function yn doesn't work with below
#cd temp & wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-${KERNEL_VERSION}.tar.bz2

######################### systemd
# http://exherbo.org/docs/systemd.html

echo '*/* systemd' >> /etc/paludis/options.conf

#for sys-auth/ConsoleKit -> sys-apps/dbus
#for x11-libs/libX11 -> sys-auth/ConsoleKit
cave resolve -x sys-apps/systemd
#echo "sys-apps/util-linux build_options: -recommended_tests" >> /etc/paludis/options.conf
cave resolve world -cx
eclectic init set systemd

eclectic news read 2013-05-31-stages-set
cave update-world app-arch/libarchive app-editors/vim app-text/wgetpaste net-misc/dhcpcd app-arch/zip sys-boot/grub
cave purge -x

cave resolve gpm -x
systemctl enable gpm
systemctl start gpm

#grub
#set options for systemd as described here http://www.mailstation.de/wordpress/?p=48
#vmware options described here http://en.gentoo-wiki.com/wiki/VMware_Guest#Kernel_options
#vmware installation described here http://en.gentoo-wiki.com/wiki/VMware_Workstation
#supergrubdisk http://www.supergrubdisk.org/super-grub2-disk/
#change vmware machine to 1024 MB, 512 MB isn't sufficient, change boot order for vmware machine with F2 (fn+F2 on macbook) or ESC to change ordering temporarily
#nice grub2 guide https://help.ubuntu.com/community/Grub2
#guid booting http://docs.funtoo.org/wiki/GUID_Booting_Guide

#enable fuse and ext4
#ext4 options described here http://en.gentoo-wiki.com/wiki/Ext4#Configuring_the_kernel

#use kernel version from http://git.exherbo.org/summer/packages/sys-kernel/linux-headers/index.html
#and put archive in /var/cache/paludis/distfiles/ so you don't have to download linux source again
#or add particular exheres to /var/db/paludis/repositories/arbor/packages/sys-kernel/linux-headers

#in order to zgrep sth /proc/config
#CONFIG_IKCONFIG_PROC=y
#CONFIG_IKCONFIG_PROC=y
cd /mnt/${projname}/temp && wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-${KERNEL_VERSION}.tar.bz2
cd /mnt/${projname}/temp && tar xvjf linux-${KERNEL_VERSION}.tar.bz2 -C /usr/src
cd /usr/src/linux-${KERNEL_VERSION} && make menuconfig
cd /usr/src/linux-${KERNEL_VERSION} && time make && make modules_install && cp arch/x86_64/boot/bzImage /boot/kernel

#/boot/grub directory will also be created
grub-install /dev/sda
cp /mnt/${projname}/grub.cfg /boot/grub/

ln -sf /proc/self/mounts /etc/mtab

localedef -i pl_PL -f UTF-8 pl_PL.UTF-8

##### Network
#TODO: ifplugd for eth?
#https://wiki.archlinux.org/index.php/Wireless_Setup
#wicd vs netoworkmanager http://www.linuxquestions.org/questions/slackware-14/wicd-vs-networkmanager-4175458775/
#wicd howto http://forum.manjaro.org/index.php?topic=3534.0

#for ip command, newer than iwconfig from wireless_tools
cave resolve iproute2 -x
#openssl or gnutls use flag to have encryption
echo "net-wireless/wpa_supplicant dbus nl80211" >> /etc/paludis/options.conf
cave resolve NetworkManager -x
#cave resolve gnome-desktop/network-manager-applet -x
#net-wireless/ModemManager "Provides mobile 3G support for NetworkManager

#dhcpcd will autorun wpa_supplicant, if there is /etc/wpa_supplicant.conf, this path hardcoded in hook
systectl enable dhcpcd
systectl start dhcpcd

#start ethernet network by hand
#ifconfig eth0 up && dhcpcd eth0 && ping -c 3 wp.pl

#to disable/enable switch on device
cave resolve rfkill


#== ntfs
cave resolve ntfs-3g_ntfsprogs -x

#== wayland
# http://www.chaosreigns.com/wayland/state/
# http://www.chaosreigns.com/wiki/Exherbo
echo '*/* wayland -X' >> /etc/paludis/options.conf
echo 'CPPFLAGS="${CPPFLAGS} -DMESA_EGL_NO_X11_HEADERS"' >> /etc/paludis/bashrc
echo "dev-libs/libxml2 python" >> /etc/paludis/options.conf
echo "app-text/poppler glib cairo" >> /etc/paludis/options.conf
cave resolve wayland weston -x
# when running weston:
# Error:    failed to add default include path /usr/share/X11/xkb
# http://www.mail-archive.com/wayland-bugs@lists.freedesktop.org/msg01350.html
cave resolve xkeyboard-config -x

#noveau?
#lspci
#grep -i drm /usr/src/linux/.config

#remove
cave uninstall mesa -r '*/*' -x

#== REISUB Reboot Even If System Utterly Broken

in linux config
CONFIG_MAGIC_SYSRQ=y

help (fn+alt+prtsc, release prtsc)
alt+sysrq+h
restart
alt+sysrq+REISUB

echo "1" > /proc/sys/kernel/sysrq
#or if you wish to have it enabled during boot (or in /etc/sysctl.conf)
echo "kernel.sysrq = 1" >> /etc/sysctl.d/99-sysctl.conf

default is 16, only sync
https://fedoraproject.org/wiki/QA/Sysrq

https://wiki.archlinux.org/index.php/Keyboard_Shortcuts
http://royal.pingdom.com/2012/08/13/troubleshooting-sysrq/ 

#== other

cave resolve sshfs -x

cave resolve tree -x





#unset needed for sysrescuecd or zsh
##unset path && cave resolve -x sydbox
##cave resolve -x glibc
#python fails, add
#labels have changes, or backup ndbam and replace s/build,run/build+run/
#rm -R /var/cache/paludis/metadata/* &&
#The 'everything' set is deprecated. Use either 'installed-packages' or 'installed-slots' instead
##cave resolve installed-packages --dl-upgrade always --continue-on-failure if-independent 2>&1 | tee ${proj}/temp/e.log
#--suggestions take
#--dl-reinstall if-use-changed

#adding repo with cave
#someone mistakenly named file
#config_template '/etc/paludis/repository.template' is not a regular file (paludis::ConfigurationError)
##mv /etc/paludis/repository.template\: /etc/paludis/repository.template

#grub-static is installed? and it won't upgrade on x86 beaces is keyworded ~amd64; at this moment grub can't be compiled on amd64
mv /etc/init.d/net.eth0 /etc/init.d/net.wlan0; cp ${proj}/conf/etc/conf.d/net.wlan0 /etc/conf.d/net; cp ${proj}/conf/etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/;


#it should work in busybox, but in bash? http://www.openchill.org/?cat=9

#extract config from kernel image /usr/src/linux/scripts/extract-ikconfig /boot/image > .config
yes ? | make --quiet oldconfig

enable ctrl+alt+del in /etc/inittab

#early install of kvm, to check if i can already install it
#should I install qemu-kvm or qemu?
#http://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine
#http://www.techtopia.com/index.php/Installing_and_confguring_Fedora_KVM_Virtualization
#qemu for full hardware virtualization: guest different arch then host
#qemu-kvm: kvm uses qemu for device emulation like vga, disk controllers etc. kvm is hypervisor as linux module
#VirtIO framework (libvirt, virt-manger, virt-viewer, virtinst): allows paravirtualization, faster, installing paravirtual devices in guest like Ethernet card, disk I/O controller etc.
#http://virt-manager.org

cave search --name qemu
cave resolve qemu-kvm -x

#not needed anymore?
#wget http://altruistic.lbl.gov/mirrors/ubuntu/pool/universe/m/mc/mc_4.6.2-2.diff.gz
#wget http://ftp.debian.org/debian/pool/main/m/mc/mc_4.7.0-pre1-3.diff.gz

#== elinks
echo "net-www/elinks" >> /etc/paludis/package_unmask.conf
echo "net-www/elinks gpm" >> /etc/paludis/options.conf
#dev-libs/tre need this for tests
localedef -i en_US -f ISO-8859-1 en_US.ISO-8859-1
cave resolve elinks -x

#irssi config generator: make-irssi-config.sh < http://www.matthew.ath.cx/programs/irssiconfig < http://pl.wikibooks.org/wiki/Irssi
cave resolve -x htop mc irssi terminus-font

echo "fonts/terminus-font X" >> /etc/paludis/options.conf
#many things get installed, not only terminus
#terminus moved to sourceforge
#eclectic-fontconfig is suggested
#do I have to do eclectic fontconfig enable 21 etc.?
cave resolve -x terminus-font --suggestions take

sh ${proj}/grub.sh

#http://nouveau.freedesktop.org/wiki/ExherboInstall
#http://intellinuxgraphics.org/user.html
#http://intellinuxgraphics.org/install.html
#http://en.gentoo-wiki.com/wiki/Intel_GMA
#matrix with suported features
#http://www.x.org/wiki/IntelGraphicsDriver
#http://www.x.org/wiki/ModularDevelopersGuide
#how to enable ctrl+alt+backspace
#http://www.gentoo.org/proj/en/desktop/x/x11/xorg-server-1.6-upgrade-guide.xml

#http://exherbo.org/docs/exheres-for-smarties.html
#In any of the variants, opt may optionally end in a (+) or a (-) to indicate that, when matching the spec against a package that does not have the flag, that it should be assumed to be enabled or disabled respectively. If neither is specified, it is illegal for the remainder of the spec to match any such package. The (+) or (-) goes before the =, !=, ? or !?, if both are present.
#W jakimkolwiek wariancie, opt może opcjonalnie konczyć się na (+) lub (-) aby wskazać, że kiedy zachodzi dopasowywanie spec do pakietu, który nie ma tej flagi, że to powinno być zakładane, że jest włączone lub wyłączone odpowiednio. Jeśli żedne nie jest określone, to jest nielegalne dla przypominacza speca, aby dopasować jakikolwiek taki pakiet. (+) lub (-) idzie przed =, !=, ? lub !?, jeśli obydwa są dostępne.

#what about VIDEO_DRIVERS: gallium-intel intel for x11-dri/mesa
#echo "*/* INPUT_DRIVERS: evdev -keyboard -mouse VIDEO_DRIVERS: intel" >> /etc/paludis/options.conf
echo "*/* VIDEO_DRIVERS: intel nouveau" >> /etc/paludis/options.conf
#looks like INPUT_DRIVERS doesn't work anymore
#echo "*/* INPUT_DRIVERS: evdev" >> /etc/paludis/options.conf
#no package libx11 when running cave resolve xorg-server?
#echo "x11-libs/libX11 xcb" >> /etc/paludis/options.conf
#encodings and fonts
#KSC5601.1987-0 font-daewoo-misc, JISX0208.1983-0 font-jis-misc, GB2312.1980-0 font-isas-misc, font-misc-misc for iso and jisx0201 and koi08-r
#problem: startx very slow, LC_ALL=C startx or install proper fonts?
#solution: install fonts with encodings listed in vim /usr/share/X11/locale/en_US.UTF-8/XLC_LOCALE or comments those encodings in this file
#/usr/share/X11/locale/en_US.UTF-8/
#not needed, already in exheres
#echo "fonts/font-misc-misc ENCODINGS: iso8859-13 iso8859-14 iso8859-15 iso8859-2 iso8859-3 iso8859-4 iso8859-5 iso8859-7 iso8859-9 jisx0201 koi8-r" >> /etc/paludis/options.conf
# eclectic-fontconfig is suggested, but installed previously with terminus-font
# cat font_list | grep -E "^\*[^:]+/"
#python tests took too long, more than hour and it stil was testing
echo "dev-lang/python build_options: -recommended_tests" >> /etc/paludis/options.conf
#strange:
#install.sh: line 17:  9359 Naruszenie ochrony pamięci   cave resolve xorg-server -x
#and line 17: eval "time (${p})";
#i can't even run it by hand with time: time cave resolve xorg-server -x
#udev or hal, without it Alt+SysRq+RESUIB
#no udev flag
#echo "x11-server/xorg-server udev" >> /etc/paludis/options.conf

#you would need evdev if xorg-server uses udev for input devices
#evdev default?
#cave resolve xf86-input-evdev -x

#udev just needs glib
#no package udev?
#echo "sys-fs/udev glib" >> /etc/paludis/options.conf
#I encountered the following errors for untaken packages:
#(!) sys-auth/ConsoleKit:(unknown)::(install_to_slash)
#but i couldn't find wich untaken package caused it, strange.
#Whatever, but ConsoleKit is in repository/desktop
#What is even more strange, that it doesn't install ConsoleKit
#but adding repo solved the problem
#or --suggestions ignore ?
cave resolve xorg-server -x
#do not run with take, or you will have to enable radeon or sth?
# --suggestions take

#take suggestions for xterm, twm etc.
#no suggestions now
cave resolve xinit --suggestions take -x

#why do I have to install intel manually, why there are VIDEO_DRIVERS?
cave resolve xf86-video-intel xf86-video-nouveau -x

#you will need these fonts or startx+twm will start slowly
#switch to console where you run startx to see for yourself
#twm: warning: font for charset JISX0208.1983-0 is lacking.
#twm: warning: font for charset KSC5601.1987-0 is lacking.
#twm: warning: font for charset GB2312.1980-0 is lacking.
#not anymore
#cave resolve font-daewoo-misc font-jis-misc font-isas-misc -x

X -retro

cave resolve xterm -x
#is it needed?
cave resolve xf86-video-modesetting -x
echo "exec twm" > ~/.xinitrc
#run as normal user
startx

#== GNOME
#error: gnome-doc-utils missing
#gnome-doc-utils >= 0.3.2 not found
#Install failed for 'gnome-desktop/gconf-editor-3.0.1:0
cave resolve gconf-editor

#== Icons and Cursors
cave resolve dmz-cursor-theme -x
cave resolve tango-icon-theme -x
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'

#== groups
#list
cut -d: -f1 /etc/group | sort
#add to existing user
usermod -aG group1 group2 user1
#== Sound
usermod -aG audio <user> && shutdown -r now

#== Flash for Firefox
cave resolve adobe-flash -x && shutdown -r now


#http://en.wikipedia.org/wiki/Unicode_typefaces
#http://wiki.archlinux.org/index.php/Fonts
#http://wiki.archlinux.org/index.php/Xorg_Font_Configuration
#http://en.gentoo-wiki.com/wiki/X.Org/Fonts
#if you get warning: font for charset ISO8859-2 is lacking. (and others codings)
#and for TTF font warning
#you have to download liberation manually with
wget --no-check-certificate https://fedorahosted.org/releases/l/i/liberation-fonts/liberation-fonts-ttf-1.05.2.20091227.tar.gz
cave resolve liberation-fonts -x
#for Type1 warning
cave resolve font-xfree86-type1 -x

#after installing and uninstalling font-daewoo-misc and startx i got:
#Warning: Unable to load any usable fontset
#twm:  unable to open fontset "-adobe-helvetica-bold-r-normal--*-120-*-*-*-*-*-*"
#fc-cache -vf doesn't help, /usr/lib64/X11/fonts/misc/fonts.dir isn't updated

#FATAL: Module fbcon not found.
#when running startx, you can see above output.
#X want's this module, but when it's builtin, modprobe will return warning.
#Anyway, it's if fbcon is compiled in. X doesn't even use it.
#It's for other architectures than x86.
#Maybe it should stay built-in not as module
#less linux-source/Documentation/fb/fbcon.txt
#zgrep FRAMEBUFFER_CONSOLE /proc/config.gz
#Device Drivers > Graphics support > Console display driver support > Framebuffer Console support

#lxde
cave resolve repository/lxde-unofficial -x
#for openbox and corefonts
#and xfce
cave resolve repository/rbrown -x
#for xarchiver
cave resolve repository/exhereses-cn -x
echo "x11-libs/pango X" >> /etc/paludis/options.conf
echo "x11-libs/cairo X" >> /etc/paludis/options.conf

#I encountered the following errors for untaken packages:
#(!) app-arch/dpkg:(unknown)::(install_to_slash)
cave resolve repository/ingmar -x
#(!) app-arch/rpm:(unknown)::(install_to_slash)
#and mono, java
cave resolve repository/SuperHeron-misc -x

#this doesn't work, but it's in official FAQ of exherbo
echo "lxde-desktop/lxappearance ~amd64" >> /etc/paludis/platforms.conf

#failed lxde-desktop/lxsession-0.4.3:0::lxde-unofficial
#checking for DBUS... no
#configure: error: To build with DBUS support, you must have the development package for dbus-1, or you can use --disable-dbus to disable DBUS support.
#
#dbus will give shutdown and restart in lxde logout menu
echo "sys-apps/dbus X" >> /etc/paludis/options.conf
cave resolve dbus -x1
eclectic rc add dbus default
/etc/init.d/dbus start

startx
#(EE) Failed to load module "vesa" (module does not exist, 0)
#(EE) Failed to load module "fbdev" (module does not exist, 0)

#** (lxsession-logout:4776): WARNING **: dbus-interface.c:71: DBUS: The name org.freedesktop.Hal was not provided by any .service files

#failed leafpad, downloaded file was HTML, not tar.gz

#cannot run in time (line)
cave resolve lxde* -X */* --suggestions ignore -x --continue-on-failure if-independent 2>&1 | tee ${proj}/temp/e.log
echo "startlxde" > ~/.xinitrc
#no icons: install gnome-icon-theme or choose tango from lxappearance
#missing icon on launchbar: it is firefox: ~/.config/lxpanel/LXDE/panels/panel
#http://wiki.archlinux.org/index.php/LXDE

#http://wiki.archlinux.org/index.php/Start_X_at_boot#Starting_X_as_preferred_user_without_logging_in

#I see no icons in pcmanfm, maybe i should install lxde-icon-theme
#http://blog.lxde.org/?p=737
#lxde-desktop/lxde-icon-theme-0.0.1 only ~x86
#after installing lxde-icon-theme and switching to x11-themes/tango-icon-theme-0.8.1, tango doesn't include system-software-install
cave resolve lxde-icon-theme -x

#on panel there is element without icon, according to ~/.config/lxpanel/LXDE/panels/panel it is lxde-logout.desktop, you can get it from some lxde-common*.rpm
#lxde-common-0.5.0 in exherbo doesn't include lxde-desktop-preferences.desktop  lxde-lock-screen.desktop  lxde-logout.desktop
#i have downloaded http://rpm.pbone.net/index.php3/stat/4/idpl/13914959/dir/fedora_13/com/lxde-common-0.5.4-1.fc13.noarch.rpm.html
#and unpacked it with rpmunpack from rpm2targz
#running command from lxde-lock-screen.desktop gives error about missing xprop
#so xprop should be dependency for xdg-utils maybe
cave resolve xprop xscreensaver -x
xdg-screensaver lock
#can't run xscreensaver as root without weaking system http://www.jwz.org/xscreensaver/faq.html

#Unable to get monitor information
lxranrd

#for chromium
cave resolve repository/pipping -x
#for ffmpeg
cave resolve repository/media -x
echo "media/ffmpeg threads" >> /etc/paludis/options.conf
#masked by repository
echo "media/ffmpeg" >> /etc/paludis/package_unmask.conf
cave resolve chromium -x

cave resolve repository/gauteh -x
cave resolve sys-fs/ntfs-3g sys-fs/ntfsprogs -x

cave resolve alsa-utils -x
alsaconf
alsamixer
mv /etc/modprobe.d/sound /etc/modprobe.d/sound.conf
eclectic rc add alsasound default

#after reboot
#/etc/init.d/alsasound start
# * Loading ALSA modules ...
# *   Loading: snd-card-0 ...   [ ok ]
# *   Loading: snd-mixer-oss ...[ ok ]
# *   Loading: snd-pcm-oss ...  [ ok ]
# *   Loading: snd-seq-oss ...  [ ok ]
# * Restoring Mixer Levels ...
#alsactl: set_control:1388: Cannot write control '2:0:0:PCM Playback Volume:0' : Operation not permitted

#pdf
#Package poppler-glib was not found in the pkg-config search path
echo "app-text/poppler cairo glib" >> /etc/paludis/options.conf
#zathura hangs when i press n (for next page i suppose)
cave resolve zathura -x
cave resolve epdfview -x

#icewm
cave resolve repository/desktop-unofficial -x
cave resolve icewm -x
cave resolve icewm-themes -x

#dev-libs/xulrunner-1.9.2.4::desktop failed
#make[2]: *** [libs_tier_gecko] Error 2
#cave uninstall app-arch/zip media-libs/lcms app-text/iso-codes gnome-platform/libglade x11-libs/libnotify
cave uninstall media-libs/lcms app-text/iso-codes gnome-platform/libglade x11-libs/libnotify -x

#get firefox nigthly, need gtk+ and alsa-utils (libasound2 from alsa-lib)
#echo "x11-libs/cairo X" >> /etc/paludis/options.conf
#echo "x11-libs/pango X" >> /etc/paludis/options.conf

#archivers
cave resolve zip -x
#usage: unrar x file.rar
cave resolve unrar -x

#
#node # ./configure
#Checking for program g++ or c++          : /usr/bin/g++
#Checking for program cpp                 : /usr/bin/cpp
#Checking for program ar                  : /usr/bin/ar
#Checking for program ranlib              : /usr/bin/ranlib
#Checking for g++                         : ok
#Checking for program gcc or cc           : /usr/bin/gcc
#Checking for gcc                         : ok
#Checking for library dl                  : yes
#Checking for library execinfo            : not found
#Checking for openssl                     : yes
#Checking for library rt                  : yes
#--- libeio ---
#Checking for library pthread             : yes
#Checking for function pthread_create     : yes
#Checking for function pthread_atfork     : yes
#Checking for futimes(2)                  : yes
#Checking for readahead(2)                : yes
#Checking for fdatasync(2)                : yes
#Checking for pread(2) and pwrite(2)      : yes
#Checking for sendfile(2)                 : yes
#Checking for sync_file_range(2)          : yes
#--- libev ---
#Checking for header sys/inotify.h        : yes
#Checking for function inotify_init       : yes
#Checking for header sys/epoll.h          : yes
#Checking for function epoll_ctl          : yes
#Checking for header port.h               : not found
#Checking for header poll.h               : yes
#Checking for function poll               : yes
#Checking for header sys/event.h          : not found
#Checking for header sys/queue.h          : yes
#Checking for function kqueue             : not found
#Checking for header sys/select.h         : yes
#Checking for function select             : yes
#Checking for header sys/eventfd.h        : yes
#Checking for function eventfd            : yes
#Checking for SYS_clock_gettime           : yes
#Checking for library rt                  : yes
#Checking for function clock_gettime      : yes
#Checking for function nanosleep          : yes
#Checking for function ceil               : yes
#Checking for fdatasync(2) with c++       : yes
#'configure' finished successfully (4.501s)

#execinfo in gnulib, but do I really need those "not found"?

#for libev for node.js
#cave resolve repository/ferdy -x
#cave resolve libev -x
#but ./configure outputs the same

./configure
mkdir rf
#maybe i should make and than make install
#http://exherbo.org/docs/faq.html
#http://ciaranm.wordpress.com/2008/05/20/managing-unpackaged-packages-or-whats-this-importare-thing/
make DESTDIR=./rf install
make test

#Waf: Entering directory `/mnt/storage/sandbox/node/build'
#DEST_OS: linux
#DEST_CPU: x86_64
#Parallel Jobs: 2
#Waf: Leaving directory `/mnt/storage/sandbox/node/build'
#'build' finished successfully (0.095s)
#python tools/test.py --mode=release simple message
#=== release test-error-reporting ===
#Path: simple/test-error-reporting
#assert:80
#  throw new assert.AssertionError({
#        ^
#AssertionError: true == false
#    at /mnt/storage/sandbox/node/test/simple/test-error-reporting.js:44:10
#    at /mnt/storage/sandbox/node/test/simple/test-error-reporting.js:20:5
#    at ChildProcess.<anonymous> (child_process:82:21)
#    at ChildProcess.emit (events:32:26)
#    at ChildProcess.onexit (child_process:130:12)
#    at node.js:266:9
#Command: build/default/node /mnt/storage/sandbox/node/test/simple/test-error-reporting.js
#=== release test-http-full-response ===
#Path: simple/test-http-full-response
#ab not installed? skipping test.
#/bin/sh: ab: command not found
#assert:80
#  throw new assert.AssertionError({
#        ^
#AssertionError: 0 == 3
#    at EventEmitter.<anonymous> (/mnt/storage/sandbox/node/test/simple/test-http-full-response.js:65:10)
#    at EventEmitter.emit (events:25:26)
#    at EventEmitter.exit (node.js:236:11)
#    at /mnt/storage/sandbox/node/test/simple/test-http-full-response.js:26:15
#    at ChildProcess.<anonymous> (child_process:82:21)
#    at ChildProcess.emit (events:32:26)
#    at Stream.<anonymous> (child_process:110:12)
#    at Stream.emit (events:25:26)
#    at net:1001:12
#    at EventEmitter._tickCallback (node.js:50:25)
#Command: build/default/node /mnt/storage/sandbox/node/test/simple/test-http-full-response.js
#=== release undefined_reference_in_new_context ===
#Path: message/undefined_reference_in_new_context
#before
#
#
#/mnt/storage/sandbox/node/test/message/undefined_reference_in_new_context.js:9
#script.runInNewContext();
#       ^
#ReferenceError: foo is not defined
#    at evalmachine.<anonymous>:1:1
#    at Object.<anonymous> (/mnt/storage/sandbox/node/test/message/undefined_reference_in_new_context.js:9:8)
#    at Module._compile (module:386:21)
#    at Module._loadScriptSync (module:395:8)
#    at Module.loadSync (module:301:10)
#    at Object.runMain (module:449:22)
#    at node.js:253:10
#Command: build/default/node /mnt/storage/sandbox/node/test/message/undefined_reference_in_new_context.js
#[00:18|% 100|+ 105|-   3]: Done
#make: *** [test] Error 1


#ab not installed? skipping test.
#/bin/sh: ab: command not found
#http://httpd.apache.org/docs/2.0/programs/ab.html
#in gentoo part of http://gentoo-portage.com/app-admin/apache-tools
cave resolve apache -x
#now make tests outputs 2 errors instead of 3

#node.js is not valid package name
cave import --location ./rf www-servers/node.js 0.1.100 0 --execute

cave resolve repository/net -x
cave resolve whois -x

echo "app-emulation/wine alsa -camera -dbus -gnutls -lcms -mp3 -openal opengl -samba" >> /etc/paludis/options.conf
cave resolve wine -x

#Thunar video and pdf thumbnails
echo "xfce-base/exo libnotify" >> /etc/paludis/options.conf
echo "xfce-base/Thunar dbus exif startup-notification trash-plugin wallpaper-plugin" >> /etc/paludis/options.conf
cave resolve Thunar -x
#make[3]: Entering directory `/var/tmp/paludis/build/xfce-base-xfconf-4.6.1/work/xfconf-4.6.1/tests/set-properties'
#sydbox@1279344417: Access Violation!
#sydbox@1279344417: Child Process ID: 11924
#sydbox@1279344417: Child CWD: /var/tmp/paludis/build/xfce-base-xfconf-4.6.1/work/xfconf-4.6.1/tests/set-properties
#sydbox@1279344417: Last Exec: execve("/usr/bin/dbus-daemon", ["/usr/bin/dbus-daemon", "--fork", "--print-pid", "5", "--print-address", "7", "--session"])
#sydbox@1279344417: Reason: bind{family=AF_UNIX path=/tmp/dbus-6x8HCIQBQ4 abstract=true}
#Failed to start message bus: Failed to bind socket "/tmp/dbus-6x8HCIQBQ4": Cannot assign requested address
#EOF in dbus-launch reading address from bus daemon
#
#(xfconfd:11947): xfconfd-CRITICAL **: Xfconfd failed to start: /usr/bin/dbus-launch terminated abnormally with the following error: Autolaunch error: X11 initialization failed.


echo "media/mplayer X mp3 xv truetype a52 dts aac h264 theora vorbis vp8" >> /etc/paludis/options.conf
cave resolve repository/media-unofficial -x
cave resolve mplayer -x

cave resolve repository/games -x
cave resolve freedroidrpg

#old
#hal deprecated?
#suggested pm-utils: Suspend and hibernation utilities for HAL
cave resolve -x hal --suggestions take
#hal and dbus is needed for evdev?
/etc/init.d/hald start
eclectic rc add hald default

#for cave resolve gnome -x
wget --no-check-certificate https://fedorahosted.org/releases/x/m/xmlto/xmlto-0.0.22.tar.bz2
#add repos gnome.conf compnerd.conf media.conf perl.conf
echo "media-libs/libcanberra gtk" >> /etc/paludis/options.conf
echo "dev-libs/libxml2 python" >> /etc/paludis/options.conf

#for cave resolve openoffice -x
#add repos office.conf scientific.conf

#old?
echo "lxde-desktop/lxsession hal" >> /etc/paludis/options.conf
echo "x11-apps/pcmanfm desktop -gamin hal" >> /etc/paludis/options.conf
echo "x11-wm/openbox startup-notification"  >> /etc/paludis/options.conf
#Error: no fam or gamin detected. x11-apps/pcmanfm-0.5.1::gauteh, install gamin
#leafpad hated docdir option, http://lists.exherbo.org/pipermail/exherbo-dev/2009-October/000570.html
#so you have to add to exheres DEFAULT_SRC_CONFIGURE_PARAMS=( --hates=docdir )
#cave resolve lxde-common lxde gamin -x


# backup #######################################################################

#tar, looks like tar.bz2 is 3x faster than tar.xv
read -p "description: " desc && cd /mnt/${distro} && tar -vpcaf ${backup}/${distro}-${arch}-${indate}-${desc}.tar.bz2 --exclude "var/tmp/ccache/*" --exclude "var/tmp/paludis/build/*" --exclude "var/cache/paludis/distfiles/*" --exclude "usr/src/*" . 2>&1 | tee ${proj}/temp/tar.log && export name="${backup}/${distro}-${arch}-${indate}-${desc}.tar.bz2"

cd ${backup}/ && sha1sum ${name} > ${name}.sha1sum

cd /mnt/${distro} && tar -vpxaf ${name} 2>&1 | tee ${proj}/temp/untar.log

# deprecated ###################################################################

#rsync
rsync --delete -aHWv --stats --progress /mnt/${distro} ${backup}/${distro}-${arch}-bootable/
rsync --delete -aHWv --stats --progress --link-dest=${backup}/${distro}-${arch}-bootable /mnt/${distro} ${backup}/${distro}-${arch}-bootable-wifi_fight/

#verify
#extract backup to test and verify, only size and times by default
rsync -nvaHW --exclude "var/tmp/paludis/build/*" --exclude "var/tmp/ccache/*" /mnt/${distro}/ test/
find /mnt/${distro}/ -xdev -type f -print0 | xargs -0 -n 1 sha1sum > ${backup}/${distro}-${arch}-bootable/sha1sum
du -s -b /mnt/${distro}/ > ${backup}/${distro}-${arch}-bootable/bytes

# exherbo paludis doc ##########################################################

#list of installed packages (from FAQ)
cave show */*::/

#Kicktoo: install gentoo, funtoo, exherbo from one set of functions http://www.openchill.org/?cat=9

elinks /usr/share/doc/paludis-scm/index.html

#when i got error about paludis and labels change, i get stderr stdout stderr, instead of stderr stdout. Solution to this is paludis -i <package> 2>&1 | tee or /usr/share/paludis/hooks/demos/elog.bash

#virtual
#to choose not the prefered on: echo "cat/package" >> /etc/paludis/package_mask.conf
