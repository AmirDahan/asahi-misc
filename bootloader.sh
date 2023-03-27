#!/bin/bash
#
# This script will help you skip uboot and grub when booting.
#

#Autodetect root elevator.
ROOTCMD="su"
if [ -f /usr/bin/sudo ]; then
    ROOTCMD="sudo"
elif [ -f /usr/bin/doas ]; then
    ROOTCMD="doas"
fi

download () {
    #Install or update m1n1.
    cd /tmp
    git clone https://github.com/AsahiLinux/m1n1
    cd m1n1
    make RELEASE=1

    #Move the bootloader to the local bin dir.
    $ROOTCMD mv ./build/m1n1.bin /usr/local/bin/m1n1.bin

    #Cleanup
    cd ..
    rm -rf m1n1
}

generate () {
    BINPATH="/usr/local/bin/m1n1.bin"
    INITRD="/boot/initramfs-linux-asahi-edge.img"
    KERNEL="/boot/vmlinuz-linux-asahi-edge"
    PARAMETERS="loglevel=3 quiet nmi_watchdog=0"

    #Automatic root UUID detection.
    ROOTUUID=$(cat /etc/fstab | grep "/ ext4" | cut -d ' ' -f 1 | cut -d '=' -f2)

    #DTB path.
    DTBDIR="/usr/lib/modules/$(uname -r)/dtbs/*.dtb"

    #Notch detection.
    NOTCH=""
    MODEL=$(tr -d '\0' < /sys/firmware/devicetree/base/model)
    case $MODEL in
      "MacBook Pro (14-inch, M1, 2021)" | "MacBook Pro (16-inch, M1, 2021)" | "MacBook Pro (14-inch, M2, 2023)" | "MacBook Pro (16-inch, M2, 2023)" | "Apple MacBook Air (13-inch, M2, 2022)")
        NOTCH="apple_dcp.show_notch=1"
        ;;
    esac

    #Full commandline arguments.
    CMDLINE="chosen.bootargs=earlycon root=UUID=$ROOTUUID rw $NOTCH $PARAMETERS"

    if [[ $1 != "def" ]]; then
        echo "Enter the location of m1n1: (Default: /usr/local/bin/m1n1.bin)"
        read BINPATH

        echo "Enter the location of the kernel: (Default: /boot/vmlinuz-linux-asahi-edge)"
        read KERNEL

        echo "Enter the location of initramfs: (Default: /boot/initramfs-linux-asahi-edge.img)"
        read INITRD

        echo "Enter optional kernel parameters: (Default: loglevel=3 quiet nmi_watchdog=0)"
        read PARAMETERS
        CMDLINE="chosen.bootargs=earlycon root=UUID=$ROOTUUID rw $NOTCH $PARAMETERS"

        echo "Root UUID is: $ROOTUUID"
        echo "DTBs location: $DTBDIR"
        echo "Initrd is: $INITRD"
        echo "Kernel is: $KERNEL"
        echo "Kernel parameters: $CMDLINE"
    fi

    #Validate that the files exist.
    echo "Checking files..."
    if [[ -f "$BINPATH" ]] && [[ -f "$KERNEL" ]] && [[ -f "$INITRD" ]]; then
        echo "All is good, Proceeding..."
    else
        echo "Errors were found, Aborting..."
        exit
    fi

    #Compress the kernel and initramfs.
    echo "Compressing kernel and initramfs..."
    $ROOTCMD gzip -k1 $INITRD
    $ROOTCMD gzip -k1 $KERNEL

    #Backup the old bootloader.
    echo "Backing up the previous version of the bootloader..."
    $ROOTCMD mv /boot/efi/m1n1/boot.bin /boot/efi/m1n1/boot.bin.old

    #Generate the bootloader
    echo "Generating m1n1 binary..."
    $ROOTCMD su -c "cat $BINPATH \
        <(echo $CMDLINE) \
        $DTBDIR \
        $INITRD.gz \
        $KERNEL.gz \
        > /boot/efi/m1n1/boot.bin"

    #Cleanup
    $ROOTCMD rm $KERNEL.gz $INITRD.gz
}

case $1 in

  download)
    echo "Downloading/Updating m1n1 binary..."
    download
    ;;

  generate)
    echo "Generating/Regenerating bootloader file..."
    generate $2
    ;;

  *)
    echo "Unknown argument."
    echo "List of available arguments:"
    echo "download - Downloads or Updates the m1n1 bootloader binary."
    echo "generate - Generates or Regenerates the bootloader binary."
    ;;
esac

