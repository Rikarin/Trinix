# TrinityOS #
TrinityOS is a hobby operating system written from scratch. OS is written in D (http://www.dlang.org/) and asm (NASM). It means OS is fully OOP and now supports only x64 arch PC. Development began one beutiful day in January and continue to this day. We have own framework based on .NET-like classes, interfaces and other .NET things.

(Sorry for my bad english, if u have better translate so contact me by mail or irc)


# Community #
If u have any questions or feedbacks u can contact me by E-Mail: `Bloodman@gshost.eu` or on IRC: `#TrinityOS` on `Freenode`.
(We are looking for developers and testers)


# How to build #
* Install dmd, nasm, ld, gcc, qemu and other needed stuffs.
* Build druntime `make runtime`
* Build and run OS `make debug`
* Have a fun!


# We have #
* GRUB Multiboot 2 bootloader
* GDT, IDT, TSS tables for x64 mode
* ACPI driver (need to be fixed for version 2)
* LocalAPIC, IOAPIC drivers with multiprocessor configuration
* Cache info form CPU
* Basic timer based on APIC
* PML4 Paging where every process have their own page table (need to be fixed up)
* Memory manager for physical address & HEAP
* Dynamic syscalls database with syscall/sysret handler
* VFS manager with `proc`, `dev`, `tmp` filesystems for kernel operations. Basic `dev` devices like null, zero, ttyS, random and pipes
* Asynchronous singls where singnals are processed only by first thread of every process
* Multitasking where `Process` is only group of `Threads` with same things as are paging direcotry, file descriptors, signal handlers, etc.
* Basic syscalls for reading, writing, etc. calls for FSNode, creating process/thread, ...


# When we need update druntime #
druntime:
	add to files src/gc/gc.d & src/gcstub/gc.d:
		extern(C) void* malloc(size_t sz, uint ba = 0);
		extern(C) void* calloc(size_t sz, uint ba = 0);
		extern(C) void* realloc(void* p, size_t sz, uint ba = 0);
		extern(C) void free(void* p);
	and modify gc_... functions for using our own calls
	
	
# Licence #
Still working on it but this OS is now opensource for non comercial use. Please dont redistribute source code of this OS. You can modify it only for own or developing use.