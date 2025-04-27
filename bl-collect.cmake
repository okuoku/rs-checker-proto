include(./env.cmake)

file(GLOB_RECURSE binlogs
    LIST_DIRECTORIES false
    ${BINLOGROOT}/*.binlog)

set(idx 1)
foreach(e IN LISTS binlogs)
    message(STATUS "Binlog: ${e}")
    set(outfile ${OUTPATH}/binlog-${idx}.json)
    execute_process(COMMAND
        ${BINLOGDUMP} ${e}
        OUTPUT_FILE ${outfile}
        RESULT_VARIABLE rr
    )
    if(rr)
        message(STATUS "Warning: Failed to analyze ${e} (${rr})")
    endif()
    math(EXPR idx "${idx}+1")
endforeach()
