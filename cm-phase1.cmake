# Phase1: Collect CMake project builddirs

include(./env.cmake) # => PROJROOT

file(MAKE_DIRECTORY ${OUTPATH})

file(GLOB_RECURSE caches LIST_DIRECTORIES false RELATIVE
    ${PROJROOT}
    ${PROJROOT}/CMakeCache.txt)

file(WRITE ${OUTPATH}/cm-projdirs.txt "")

foreach(e IN LISTS caches)
    cmake_path(REMOVE_FILENAME e)
    set(e "${PROJROOT}/${e}")
    cmake_path(NORMAL_PATH e)
    message(STATUS "CMake builddir: ${e}")
    file(APPEND ${OUTPATH}/cm-projdirs.txt "${e}\n")
endforeach()

