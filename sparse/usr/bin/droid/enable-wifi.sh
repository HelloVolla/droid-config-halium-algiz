#!/bin/bash


# Wait for the property system to be up.
while [ ! -e /dev/socket/property_service ]; do sleep 0.1; done

# Wait for nvram to be loaded.
while [ "$(getprop vendor.service.nvram_init)" != "Ready" ]; do sleep 0.2; done


# Load device-specific connectivity kernel modules starting with WLAN
modprobe wmt_chrdev_wifi
modprobe wlan_drv_gen4m

# Silence all wlan debug logging down to just errors/warnings
printf '0xFF:0x03' > /proc/net/wlan/dbgLevel

# Load other connectivity kernel modules as well now
modprobe bt_drv_6877
modprobe gps_drv
modprobe fmradio_drv_connac2x

# Wait for nvram yet again..
while [ "$(getprop vendor.mtk.nvram.ready)" != "1" ]; do sleep 0.2; done

# Wait for /dev/wmtWifi to exist..
while [ ! -c /dev/wmtWifi ]; do sleep 0.2; done

# Avoid ap0 interface getting created on some boots
sleep 1

# Finally enable the adapter in station mode
echo P > /dev/wmtWifi


# Enable WoWLAN to avoid network disconnect before suspend
while [ ! -e /sys/class/ieee80211/phy0 ]; do sleep 1; done
iw phy phy0 wowlan enable magic-packet
