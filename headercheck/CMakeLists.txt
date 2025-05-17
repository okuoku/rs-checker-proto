cmake_minimum_required(VERSION 3.20)
project(headercheck NONE)

include(../stds/c17.cmake)
include(../stds/posix.cmake)
include(../stds/cxx.cmake)

set(hdrs)
set(libs)

macro(setset setname nam)
    set(${setname}_${nam} ${ARGN})
    list(APPEND set_${setname} ${nam})
endmacro()

#include(../platforms/cygwin64.cmake)
#include(../platforms/mingw64-clang.cmake)
include(../platforms/ndk.cmake)

find_program(node node)
if(NOT node)
    message(FATAL_ERROR "Node js required.")
endif()

find_program(cygpath cygpath)

macro(convpath in var)
    if(cygpath)
        execute_process(COMMAND ${cygpath} -m ${${in}}
            OUTPUT_VARIABLE ${var}
            OUTPUT_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE rr)
        if(rr)
            message(FATAL_ERROR "Failed to convert path")
        endif()
    else()
        set(${var} "${${in}}")
    endif()
    cmake_path(SET ${var} "${${var}}")
    cmake_path(NORMAL_PATH ${var})
endmacro()

macro(csym out nam)
    string(MAKE_C_IDENTIFIER "${nam}" ${out})
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

function(find_linkfile var nam)
    foreach(e IN LISTS RS_LINK_PATH)
        if(EXISTS ${e}/${nam})
            set(found ${e}/${nam})
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

foreach(hdr IN LISTS set_hdr)
    reghdrs(hdr_${hdr} ${hdr})
endforeach()

function(reglib path)
    set(p "${path}")
    cmake_PATH(NORMAL_PATH p)
    cmake_path(GET p FILENAME fil)
    cmake_path(GET p EXTENSION LAST_ONLY type)
    string(MAKE_C_IDENTIFIER "${fil}" sym)
    set(libs ${libs} ${sym} PARENT_SCOPE)
    if(libpath_sym)
        message(FATAL_ERROR "We already have ${sym} as [${libpath_${sym}}]")
    endif()
    set(libpath_${sym} ${p} PARENT_SCOPE)
    set(libname_${sym} ${fil} PARENT_SCOPE)
endfunction()

foreach(sym IN LISTS set_lib)
    foreach(l IN LISTS lib_${sym})
        find_linkfile(fil "${l}")
        if(NOT fil)
            message(FATAL_ERROR "Cannot find: ${l} (${sym})")
        endif()
        message(STATUS "Lib(${sym}): ${fil}")
        reglib("${fil}")
    endforeach()
endforeach()

# Library symbol analysis
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libsym)
foreach(sym IN LISTS libs)
    set(script ${CMAKE_CURRENT_LIST_DIR}/gensymtbl.cmake)
    set(outfile ${CMAKE_CURRENT_BINARY_DIR}/libsym/${sym}.txt)
    set(file ${libpath_${sym}})
    cmake_path(GET file EXTENSION LAST_ONLY type)
    if("${type}" STREQUAL ".a")
        set(mode STATIC)
    else()
        set(mode SHARED)
    endif()
    add_custom_command(COMMAND 
        ${CMAKE_COMMAND} -DFILE=${file}
        -DMODE=${mode}
        -DNM=${RS_NM}
        -DDST=${CMAKE_CURRENT_BINARY_DIR}/libsym/${sym}.txt
        -P ${script}
        DEPENDS ${file} ${script} ${RS_NM}
        OUTPUT ${outfile})
    add_custom_target(libsym_${sym} ALL DEPENDS ${outfile})
endforeach()

