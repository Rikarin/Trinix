module TaskManager.Signal;

import TaskManager.Task;


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
			
		}
	}

public:
	void ReturnFromSignalHandler() {
		debug(only) {
			import Core.Log;
			import System.Convert;
			Log.Debug("Return from signal process=" ~ Convert.ToString(Task.CurrentProcess.id));
		}
	}
}