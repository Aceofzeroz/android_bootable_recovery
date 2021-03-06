LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

ifeq ($(BUILD_SAFESTRAP), true)
  COMMON_GLOBAL_CFLAGS += -DBUILD_SAFESTRAP
  COMMON_GLOBAL_CPPFLAGS += -DBUILD_SAFESTRAP
endif

LOCAL_SRC_FILES := \
    gui.cpp \
    resources.cpp \
    pages.cpp \
    text.cpp \
    image.cpp \
    action.cpp \
    console.cpp \
    fill.cpp \
    button.cpp \
    checkbox.cpp \
    fileselector.cpp \
    progressbar.cpp \
    animation.cpp \
    object.cpp \
    slider.cpp \
    slidervalue.cpp \
    listbox.cpp \
    keyboard.cpp \
    input.cpp \
    blanktimer.cpp \
    partitionlist.cpp \
    mousecursor.cpp

ifneq ($(TWRP_CUSTOM_KEYBOARD),)
  LOCAL_SRC_FILES += $(TWRP_CUSTOM_KEYBOARD)
else
  LOCAL_SRC_FILES += hardwarekeyboard.cpp
endif

LOCAL_SHARED_LIBRARIES += libminuitwrp libc libstdc++
LOCAL_MODULE := libguitwrp

# Use this flag to create a build that simulates threaded actions like installing zips, backups, restores, and wipes for theme testing
#TWRP_SIMULATE_ACTIONS := true
ifeq ($(TWRP_SIMULATE_ACTIONS), true)
LOCAL_CFLAGS += -D_SIMULATE_ACTIONS
endif

#TWRP_EVENT_LOGGING := true
ifeq ($(TWRP_EVENT_LOGGING), true)
LOCAL_CFLAGS += -D_EVENT_LOGGING
endif

ifneq ($(RECOVERY_SDCARD_ON_DATA),)
	LOCAL_CFLAGS += -DRECOVERY_SDCARD_ON_DATA
endif
ifneq ($(TW_EXTERNAL_STORAGE_PATH),)
	LOCAL_CFLAGS += -DTW_EXTERNAL_STORAGE_PATH=$(TW_EXTERNAL_STORAGE_PATH)
endif
ifneq ($(TW_NO_SCREEN_BLANK),)
	LOCAL_CFLAGS += -DTW_NO_SCREEN_BLANK
endif
ifneq ($(TW_NO_SCREEN_TIMEOUT),)
	LOCAL_CFLAGS += -DTW_NO_SCREEN_TIMEOUT
endif
ifeq ($(HAVE_SELINUX), true)
LOCAL_CFLAGS += -DHAVE_SELINUX
endif
ifeq ($(TW_OEM_BUILD),true)
    LOCAL_CFLAGS += -DTW_OEM_BUILD
endif

# Safestrap virtual size defaults
ifndef BOARD_DEFAULT_VIRT_SYSTEM_SIZE
    BOARD_DEFAULT_VIRT_SYSTEM_SIZE := 600
endif
ifndef BOARD_DEFAULT_VIRT_SYSTEM_MIN_SIZE
    BOARD_DEFAULT_VIRT_SYSTEM_MIN_SIZE := 600
endif
ifndef BOARD_DEFAULT_VIRT_SYSTEM_MAX_SIZE
    BOARD_DEFAULT_VIRT_SYSTEM_MAX_SIZE := 1000
endif
LOCAL_CFLAGS += -DDEFAULT_VIRT_SYSTEM_SIZE=\"$(BOARD_DEFAULT_VIRT_SYSTEM_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_SYSTEM_MIN_SIZE=\"$(BOARD_DEFAULT_VIRT_SYSTEM_MIN_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_SYSTEM_MAX_SIZE=\"$(BOARD_DEFAULT_VIRT_SYSTEM_MAX_SIZE)\"
ifndef BOARD_DEFAULT_VIRT_DATA_SIZE
    BOARD_DEFAULT_VIRT_DATA_SIZE := 2000
endif
ifndef BOARD_DEFAULT_VIRT_DATA_MIN_SIZE
    BOARD_DEFAULT_VIRT_DATA_MIN_SIZE := 1000
endif
ifndef BOARD_DEFAULT_VIRT_DATA_MAX_SIZE
    BOARD_DEFAULT_VIRT_DATA_MAX_SIZE := 16000
endif
LOCAL_CFLAGS += -DDEFAULT_VIRT_DATA_SIZE=\"$(BOARD_DEFAULT_VIRT_DATA_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_DATA_MIN_SIZE=\"$(BOARD_DEFAULT_VIRT_DATA_MIN_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_DATA_MAX_SIZE=\"$(BOARD_DEFAULT_VIRT_DATA_MAX_SIZE)\"
ifndef BOARD_DEFAULT_VIRT_CACHE_SIZE
    BOARD_DEFAULT_VIRT_CACHE_SIZE := 300
endif
ifndef BOARD_DEFAULT_VIRT_CACHE_MIN_SIZE
    BOARD_DEFAULT_VIRT_CACHE_MIN_SIZE := 300
endif
ifndef BOARD_DEFAULT_VIRT_CACHE_MAX_SIZE
    BOARD_DEFAULT_VIRT_CACHE_MAX_SIZE := 1000
endif
LOCAL_CFLAGS += -DDEFAULT_VIRT_CACHE_SIZE=\"$(BOARD_DEFAULT_VIRT_CACHE_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_CACHE_MIN_SIZE=\"$(BOARD_DEFAULT_VIRT_CACHE_MIN_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_CACHE_MAX_SIZE=\"$(BOARD_DEFAULT_VIRT_CACHE_MAX_SIZE)\"

