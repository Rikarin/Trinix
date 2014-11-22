#undef TARGET_OS_CPP_BUILTINS
#define TARGET_OS_CPP_BUILTINS()      \
  do {                                \
    builtin_define_std ("trinix");      \
    builtin_define_std ("unix");      \
    builtin_assert ("system=trinix");   \
    builtin_assert ("system=unix");   \
  } while(0);

  
#define LIB_SPEC "-L /zlozka/Externals/Output/x86_64/CrossCompiler/System/Library/ -lld"

#undef STARTFILE_SPEC
#define STARTFILE_SPEC "%{!shared: %{!pg:crt0.o%s}} crti.o%s %{!shared:crtbegin.o%s}"

#undef ENDFILE_SPEC
#define ENDFILE_SPEC "%{!shared:crtend.o%s} crtn.o%s"

#undef LINK_SPEC
#define LINK_SPEC "%{shared:-shared} %{!shared: %{!static: %{rdynamic:-export-dynamic} %{!dynamic-linker:-dynamic-linker /System/Library/ld.so}}}"

#undef INCLUDE_DEFAULTS
#define INCLUDE_DEFAULTS \
{ \
	{ "/zlozka/Externals/Output/x86_64/CrossCompiler/System/Include", "GCC", 0, 0, 0, 0 }, \
	{ "/zlozka/Externals/Output/x86_64/CrossCompiler/System/Include/D", "GCC", 0, 0, 0, 0 }, \
	{ "/zlozka/Externals/Output/x86_64/CrossCompiler/System/Include/CPP", "G++", 1, 1, 0, 0 }, \
	{ 0, 0, 0, 0, 0, 0 } \
}


/* I dont know what really STANDARD_STARTFILE_PREFIX is */
#undef STANDARD_STARTFILE_PREFIX
#define STANDARD_STARTFILE_PREFIX "/zlozka/Externals/Output/x86_64/CrossCompiler/System/Library/"

#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/zlozka/Externals/Output/x86_64/CrossCompiler/System/Library/"
#define STANDARD_STARTFILE_PREFIX_2 "/zlozka/Externals/Output/x86_64/CrossCompiler/System/Library/"

/*
#undef STANDARD_EXEC_PREFIX
#define STANDARD_EXEC_PREFIX "/zlozka/Externals/Output/x86_64/CrossCompiler/System/Binary"*/