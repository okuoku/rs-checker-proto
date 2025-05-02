include(${CMAKE_CURRENT_LIST_DIR}/detect.cmake)

cmake_path(SET ndkbinroot f:/android-sdk/ndk/27.0.12077973/toolchains/llvm/prebuilt/windows-x86_64/bin)

set(clang ${ndkbinroot}/clang.exe)

set(RS_C_COMPILER ${clang} -x c --target=aarch64-linux-android35)
set(RS_CXX_COMPILER ${clang} -x c++ --target=aarch64-linux-android35)

detect(GCC)
