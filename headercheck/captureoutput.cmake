if(NOT SRC)
    message(FATAL_ERROR "SRC is required")
endif()
if(NOT DST)
    message(FATAL_ERROR "DST is required")
endif()
if(NOT MODE)
    message(FATAL_ERROR "MODE is required")
endif()

set(inarg)
set(args)
set(cnt 1)

while(DEFINED CMAKE_ARGV${cnt})
    set(arg ${CMAKE_ARGV${cnt}})
    #message(STATUS "RAWARG: ${arg}")
    if(inarg)
        list(APPEND args "${arg}")
    elseif("${arg}" STREQUAL "__CMD__")
        set(inarg TRUE)
    endif()
    math(EXPR cnt "${cnt}+1")
endwhile()

if("${MODE}" STREQUAL ast)
    execute_process(COMMAND
        ${args} -Xclang -ast-dump=json -c ${SRC}
        -o ${DST}.o
        OUTPUT_FILE ${DST}
        RESULT_VARIABLE rr)
elseif("${MODE}" STREQUAL warnings)
    execute_process(COMMAND
        ${args} -Wextra -pedantic -c ${SRC}
        -o ${DST}.o
        OUTPUT_FILE ${DST}
        RESULT_VARIABLE rr)
else()
    message(FATAL_ERROR "Unknown request [${MODE}]")
endif()

if(rr)
    message(FATAL_ERROR "failed to generate ast: [${rr}]")
endif()

file(REMOVE ${DST}.o)
