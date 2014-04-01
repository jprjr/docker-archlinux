#!/usr/bin/env bash
# Generate a minimal filesystem for archlinux and load it into the local
# docker as "archlinux"
# requires root
set -e

today=$1
echo "Building image for $today"

cd $(dirname "${BASH_SOURCE[0]}")

mkdir /run/shm

pacman -Syy
pacman -S --noconfirm --needed arch-install-scripts expect tar base-devel docker lxc

# start docker-in-docker daemon
nohup /opt/mkimage/wrapdocker 0<&- &>/dev/null &

pacman -Syu --noconfirm
pacman -S --noconfirm arch-install-scripts expect tar base-devel

ROOTFS=$(mktemp -d /tmp/rootfs-archlinux-XXXXXXXXXX)
chmod 755 $ROOTFS

# packages to ignore for space savings
PKGIGNORE=linux,jfsutils,lvm2,cryptsetup,groff,man-db,man-pages,mdadm,pciutils,pcmciautils,reiserfsprogs,s-nail,xfsprogs

expect << EOF
  set timeout 600
  set send_slow {1 1}
  spawn pacstrap -C ./mkimage-arch-pacman.conf -c -d -G -i $ROOTFS base haveged --ignore $PKGIGNORE
  expect {
    "Install anyway?" { sleep 1; send n\r; exp_continue }
    "(default=all)" { sleep 1; send \r; exp_continue }
    "Proceed with installation?" {sleep 1; send "\r"; exp_continue }
    "skip the above package" {sleep 1; send "y\r"; exp_continue }
    "checking" { exp_continue }
    "loading" { exp_continue }
    "installing" { exp_continue }
  }
EOF

touch $ROOTFS/etc/resolv.conf

arch-chroot $ROOTFS /bin/sh -c "haveged -w 1024; pacman-key --init; pkill haveged; pacman -Rs --noconfirm haveged; pacman-key --populate archlinux"
arch-chroot $ROOTFS /bin/sh -c "ln -s /usr/share/zoneinfo/UTC /etc/localtime"
echo 'en_US.UTF-8 UTF-8' > $ROOTFS/etc/locale.gen
arch-chroot $ROOTFS locale-gen
arch-chroot $ROOTFS /bin/sh -c 'echo "Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist'

# udev doesn't work in containers, rebuild /dev
DEV=$ROOTFS/dev
rm -rf $DEV
mkdir -p $DEV
mknod -m 666 $DEV/null c 1 3
mknod -m 666 $DEV/zero c 1 5
mknod -m 666 $DEV/random c 1 8
mknod -m 666 $DEV/urandom c 1 9
mkdir -m 755 $DEV/pts
mkdir -m 1777 $DEV/shm
mknod -m 666 $DEV/tty c 5 0
mknod -m 600 $DEV/console c 5 1
mknod -m 666 $DEV/tty0 c 4 0
mknod -m 666 $DEV/full c 1 7
mknod -m 600 $DEV/initctl p
mknod -m 666 $DEV/ptmx c 5 2

tar --xz -f /output/arch_rootfs_untested.tar.xz --numeric-owner -C $ROOTFS -c . 
rm -rf $ROOTFS

cat /output/arch_rootfs_untested.tar.xz | docker import - archtest
docker run -t -i archtest echo Success.
mv /output/arch_rootfs_untested.tar.xz /output/arch_rootfs_$today.tar.xz
