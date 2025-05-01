set(posix_standard_header_names_issue5
    # https://pubs.opengroup.org/onlinepubs/7908799/headix.html
    aio.h  arpa/inet.h  assert.h  cpio.h  ctype.h  curses.h  dirent.h  dlfcn.h
    errno.h  fcntl.h  float.h  fmtmsg.h  fnmatch.h  ftw.h
    glob.h  grp.h  iconv.h  inttypes.h  iso646.h  langinfo.h  libgen.h  limits.h  locale.h
    math.h  monetary.h  mqueue.h  ndbm.h  netdb.h  netinet/in.h  nl_types.h  poll.h  pthread.h  pwd.h
    re_comp.h # LEGACY
    regex.h  
    regexp.h # LEGACY
    sched.h  search.h  semaphore.h  setjmp.h  signal.h  stdarg.h  stddef.h  stdio.h  stdlib.h  string.h  strings.h  stropts.h  syslog.h
    sys/ipc.h  sys/mman.h  sys/msg.h  sys/resource.h  sys/sem.h  sys/shm.h  sys/socket.h  sys/stat.h  sys/statvfs.h  sys/time.h  sys/timeb.h  sys/times.h  sys/types.h  sys/uio.h  sys/un.h  sys/utsname.h  sys/wait.h
    tar.h  term.h  termios.h  time.h  ucontext.h  ulimit.h  unctrl.h  unistd.h  utime.h  utmpx.h
    varargs.h # LEGACY
    wchar.h  wctype.h  wordexp.h  
    xti.h # ??? (Special)
)

set(posix_standard_header_names_issue6
    # https://pubs.opengroup.org/onlinepubs/009695399/idx/head.html
    aio.h arpa/inet.h assert.h complex.h cpio.h ctype.h dirent.h dlfcn.h errno.h fcntl.h 
    fenv.h float.h fmtmsg.h fnmatch.h ftw.h glob.h grp.h iconv.h inttypes.h iso646.h langinfo.h 
    libgen.h limits.h locale.h math.h monetary.h mqueue.h ndbm.h net/if.h netdb.h
    netinet/in.h netinet/tcp.h nl_types.h poll.h pthread.h pwd.h regex.h sched.h search.h
    semaphore.h setjmp.h signal.h spawn.h stdarg.h stdbool.h stddef.h stdint.h stdio.h
    stdlib.h string.h strings.h stropts.h 
    sys/ipc.h sys/mman.h sys/msg.h sys/resource.h sys/select.h sys/sem.h sys/shm.h
    sys/socket.h sys/stat.h sys/statvfs.h sys/time.h sys/timeb.h sys/times.h sys/types.h
    sys/uio.h sys/un.h sys/utsname.h sys/wait.h syslog.h
    tar.h termios.h tgmath.h time.h trace.h ucontext.h ulimit.h unistd.h utime.h
    utmpx.h wchar.h wctype.h wordexp.h
)

set(posix_standard_header_names_issue7 # 2018
    # https://pubs.opengroup.org/onlinepubs/9699919799/idx/head.html
    aio.h arpa/inet.h assert.h complex.h cpio.h ctype.h dirent.h dlfcn.h errno.h fcntl.h
    fenv.h float.h fmtmsg.h fnmatch.h ftw.h glob.h grp.h iconv.h inttypes.h iso646.h langinfo.h
    libgen.h limits.h locale.h math.h monetary.h mqueue.h ndbm.h net/if.h netdb.h
    netinet/in.h netinet/tcp.h nl_types.h poll.h pthread.h pwd.h regex.h sched.h search.h
    semaphore.h setjmp.h signal.h spawn.h stdarg.h stdbool.h stddef.h stdint.h stdio.h
    stdlib.h string.h strings.h stropts.h
    sys/ipc.h sys/mman.h sys/msg.h sys/resource.h sys/select.h sys/sem.h sys/shm.h
    sys/socket.h sys/stat.h sys/statvfs.h sys/time.h sys/times.h sys/types.h
    sys/uio.h sys/un.h sys/utsname.h sys/wait.h syslog.h
    tar.h termios.h tgmath.h time.h trace.h ulimit.h unistd.h utime.h
    utmpx.h wchar.h wctype.h wordexp.h
)

set(posix_standard_header_names_issue8 # 2024
    aio.h arpa/inet.h assert.h complex.h cpio.h ctype.h devctl.h dirent.h dlfcn.h endian.h
    errno.h fcntl.h
    fenv.h float.h fmtmsg.h fnmatch.h ftw.h glob.h grp.h iconv.h inttypes.h iso646.h langinfo.h
    libintl.h
    libgen.h limits.h locale.h math.h monetary.h mqueue.h ndbm.h net/if.h netdb.h
    netinet/in.h netinet/tcp.h nl_types.h poll.h pthread.h pwd.h regex.h sched.h search.h
    semaphore.h setjmp.h signal.h spawn.h stdalign.h stdarg.h stdatomic.h stdbool.h
    stddef.h stdint.h stdio.h
    stdlib.h stdnoreturn.h string.h strings.h
    sys/ipc.h sys/mman.h sys/msg.h sys/resource.h sys/select.h sys/sem.h sys/shm.h
    sys/socket.h sys/stat.h sys/statvfs.h sys/time.h sys/times.h sys/types.h
    sys/uio.h sys/un.h sys/utsname.h sys/wait.h syslog.h
    tar.h termios.h tgmath.h threads.h time.h uchar.h unistd.h
    utmpx.h wchar.h wctype.h wordexp.h
)
