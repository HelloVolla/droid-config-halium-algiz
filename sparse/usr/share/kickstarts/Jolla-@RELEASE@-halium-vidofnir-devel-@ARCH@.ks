# DisplayName: Jolla dont_be_evil/@ARCH@ (release) 1
# KickstartType: release
# SuggestedImageType: fs
# SuggestedArchitecture: armv7hl

timezone --utc UTC

### Commands from /tmp/sandbox/usr/share/ssu/kickstart/part/default
part / --fstype="ext4" --size=8000 --label=root

## No suitable configuration found in /tmp/sandbox/usr/share/ssu/kickstart/bootloader

repo --name=adaptation-community-algiz-@RELEASE@ --baseurl=http://repo.sailfishos.org/obs/nemo:/devel:/hw:/volla:/halium-algiz/sailfish_latest_@ARCH@/
repo --name=adaptation-community-halium12-@RELEASE@ --baseurl=http://repo.sailfishos.org/obs/nemo:/devel:/hw:/halium:/12/sailfish_latest_@ARCH@/
repo --name=adaptation-community-common-halium-@RELEASE@ --baseurl=http://repo.sailfishos.org/obs/nemo:/devel:/hw:/common/sailfish_latest_@ARCH@/

repo --name=sailfishos-chum-@RELEASE@ --baseurl=http://repo.sailfishos.org/obs/sailfishos:/chum/@RELEASE@_@ARCH@/
repo --name=adaptation-common-@RELEASE@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla-hw/adaptation-common/@ARCH@/
repo --name=apps-@RELEASE@ --baseurl=https://releases.jolla.com/jolla-apps/@RELEASE@/@ARCH@/
repo --name=hotfixes-@RELEASE@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/hotfixes/@ARCH@/
repo --name=jolla-@RELEASE@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla/@ARCH@/

%packages
patterns-sailfish-device-configuration-halium-algiz
%end

%attachment
#Copy some files out of the image for the user to flash
/boot/boot.img
/etc/hw-release
droid-config-halium-algiz-out-of-image-files
%end

%pre
export SSU_RELEASE_TYPE=release
### begin 01_init
touch $INSTALL_ROOT/.bootstrap
### end 01_init
%end

%post
### later we need to move here the kernel and modules

export SSU_RELEASE_TYPE=release
### begin 01_arch-hack
if [ "@ARCH@" == armv7hl ] || [ "@ARCH@" == armv7tnhl ]; then
    # Without this line the rpm does not get the architecture right.
    echo -n "@ARCH@-meego-linux" > /etc/rpm/platform

    # Also libzypp has problems in autodetecting the architecture so we force tha as well.
    # https://bugs.meego.com/show_bug.cgi?id=11484
    echo "arch = @ARCH@" >> /etc/zypp/zypp.conf
fi
### end 01_arch-hack
### begin 01_rpm-rebuilddb
# Rebuild db using target's rpm
echo -n "Rebuilding db using target rpm.."
rm -f /var/lib/rpm/__db*
rpm --rebuilddb
echo "done"
### end 01_rpm-rebuilddb
### begin 50_oneshot
# exit boostrap mode
rm -f /.bootstrap

# export some important variables until there's a better solution
export LANG=en_US.UTF-8
export LC_COLLATE=en_US.UTF-8
export GSETTINGS_BACKEND=gconf

# run the oneshot triggers for root and first user uid
UID_MIN=$(grep "^UID_MIN" /etc/login.defs |  tr -s " " | cut -d " " -f2)
DEVICEUSER=`getent passwd $UID_MIN | sed 's/:.*//'`

if [ -x /usr/bin/oneshot ]; then
   /usr/bin/oneshot --mic
   su -c "/usr/bin/oneshot --mic" $DEVICEUSER
fi
### end 50_oneshot
### begin 60_ssu
if [ "$SSU_RELEASE_TYPE" = "rnd" ]; then
    [ -n "@RNDRELEASE@" ] && ssu release -r @RNDRELEASE@
    [ -n "@RNDFLAVOUR@" ] && ssu flavour @RNDFLAVOUR@
    # RELEASE is reused in RND setups with parallel release structures
    # this makes sure that an image created from such a structure updates from there
    [ -n "@RELEASE@" ] && ssu set update-version @RELEASE@
    ssu mode 2
else
    [ -n "@RELEASE@" ] && ssu release @RELEASE@
    ssu mode 4
fi
### end 60_ssu
### begin 70_sdk-domain

export SSU_DOMAIN=@RNDFLAVOUR@

if [ "$SSU_RELEASE_TYPE" = "release" ] && [[ "$SSU_DOMAIN" = "public-sdk" ]];
then
    ssu domain sailfish
fi
### end 70_sdk-domain

### Group_setup
#Add Android groups/users
groupadd system --gid     1000
groupadd radio --gid      1001
groupadd bluetooth --gid  1002
groupadd graphics --gid   1003
groupadd camera --gid     1006
groupadd log --gid        1007
groupadd compass --gid    1008
groupadd mount --gid      1009
groupadd wifi --gid       1010
groupadd media --gid       1013
groupadd dhcp --gid       1014
groupadd adb --gid        1011
groupadd install --gid    1012
groupadd media --gid      1013
groupadd drm --gid        1019
groupadd gps --gid        1021
groupadd nfc --gid        1027
groupadd shell --gid      2000
groupadd cache --gid      2001
groupadd diag --gid       2002
groupadd net_bt_admin --gid  3001
groupadd net_bt --gid     3002
groupadd inet --gid       3003
groupadd net_raw --gid    3004
groupadd misc --gid       9998

useradd system --uid 1000 -g system -r -s /sbin/nologin
useradd radio --uid 1001 -g radio -r -s /sbin/nologin
useradd bluetooth --uid 1002 -g bluetooth -r -s /sbin/nologin
useradd wifi --uid 1010 -g wifi -r -s /sbin/nologin
useradd media --uid 1013 -g media -r -s /sbin/nologin
useradd drm --uid 1019 -g drm -r -s /sbin/nologin
useradd gps --uid 1021 -g gps -r -s /sbin/nologin
useradd nfc --uid 1027 -g nfc -r -s /sbin/nologin
### end group_setup

touch /.writable_image
%end

%post --nochroot
export SSU_RELEASE_TYPE=release
### begin 01_release
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi
### end 01_release
%end

%pack

echo "start pack"
echo $IMG_OUT_DIR
echo `pwd`
find
echo "end pack"
%end
