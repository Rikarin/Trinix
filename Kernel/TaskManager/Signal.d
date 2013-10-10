module TaskManager.Signal;

import TaskManager.Task;
import TaskManager.Process;
import Architectures.CPU;
import Architectures.Core;


struct SignalTable {
	uint Signum;
	void function() CallBack;
	InterruptStack RegistersBefore;
}

struct SignalState {
	ulong rsp;
	ulong rbp;
	ulong rip;
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

		/*	pop RBX; //User stack
			pop RCX; //ThreadEntry

			xor RAX, RAX;
			mov AX, 0x1B;
			mov DS, AX;
			mov ES, AX;
			mov FS, AX;
			mov GS, AX;

			push RAX;
			push RBX;

			pushfq;
			pop RAX;
			or RAX, 0x200UL;
			push RAX;

			push 0x23UL;
			push RCX;
			jmp _CPU_iretq;*/
			
		}
	}

public:
	enum Count = 20;


	void ReturnFromSignalHandler() {
		debug(only) {
			import Core.Log;
			import System.Convert;
			Log.Debug("Return from signal process=" ~ Convert.ToString(Task.CurrentProcess.id));
		}
	}

	void FixStacks() {

	}

	void Handle(Process process, SignalTable signal) {

	}
}