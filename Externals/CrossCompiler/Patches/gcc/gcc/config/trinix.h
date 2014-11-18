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
#define LINK_SPEC "%{shared:-shared} %{!shared: %{!static: %{rdynamic:-export-dynamic} %{!dynamic-linker:-dynamic-linker /System/Library/ld-trinix.so}}}"


#undef NATIVE_SYSTEM_HEADER_DIR
#define NATIVE_SYSTEM_HEADER_DIR "/inkludy"

#undef STANDARD_STARTFILE_PREFIX
#define STANDARD_STARTFILE_PREFIX "/rododendron"

/*
/zlozka/Externals/Output/x86_64/usr/lib/gcc/x86_64-unknown-trinix/4.9.2/include/d
*/
/* Look for the include files in the system-defined places.  */

#undef GPLUSPLUS_INCLUDE_DIR
#define GPLUSPLUS_INCLUDE_DIR "/hovno/stacka/gdsds++"

#undef GCC_INCLUDE_DIR
#define GCC_INCLUDE_DIR "/kokot/gcciba"

#undef CC_INCLUDE_DIR
#define CC_INCLUDE_DIR "/kcurak/iCce"
/*
#undef INCLUDE_DEFAULTS
#define INCLUDE_DEFAULTS			\
  {						\
  { D_IMPORT_PATH, "D", 1, 1 },	\
    { 0, 0, 0, 0 }				\
  }
  */
  /*{ GPLUSPLUS_INCLUDE_DIR, "G++", 1, 1 },	\
    { GCC_INCLUDE_DIR, "GCC", 0, 0 },		\*/

/* Under NetBSD, the normal location of the compiler back ends is the
   /usr/libexec directory.  */
/*
#undef STANDARD_EXEC_PREFIX
#define STANDARD_EXEC_PREFIX		"/mrdka/libexec/"*/