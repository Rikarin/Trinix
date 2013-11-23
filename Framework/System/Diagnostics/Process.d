module System.Diagnostics.Process;

import System;
import System.Diagnostics;

import System.IFace;
import System.ResourceCaller;


enum SigNum {
	SIGHUP = 1, /* Hangup */
	SIGINT,     /* Interupt */
	SIGQUIT,    /* Quit */
	SIGILL,     /* Illegal instruction */
	SIGTRAP,    /* A breakpoint or trace instruction has been reached */
	SIGABRT,    /* Another process has requested that you abort */
	SIGEMT,     /* Emulation trap XXX */
	SIGFPE,     /* Floating-point arithmetic exception */
	SIGKILL,    /* You have been stabbed repeated with a large knife */
	SIGBUS,     /* Bus error (device error) */
	SIGSEGV,    /* Segmentation fault */
	SIGSYS,     /* Bad system call */
	SIGPIPE,    /* Attempted to read or write from a broken pipe */
	SIGALRM,    /* This is your wakeup call. */
	SIGTERM,    /* You have been Schwarzenegger'd */
	SIGUSR1,    /* User Defined Signal #1 */
	SIGUSR2,    /* User Defined Signal #2 */
	SIGCHLD,    /* Child status report */
	SIGPWR,     /* We need moar powah! */
	SIGWINCH,   /* Your containing terminal has changed size */
	SIGURG,     /* An URGENT! event (On a socket) */
	SIGPOLL,    /* XXX OBSOLETE; socket i/o possible */
	SIGSTOP,    /* Stopped (signal) */
	SIGTSTP,    /* ^Z (suspend) */
	SIGCONT,    /* Unsuspended (please, continue) */
	SIGTTIN,    /* TTY input has stopped */
	SIGTTOUT,   /* TTY output has stopped */
	SIGVTALRM,  /* Virtual timer has expired */
	SIGPROF,    /* Profiling timer expired */
	SIGXCPU,    /* CPU time limit exceeded */
	SIGXFSZ,    /* File size limit exceeded */
	SIGWAITING, /* Herp */
	SIGDIAF,    /* Die in a fire */
	SIGHATE,    /* The sending process does not like you */
	SIGWINEVENT, /* Window server event */
	SIGCAT,     /* Everybody loves cats */

	SIGTTOU
}


class Process {
private:
	ResourceCaller syscall;


public:
	static Process Start(ProcessStartInfo startInfo) {
		ulong[2] tmp = [IFace.Process.S_CREATE, cast(ulong)&startInfo];
		return new Process(ResourceCaller.StaticCall(IFace.Process.OBJECT, tmp));
	}

	static @property Process Current() {
		ulong[1] tmp = [IFace.Process.CURRENT];
		return new Process(ResourceCaller.StaticCall(IFace.Process.OBJECT, tmp));
	}

	static void Switch() {
		ulong[1] tmp = [IFace.Process.SWITCH];
		ResourceCaller.StaticCall(IFace.Process.OBJECT, tmp);
	}


	ulong ResID() { return syscall.ResID(); }

	this(ulong id) {
		syscall = new ResourceCaller(id, IFace.Process.OBJECT);
	}

	void SetSignalHanlder(SigNum signal, void delegate() hanlder) {
		Convert.DelegateToLong dtl;
		dtl.Delegate = hanlder;
		ulong[3] tmp = [signal, dtl.Value1, dtl.Value2];

		syscall.Call(IFace.Process.SET_HANDLER, tmp);
	}

	void SetSignalHanlder(SigNum signal, void function() hanlder) {
		ulong[3] tmp = [signal, 0, cast(ulong)hanlder];
		syscall.Call(IFace.Process.SET_HANDLER, tmp);
	}

	void SendSignal(SigNum signal) {
		ulong[1] tmp = [signal];
		syscall.Call(IFace.Process.SEND_SIGNAL, tmp);
	}
}