#!/sbin/bbx sh
# By: Hashcode
PATH=/sbin:/system/xbin:/system/bin

# system/userdata/cache
IMAGE_NAME=`echo '${1}' | tr '[a-z]' '[A-Z]'`
LOOP_DEV=${2}
ROMSLOT_NAME=${3}
BBX=/sbin/bbx
SS_CONFIG=/ss.config
DISABLE_JOURNAL=


. /sbin/ss_function.sh
readConfig

eval CURRENT_BLOCK=\$BLOCK_${IMAGE_NAME}

$BBX rm $BLOCK_DIR/$CURRENT_BLOCK
$BBX ln -s $BLOCK_DIR/loop$LOOP_DEV $BLOCK_DIR/$CURRENT_BLOCK

if [ "$SS_USE_DATAMEDIA" = "1" ]; then
	DISABLE_JOURNAL="-O ^has_journal"
fi

# Ensure the system is the correct fs type after rom-slot creation
if [ "$LOOP_DEV" = "-system" ]; then
	mke2fs -t $SYSTEM_FSTYPE -m 0 $BLOCK_DIR/loop$LOOP_DEV
	e2fsck -p -v $BLOCK_DIR/loop$LOOP_DEV
	mount -t $SYSTEM_FSTYPE $BLOCK_DIR/loop$LOOP_DEV /system
fi

#Same for userdata
if [ "$LOOP_DEV" = "-userdata" ]; then
	mke2fs -t $USERDATA_FSTYPE -m 0 $BLOCK_DIR/loop$LOOP_DEV
	e2fsck -p -v $BLOCK_DIR/loop$LOOP_DEV
	mount -t $USERDATA_FSTYPE $BLOCK_DIR/loop$LOOP_DEV /data
fi

#And finally for cache
if [ "$LOOP_DEV" = "-cache" ]; then
	mke2fs -t $USERDATA_FSTYPE -m 0 $BLOCK_DIR/loop$LOOP_DEV
	e2fsck -p -v $BLOCK_DIR/loop$LOOP_DEV
	mount -t $USERDATA_FSTYPE $BLOCK_DIR/loop$LOOP_DEV /cache
fi
