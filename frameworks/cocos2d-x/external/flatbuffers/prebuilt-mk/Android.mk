LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos_flatbuffers_static

LOCAL_MODULE_FILENAME := flatbuffers

LOCAL_SRC_FILES := ..\..\..\prebuilt\android/$(TARGET_ARCH_ABI)/flatbuffers.a

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../..

LOCAL_CPPFLAGS += -fexceptions
                                 
include $(PREBUILT_STATIC_LIBRARY)
