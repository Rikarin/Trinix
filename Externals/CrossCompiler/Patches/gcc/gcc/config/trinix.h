#undef TARGET_OS_CPP_BUILTINS
#define TARGET_OS_CPP_BUILTINS()      \
  do {                                \
    builtin_define_std ("trinix");      \
    builtin_define_std ("unix");      \
    builtin_assert ("system=trinix");   \
    builtin_assert ("system=unix");   \
  } while(0);

/*
#define LIB_SPEC	"-lc -lld-trinix -lposix"
#define LIBSTDCXX "c++
*/

#undef STARTFILE_SPEC
#define STARTFILE_SPEC "%{!shared: %{!pg:crt0.o%s}} crti.o%s %{!shared:crtbegin.o%s}"

#undef ENDFILE_SPEC
#define ENDFILE_SPEC "%{!shared:crtend.o%s} crtn.o%s"

#undef LINK_SPEC
#define LINK_SPEC "%{shared:-shared} %{!shared: %{!static: %{rdynamic:-export-dynamic} %{!dynamic-linker:-dynamic-linker /System/Libraries/ld-trinix.so}}}"

#undef TARGET_VERSION
#define TARGET_VERSION fprintf(stderr, " (i386 trinix)");