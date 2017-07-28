LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := box2d_static

LOCAL_MODULE_FILENAME := libbox2d

LOCAL_SRC_FILES := ..\..\..\prebuilt\android/$(TARGET_ARCH_ABI)/libbox2d.a

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../..

                                 
include $(PREBUILT_STATIC_LIBRARY)
