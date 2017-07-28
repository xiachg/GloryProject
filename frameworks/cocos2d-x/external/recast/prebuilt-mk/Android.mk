LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := recast_static

LOCAL_MODULE_FILENAME := librecast

LOCAL_SRC_FILES := ..\..\..\prebuilt\android/$(TARGET_ARCH_ABI)/librecast.a

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../..

                                 
include $(PREBUILT_STATIC_LIBRARY)
