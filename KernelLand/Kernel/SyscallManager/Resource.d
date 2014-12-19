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

module SyscallManager.Resource;

import Core;
import Library;
import TaskManager;
import ObjectManager;
import SyscallManager;


abstract class Resource {
	private Mutex _mutex;
	private LinkedList!(CallTable *) _callTables;
	private LinkedList!Process _processes;

	private long _id;
	private DeviceType _type;
	private long _version;
	private string _identifier;

	protected struct CallTable {
		long ID;
		string Identifier;
		long Params;

		union {
			long delegate() Callback0;
			long delegate(long) Callback1;
			long delegate(long, long) Callback2;
			long delegate(long, long, long) Callback3;
			long delegate(long, long, long, long) Callback4;
			long delegate(long, long, long, long, long) Callback5;
		}
	}

	@property long Handle() {
		return _id;
	}

	@property ref DeviceType Type() {
		return _type;
	}

	@property ref long Version() {
		return _version;
	}

	@property ref string Identifier() {
		return _identifier;
	}

	// Called from ResourceManager
	package long Call(long id, long param1, long param2, long param3, long param4, long param5) {
		switch (id) {
			case 0:
				return _type;

			case 1:
				(cast(char *)param1)[0 .. _identifier.length] = _identifier[0 .. $];
				return param1;

			case 2:
				return _version;

			case 3:
				long ret;
				foreach_reverse (x; _callTables) {
					if (ret == param2)
						return ret;

					(cast(char **)param1)[ret++][0 .. x.Value.Identifier.length] = x.Value.Identifier[0 .. $];
				}
				return ret;

			case 4:
				foreach_reverse (x; _callTables)
					if ((cast(char *)param1)[0 .. param2] == x.Value.Identifier)
						return x.Value.ID;
				return -1;

			default:
		}

		_mutex.WaitOne();
		scope(exit) _mutex.Release();
			
		if (!_processes.Contains(Task.CurrentProcess)) {
            Log("Process %d tried to use resource without attaching them first", Task.CurrentProcess.ID);
			return -1;
		}

		foreach_reverse (x; _callTables) {
			if (x.Value.ID == id) {
				switch (x.Value.Params) {
					case 0:
						return x.Value.Callback0();
					case 1:
						return x.Value.Callback1(param1);
					case 2:
						return x.Value.Callback2(param1, param2);
					case 3:
						return x.Value.Callback3(param1, param2, param3);
					case 4:
						return x.Value.Callback4(param1, param2, param3, param4);
					case 5:
						return x.Value.Callback5(param1, param2, param3, param4, param5);
					default:
						return -1;
				}
			}
		}

		return -1;
	}

	protected this(DeviceType type, string identifier, long ver, const CallTable[] callTables) {
		_callTables = new LinkedList!(CallTable *)();
		_processes  = new LinkedList!Process();
		_mutex      = new Mutex();
		_type       = type;
		_identifier = identifier;
		_version    = ver;
		_id         = ResourceManager.Register(this);

		AddCallTables(callTables);
	}

	protected this(const ModuleDef info, const CallTable[] callTables) {
		_callTables = new LinkedList!(CallTable *)();
		_processes  = new LinkedList!Process();
		_mutex      = new Mutex();
		_type       = info.Type;
		_identifier = info.Identifier;
		_version    = info.Version;
		_id         = ResourceManager.Register(this);
		
		AddCallTables(callTables);
	}

	protected ~this() {
		delete _mutex;
		delete _callTables;

		ResourceManager.Unregister(this);
	}

	void AttachProcess(Process process) {
		if (_processes.Contains(process) == -1)
			return;

		_processes.Add(process);
	}

	bool DetachProcess(Process process) {
		_processes.Remove(process);

		if (!_processes.Count)
			return true;

		return false;
	}

	protected void AddCallTables(const CallTable[] callTables) {
		foreach (x; callTables)
			if (!_callTables.Contains(cast(CallTable *)&x))
				_callTables.Add(cast(CallTable *)&x);
	}
}