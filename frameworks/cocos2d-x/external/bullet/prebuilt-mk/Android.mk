LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := bullet_static

LOCAL_MODULE_FILENAME := libbullet

LOCAL_SRC_FILES := ..\..\..\prebuilt\android/$(TARGET_ARCH_ABI)/libbullet.a

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../..

                                 
include $(PREBUILT_STATIC_LIBRARY)
