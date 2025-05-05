if(NOT ELF)
    message(FATAL_ERROR "ELF needed")
endif()

if(NOT NM)
    message(FATAL_ERROR "NM needed")
endif()

if(NOT DST)
    message(FATAL_ERROR "DST needed")
endif()


execute_process(
    COMMAND ${NM} --no-demangle --quiet --defined-only
    --dynamic ${ELF}
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE out
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "Failed to fetch [${ELF}] (${rr})")
endif()

string(REPLACE "\r" "" str "${out}")
string(REPLACE "\n" ";" str "${out}")

set(acc)
foreach(l IN LISTS str)
    if("${l}" MATCHES "[^ ]* . (.*)")
        set(symver ${CMAKE_MATCH_1})
        if("${symver}" MATCHES "([^@]*)")
            set(sym ${CMAKE_MATCH_1})
        else()
            set(sym ${symver})
        endif()
        set(acc "${acc}${sym}\n")
    else()
        message(FATAL_ERROR "Output [${l}] Did not match input rule!")
    endif()
endforeach()

file(WRITE "${DST}" "${acc}")
