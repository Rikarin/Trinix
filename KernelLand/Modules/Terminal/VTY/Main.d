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
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 * 
 * TODO:
 * 		o Check if server or clinet doesnt EOF...
 * 		o Check for flags...
 *      o To Read/Write methods add timeout, checkout for is server connected
 *      o Let user to define his own Termios and pass them to constructor
 *      o Implement static calls
 *      o Protect syscall inputs
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
	private static const ResouceCallTable _rcs = {
		_DriverInfo_Terminal_VTY.Identifier,
		&StaticCallback
	};

	private PTYDev _master;
	private TTYDev _slave;

	private Queue!char _in;
	private Queue!char _out;

	private Mutex _lockIn;
	private Termios _termios;
    private WindowSize _window;

    private long _canonBufferLength;
    private char[512] _canonBuffer;

    //private Process _controllProcess;
    private Thread _fgThread;

	this() {
		static const CallTable[] callTable = [
        ];

		_lockIn = new Mutex();

		_in  = new Queue!char();
		_out = new Queue!char();

		_master = new PTYDev(this, DeviceManager.DevFS, FSNode.NewAttributes("pty0"));
		_slave  = new TTYDev(this, DeviceManager.DevFS, FSNode.NewAttributes("tty0"));

        _window.Row = 25;
        _window.Col = 80;

        _termios.InputFlags   = InputModes.ICRNL  | InputModes.BRKINT;
        _termios.OutputFlags  = OutputModes.ONLCR | OutputModes.OPOST;
        _termios.LocalFlags   = LocalModes.ECHO   | LocalModes.ECHOE | LocalModes.ECHOK | LocalModes.ICANON
                              | LocalModes.ISIG   | LocalModes.IEXTEN;
        _termios.ControlFlags = ControlModes.CREAD;

        _termios.ControlChars[Commands.VEOF]   = 4;  /* ^D */
        _termios.ControlChars[Commands.VEOL]   = 0;  /* Not set */
        _termios.ControlChars[Commands.VERASE] = '\b';
        _termios.ControlChars[Commands.VINTR]  = 3;  /* ^C */
        _termios.ControlChars[Commands.VKILL]  = 21; /* ^U */
        _termios.ControlChars[Commands.VMIN]   = 1;
        _termios.ControlChars[Commands.VQUIT]  = 28; /* ^\ */
        _termios.ControlChars[Commands.VSTART] = 17; /* ^Q */
        _termios.ControlChars[Commands.VSTOP]  = 19; /* ^S */
        _termios.ControlChars[Commands.VSUSP]  = 26; /* ^Z */
        _termios.ControlChars[Commands.VTIME]  = 0;

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
		ResourceManager.AddCallTable(_rcs);

		return ModuleResult.Successful;
	}
	
	static ModuleResult Finalize() {
		ResourceManager.RemoveCallTable(_rcs);

		return ModuleResult.Successful;
	}

	void Input(char c) {
        if (_termios.LocalFlags & LocalModes.ICANON) {
            if (c == _termios.ControlChars[Commands.VKILL]) {
                while (_canonBufferLength > 0) {
                    _canonBuffer[_canonBufferLength--] = '\0';
                    if (_termios.LocalFlags & LocalModes.ECHO) {
                        Output('\010');
                        Output(' ');
                        Output('\010');
                    }
                }
                return;
            }

            if (c == _termios.ControlChars[Commands.VERASE]) {
                if (_canonBufferLength) {
                    _canonBuffer[_canonBufferLength--] = '\0';
                    if (_termios.LocalFlags & LocalModes.ECHO) {
                        Output('\010');
                        Output(' ');
                        Output('\010');
                    }
                }
                return;
            }

            if (c == _termios.ControlChars[Commands.VINTR]) {
                if (_termios.LocalFlags & LocalModes.ECHO) {
                    Output('^');
                    Output(cast(char)('@' + c));
                    Output('\n');
                }

                _canonBufferLength = 0;
                _canonBuffer[0]    = '\0';

                if (_fgThread !is null)
                    _fgThread.PostSignal(SignalType.SIGINT);

                return;
            }

            if (c == _termios.ControlChars[Commands.VQUIT]) {
                if (_termios.LocalFlags & LocalModes.ECHO) {
                    Output('^');
                    Output(cast(char)('@' + c));
                    Output('\n');
                }

                _canonBufferLength = 0;
                _canonBuffer[0]    = '\0';

                if (_fgThread !is null)
                    _fgThread.PostSignal(SignalType.SIGQUIT);

                return;
            }

            _canonBuffer[_canonBufferLength] = c;

            if (_termios.LocalFlags & LocalModes.ECHO)
                Output(c);

            if (_canonBuffer[_canonBufferLength] == '\n') {
                _canonBufferLength++;

                foreach (x; _canonBuffer[0 .. _canonBufferLength])
                    _in.Enqueue(x);

                _canonBufferLength = 0;
                return;
            }

            if (_canonBufferLength == 512) {
                foreach (x; _canonBuffer[0 .. _canonBufferLength])
                    _in.Enqueue(x);

                _canonBufferLength = 0;
                return;
            }

            _canonBufferLength++;
            return;
        } else if (_termios.LocalFlags & LocalModes.ECHO)
            Output(c);
        _in.Enqueue(c);
  	}

	void Output(char c) {
        if (c == '\n' && (_termios.OutputFlags & OutputModes.ONLCR))
            _out.Enqueue('\r');

        _out.Enqueue('\n');
	}

	static long StaticCallback(long param1, long param2, long param3, long param4, long param5) {
		switch (param1) {
			case 1:
				FSNode master, slave;
				new VTY(master, slave);

				param2 = master.Handle;
				param3 = slave.Handle;
				return 0;
		}

		return -1;
	}
}

class TTYDev : CharNode {
	private VTY _vty;

	this(VTY vty, DirectoryNode parent, FileAttributes attributes) {
		_vty = vty;

		super(parent, attributes);
		Identifier = "com.modules.Terminal.VTY.TTY";
		m_attributes.Length = _vty._in.Count;
	}

	ulong Read(long offset, byte[] data) {
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

class PTYDev : CharNode {
	private VTY _vty;
	private Mutex _mutex;

	this(VTY vty, DirectoryNode parent, FileAttributes attributes) {
		_vty   = vty;
		_mutex = new Mutex();

		super(parent, attributes);
		Identifier = "com.modules.Terminal.VTY.PTY";
		m_attributes.Length = _vty._out.Count;
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