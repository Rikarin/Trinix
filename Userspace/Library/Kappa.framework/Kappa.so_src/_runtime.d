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
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module _runtime;


extern(C) void* malloc(long size, int ba) {
	return null;
}

extern(C) void free(void* ptr) {
}


extern(C) void* memcpy(void* dest, void* src, ulong count) {
	asm {
		"cld; rep movsb" : "+c" (count), "+S" (src), "+D" (dest) : : "memory";
	}
	return dest;
}

extern(C) int memcmp(const void *ptr1, const void *ptr2, ulong num) {
	int ret = 0;
	while (num--) {
		if ((cast(char *)ptr1)[num] != (cast(char *)ptr2)[num]) {
			ret = -1;
			break;
		}
	}
	return ret;
}

extern(C) void* memset(void* ptr, int value, ulong count) {
	asm {
		"cld; rep stosb" : "+c" (count), "+D" (ptr) : "a" (value) : "memory";
	}
	return ptr;
}

extern(C) ulong strlen(const char *str) {
	int ret = 0;
	while (str[ret++]) { }
	return ret;
}

extern(C) void *realloc(void *ptr, long sz) {
	void *ret = malloc(sz, 0);
	memcpy(ret, ptr, sz);
	return ret;
}

extern(C) void *calloc(long sz, int ba) {
	void* ret = malloc(sz, ba);
	return cast(void *)memset(ret, 0, sz);
}

extern(C) void pthread_mutex_lock() { asm {"cli; hlt"; } }
extern(C) void pthread_mutex_unlock() { asm {"cli; hlt"; } }
extern(C) void pthread_mutex_init() { asm {"cli; hlt"; } }
extern(C) void pthread_mutex_destroy() { asm {"cli; hlt"; } }
extern(C) void _d_monitor_destroy() { asm {"cli; hlt"; } }

extern(C) void program_invocation_name() { asm {"cli; hlt"; } }
extern(C) void stderr() { asm {"cli; hlt"; } }
extern(C) void fprintf() { asm {"cli; hlt"; } }
extern(C) void dl_iterate_phdr() { asm {"cli; hlt"; } }
extern(C) void __tls_get_addr() { asm {"cli; hlt"; } }

extern(C)void _memset128ii() { asm {"cli; hlt"; } }

extern(C) void _Unwind_Resume() { asm {"cli; hlt"; } }
extern(C) void _Dmodule_ref() { asm {"cli; hlt"; } }
extern(C) void __gdc_personality_v0() { asm {"cli; hlt"; } }
extern(C) void abort() { asm {"cli; hlt"; } }