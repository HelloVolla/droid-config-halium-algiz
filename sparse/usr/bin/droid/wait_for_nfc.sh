#!/bin/sh
while [ "$(binder-list -d /dev/hwbinder |grep android.hardware.nfc@1.0::INfc/default)" == "" ]; do
	echo "Waiting for hwc"
	sleep 1
done

exit 0
