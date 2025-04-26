# Phase2: Inject CMake File API Queries

include(./env.cmake)

file(STRINGS ${OUTPATH}/cm-projdirs.txt projdirs)

foreach(e IN LISTS projdirs)
    set(querydir "${e}/.cmake/api/v1/query/client-${PROJNAME}/")
    cmake_path(NORMAL_PATH querydir)
    file(MAKE_DIRECTORY "${querydir}")
    file(COPY_FILE "${CMAKE_CURRENT_LIST_DIR}/query.json" "${querydir}/query.json")
    message(STATUS "Generated query at ${querydir}")
endforeach()
