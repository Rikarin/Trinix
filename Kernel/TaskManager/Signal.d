module TaskManager.Signal;

import TaskManager.Task;
import TaskManager.Process;
import Architectures.CPU;
import Architectures.Core;


struct SignalTable {
	SigNum Signum;
	void function() CallBack;
	InterruptStack RegistersBefore;
}

struct SignalState {
	ulong rsp;
	ulong rbp;
	ulong rip;
}

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
	SIGWINEVEN, /* Window server event */
	SIGCAT,     /* Everybody loves cats */

	SIGTTOU
}


class Signal {
static:
private:
	const byte isdeadly[] = [
		0, /* 0? */
		1, /* SIGHUP     */
		1, /* SIGINT     */
		2, /* SIGQUIT    */
		2, /* SIGILL     */
		2, /* SIGTRAP    */
		2, /* SIGABRT    */
		2, /* SIGEMT     */
		2, /* SIGFPE     */
		1, /* SIGKILL    */
		2, /* SIGBUS     */
		2, /* SIGSEGV    */
		2, /* SIGSYS     */
		1, /* SIGPIPE    */
		1, /* SIGALRM    */
		1, /* SIGTERM    */
		1, /* SIGUSR1    */
		1, /* SIGUSR2    */
		0, /* SIGCHLD    */
		0, /* SIGPWR     */
		0, /* SIGWINCH   */
		0, /* SIGURG     */
		0, /* SIGPOLL    */
		3, /* SIGSTOP    */
		3, /* SIGTSTP    */
		0, /* SIGCONT    */
		3, /* SIGTTIN    */
		3, /* SIGTTOUT   */
		1, /* SIGVTALRM  */
		1, /* SIGPROF    */
		2, /* SIGXCPU    */
		2, /* SIGXFSZ    */
		0, /* SIGWAITING */
		1, /* SIGDIAF    */
		0, /* SIGHATE    */
		0, /* SIGWINEVENT*/
		0, /* SIGCAT     */
	];


	void Enter(ulong location, int signum, ulong stack) {
		asm {
			naked;
			cli;

			mov RSP, RDI; //stack

			push RSI; //signum
			push SignalReturn;

			mov AX, 0x1B;
			mov DS, AX;
			mov ES, AX;
			mov FS, AX;
			mov GS, AX;
			mov RAX, RSP;

			push 0x1B;
			push RAX;

			pushfq;
			pop RAX;
			or RAX, 0x200UL;
			push RAX;

			push 0x23UL;
			push RDX; //location
			jmp _CPU_iretq;
		}
	}

public:
	enum Count = 37;
	enum SignalReturn = 0xFFFFFFFF_FFFFDEAD;


	void ReturnFromSignalHandler() {
		debug(only) {
			import Core.Log;
			import System.Convert;
			Log.Debug("Return from signal process=" ~ Convert.ToString(Task.CurrentProcess.id));
		}
		Task.Switch();
	}

	void FixStacks() {

	}

	void Handle(Process process, SignalTable signal) {
		if (signal.Signum == SigNum.SIGSEGV) {
			import Core.Log;
			Log.Print(" ==== Page Fault ====", 0x200);
		} else
			Enter(cast(ulong)signal.CallBack, 0x456, cast(ulong)(new byte[0x1000]).ptr);
	}
}