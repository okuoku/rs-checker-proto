include(${CMAKE_CURRENT_LIST_DIR}/detect.cmake)

set(RS_C_COMPILER clang -x c)
set(RS_CXX_COMPILER clang -x c++) # MinGW clang not support coroutines??

detect(GCC)
