module FileSystem.TTY;

import System.Collections.Generic.Queue;
import VFSManager.CharNode;
import TaskManager.Process;
import System.Termios;


class TTY {
package:
	long name;

	PTYDev master;
	TTYDev slave;

	WinSize size;
	Termios termios;

	Queue!char inQueue;
	Queue!char outQueue;

	Process fgProc;
	Process bgProc;

	char[] cannonBuffer;
	ulong cannonPointer;


	this() {
		inQueue  = new Queue!char();
		outQueue = new Queue!char();

		master = new PTYDev(this);
		slave  = new TTYDev(this);

		cannonBuffer = new char[512];

		//TODO NAME
		size.Row = 25;
		size.Col = 80;

		termios.IFlag = InputModes.ICRNL | InputModes.BRKINT;
		termios.OFlag = OutputModes.ONLCR | OutputModes.OPOST;
		termios.LFlag = LocalModes.ECHO | LocalModes.ECHOE | LocalModes.ECHOK | LocalModes.ICANON | LocalModes.ISIG | LocalModes.IEXTEN;
		termios.CFlag = ControlModes.CREAD;
		termios.c_cc[Commands.VEOF]   =  4; /* ^D */
		termios.c_cc[Commands.VEOL]   =  0; /* Not set */
		termios.c_cc[Commands.VERASE] = '\b';
		termios.c_cc[Commands.VINTR]  =  3; /* ^C */
		termios.c_cc[Commands.VKILL]  = 21; /* ^U */
		termios.c_cc[Commands.VMIN]   =  1;
		termios.c_cc[Commands.VQUIT]  = 28; /* ^\ */
		termios.c_cc[Commands.VSTART] = 17; /* ^Q */
		termios.c_cc[Commands.VSTOP]  = 19; /* ^S */
		termios.c_cc[Commands.VSUSP]  = 26; /* ^Z */
		termios.c_cc[Commands.VTIME]  =  0;
	}

	~this() {
		delete inQueue;
		delete outQueue;

		delete master;
		delete slave;

		delete cannonBuffer;
	}

	void Input(char c) {
		if (termios.LFlag & LocalModes.ICANON) {
			if (c == termios.c_cc[Commands.VKILL]) {
				while (cannonPointer) {
					cannonBuffer[cannonPointer--] = '\0';
					if (termios.LFlag & LocalModes.ECHO) {
						Output('\010');
						Output(' ');
						Output('\010');
					}
				}
				return;
			}
			if (c == termios.c_cc[Commands.VERASE]) {
				if (cannonPointer) {
					cannonBuffer[cannonPointer--] = '\0';
					if (termios.LFlag & LocalModes.ECHO) {
						Output('\010');
						Output(' ');
						Output('\010');
					}
				}
				return;
			}
			if (c == termios.c_cc[Commands.VINTR]) {
				if (termios.LFlag & LocalModes.ECHO) {
					Output('^');
					Output(cast(char)('@' + c));
					Output('\n');
				}
				cannonPointer = 0;
				cannonBuffer[0] = '\0';

				//if (fgProc !is null) send signal SIGINT
				return;
			}
			if (c == termios.c_cc[Commands.VQUIT]) {
				if (termios.LFlag & LocalModes.ECHO) {
					Output('^');
					Output(cast(char)('@' + c));
					Output('\n');
				}
				cannonPointer = 0;
				cannonBuffer[0] = '\0';

				//if (fgProc !is null) send signal SIGQUIT
				return;
			}

			cannonBuffer[cannonPointer] = c;

			if (termios.LFlag & LocalModes.ECHO)
				Output(c);

			if (cannonBuffer[cannonPointer] == '\n') {
				cannonPointer++;

				foreach (i; 0 .. cannonPointer)
					inQueue.Enqueue(cannonBuffer[i]);

				cannonPointer = 0;
				return;
			}
			if (cannonPointer == 512) {
				foreach (i; 0 .. cannonPointer)
					inQueue.Enqueue(cannonBuffer[i]);
					
				cannonPointer = 0;
				return;
			}
			cannonPointer++;
			return;
		} else if (termios.LFlag & LocalModes.ECHO)
			Output(c);

		inQueue.Enqueue(c);
	}

	void Output(char c) {
		if (c == '\n' && (termios.OFlag & OutputModes.ONLCR)) {
			outQueue.Enqueue('\r');
		}

		outQueue.Enqueue(c);
	}
}


class PTYDev : CharNode {
	TTY tty;

	@property override ulong Length() {
		return tty.outQueue.Count;
	}


	this(TTY tty, string name = "pty") {
		super(name);
		this.tty = tty;
	}


	override ulong Read(ulong offset, byte[] data) {
		foreach (ref x; data)
			x = tty.outQueue.Dequeue();

		return data.length;
	}

	override ulong Write(ulong offset, byte[] data) {
		foreach (x; data)
			tty.Input(x);

		return data.length;
	}
}


class TTYDev : CharNode {
	TTY tty;

	@property override ulong Length() {
		return tty.inQueue.Count;
	}


	this(TTY tty, string name = "tty") {
		super(name);
		this.tty = tty;
	}


	override ulong Read(ulong offset, byte[] data) {
		if (tty.termios.LFlag & LocalModes.ICANON) {
			foreach (ref x; data)
				x = tty.inQueue.Dequeue();

			return data.length;
		} else {
			ulong len;

			if (!tty.termios.c_cc[Commands.VMIN])
				len = tty.outQueue.Count > data.length ? data.length : tty.outQueue.Count;
			else
				len = tty.termios.c_cc[Commands.VMIN] > data.length ? data.length : tty.termios.c_cc[Commands.VMIN];

			foreach (ref x; data[0 .. len])
				x = tty.inQueue.Dequeue();

			return len;
		}
	}

	override ulong Write(ulong offset, byte[] data) {
		foreach (x; data)
			tty.Output(x);

		return data.length;
	}
}