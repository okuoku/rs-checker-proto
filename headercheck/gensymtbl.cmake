if(NOT FILE)
    message(FATAL_ERROR "FILE needed")
endif()

if(NOT NM)
    message(FATAL_ERROR "NM needed")
endif()

if(NOT DST)
    message(FATAL_ERROR "DST needed")
endif()

if(NOT MODE)
    message(FATAL_ERROR "MODE needed")
endif()


set(acc)
if("${MODE}" STREQUAL SHARED)
    execute_process(
        COMMAND ${NM} --no-demangle --quiet --defined-only
        --dynamic ${FILE}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE out
        RESULT_VARIABLE rr)

    if(rr)
        message(FATAL_ERROR "Failed to fetch [${FILE}] (${rr})")
    endif()

    string(REPLACE "\r" "" str "${out}")
    string(REPLACE "\n" ";" str "${out}")

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
elseif("${MODE}" STREQUAL STATIC)
    execute_process(
        COMMAND ${NM} --quiet --extern-only ${FILE}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE out
        RESULT_VARIABLE rr)

    if(rr)
        message(FATAL_ERROR "Failed to fetch [${FILE}] (${rr})")
    endif()

    string(REPLACE "\r" "" str "${out}")
    string(REPLACE "\n" ";" str "${out}")

    set(files)
    set(curfile)
    foreach(l IN LISTS str)
        if("${l}" MATCHES "([^:]*):")
            set(curfile ${CMAKE_MATCH_1})
            #message(STATUS "FILE: ${curfile}")
            list(APPEND files "${curfile}")
        elseif("${l}" MATCHES "[0-9a-f-]*[ ]*(.) (.*)")
            # llvm-nm may emit --------- as address
            if(NOT curfile)
                message(FATAL_ERROR "No curfile?? [${l}]")
            endif()
            set(sym "${CMAKE_MATCH_2}")
            set(type "${CMAKE_MATCH_1}")

            if(syms_${curfile})
                list(APPEND syms_${curfile} ${sym})
            else()
                set(syms_${curfile} ${sym})
            endif()
            set(sym_${curfile}_${sym} ${type})

            #message(STATUS "SYM: ${sym} <${type}> [${curfile}]")
        endif()
    endforeach()

    # Ignore symbol requirement for now
    set(picksym_T pick)
    set(picksym_t pick)
    set(picksym_V pick) # ELF weak symbol
    #set(picksym_U undefined)
    set(picksym_w ON) # Non-elf weak symbol
    set(picksym_W ON) # Non-elf weak symbol

    set(picksym_R ON) # RO data
    set(picksym_D ON) # RW data
    set(picksym_B ON) # Uninitialized BSS
    foreach(file IN LISTS files)
        foreach(sym IN LISTS syms_${file})
            set(type ${sym_${file}_${sym}})
            if(picksym_${type})
                # Record a symbol
                set(acc "${acc}${sym}\n")
                #message(STATUS "PICK: ${sym} <${type}> [${curfile}]")
            elseif("${type}" STREQUAL "U")
                # Ignore
            else()
                message(FATAL_ERROR "Unknown symtype ${type} [${sym}][${file}]")
            endif()
        endforeach()
    endforeach()
endif()

file(WRITE "${DST}" "${acc}")
