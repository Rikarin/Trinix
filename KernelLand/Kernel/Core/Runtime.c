/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

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

void pthread_mutex_lock() { asm ("cli; hlt"); }
void pthread_mutex_unlock() { asm ("cli; hlt"); }
void pthread_mutex_init() { asm ("cli; hlt"); }
void pthread_mutex_destroy() { asm ("cli; hlt"); }
void _d_monitor_destroy() { asm ("cli; hlt"); }

void program_invocation_name() { asm ("cli; hlt"); }
void stderr() { asm ("cli; hlt"); }
void fprintf() { asm ("cli; hlt"); }
void dl_iterate_phdr() { asm ("cli; hlt"); }
void __tls_get_addr() { asm ("cli; hlt"); }

void _memset128ii() { asm ("cli; hlt"); }

void _Unwind_Resume() { asm ("cli; hlt"); }
void _Dmodule_ref() { asm ("cli; hlt"); }
void __gdc_personality_v0() { asm ("cli; hlt"); }
void abort() { asm ("cli; hlt"); }