# asahi-misc
A set of miscellaneous shell scripts that do various fun things on asahi linux.

# Disclaimer!
The bootloader script requires linux-asahi-edge, If you use something different<br />
then pleasee change it in the script, Additionally please double check that the<br />
ROOTUUID is correct, Otherwise the bootloader might fail to boot you back to asahi.<br />
These scripts were tested on asahi linux (Arch linux ARM) on an M2 MacbookAir 13 inch.<br />

# How to install
```
git clone https://github.com/AmirDahan/asahi-misc
chmod +x asahi-misc/*
sudo mv asahi-misc /usr/share
```

# What does this thing do?
**bootloader.sh**<br />
``install``: Installs a pacman hook that automatically regenerates the bootloader when updating.<br />
``uninstall``: Uninstalls the pacman hook.<br />
``generate``: Manually regenerates the bootloader, use the ``def`` argument to use defaults.<br />

**custom-splash.sh**<br />
Changes the image shown during the boot process. (Specify a full path to an image when running)<br />

**power.sh**<br />
``install``: Installs a udev rule to improve powersavings.<br />
``uninstall``: Uninstalls the powersaving udev rule.<br />
``powersave``: Manually set the powersavings mode to either ``on`` or ``off``.<br />
``status``: Display charge/discharge wattage and battery state.<br />

# What and why?
**bootloader.sh**<br />
The bootloader script was created because i was bothered by the fact that there's 3 layers of bootloaders,<br />
Ideally on a normal system you should only need UEFI act as your bootloader, Maybe grub if you dualboot.<br />

But on Apple silicon you have to go through this mess ``iBoot -> m1n1 -> u-boot -> grub -> Linux``<br />
Using the bootloader script should reduce this mess to ``iBoot -> m1n1 -> Linux``<br />

It's ideal if you don't wanna wait 3 seconds followed by 5 more when booting and dont want to boot from an external device.<br />

**custom-splash.sh**<br />
The custom splash script was created because customization options and style points.<br />
I'm not sure if it's possible to completely change the asahi logo on boot but this is good enough.<br />

**power.sh**<br />
The power script was created because i thought it would be cool to have the performance cores disabled when on battery power<br />
and not doing something intensive.<br />
Then i realized that you can't turn off those cores yet, My solution? "Underclock" on battery and Turbo when ac power.<br />
The power script should also in theory limit the battery's maximal charge state to 80% but that doesn't seem to be working atm...<br />
