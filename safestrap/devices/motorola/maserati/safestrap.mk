#include $(ANDROID_BUILD_TOP)/bootable/recovery/safestrap/devices/common/safestrap-common.mk
include $(ANDROID_BUILD_TOP)/bootable/recovery/safestrap/devices/motorola/common-omap4/safestrap-common-omap4.mk

TW_BRIGHTNESS_PATH := /sys/class/backlight/lm3532_bl/brightness
