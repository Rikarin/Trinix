// D import file generated from '_runtime.d'
module _runtime;
extern (C) void* malloc(long size, int ba);

extern (C) void free(void* ptr);

extern (C) void* memcpy(void* dest, void* src, ulong count);

extern (C) int memcmp(const void* ptr1, const void* ptr2, ulong num);

extern (C) void* memset(void* ptr, int value, ulong count);

extern (C) ulong strlen(const char* str);

extern (C) void* realloc(void* ptr, long sz);

extern (C) void* calloc(long sz, int ba);

extern (C) void pthread_mutex_lock();

extern (C) void pthread_mutex_unlock();

extern (C) void pthread_mutex_init();

extern (C) void pthread_mutex_destroy();

extern (C) void _d_monitor_destroy();

extern (C) void program_invocation_name();

extern (C) void stderr();

extern (C) void fprintf();

extern (C) void dl_iterate_phdr();

extern (C) void __tls_get_addr();

extern (C) void _memset128ii();

extern (C) void _Unwind_Resume();

extern (C) void _Dmodule_ref();

extern (C) void __gdc_personality_v0();

extern (C) void abort();

