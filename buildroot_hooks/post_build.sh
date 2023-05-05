#!/bin/bash

echo "Post-Build: begin"

echo " + make udev and Xorg start up optional"
mkdir -p $TARGET_DIR/etc/init.d/optional_xorg
for file in \
	$TARGET_DIR/etc/init.d/S??udev \
	$TARGET_DIR/etc/init.d/S??xorg \
	; do
	[[ -e $file ]] && mv $file $TARGET_DIR/etc/init.d/optional_xorg
done

echo "Post-Build: done"
