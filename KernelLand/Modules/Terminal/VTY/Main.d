/**
 * TODO:
 * 		o Check if server or clinet doesnt EOF...
 * 		o Check for flags...
 */

module Modules.Terminal.VTY.Main;

import Core; //TESTING ONLY
import Library;
import VFSManager;
import TaskManager;
import ObjectManager;
import SyscallManager;
import Modules.Terminal.VTY.DriverInfo;


class VTY : Resource {
	private PTYDev _master;
	private TTYDev _slave;

	private Queue!char _in;
	private Queue!char _out;

	private Mutex _lockIn;
	private Termios _termios;

	this() {
		static const ResouceCallTable rcs = {_DriverInfo_Terminal_VTY.Identifier, &StaticCallback};
		static const CallTable[] callTable = [
			//{0, ".Attributes", 0, null}
		];

		_lockIn = new Mutex();

		_in  = new Queue!char();
		_out = new Queue!char();

		_master = new PTYDev(this, DeviceManager.DevFS, FSNode.NewAttributes("pty0"));
		_slave  = new TTYDev(this, DeviceManager.DevFS, FSNode.NewAttributes("tty0"));

		
		ResourceManager.AddCallTables(rcs);
		super(_DriverInfo_Terminal_VTY, callTable);
	}

	this(out FSNode master, out FSNode slave) {
		this();

		master = _master;
		slave  = _slave;
	}

	~this() {
		delete _in;
		delete _out;

		delete _master;
		delete _slave;
	}

	static ModuleResult Initialize(string[] args) {
		new VTY();
		Log.WriteLine("test");
		return ModuleResult.Sucessful;
	}
	
	static ModuleResult Finalize() {
		return ModuleResult.Error;
	}

	void Input(char c) {

	}

	void Output(char c) {

	}

	static long StaticCallback(long param1, long param2, long param3, long param4, long param5) {
		return -2;
	}
}

class TTYDev : CharNode { //client, slave
	private VTY _vty;

	this(VTY vty, DirectoryNode parent, FileAttributes attributes) {
		_vty = vty;

		super(parent, attributes);
		Identifier = "com.modules.Terminal.VTY.TTY";
		_attributes.Length = _vty._in.Count;
	}

	ulong Read(long offset, byte[] data) {
		//TODO timeout, server disconnected,...
		_vty._lockIn.WaitOne();
		scope(exit) _vty._lockIn.Release();

		if (_vty._termios.LocalFlags & LocalModes.ICANON) {
			foreach (ref x; data)
				x = _vty._in.Dequeue();

			return data.length;
		} else {
			ulong len;

			if (!_vty._termios.ControlChars[Commands.VMIN])
				len = _vty._in.Count > data.length ? data.length : _vty._in.Count;
			else
				len = _vty._termios.ControlChars[Commands.VMIN] > data.length ? data.length : _vty._termios.ControlChars[Commands.VMIN];

			foreach (ref x; data[0 .. len])
				x = _vty._in.Dequeue();

			return len;
		}
	}

	ulong Write(long offset, byte[] data) {
		foreach (x; data)
			_vty.Output(x);

		return data.length;
	}
}

class PTYDev : CharNode { //server, master
	private VTY _vty;
	private Mutex _mutex;

	this(VTY vty, DirectoryNode parent, FileAttributes attributes) {
		_vty   = vty;
		_mutex = new Mutex();

		super(parent, attributes);
		Identifier = "com.modules.Terminal.VTY.PTY";
		_attributes.Length = _vty._out.Count;
	}

	ulong Read(long offset, byte[] data) {
		long collected;

		while (!collected) {
			_mutex.WaitOne();
			while (_vty._out.Count > 0 && collected < data.length)
				data[collected++] = _vty._out.Dequeue();
			_mutex.Release();
		}

		return collected;
	}
	
	ulong Write(long offset, byte[] data) {
		foreach (x; data)
			_vty.Input(x);

		return data.length;
	}
}