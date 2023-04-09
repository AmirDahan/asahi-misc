#!/bin/sh
#
# This script generates an m1n1 binary with a custom boot image.
#

#Autodetect root elevator.
ROOTCMD=""
if [[ $(whoami) != "root" ]]; then
    if [ -f /usr/bin/sudo ]; then
        ROOTCMD="sudo"
    elif [ -f /usr/bin/doas ]; then
        ROOTCMD="doas"
    else
        ROOTCMD="su"
    fi
fi

#Check if imagemagick is installed.
which convert  || { echo 'ImageMagick not installed.'; exit 1; }

#Check if an image was specified.
if [[ ! -f $1 ]]; then
    echo "File not found or specified."
    echo "custom-splash.sh /path/to/image"
    exit
fi

#Note.
echo "Note: When m1n1 updates it will overwrite this and restore the original boot image.
So make sure to run this again after every bootloader update."

#Clone repo.
git clone -q https://github.com/AsahiLinux/m1n1
cd m1n1/data

#Image stuff.
cp $1 image-src.png
rm bootlogo_*
convert image-src.png -resize 128x128 bootlogo_128.png
convert image-src.png -resize 256x256 bootlogo_256.png
./makelogo.sh
cd ..

#Build & install.
make ARCH= RELEASE=1
$ROOTCMD mv build/m1n1.bin /usr/lib/asahi-boot/m1n1.bin
cd ..
rm -rf m1n1

#Tell the user what to do next.
echo "Please regenerate the bootloader using bootloader.sh generate def"
