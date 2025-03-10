%package -n patterns-sailfish-device-configuration-halium-algiz
Summary: Sailfish HW Adaptation halium-algiz

Requires: patterns-sailfish-device-configuration-common-halium-algiz
Requires: patterns-sailfish-device-adaptation-halium-algiz

Requires: patterns-sailfish-cellular-apps
Requires: patterns-sailfish-applications
Requires: patterns-sailfish-ui

# jolla-rnd-device will enable usb-moded even when UI is not yet
# brought up (useful during development, available since update10)
Requires: jolla-rnd-device

Requires: sailfish-content-graphics-z1.5

# For NFC
Requires: jolla-settings-system-nfc

# For flashlight control
Requires: jolla-settings-system-flashlight

# For multi-SIM devices
Requires: jolla-settings-networking-multisim

# Introduced starting Sailfish OS 2.0.4.x:
# 3rd party accounts like Twitter, VK, cloud services, etc
Requires: jolla-settings-accounts-extensions-3rd-party-all

# Introduced starting Sailfish OS 2.1.1.26
# Required for Jolla Store Access
Requires: patterns-sailfish-consumer-generic

Requires: jolla-settings-accounts-extensions-3rd-party-all

# For Mozilla location services (online)
Requires: geoclue-provider-mlsdb

# Sailfish OS CSD tool for hardware testing
Requires: csd

# Devices with 2G or more memory should also include this booster
# to improve camera startup times and the like
Requires: mapplauncherd-booster-silica-qt5-media

#Add FP support
Requires: sailfish-fpd-community
Requires: sailfish-devicelock-fpd
#Requires: droid-fake-crypt

#WLAN
Requires: sailfish-connman-plugin-tethering-wmtwifi

#Debug tools
Recommends: vi
Recommends: strace
Recommends: gdb
Recommends: mce-tools

#Sailfish porter tools
Recommends: jolla-developer-mode
Recommends: sailfishsilica-qt5-demos
Recommends: busybox-static
Recommends: net-tools
Recommends: openssh-clients
Recommends: openssh-server
Recommends: vim-enhanced
Recommends: zypper
Recommends: strace
Recommends: jolla-rnd-device

%description -n patterns-sailfish-device-configuration-halium-algiz
Pattern with packages for halium-algiz configurations

%files -n patterns-sailfish-device-configuration-halium-algiz
