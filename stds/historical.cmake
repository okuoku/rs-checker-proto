set(historical_header_names
    wait.h # => sys/wait.h
    termio.h # => termios.h

    # BSD
    # sysexits: https://man.freebsd.org/cgi/man.cgi?query=sysexits&apropos=0&sektion=0&manpath=FreeBSD+15.0-CURRENT&arch=default&format=html
    sysexits.h
    # pty: ???
    pty.h
    # paths: ???
    paths.h
    # ifaddrs: ???
    ifaddrs.h
    # fts: ???
    fts.h
    # err: ???
    err.h

    # Linux
    # utmp: https://man7.org/linux/man-pages/man5/utmp.5.html
    utmp.h
    lastlog.h # => utmp.h

    # glibc ??
    resolv.h
    getopt.h # POSIX: unistd.h (historically stdio.h)
    error.h

    # Solaris
    stdio_ext.h
)

set(__bogus_headers_historical
    time64.h # 32bit only

)
