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

module TaskManager.SignalType;


enum SignalType {
	Null,
	SIGHUP, /* Hangup */
	SIGINT, /* Interupt */
	SIGQUIT, /* Quit */
	SIGILL, /* Illegal instruction */
	SIGTRAP, /* A breakpoint or trace instruction has been reached */
	SIGABRT, /* Another process has requested that you abort */
	SIGEMT, /* Emulation trap XXX */
	SIGFPE, /* Floating-point arithmetic exception */
	SIGKILL, /* You have been stabbed repeated with a large knife */
	SIGBUS, /* Bus error (device error) */
	SIGSEGV, /* Segmentation fault */
	SIGSYS, /* Bad system call */
	SIGPIPE, /* Attempted to read or write from a broken pipe */
	SIGALRM, /* This is your wakeup call. */
	SIGTERM, /* You have been Schwarzenegger'd */
	SIGUSR1, /* User Defined Signal #1 */
	SIGUSR2, /* User Defined Signal #2 */
	SIGCHLD, /* Child status report */
	SIGPWR, /* We need moar powah! */
	SIGWINCH, /* Your containing terminal has changed size */
	SIGURG, /* An URGENT! event (On a socket) */
	SIGPOLL, /* XXX OBSOLETE; socket i/o possible */
	SIGSTOP, /* Stopped (signal) */
	SIGTSTP, /* ^Z (suspend) */
	SIGCONT, /* Unsuspended (please, continue) */
	SIGTTIN, /* TTY input has stopped */
	SIGTTOUT, /* TTY output has stopped */
	SIGVTALRM, /* Virtual timer has expired */
	SIGPROF, /* Profiling timer expired */
	SIGXCPU, /* CPU time limit exceeded */
	SIGXFSZ /* File size limit exceeded */
}