include(${CMAKE_CURRENT_LIST_DIR}/detect.cmake)

set(ndkversion 29.0.13113456)
cmake_path(SET ndkroot f:/android-sdk/ndk/${ndkversion}/toolchains/llvm/prebuilt/windows-x86_64)
set(ndkbinroot ${ndkroot}/bin)

set(clang ${ndkbinroot}/clang.exe)

set(RS_C_COMPILER ${clang} -x c --target=aarch64-linux-android35)
set(RS_CXX_COMPILER ${clang} -x c++ --target=aarch64-linux-android35)
set(RS_NM e:/msys64_qemu/mingw64/bin/llvm-nm.exe)
set(RS_LINK_PATH 
    ${ndkroot}/sysroot/usr/lib/aarch64-linux-android/35
    ${ndkroot}/sysroot/usr/lib/aarch64-linux-android)

detect(GCC)

set(ANDROID_UNKNOWN_LIBS_FIXME
    # FIXME: Find documentation for these
    libnativehelper.so
    libstdc++.so

    # and their static versions
    libstdc++.a

    # and compiler_rt
    libcompiler_rt-extras.a

    # unknown
    libc++experimental.a
    libc++abi.a
)

# https://developer.android.com/ndk/guides/stable_apis

# Core C/C++
# FIXME: Android NDK provides C11 + C++17
setset(lib ANDROID_CORE libc.so libm.so libc.a libm.a)
setset(lib ANDROID_CORE_CXX libc++_shared.so libc++_static.a)
setset(lib ANDROID_CORE_DLFCN libdl.so libdl.a)

# Logging
setset(hdr ANDROID_LOGGING android/log.h)
setset(lib ANDROID_LOGGING liblog.so)

# Trace
setset(hdr ANDROID_TRACE android/trace.h)
# setset(lib ANDROID_TRACE libandroid.so) # Is documented but ignore here.

# zlib compression
setset(hdr ANDROID_ZLIB zlib.h)
setset(lib ANDROID_ZLIB libz.so libz.a)


# Graphics::OpenGL ES 1.0 - 3.2
setset(hdr KHR_GLES1
    GLES/gl.h
    GLES/glext.h
)
set(hdrdeps_GLES/glext.h GLES/gl.h)

setset(hdr KHR_GLES2
    GLES2/gl2.h
    GLES2/gl2ext.h
)
set(hdrdeps_GLES2/gl2ext.h GLES2/gl2.h)

setset(hdr KHR_GLES30
    GLES3/gl3.h
    GLES3/gl3ext.h
)
set(hdrdeps_GLES3/gl3ext.h GLES3/gl3.h)

setset(hdr KHR_GLES31 GLES3/gl31.h)
setset(hdr KHR_GLES32 GLES3/gl32.h)

setset(lib KHR_GLES1 libGLESv1_CM.so)
setset(lib KHR_GLES2 libGLESv2.so)
setset(lib KHR_GLES3 libGLESv3.so)

# Graphics::EGL
setset(hdr KHR_EGL EGL/egl.h EGL/eglext.h)
set(hdrdeps_EGL/eglext.h EGL/egl.h)

setset(lib KHR_EGL libEGL.so)

# Graphics::Vulkan
setset(hdr KHR_VULKAN vulkan/vulkan.h)
setset(lib KHR_VULKAN libvulkan.so)

# Graphics::Bitmaps
setset(hdr ANDROID_BITMAPS android/bitmap.h)
setset(lib ANDROID_BITMAPS libjnigraphics.so)

# Graphics::Sync API
setset(hdr ANDROID_SYNC android/sync.h)
setset(lib ANDROID_SYNC libsync.so)

# Camera
setset(hdr ANDROID_CAMERA
    camera/NdkCameraCaptureSession.h
    camera/NdkCameraDevice.h
    camera/NdkCameraError.h
    camera/NdkCameraManager.h
    camera/NdkCameraMetadata.h
    camera/NdkCameraMetadataTags.h
    camera/NdkCameraWindowType.h
    camera/NdkCaptureRequest.h)
setset(lib ANDROID_CAMERA libcamera2ndk.so)

# Media::libmediandk
setset(hdr ANDROID_MEDIANDK
    media/NdkImage.h
    media/NdkImageReader.h
    media/NdkMediaCodec.h
    media/NdkMediaCodecInfo.h
    media/NdkMediaCodecStore.h
    media/NdkMediaCrypto.h
    media/NdkMediaDataSource.h
    media/NdkMediaDrm.h
    media/NdkMediaError.h
    media/NdkMediaExtractor.h
    media/NdkMediaFormat.h
    media/NdkMediaMuxer.h)
setset(lib ANDROID_MEDIANDK libmediandk.so)


# Media::OpenMAX AL
setset(hdr KHR_OMX_AL
    OMXAL/OpenMAXAL.h
    OMXAL/OpenMAXAL_Platform.h
    OMXAL/OpenMAXAL_Android.h)
