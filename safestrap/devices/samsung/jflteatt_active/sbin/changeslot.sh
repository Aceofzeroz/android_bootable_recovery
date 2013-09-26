#!/sbin/bbx sh
# By: Hashcode
# Last Editted: 09/19/2013
SS_SLOT=${1}
BLOCK_DIR=/dev/block

BLOCK_SYSTEM=mmcblk0p16
BLOCK_USERDATA=mmcblk0p27
BLOCK_CACHE=mmcblk0p18
BLOCK_BOOT=mmcblk0p20

SS_MNT=/ss
SS_DIR=$SS_MNT/safestrap

/sbin/bbx umount /system
/sbin/bbx umount /data
/sbin/bbx umount /cache
/sbin/bbx umount /boot

/sbin/bbx rm $BLOCK_DIR/$BLOCK_SYSTEM
/sbin/bbx rm $BLOCK_DIR/$BLOCK_USERDATA
/sbin/bbx rm $BLOCK_DIR/$BLOCK_CACHE
/sbin/bbx rm $BLOCK_DIR/$BLOCK_BOOT
/sbin/bbx losetup -d $BLOCK_DIR/loop-system
/sbin/bbx losetup -d $BLOCK_DIR/loop-userdata
/sbin/bbx losetup -d $BLOCK_DIR/loop-cache
/sbin/bbx losetup -d $BLOCK_DIR/loop-boot

if [ "$SS_SLOT" = "stock" ]; then
	/sbin/bbx ln -s $BLOCK_DIR/$BLOCK_SYSTEM-orig $BLOCK_DIR/$BLOCK_SYSTEM
	/sbin/bbx ln -s $BLOCK_DIR/$BLOCK_USERDATA-orig $BLOCK_DIR/$BLOCK_USERDATA
	/sbin/bbx ln -s $BLOCK_DIR/$BLOCK_CACHE-orig $BLOCK_DIR/$BLOCK_CACHE
#	/sbin/bbx ln -s $BLOCK_DIR/$BLOCK_BOOT-orig $BLOCK_DIR/$BLOCK_BOOT
	/sbin/bbx ln -s /dev/null $BLOCK_DIR/$BLOCK_BOOT
else
	/sbin/bbx losetup $BLOCK_DIR/loop-system $SS_DIR/$SS_SLOT/system.img
	/sbin/bbx losetup $BLOCK_DIR/loop-userdata $SS_DIR/$SS_SLOT/userdata.img
	/sbin/bbx losetup $BLOCK_DIR/loop-cache $SS_DIR/$SS_SLOT/cache.img
#	/sbin/bbx losetup $BLOCK_DIR/loop-boot $SS_DIR/$SS_SLOT/boot.img
	/sbin/bbx ln -s $BLOCK_DIR/loop-system $BLOCK_DIR/$BLOCK_SYSTEM
	/sbin/bbx ln -s $BLOCK_DIR/loop-userdata $BLOCK_DIR/$BLOCK_USERDATA
	/sbin/bbx ln -s $BLOCK_DIR/loop-cache $BLOCK_DIR/$BLOCK_CACHE
#	/sbin/bbx ln -s $BLOCK_DIR/loop-boot $BLOCK_DIR/$BLOCK_BOOT
	/sbin/bbx ln -s /dev/null $BLOCK_DIR/$BLOCK_BOOT
fi
/sbin/bbx echo "$SS_SLOT" > $SS_DIR/active_slot
