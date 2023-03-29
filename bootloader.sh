#!/bin/bash
#
# This script will help you skip uboot and grub when booting.
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

install () {
    #Check if the hooks directory exists.
    if [ ! -d "/etc/pacman.d/hooks" ]; then
        $ROOTCMD mkdir /etc/pacman.d/hooks
    fi

    #Install the update hook.
    echo "[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux-asahi-edge
Target = mkinitcpio
Target = m1n1

[Action]
Description = Improve boot process
When = PostTransaction
Exec = /usr/share/asahi-misc/bootloader.sh generate def
Depends = linux-asahi-edge
Depends = mkinitcpio
Depends = m1n1" | $ROOTCMD tee /etc/pacman.d/hooks/update-bootloader.hook
}

uninstall () {
    if [ -f "/etc/pacman.d/hooks/update-bootloader.hook" ]; then
        $ROOTCMD rm /etc/pacman.d/hooks/update-bootloader.hook
    fi
}

generate () {
    BINPATH="/usr/lib/asahi-boot/m1n1.bin"
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

    if [[ $1 != "def" ]]; then
        echo "Enter the location of m1n1: (Default: $BINPATH)"
        read BINPATH

        echo "Enter the location of the kernel: (Default: $KERNEL)"
        read KERNEL

        echo "Enter the location of initramfs: (Default: $INITRD)"
        read INITRD

        echo "Enter optional kernel parameters: (Default: $PARAMETERS)"
        read PARAMETERS
    fi

    #Full commandline arguments.
    CMDLINE="chosen.bootargs=earlycon root=UUID=$ROOTUUID rw $NOTCH $PARAMETERS"

    #Verification.
    echo "Root UUID is: $ROOTUUID"
    echo "DTBs location: $DTBDIR"
    echo "Initrd is: $INITRD"
    echo "Kernel is: $KERNEL"
    echo "Kernel parameters: $CMDLINE"

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

  install)
    install
    ;;
  uninstall)
    uninstall
    ;;
  generate)
    generate $2
    ;;

  *)
    echo "Unknown argument."
    echo "List of available arguments:"
    echo "install - Installs a packman hook to regenerate the bootloader when updating."
    echo "uninstall - Uninstall the pacman hook."
    echo "generate - Regenerate the bootloader manually."
    ;;
esac

