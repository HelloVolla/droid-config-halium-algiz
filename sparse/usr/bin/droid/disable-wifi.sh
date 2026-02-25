#!/bin/bash
if [ -e "/dev/wmtWifi" ]; then
	echo 0 > /dev/wmtWifi
fi