# Header analysis
set(probes_total)
set(probes_c)
set(probes_cxx)
set(dir ${CMAKE_CURRENT_BINARY_DIR}/probes)
foreach(e IN LISTS hdrs)
    set(file ${hdrfile_${e}})
    set(probefile_c ${dir}/cdummy_${e}.c)
    set(probefile_cxx ${dir}/cxxdummy_${e}.cxx)

    find_header(find_c_${e} ${file} C)
    find_header(find_cxx_${e} ${file} CXX)
    if(probename_${e})
        if(NOT "${probename_${e}}" STREQUAL "${file}")
            message(FATAL_ERROR "${e}: Unmatch [${probename_${e}}] vs. [${file}]")
        endif()
    else()
        set(probename_${e} ${file})
        list(APPEND probes_total ${e})
    endif()

    # Create dep header
    set(deps "")
    if(hdrdeps_${file})
        foreach(f IN LISTS hdrdeps_${file})
            set(deps "${deps}#include <${f}>\n")
        endforeach()
    endif()

    # Detect language
    set(gen_c OFF)
    set(gen_cxx OFF)
    if(find_c_${e})
        set(gen_c ON)
    endif()
    if(find_cxx_${e})
        set(gen_cxx ON)
    endif()
    if(hdrcxxonly_${file})
        set(gen_c OFF)
    endif()

    # Generate
    if(find_c_${e} OR find_cxx_${e})
        if(gen_c)
            file(WRITE ${probefile_c} "${deps}\n#include<${file}>\n\nint dummy_${e}_c = 0;\n")
            set(probe_c_${e} ${probefile_c})
            list(APPEND probes_c ${e})
        endif()

        if(gen_cxx)
            file(WRITE ${probefile_cxx} "${deps}\n#include<${file}>\n\nint dummy_${e}_cxx = 0;\n")
            set(probe_cxx_${e} ${probefile_cxx})
            list(APPEND probes_cxx ${e})
        endif()
    else()
        message(STATUS "NOT FOUND ${e}: ${hdrenv_${e}}")
    endif()
endforeach()

set(outdir ${CMAKE_CURRENT_BINARY_DIR}/check)
file(MAKE_DIRECTORY ${outdir})

convpath(CMAKE_CURRENT_LIST_DIR headercheck)

foreach(lang c cxx)
    foreach(e IN LISTS probes_${lang})
        if("${lang}" STREQUAL c)
            set(ul C)
        else()
            set(ul CXX)
        endif()
        set(in ${probe_${lang}_${e}})
        set(outname ${outdir}/${e}.${lang}.i)
        set(outmac ${outdir}/${e}.${lang}.m)
        set(outdef ${outdir}/${e}.${lang}.u)
        set(outdep_temp ${outdir}/${e}.${lang}.mk)
        set(outdep ${outdir}/${e}.${lang}.d)
        set(outast1 ${outdir}/${e}.${lang}.json)
        set(outpick1 ${outdir}/${e}.${lang}.isym)
        set(outast2 ${outdir}/${e}.p${lang}.json)
        set(outpick2 ${outdir}/${e}.${lang}.psym)
        set(script ${CMAKE_CURRENT_LIST_DIR}/captureoutput.cmake)
        set(filtdepscript ${CMAKE_CURRENT_LIST_DIR}/filtdeps.cmake)
        set(astscript ${headercheck}/pickast.mjs)
        set(outputs
            ${outname}
            ${outdep_temp} ${outdep}
            ${outmac}
            # -dU analysis is only on GCC
            # ${outdef}
            ${outast1} ${outast2}
            ${outpick1} ${outpick2}
        )
        add_custom_command(OUTPUT ${outputs}
            COMMAND ${RS_${ul}_COMPILER} -o ${outname} -E ${in}
            COMMAND ${RS_${ul}_COMPILER} -o ${outmac} -dD -E ${in}
            # COMMAND ${RS_C_COMPILER} -o ${outdef} -dU -E ${in}
            COMMAND ${RS_${ul}_COMPILER} -M -MF ${outdep_temp} -E ${in}
            COMMAND ${CMAKE_COMMAND} -DSRC=${outdep_temp} -DDST=${outdep}
            -P ${filtdepscript}
            COMMAND ${CMAKE_COMMAND} -DMODE=ast
            -DSRC=${in} -DDST=${outast1} -P ${script} --
            __CMD__ ${RS_${ul}_COMPILER}
            COMMAND ${CMAKE_COMMAND} -DMODE=ast
            -DSRC=${outname} -DDST=${outast2} -P ${script} --
            __CMD__ ${RS_${ul}_COMPILER}
            COMMAND ${node} ${astscript} ${outast1} ${outpick1}
            COMMAND ${node} ${astscript} ${outast2} ${outpick2}
            IMPLICIT_DEPENDS ${ul} ${probe_${lang}_${e}}
            DEPENDS ${probe_${lang}_${e}} ${script} ${filtdepscript} ${astscript})
        add_custom_target(gen_${lang}_${e} ALL DEPENDS ${outputs})
    endforeach()
