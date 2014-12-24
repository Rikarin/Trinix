# Trinix #

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Bloodmanovski/Trinix?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
Trinix is a hobby operating system written from scratch. OS is written in D language.
Based on OOP standards cuz POSIX is shit. Only 64-bit CPU is, was and will be supported.
Development began one beautiful day in January 3 years ago.
We had (we dont have it now lol) a framework based on .NET-like conventions but better.


# Community #
You can join us. Just fork, innovate and pull back.

Wiki: http://trinix.wikia.com/
IRC: `#Trinix` on `Freenode`
E-Mail: `satoshi@gshost.eu`

Please use our [Coding Conventions](https://github.com/Bloodmanovski/Trinix/blob/master/CC.md).


# How to build #
* CentOS:
* yum update && yum groupinstall "Development tools"
* Build cross-compiler `make -C Externals/CrossCompiler all`
* Build druntime. TODO
* Build OS. TODO
* Have a fun!


# Features #
* GRUB Multiboot 2 bootloader
* GDT, IDT, TSS tables for 64-bit mode
* Cache info from CPU
* PIC, PIT, RTC timers
* PML4 Paging, Virtual/Physical Memory Manager, Heap
* Statically compiled Module loader
* Resource/Syscall Manager using to manage syscall dynamically
* VFS Manager with `Ext2` readonly filesystem. Basic `dev` devices like null, zero, ...
* Synchonization primitives Spinlocks, Mutexex, Semapthores, Signals, Events, Messages, Shared Memnory, ...
* Multitasking with Thread -> Process implementation
	
	
# Licence #
Copyright (c) 2014 Trinix Foundation. All rights reserved.
 
This file is part of Trinix Operating System and is released under Trinix 
Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
except in compliance with the License. The rights granted to you under the
License may not be used to create, or enable the creation or redistribution
of, unlawful or unlicensed copies of an Trinix operating system, or to
circumvent, violate, or enable the circumvention or violation of, any terms
of an Trinix operating system software license agreement.
 
You may obtain a copy of the License at
http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 
The Original Code and all software distributed under the License are
distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.