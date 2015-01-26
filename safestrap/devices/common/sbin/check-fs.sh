#!/sbin/bbx sh
# By: Hashcode
PATH=/sbin:/system/xbin:/system/bin

# system/userdata/cache
LOOP_DEV=${1}
BBX=/sbin/bbx
SS_CONFIG=/ss.config

. /sbin/ss_function.sh
readConfig

if [ "$USERDATA_FSTYPE" = "ext3" ] && [ "$LOOP_DEV" = "-userdata" ]; then
	fsck.ext3 $BLOCK_DIR/loop$LOOP_DEV
else
	e2fsck -pfvy $BLOCK_DIR/loop$LOOP_DEV
fi

