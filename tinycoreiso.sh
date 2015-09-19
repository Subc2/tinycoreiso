#!/bin/bash
# tinycoreiso - allows modifying Tiny Core Linux ISO images
# Copyright (C) 2015 Paweł Zacharek
# 
# -----------------------------------------------------------------------
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
# -----------------------------------------------------------------------
# 
# date: 2015-09-17

HELP='tinycoreiso - allows modifying Tiny Core Linux ISO images
Syntax: tinycoreiso INPUT_FILE OUTPUT_FILE'

if [ "$#" -ne 2 ]; then
	echo "$HELP"
	exit 0
fi

if [ ! -e "$1" ]; then
	echo "File \"$1\" does not exist."
	exit 1
fi

if [ "$(whoami)" != 'root' ]; then
	echo 'This script requires root privileges.'
	exit 1
fi

INPUT="$1"
OUTPUT="$2"
NAME='TC-custom'

echo 'Extracting...'
mkdir mnt iso root
mount "$INPUT" mnt -o loop,ro
cp -a mnt/boot iso
umount mnt
rmdir mnt
mv iso/boot/core.gz .
cd root
zcat ../core.gz | cpio -i -H newc -d

echo 'Press [Enter] key if you are ready to merge your changes.'
read -rs

echo 'Merging...'
find | cpio -o -H newc | gzip -9 > ../core.gz
cd ..
rm -r root
mv core.gz iso/boot
mkisofs -l -J -R -V "$NAME" -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -o "$OUTPUT" iso
rm -r iso

echo 'ISO image has been created.'
exit 0
