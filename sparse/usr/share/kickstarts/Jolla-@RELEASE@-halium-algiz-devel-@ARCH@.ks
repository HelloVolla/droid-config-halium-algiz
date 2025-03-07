# DisplayName: Jolla algiz/@ARCH@ (release) 1
# KickstartType: release
# SuggestedImageType: fs
# SuggestedArchitecture: armv7hl

timezone --utc UTC

### Commands from /tmp/sandbox/usr/share/ssu/kickstart/part/default
part / --fstype="ext4" --size=7160 --label=root

## No suitable configuration found in /tmp/sandbox/usr/share/ssu/kickstart/bootloader

repo --name=adaptation-community-algiz-@RELEASE@ --baseurl=http://repo.sailfishos.org/obs/nemo:/devel:/hw:/volla:/halium-algiz/sailfish_latest_@ARCH@/
repo --name=adaptation-community-halium13-@RELEASE@ --baseurl=http://repo.sailfishos.org/obs/nemo:/devel:/hw:/halium:/13/sailfish_latest_@ARCH@/
repo --name=adaptation-community-common-@RELEASE@ --baseurl=http://repo.sailfishos.org/obs/nemo:/devel:/hw:/common/sailfish_latest_@ARCH@/

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

int_groupadd() {
  name=$1
  id=$2

  if ! getent group $name; then
        if getent group $id; then
            other_name=$(getent group $id 2>/dev/null |cut -d":" -f1)
            echo "Group $name did not exist yet, but another group has the same id ($id, $other_name), renaming that group"
            groupmod -g $id -n $name $other_name || :
        else
            echo "Group $name did not exist yet"
            groupadd -g $id $name || :
        fi
    else
        echo "Group $name already existed, modifying it"
        groupmod -g $id $name || :
    fi
}

#Add Android groups/users
int_groupadd system      1000
int_groupadd radio       1001
int_groupadd bluetooth   1002
int_groupadd graphics    1003
int_groupadd input       1004
int_groupadd audio       1005
int_groupadd camera      1006
int_groupadd log         1007
int_groupadd compass     1008
int_groupadd mount       1009
int_groupadd wifi        1010
int_groupadd adb         1011
int_groupadd install     1012
int_groupadd media       1013
int_groupadd dhcp        1014
int_groupadd drm         1019
int_groupadd gps         1021
int_groupadd nfc         1027
int_groupadd shell       2000
int_groupadd cache       2001
int_groupadd diag        2002
int_groupadd net_bt_admin   3001
int_groupadd net_bt      3002
int_groupadd inet        3003
int_groupadd net_raw     3004
int_groupadd misc        9998

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
