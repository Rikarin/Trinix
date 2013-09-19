module FileSystem.TTY;

import System.Collections.Generic.All;
import VFSManager.PipeNode;
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


	this() {
		inQueue  = new Queue!char();
		outQueue = new Queue!char();

		master = new PTYDev(this);
		slave  = new TTYDev(this);
	}
}


class PTYDev : PipeNode {
	TTY tty;

	override void Open() { }
	override void Close() { }

	@property override ulong Length() {
		return tty.outQueue.Count;
	}


	this(TTY tty, string name = "pty") {
		super(name);
		this.tty = tty;
	}


	override ulong Read(ulong offset, byte[] data) {
		return 0;
	}

	override ulong Write(ulong offset, byte[] data) {
		return 0;	
	}
}


class TTYDev : PipeNode {
	TTY tty;

	override void Open() { }
	override void Close() { }

	@property override ulong Length() {
		return tty.inQueue.Count;
	}


	this(TTY tty, string name = "tty") {
		super(name);
		this.tty = tty;
	}


	override ulong Read(ulong offset, byte[] data) {
		return 0;
	}

	override ulong Write(ulong offset, byte[] data) {
		return 0;
	}
}