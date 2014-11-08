extern void* malloc(long sz, int ba);

void* memcpy(void* dest, void* src, unsigned long count) {
	asm volatile("cld; rep movsb" : "+c" (count), "+S" (src), "+D" (dest) : : "memory");
	return dest;
}

int memcmp(const void *ptr1, const void *ptr2, unsigned long num) {
	int ret = 0;
	while (num--) {
		if (((char *)ptr1)[num] != ((char *)ptr2)[num]) {
			ret = -1;
			break;
		}
	}
	return ret;
}

void* memset(void* ptr, int value, unsigned long count) {
	asm volatile ("cld; rep stosb" : "+c" (count), "+D" (ptr) : "a" (value) : "memory");
	return ptr;
}

unsigned long strlen(const char *str) {
	int ret = 0;
	while (str[ret++]) { }
	return ret;
}

void *realloc(void *ptr, long sz) {
	void *ret = malloc(sz, 0);
	memcpy(ret, ptr, sz);
	return ret;
}

void *calloc(long sz, int ba) {
	void* ret = malloc(sz, ba);
	return (void *)memset(ret, 0, sz);
}

int pthread_mutex_lock(void *mutex) { asm ("cli; hlt"); }
int pthread_mutex_unlock(void *mutex) { asm ("cli; hlt"); }
int pthread_mutex_init() { asm ("cli; hlt"); }
int pthread_mutex_destroy() { asm ("cli; hlt"); }
void _d_monitor_destroy() { asm ("cli; hlt"); }

void program_invocation_name() { asm ("cli; hlt"); }
void stderr() { asm ("cli; hlt"); }
void fprintf() { asm ("cli; hlt"); }
void dl_iterate_phdr() { asm ("cli; hlt"); }
void __tls_get_addr() { asm ("cli; hlt"); }

void _memset128ii() { asm ("cli; hlt"); }

void* _Unwind_Resume() { asm ("cli; hlt"); }
void* _Dmodule_ref() { asm ("cli; hlt"); }
void* __gdc_personality_v0() { asm ("cli; hlt"); }
void* abort() { asm ("cli; hlt"); }