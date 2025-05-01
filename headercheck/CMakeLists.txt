cmake_minimum_required(VERSION 3.20)
project(headercheck C CXX)

include(../stds/c17.cmake)
include(../stds/posix.cmake)
include(../stds/cxx.cmake)

set(hdrs)

# Checked with `echo | gcc -v -x c++ -E -`
set(RS_CXX_PATH 
    /usr/lib/gcc/x86_64-pc-cygwin/11/include/c++
    /usr/lib/gcc/x86_64-pc-cygwin/11/include/c++/x86_64-pc-cygwin
    /usr/lib/gcc/x86_64-pc-cygwin/11/include/c++/backward
    /usr/lib/gcc/x86_64-pc-cygwin/11/include
    /usr/local/include
    /usr/include
    /usr/lib/gcc/x86_64-pc-cygwin/11/../../../../lib/../include/w32api
)

# Checked with `echo | gcc -v -x c -E -`
set(RS_C_PATH 
    /usr/lib/gcc/x86_64-pc-cygwin/11/include
    /usr/local/include
    /usr/include
    /usr/lib/gcc/x86_64-pc-cygwin/11/../../../../lib/../include/w32api
)

set(RS_C_COMPILER gcc)
set(RS_CXX_COMPILER g++)

list(REMOVE_DUPLICATES RS_PREFIX_PATH)

message(STATUS "Prefix: ${RS_PREFIX_PATH}")

macro(csym out nam)
    string(REPLACE . _ _str ${nam})
    string(REPLACE / _ _str ${_str})
    set(${out} ${_str})
endmacro()

macro(reghdrs nam sym)
    foreach(e IN LISTS ${nam})
        csym(_csym ${e}) 
        # message(STATUS "SYM: ${e} => ${_csym}")
        if(hdrenv_${_csym})
            list(APPEND hdrenv_${_csym} ${sym})
        else()
            list(APPEND hdrs ${_csym})
            set(hdrenv_${_csym} ${sym})
            set(hdrfile_${_csym} ${e})
        endif()
    endforeach()
endmacro()

function(find_header var nam lang)
    foreach(e IN LISTS RS_${lang}_PATH)
        if(EXISTS ${e}/${nam})
            set(found ${e}/${nam})
            message(STATUS "FOUND: ${found}")
        endif()
        if(found)
            break()
        endif()
    endforeach()
    set(${var} ${found} PARENT_SCOPE)
endfunction()

reghdrs(c17_standard_header_names C17)
reghdrs(cxx_standard_header_names CXX)
reghdrs(posix_standard_header_names_issue5 POSIX_I5)
reghdrs(posix_standard_header_names_issue6 POSIX_I6)
reghdrs(posix_standard_header_names_issue7 POSIX_I7)
reghdrs(posix_standard_header_names_issue8 POSIX_I8)

set(probes_c)
set(probes_cxx)
set(dir ${CMAKE_CURRENT_BINARY_DIR}/probes)
foreach(e IN LISTS hdrs)
    set(file ${hdrfile_${e}})
    set(probefile_c ${dir}/cdummy_${e}.c)
    set(probefile_cxx ${dir}/cxxdummy_${e}.c)

    find_header(find_c_${e} ${file} C)
    find_header(find_cxx_${e} ${file} CXX)
    if(find_c_${e} OR find_cxx_${e})
        if(find_c_${e})
            file(WRITE ${probefile_c} "#include<${hdrfile_${e}}>\n\nint dummy_${e}_c = 0;\n")
            set(probe_c_${e} ${probefile_c})
            list(APPEND probes_c ${e})
        endif()

        if(find_cxx_${e})
            file(WRITE ${probefile_cxx} "#include<${hdrfile_${e}}>\n\nint dummy_${e}_cxx = 0;\n")
            set(probe_cxx_${e} ${probefile_cxx})
            list(APPEND probes_cxx ${e})
        endif()
    else()
        message(STATUS "NOT FOUND ${e}: ${hdrenv_${e}}")
    endif()
endforeach()

set(outdir ${CMAKE_CURRENT_BINARY_DIR}/check)
file(MAKE_DIRECTORY ${outdir})
foreach(e IN LISTS probes_c)
    set(outname ${outdir}/${e}.c.i)
    set(outmac ${outdir}/${e}.c.m)
    set(outdef ${outdir}/${e}.c.u)
    set(outdep ${outdir}/${e}.c.d)
    add_custom_command(OUTPUT ${outname} ${outdep} ${outmac} ${outdef}
        COMMAND ${RS_C_COMPILER} -o ${outname} -E ${probe_c_${e}}
        COMMAND ${RS_C_COMPILER} -o ${outmac} -dD -E ${probe_c_${e}}
        COMMAND ${RS_C_COMPILER} -o ${outdef} -dU -E ${probe_c_${e}}
        COMMAND ${RS_C_COMPILER} -M -MF ${outdep} -E ${probe_c_${e}}
        IMPLICIT_DEPENDS C ${probe_c_${e}}
        DEPENDS ${probe_c_${e}})
    add_custom_target(gen_c_${e} ALL DEPENDS ${outname})
endforeach()

foreach(e IN LISTS probes_cxx)
    set(outname ${outdir}/${e}.cpp.i)
    set(outmac ${outdir}/${e}.cpp.m)
    set(outdef ${outdir}/${e}.cpp.u)
    set(outdep ${outdir}/${e}.cpp.d)
    add_custom_command(OUTPUT ${outname} ${outdep} ${outmac} ${outdef}
        COMMAND ${RS_CXX_COMPILER} -o ${outname} -E ${probe_cxx_${e}}
        COMMAND ${RS_CXX_COMPILER} -o ${outmac} -dD -E ${probe_cxx_${e}}
        COMMAND ${RS_CXX_COMPILER} -o ${outdef} -dU -E ${probe_cxx_${e}}
        COMMAND ${RS_CXX_COMPILER} -M -MF ${outdep} -E ${probe_cxx_${e}}
        IMPLICIT_DEPENDS CXX ${probe_cxx_${e}}
        DEPENDS ${probe_cxx_${e}})
    add_custom_target(gen_cxx_${e} ALL DEPENDS ${outname})
endforeach()