ifeq ($(DEVICE_RESOLUTION),)
$(warning ********************************************************************************)
$(warning * DEVICE_RESOLUTION is NOT SET in BoardConfig.mk )
$(warning * Please see http://tinyw.in/nP7d for details    )
$(warning ********************************************************************************)
$(error stopping)
endif

ifeq ($(BUILD_SAFESTRAP), true)
ifeq "$(wildcard bootable/recovery/safestrap/devices/common/res/$(DEVICE_RESOLUTION))" ""
$(warning ********************************************************************************)
$(warning * DEVICE_RESOLUTION ($(DEVICE_RESOLUTION)) does NOT EXIST in bootable/recovery/safestrap/devices/common/res )
$(warning * Please choose an existing theme or create a new one for your device )
$(warning ********************************************************************************)
$(error stopping)
endif
else
ifeq "$(wildcard bootable/recovery/gui/devices/$(DEVICE_RESOLUTION))" ""
$(warning ********************************************************************************)
$(warning * DEVICE_RESOLUTION ($(DEVICE_RESOLUTION)) does NOT EXIST in bootable/recovery/gui/devices )
$(warning * Please choose an existing theme or create a new one for your device )
$(warning ********************************************************************************)
$(error stopping)
endif
endif

LOCAL_C_INCLUDES += bionic external/stlport/stlport $(commands_recovery_local_path)/gui/devices/$(DEVICE_RESOLUTION)

include $(BUILD_STATIC_LIBRARY)

# Transfer in the resources for the device
include $(CLEAR_VARS)
LOCAL_MODULE := twrp
LOCAL_MODULE_TAGS := eng
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/res
TWRP_RES_LOC := $(commands_recovery_local_path)/gui/devices/common/res

ifdef BUILD_SAFESTRAP
SS_COMMON := $(commands_recovery_local_path)/safestrap
TWRP_RES_LOC := $(SS_COMMON)/devices/common/res/common/res
TWRP_THEME_LOC := $(SS_COMMON)/devices/common/res/$(DEVICE_RESOLUTION)/res
else
ifeq ($(TW_CUSTOM_THEME),)
	TWRP_THEME_LOC := $(commands_recovery_local_path)/gui/devices/$(DEVICE_RESOLUTION)/res
else
	TWRP_THEME_LOC := $(TW_CUSTOM_THEME)
endif
endif
TWRP_RES_GEN := $(intermediates)/twrp
ifneq ($(TW_USE_TOOLBOX), true)
	TWRP_SH_TARGET := /sbin/busybox
else
	TWRP_SH_TARGET := /sbin/mksh
endif

ifndef BUILD_SAFESTRAP
$(TWRP_RES_GEN):
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/res/
	cp -fr $(TWRP_RES_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)/res/
	cp -fr $(TWRP_THEME_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)/res/
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/sbin/
	ln -sf $(TWRP_SH_TARGET) $(TARGET_RECOVERY_ROOT_OUT)/sbin/sh
	ln -sf /sbin/pigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gzip
	ln -sf /sbin/unpigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gunzip
else
$(TWRP_RES_GEN):
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/res/
	cp -fr $(TWRP_RES_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)/res/
	cp -fr $(TWRP_THEME_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)/res/
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/sbin/
	ln -sf /sbin/busybox $(TARGET_RECOVERY_ROOT_OUT)/sbin/sh
	ln -sf /sbin/pigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gzip
	ln -sf /sbin/unpigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gunzip
	# Safestrap Setup
	rm -rf $(OUT)/2nd-init-files
	rm -rf $(OUT)/APP
	rm -rf $(OUT)/install-files
	mkdir -p $(OUT)/2nd-init-files
	mkdir -p $(OUT)/install-files/etc/safestrap/flags
	mkdir -p $(OUT)/install-files/etc/safestrap/res
	mkdir -p $(OUT)/APP
	cp -p $(SS_COMMON)/devices/common/2nd-init-files/* $(OUT)/2nd-init-files
	cp -p $(SS_COMMON)/devices/common/2nd-init-files/fixboot.sh $(OUT)/recovery/root/sbin/
	cp -p $(SS_COMMON)/devices/common/2nd-init-files/ss_function.sh $(OUT)/recovery/root/sbin/
	cp -p $(SS_COMMON)/devices/common/2nd-init-files/ss_function.sh $(OUT)/APP/
	cp -p $(SS_COMMON)/devices/common/2nd-init-files/ss_function.sh $(OUT)/install-files/etc/safestrap/
	cp -p $(SS_COMMON)/devices/common/APP/* $(OUT)/APP/
	cp -p $(SS_COMMON)/devices/common/sbin/* $(OUT)/recovery/root/sbin/
	cp -p $(SS_COMMON)/flags/* $(OUT)/install-files/etc/safestrap/flags/
	cp -p $(SS_COMMON)/bbx $(OUT)/install-files/etc/safestrap/bbx
	cp -p $(SS_COMMON)/busybox $(OUT)/APP/busybox
	cp -p $(SS_COMMON)/lfs $(TARGET_RECOVERY_ROOT_OUT)/sbin/lfs
	cp -p $(SS_COMMON)/devices/common/splashscreen-res/$(DEVICE_RESOLUTION)/* $(OUT)/install-files/etc/safestrap/res/
	# Call out to device-specific script
	$(SS_COMMON)/devices/$(SS_PRODUCT_MANUFACTURER)/$(TARGET_DEVICE)/build-safestrap.sh
endif


LOCAL_GENERATED_SOURCES := $(TWRP_RES_GEN)
LOCAL_SRC_FILES := twrp $(TWRP_RES_GEN)
include $(BUILD_PREBUILT)
