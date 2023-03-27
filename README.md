# asahi-misc
A set of miscellaneous bash scripts that do various fun things on asahi linux.

# Disclaimer!
These scripts are highly experimental and have the potential to break your installation of asahi linux.<br />
Recovering is possible though, And protection against misconfigured settings exist.<br />
But still, Keep that in mind.<br />
These scripts were tested on asahi linux (Arch linux ARM) on an M2 MacbookAir 13 inch.<br />

# How to install
```
git clone https://github.com/AmirDahan/asahi-misc
chmod +x asahi-misc/*
sudo mv asahi-misc /usr/share
```

# What does this thing do?

**bootloader.sh**<br />
``download``: Downloads or updates the m1n1 bootloader from https://github.com/AsahiLinux/m1n1 and puts the file in /usr/local/bin<br />
``generate``: Backs up the bootloader and generates a new one with an integrated kernel, initramfs and parameters.<br />

**power.sh**<br />
``install``: Installs a udev rule to improve powersavings.<br />
``uninstall``: Uninstalls the powersaving udev rule.<br />
``powersave``: Manually set the powersavings mode to either ``on`` or ``off``.<br />
``status``: Display charge/discharge wattage and battery state.<br />

# What and why?
The bootloader script was created because i was bothered by the fact that there's 3 layers of bootloaders,<br />
Ideally on a normal system you should only need UEFI act as your bootloader, Maybe grub if you dualboot.<br />

But on Apple silicon you have to go through this mess ``iBoot -> m1n1 -> u-boot -> grub -> Linux``<br />
Using the bootloader script should reduce this mess to ``iBoot -> m1n1 -> Linux``<br />

It's ideal if you don't wanna wait 3 seconds followed by 5 more when booting and dont want to boot from an external device.<br />

The power script was created because i thought it would be cool to have the performance cores disabled when on battery power and not<br />
doing something intensive.<br />
Then i realized that you can't turn off those cores yet, My solution? Underclock and Turbo when on battery or ac power.<br />
The power script should also in theory limit the battery's maximal charge state to 80% but that doesn't seem to be working atm...<br />
