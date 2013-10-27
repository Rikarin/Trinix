# TrinityOS #
TrinityOS is a hobby operating system written from scratch. OS is written in D (http://www.dlang.org/) and asm (NASM). It means OS is fully OOP. For now only 64-bit is supported. Development began one beautiful day in January and continues to this day. We have a framework based on .NET-like classes, interfaces and other .NET things.

(Sorry for bad english, if you have a better translation contact me by mail or irc)


# Community #
If you have any questions or feedback, you can contact me by E-Mail: `Bloodman@gshost.eu` or on IRC: `#TrinityOS` on `Freenode`.
(We are looking for developers and testers)


# How to build #
* Install dmd, nasm, ld, gcc, qemu and other needed stuff.
* Build druntime `make runtime`
* Build the OS `make debug`
* Have a fun!


# Features #
* GRUB Multiboot 2 bootloader
* GDT, IDT, TSS tables for 64-bit mode
* ACPI driver (needs to be fixed for version 2)
* LocalAPIC, IOAPIC drivers with multiprocessor configuration
* Cache info from CPU
* Basic timer based on APIC
* PML4 Paging where every process has its own page table (needs to be fixed up)
* Memory manager for physical address & HEAP
* Dynamic syscalls database with syscall/sysret handler
* VFS manager with `proc`, `dev`, `tmp` filesystems for kernel operations. Basic `dev` devices like null, zero, ttyS, random and pipes
* Asynchronous singls where signals are processed only by first thread of every process
* Multitasking where `Process` is only a group of `Threads` with the same things as are paging directory, file descriptors, signal handlers, etc.
* Basic syscalls for reading, writing, etc. calls for FSNode, creating process/thread, ...


# When we need to update druntime #
druntime:
	add to files src/gc/gc.d & src/gcstub/gc.d:
		extern(C) void* malloc(size_t sz, uint ba = 0);
		extern(C) void* calloc(size_t sz, uint ba = 0);
		extern(C) void* realloc(void* p, size_t sz, uint ba = 0);
		extern(C) void free(void* p);
	and modify gc_... functions for using our own calls
	
	
# Licence #
Still working on it but this OS is now opensource for non-commercial use. Please don't redistribute source code of this OS. You can modify only for personal use or development.
