#!/bin/sh
#
# Simple wattage meter for Apple silicon macbooks.
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
    #Add udev rule.
    echo 'ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/sh /usr/share/asahi-misc/power.sh powersave off"' | $ROOTCMD tee > /etc/udev/rules.d/10-powersave.rules
    echo 'ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/sh /usr/share/asahi-misc/power.sh powersave on"' | $ROOTCMD tee >> /etc/udev/rules.d/10-powersave.rules
    echo 'KERNEL=="macsmc-battery", SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}="80"' | $ROOTCMD tee >> /etc/udev/rules.d/10-powersave.rules
}

uninstall () {
    $ROOTCMD rm /etc/udev/rules.d/10-powersave.rules
}

powersave () {
echo $1
    if [[ $1 == "on" ]]; then
        echo "conservative" | $ROOTCMD tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        echo 5 | $ROOTCMD tee /proc/sys/vm/laptop_mode
        $ROOTCMD iw dev wlan0 set power_save on
        echo "Powersavings enabled."
    else
        echo "performance" | $ROOTCMD tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        echo 0 | $ROOTCMD tee /proc/sys/vm/laptop_mode
        $ROOTCMD iw dev wlan0 set power_save off
        echo "Powersavings disabled."
    fi
}

status () {
    CURRENT=$(cat /sys/class/power_supply/macsmc-battery/current_now)
    VOLTAGE=$(cat /sys/class/power_supply/macsmc-battery/voltage_now)
    STATE=$(cat /sys/class/power_supply/macsmc-battery/status)

    awk "BEGIN {printf \"%.2f W $STATE\n\", $(($CURRENT * $VOLTAGE)) / 1000000000000 }"
}

case $1 in
  install)
    echo "Installing power management udev rules..."
    install
    ;;

  uninstall)
    echo "Uninstalling power management udev rules..."
    uninstall
    ;;
  powersave)
    powersave $2
    ;;
  status)
    status
    ;;

  *)
    echo "Unknown argument."
    echo "List of available arguments:"
    echo "install   - Installs the udev rule."
    echo "uninstall - Uninstalls the udev rule."
    echo "powersave - Sets the powersave mode."
    echo "status    - Displays power information"
    ;;
esac
