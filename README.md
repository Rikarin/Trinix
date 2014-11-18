# Trinix (REWRITE ME PLS)#
Trinix is a hobby operating system written from scratch. OS is written in D language. Based on OOP standards cuz POSIX is shit. Only 64-bit CPU is, was and will be supported. Development began one beautiful day in January 3 years ago. We had (we dont have it now lol) a framework based on .NET-like conventions but better.


# Community #
You can join us. Just fork, innovate and pull back.

If you have any questions or feedback, contact me on IRC: `#Trinix` on `Freenode`.
Or via mail satoshi@gshost.eu


# How to build #
* CentOS:
* yum update && yum groupinstall "Development tools"
* Build cross-compiler `make -C Externals/CrossCompiler all`
* Build druntime. TODO
* Build OS. TODO
* Have a fun! TODO LOL


# Features #
* GRUB Multiboot 2 bootloader
* GDT, IDT, TSS tables for 64-bit mode
* ACPI driver -NOPE
* LocalAPIC, IOAPIC drivers with multiprocessor configuration -NOPE
* Cache info from CPU
* Basic timer based on APIC -NOPE
* PML4 Paging where every process has its own page table (needs to be fixed up)
* Memory manager for physical address & HEAP
* Dynamic syscalls database with syscall/sysret handler -Object Manager/Handles
* VFS manager with `proc`, `dev`, `tmp` filesystems for kernel operations. Basic `dev` devices like null, zero, ttyS, random and pipes
* Asynchronous singls where signals are processed only by first thread of every process
* Multitasking where `Process` is only a group of `Threads` with the same things as are paging directory, file descriptors, signal handlers, etc.
* Basic syscalls for reading, writing, etc. calls for FSNode, creating process/thread, ...


# When we need to update druntime #
pff, I never heard about patchfiles LOL TODO
druntime:
	add to files src/gc/gc.d & src/gcstub/gc.d:
		extern(C) void* malloc(size_t sz, uint ba = 0);
		extern(C) void* calloc(size_t sz, uint ba = 0);
		extern(C) void* realloc(void* p, size_t sz, uint ba = 0);
		extern(C) void free(void* p);
	and modify gc_... functions for using our own calls
	
	
# Licence #
THIS IS SHIT LOL TODO...
Still working on it but this OS is now opensource for non-commercial use. Please don't redistribute modified source code of this OS. You can modify it only for personal or development use.
