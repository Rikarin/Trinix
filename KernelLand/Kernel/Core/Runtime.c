/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
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


void pthread_mutex_init()              { asm ("cli; hlt"); }
void pthread_mutex_destroy()           { asm ("cli; hlt"); }
void pthread_mutex_trylock()           { asm ("cli; hlt"); }
void pthread_mutex_lock()              { asm ("cli; hlt"); }
void pthread_mutex_unlock()            { asm ("cli; hlt"); }
void pthread_mutexattr_init()          { asm ("cli; hlt"); }
void pthread_mutexattr_settype()       { asm ("cli; hlt"); }
void pthread_mutexattr_destroy()       { asm ("cli; hlt"); }
void pthread_create()                  { asm ("cli; hlt"); }
void pthread_detach()                  { asm ("cli; hlt"); }
void pthread_self()                    { asm ("cli; hlt"); }
void pthread_join()                    { asm ("cli; hlt"); }
void pthread_kill()                    { asm ("cli; hlt"); }
void pthread_getschedparam()           { asm ("cli; hlt"); }
void pthread_getspecific()             { asm ("cli; hlt"); }
void pthread_setspecific()             { asm ("cli; hlt"); }
void pthread_key_create()              { asm ("cli; hlt"); }
void pthread_key_delete()              { asm ("cli; hlt"); }
void pthread_getattr_np()              { asm ("cli; hlt"); }
void pthread_setschedprio()            { asm ("cli; hlt"); }
void pthread_attr_init()               { asm ("cli; hlt"); }
void pthread_attr_setstacksize()       { asm ("cli; hlt"); }
void pthread_attr_setdetachstate()     { asm ("cli; hlt"); }
void pthread_attr_getstack()           { asm ("cli; hlt"); }
void pthread_attr_destroy()            { asm ("cli; hlt"); }
                                       
void _pthread_cleanup_pop()            { asm ("cli; hlt"); }
void _pthread_cleanup_push()           { asm ("cli; hlt"); }
                                       
void program_invocation_name()         { asm ("cli; hlt"); }
void stderr()                          { asm ("cli; hlt"); }
void fprintf()                         { asm ("cli; hlt"); }
void abort()                           { asm ("cli; hlt"); }
                                       
void __tls_get_addr()                  { asm ("cli; hlt"); }
void dl_iterate_phdr()                 { asm ("cli; hlt"); }
void qsort_r()                         { asm ("cli; hlt"); }
void printf()                          { asm ("cli; hlt"); }
void vprintf()                         { asm ("cli; hlt"); }
void putchar()                         { asm ("cli; hlt"); }
void __errno_location()                { asm ("cli; hlt"); }
void time()                            { asm ("cli; hlt"); }
void munmap()                          { asm ("cli; hlt"); }
void mmap64()                          { asm ("cli; hlt"); }
void memmove()                         { asm ("cli; hlt"); }
void clock_gettime()                   { asm ("cli; hlt"); }
void clock_getres()                    { asm ("cli; hlt"); }
void sysconf()                         { asm ("cli; hlt"); }
void sem_init()                        { asm ("cli; hlt"); }
void sem_wait()                        { asm ("cli; hlt"); }
void sem_post()                        { asm ("cli; hlt"); }
void sigaction()                       { asm ("cli; hlt"); }
void sigfillset()                      { asm ("cli; hlt"); }
void sigsuspend()                      { asm ("cli; hlt"); }
void sigdelset()                       { asm ("cli; hlt"); }
void nanosleep()                       { asm ("cli; hlt"); }
                                       
void sched_yield()                     { asm ("cli; hlt"); }
void sched_get_priority_max()          { asm ("cli; hlt"); }
void sched_get_priority_min()          { asm ("cli; hlt"); }
                                       
void _Unwind_GetIP()                   { asm ("cli; hlt"); }
void _Unwind_SetGR()                   { asm ("cli; hlt"); }
void _Unwind_SetIP()                   { asm ("cli; hlt"); }
void _Unwind_Resume()                  { asm ("cli; hlt"); }
void _Unwind_RaiseException()          { asm ("cli; hlt"); }
void _Unwind_GetTextRelBase()          { asm ("cli; hlt"); }
void _Unwind_GetRegionStart()          { asm ("cli; hlt"); }
void _Unwind_GetDataRelBase()          { asm ("cli; hlt"); }
void _Unwind_GetLanguageSpecificData() { asm ("cli; hlt"); }