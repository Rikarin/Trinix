module TaskManager.Signal;

import TaskManager.Task;
import TaskManager.Process;
import Architectures.CPU;
import Architectures.Core;

import Core.Log;
import System.Convert;

import System.Collections.Generic.List;
import System.Threading.All;


struct SignalState {
	ulong rsp;
	ulong rbp;
	ulong rip;
}


class Signal {
static:
private:
	__gshared List!Process retsFromSignal;
	__gshared Mutex lock;

	const byte isDeadly[] = [
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


	void Enter(void delegate() location, int signum, ulong stack) {
		location();
		
		asm {
			naked;
			cli;
			hlt;

			mov RSP, RDI; //stack
			//			push RSI; //signum
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
			hlt;
			//mov RDI, RSI;
			//mov RSI, RDX;
			jmp _CPU_iretq;
		}
	}


public:
	enum Count = 38; //37 + 0.
	enum SignalReturn = 0xFFFFFFFF_FFFFDEAD;


	bool Init() {
		lock = new Mutex();
		retsFromSignal = new List!Process();

		return true;
	}

	void ReturnFromSignalHandler() {
		debug(only) 
			Log.PrintSP("\nReturn from signal process: " ~ Convert.ToString(Task.CurrentProcess.id));

		lock.WaitOne();
		retsFromSignal.Add(Task.CurrentProcess);
		lock.Release();

		Task.Switch();
	}

	void FixStack() {
		lock.WaitOne();
		long idx = retsFromSignal.IndexOf(Task.CurrentProcess);

		if (idx == -1) {
			lock.Release();
			return;
		}

		Process proc = retsFromSignal[idx];
		retsFromSignal.RemoveAt(idx);
		lock.Release();

		proc.threads[0].rip = proc.signalState.rip;
		proc.threads[0].rsp = proc.signalState.rsp;
		proc.threads[0].rbp = proc.signalState.rbp;
		delete proc.signalStack;
	}

	void Handler(Process process, SigNum signal) {
		if (Task.CurrentProcess.state != Process.State.Running)
			return;

		if (!signal || signal > Count)
			return;

		auto handler = Task.CurrentProcess.Signals[signal];
		if (handler is null) {
			byte wat = isDeadly[signal];
			if (wat == 1 || wat == 2) {
				debug (only) {
					Log.PrintSP("\nProcess ");
					Log.PrintSP(Convert.ToString(cast(ulong)process.id));
					Log.PrintSP(" was killed by unhandled signal: ");
					Log.PrintSP(Convert.ToString(cast(ulong)signal));
				}

				Task.Exit(128 + signal);
			} else {
				debug (only) {
					Log.PrintSP("\nIgnoring signal: ");
					Log.PrintSP(Convert.ToString(cast(ulong)signal));
					Log.PrintSP(" by default");
				}
			}
			
			return;
		}

		debug (only) {
			Log.PrintSP("\nHandling signal: ");
			Log.PrintSP(Convert.ToString(cast(ulong)signal));
			Log.PrintSP(" by process: ");
			Log.PrintSP(Convert.ToString(Task.CurrentProcess.id));
		}

		Enter(handler, signal, cast(ulong)process.signalStack);
	}
}