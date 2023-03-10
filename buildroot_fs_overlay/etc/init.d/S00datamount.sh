#!/bin/sh

DEVICE_FILE="/dev/mtdblock1"
MOUNTPOINT="/data"
MOUNT_OPTIONS="noatime,rw,sync,errors=remount-ro" 

start() {
	echo "Mount $DEVICE_FILE to $MOUNTPOINT"

	echo " * Check"
	fsck.ext4 -y "$DEVICE_FILE"
	if [[ $? -gt 2 ]] ; then
		echo "Check failed! -> (Re-)Initialize"
		echo " * Format"
		mkfs.ext4 -t ext4 -F "$DEVICE_FILE"
		if [[ $? != 0 ]] ; then
			echo "mkfs.ext4 failed -> ABORT!"
			return 1
		fi
	fi

	echo " * Mount"
	mount "$DEVICE_FILE" "$MOUNTPOINT" -t ext4 -o "$MOUNT_OPTIONS"
	if [[ $? != 0 ]] ; then
		echo "Mount failed -> ABORT!"
		return 1
	fi
	
	return 0
}

stop() {
	echo "Umount $MOUNTPOINT"
	mount "$MOUNTPOINT" -o remount,ro
	sleep 1
	sync
	umount "$MOUNTPOINT"
}

restart() {
	stop
	sleep 1
	start
}

case "$1" in
	start|stop|restart)
		"$1";;
	reload)
		# Restart, since there is no true "reload" feature.
		restart;;
	*)
		echo "Usage: $0 {start|stop|restart|reload}"
		exit 1
esac