setset(lib KHR_OMX_AL libOpenMAXAL.so)

# Android native application APIs
# https://developer.android.com/ndk/reference
setset(hdr ANDROID_API_LEVELS android/api-level.h)
setset(hdr ANDROID_IMAGE_DECODER android/imagedecoder.h)
setset(hdr ANDROID_ASSET android/asset_manager.h android/asset_manager_jni.h)
# AAudio is at audio section
# Bitmap is at graphics section
# Camera is at camera section
setset(hdr ANDROID_CHOREOGRAPHER android/choreographer.h)
setset(hdr ANDROID_CONFIGURATION android/configuration.h)
setset(hdr ANDROID_DATASPACE android/data_space.h)
setset(hdr ANDROID_DYNAMIC_LINKER android/dlext.h)
setset(hdr ANDROID_FILE_DESCRIPTOR android/file_descriptor_jni.h)
setset(hdr ANDROID_FONT android/font.h android/font_matcher.h android/system_fonts.h)
setset(hdr ANDROID_ICU4C 
    unicode/parseerr.h
    unicode/ubrk.h
    unicode/uchar.h
    unicode/ucol.h
    unicode/ucpmap.h
    unicode/udisplaycontext.h
    unicode/uenum.h
    unicode/uldnames.h
    unicode/uloc.h
    unicode/ulocdata.h
    unicode/umachine.h
    unicode/unorm2.h
    unicode/urep.h
    unicode/uscript.h
    unicode/ustring.h
    unicode/utext.h
    unicode/utrans.h
    unicode/utypes.h
    unicode/uversion.h
)
setset(lib ANDROID_ICU4C libicu.so) # FIXME: Undocumented ?
setset(hdr ANDROID_INPUT android/input.h android/keycodes.h)
# Logging is at loggig section
setset(hdr ANDROID_LOOPER android/looper.h)
# Media is at Media section::mediandk
setset(hdr ANDROID_MEMORY android/sharedmem.h android/sharedmem_jni.h)
setset(hdr ANDROID_AMIDI amidi/AMidi.h)
setset(lib ANDROID_AMIDI libamidi.so) # FIXME: Undocumented ?
setset(hdr ANDROID_NATIVE_ACTIVITY 
    android/input_transfer_token_jni.h
    android/native_activity.h
    android/native_window_jni.h
    android/rect.h
    android/surface_control.h
    android/surface_control_input_receiver.h
    android/surface_control_jni.h
    android/window.h
)
# Native Hardware Buffer is at Hardware Buffer APIs section
setset(hdr ANDROID_NATIVE_WINDOW android/native_window.h android/native_window_aidl.h)
# NdkBinder is at Binder APIs section
setset(hdr ANDROID_NETWORKING android/multinetwork.h)
# NeuralNetworks is at Neural Networks API section
setset(hdr ANDROID_PERFORMANCE_HINT_MANAGER android/performance_hint.h)
setset(hdr ANDROID_PERMISSION android/permission_manager.h)
setset(hdr ANDROID_SENSOR android/sensor.h)
setset(hdr ANDROID_STORAGE android/obb.h android/storage_manager.h)
setset(hdr ANDROID_SURFACETEXTURE android/surface_texture.h android/surface_texture_jni.h)
# Sync is at Graphics section
setset(hdr ANDROID_THERMAL android/thermal.h)
# Tracing is at Trace section

setset(lib ANDROID_NATIVE_APIS libandroid.so)
setset(lib ANDROID_NATIVE_APIS_NATIVEWINDOW libnativewindow.so)


# Binder APIs
setset(hdr ANDROID_BINDER
    android/binder_status.h
    android/binder_ibinder.h
    android/binder_ibinder_jni.h
    android/binder_parcel.h
    android/binder_parcel_jni.h)
setset(lib ANDROID_BINDER libbinder_ndk.so)

# Hardware Buffer APIs
setset(hdr ANDROID_HARDWARE_BUFFER
    android/hardware_buffer.h
    android/hardware_buffer_aidl.h # Implicit ?
)
setset(hdr ANDROID_HARDWARE_BUFFER_JNI
    android/hardware_buffer.h)

# Audio::AAudio
setset(hdr ANDROID_AAUDIO
    aaudio/AAudio.h)
setset(lib ANDROID_AAUDIO libaaudio.so)

# Audio::OpenSL ES
setset(hdr KHR_SLES
    SLES/OpenSLES.h
    SLES/OpenSLES_Android.h)
setset(lib KHR_SLES libOpenSLES.so)

# Neural Networks API
setset(hdr ANDROID_NEURALNETWORKS
    android/NeuralNetworks.h
    android/NeuralNetworksTypes.h
)
setset(lib ANDROID_NEURALNETWORKS libneuralnetworks.so)