endforeach()

# Generate dir index
function(getprefix hdr lang var)
    csym(sym ${hdr})
    set(p ${find_${lang}_${sym}})
    if(p)
        cmake_path(REMOVE_FILENAME p)
        set(${var} ${p} PARENT_SCOPE)
    else()
        message(FATAL_ERROR "${hdr} was not found in ${lang}")
    endif()
endfunction()

set(dirsfile ${CMAKE_CURRENT_BINARY_DIR}/dirs.txt)
set(acc)


convpath(CMAKE_CURRENT_BINARY_DIR localbuild)

file(WRITE ${dirsfile} "_localbuild: ${localbuild}\n")
foreach(e IN LISTS RS_C_PATH)
    file(APPEND ${dirsfile} "_CPATH: ${e}\n")
endforeach()
foreach(e IN LISTS RS_CXX_PATH)
    file(APPEND ${dirsfile} "_CXXPATH: ${e}\n")
endforeach()
# Freestanding prefix: where we find <limits.h> in C
getprefix(limits.h c MAP_FREESTAND)
# C standard prefix: where we find <stdio.h> in C
getprefix(stdio.h c MAP_CSTD)
# C++ standard prefix: where we find <new> in CXX
getprefix(new cxx MAP_CXXSTD)
file(APPEND ${dirsfile} "MAP_FREESTAND: ${MAP_FREESTAND}\n")
file(APPEND ${dirsfile} "MAP_CSTD: ${MAP_CSTD}\n")
file(APPEND ${dirsfile} "MAP_CXXSTD: ${MAP_CXXSTD}\n")

set(mappings FREESTAND CXXSTD CSTD)

function(calcprefix out base path)
    string(LENGTH ${base} baselen)
    string(LENGTH ${path} pathlen)
    if("${baselen}" GREATER "${pathlen}")
        unset(${out} PARENT_SCOPE)
        return()
    endif()
    string(SUBSTRING "${path}" 0 ${baselen} dir)
    string(SUBSTRING "${path}" ${baselen} -1 file)
    if("${dir}" STREQUAL "${base}")
        set(${out} "${file}" PARENT_SCOPE)
    else()
        unset(${out} PARENT_SCOPE)
    endif()
endfunction()

# Generate probe index
set(indexfile ${CMAKE_CURRENT_BINARY_DIR}/index.txt)
set(acc)
foreach(e IN LISTS probes_total)
    foreach(l c cxx)
        if(find_${l}_${e})
            foreach(m IN LISTS mappings)
                calcprefix(mm "${MAP_${m}}" "${find_${l}_${e}}")
                if(mm)
                    set(finding_${l} "${m}:${mm}")
                    break()
                endif()
            endforeach()
        else()
            set(finding_${l} NOT_FOUND)
        endif()
    endforeach()
    set(acc "${acc}${e}\t${finding_c}\t${finding_cxx}\t${hdrenv_${e}}\n")
endforeach()
file(WRITE ${indexfile} "${acc}")


