[![Build Status](https://travis-ci.org/Bloodmanovski/Trinix.svg)](https://travis-ci.org/Bloodmanovski/Trinix)
[![Coverage Status](https://coveralls.io/repos/Bloodmanovski/Trinix/badge.svg?branch=master&service=github)](https://coveralls.io/github/Bloodmanovski/Trinix?branch=master)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Bloodmanovski/Trinix?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# Trinix #
Trinix is a hobby operating system written from scratch. OS is written in D language.
Based on OOP standards and implementing modified POSIX standards for the best usage with D. Only x86_64 CPU is supported.
Development began one beautiful day in January 3 years ago.
We are working on framework based on .NET naming conventions.


# Community #
You can join us. Just fork, innovate and pull request.

Wiki: http://trinix.wikia.com/  
IRC: `#Trinix` on `Freenode`  
E-Mail: `satoshi@gshost.eu`

Please use our [Coding Conventions](https://github.com/Bloodmanovski/Trinix/blob/master/CC.md).


# How to build #
* Use CentOS
* Install Development Tools
* Install LLVM/LDC compiler and GNU/Binutils
* call 'make image' then 'make install'
* Voila, you have an img


# Features #
* GRUB Multiboot 2 bootloader
* x86_64 support
* GDT, IDT, TSS tables
* CPU cache info
* PIC, PIT, RTC timer
* PML4 Paging, Virtual/Physical Memory Manager, Heap
* Static module loader
* Resource/Syscall Manager
* VFS Manager
* IPC: Spinlock, Mutex, Semaphore, Signal, Event, Message, Reader Writer Lock, Shared Memory
* Preemtive multitasking
* Modules: Ext2, Keyboard, Mouse, PS2 Keyboard/Mouse, ATA
	
	
# Licence #
Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 
This file is part of Trinix Operating System and is released under Trinix 
Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
except in compliance with the License. The rights granted to you under the
License may not be used to create, or enable the creation or redistribution
of, unlawful or unlicensed copies of an Trinix operating system, or to
circumvent, violate, or enable the circumvention or violation of, any terms
of an Trinix operating system software license agreement.
 
You may obtain a copy of the License at
https://github.com/Bloodmanovski/Trinix and read it before using this file.
 
The Original Code and all software distributed under the License are
distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
