extern void *malloc(long sz, int ba);

void *memcpy(void *dest, void *src, unsigned long num) {
	unsigned long i = 0;
	while (i < num) {
		((char *)dest)[i] = ((char *)src)[i];
		i++;
	}

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

void* memset(void* ptr, int value, unsigned long num) {
	while (num--)
		((unsigned char *)ptr)[num] = (unsigned char)value;
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

int pthread_mutex_lock(void *mutex) { return 0; }
int pthread_mutex_unlock(void *mutex) { return 0; }
int pthread_mutex_init() { return 0; }
int pthread_mutex_destroy() { return 0; }
void _d_monitor_destroy() { }

/*void remap() {
	unsigned long addr = 0;
	unsigned long *pd = (unsigned long *)0x22000;
	unsigned long *pt;
	int i, j;
	
	while (i < 512) {
		pt = (unsigned long *)0x23000 + i * 0x1000;
		pd[i] = (unsigned long)pt | 3;
		
		j = 0;
		while (j < 512) {
			pt[i] = addr | 3;
			addr += 0x1000;
		}
	}
}*/