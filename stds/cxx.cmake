set(cxx_standard_header_names_cxx
    # https://en.cppreference.com/w/cpp/header
    cstdlib
    execution

    cfloat
    climits
    compare
    contracts
    # coroutine # FIXME: Is not supported by MinGW Clang
    csetjmp
    csignal
    cstdarg
    cstddef
    cstdint
    exception
    initializer_list
    limits
    new
    source_location
    stdfloat
    typeindex
    typeinfo
    version

    # Concepts
    concepts

    # Diagnostics
    cassert
    cerrno
    debugging
    stacktrace
    stdexcept
    system_error

    # Memory
    memory
    memory_resource
    scoped_allocator

    # Metaprogramming
    ratio
    type_traits

    # Utils
    any
    bit
    bitset
    expected
    functional
    optional
    tuple
    utility
    variant

    # Containers
    array
    deque
    flat_map
    flat_set
    forward_list
    hive
    inplace_vector
    list
    map
    mdspan
    queue
    set
    span
    stack
    unordered_map
    unordered_set
    vector

    # Iterators
    iterator

    # Ranges
    generator
    ranges

    # Algorithms
    algorithm
    numeric

    # Strings
    cstring
    string
    string_view

    # Text
    cctype
    charconv
    clocale
    codecvt
    cuchar
    cwchar
    cwctype
    format
    locale
    regex
    text_encoding

    # Numerics
    cfenv
    cmath
    complex
    linalg
    numbers
    random
    simd
    valarray

    # Time
    chrono
    ctime

    # I/O
    cinttypes
    cstdio
    filesystem
    fstream
    iomanip
    ios
    iosfwd
    iostream
    istream
    ostream
    print
    spanstream
    sstream
    streambuf
    strstream
    syncstream

    # Concurrency
    atomic
    barrier
    condition_variable
    future
    hazard_pointer
    latch
    mutex
    rcu
    semaphore
    shared_mutex
    stop_token
    thread
)

set(cxx_standard_header_names_ccompat
    # C compat
    assert.h
    ctype.h
    errno.h
    fenv.h
    float.h
    inttypes.h
    limits.h
    locale.h
    math.h
    setjmp.h
    signal.h
    stdarg.h
    stddef.h
    stdint.h
    stdio.h
    stdlib.h
    string.h
    time.h
    uchar.h
    wchar.h
    wctype.h

    # Special C headers
    stdatomic.h
    stdbit.h
    stdckdint.h

    # Empty C headers
    ccomplex
    complex.h
    ctgmath
    tgmath.h

    # Meaningless (?)
    ciso646
    cstdalign
    cstdbool
    iso646.h
    stdalign.h
    stdbool.h
)

set(cxx_standard_header_names
    ${cxx_standard_header_names_cxx}
    ${cxx_standard_header_names_ccompat})

foreach(e IN LISTS cxx_standard_header_names_cxx)
    set(hdrcxxonly_${e} ON)
endforeach()

