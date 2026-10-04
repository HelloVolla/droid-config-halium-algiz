#!/bin/sh

GUEST_DIR=/userdata/.abm-guest
ROOTFS=/var/lib/lxc/android/rootfs

n=0
while [ "$(systemctl show -p SubState --value mount-android.service)" = "running" ] && [ $n -lt 300 ]; do
	sleep 0.1
	n=$((n+1))
done

mountpoint -q /userdata && mkdir -p $GUEST_DIR || GUEST_DIR=

if mountpoint -q /mnt/vendor/persist; then
	if [ -n "$GUEST_DIR" ] && [ ! -d $GUEST_DIR/persist ]; then
		rm -rf $GUEST_DIR/persist.tmp
		cp -a /mnt/vendor/persist $GUEST_DIR/persist.tmp && sync && \
			mv $GUEST_DIR/persist.tmp $GUEST_DIR/persist
	fi
	if [ -z "$GUEST_DIR" ] || [ ! -d $GUEST_DIR/persist ] || \
		! mount -o bind $GUEST_DIR/persist /mnt/vendor/persist; then
		echo "no private persist, remounting host persist read-only"
		mount -o remount,ro /mnt/vendor/persist
	fi
fi

if mountpoint -q /metadata; then
	if [ -z "$GUEST_DIR" ] || ! mkdir -p $GUEST_DIR/metadata || \
		! mount -o bind $GUEST_DIR/metadata /metadata; then
		echo "no private metadata, remounting host metadata read-only"
		mount -o remount,ro /metadata
	fi
	mountpoint -q $ROOTFS/metadata && mount -o bind /metadata $ROOTFS/metadata
fi

exit 0
