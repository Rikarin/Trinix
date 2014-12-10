module SyscallManager.Resource;

import Core;
import Library;
import TaskManager;
import ObjectManager;
import SyscallManager;


public abstract class Resource {
	private Mutex _mutex;
	private LinkedList!(CallTable *) _callTables;
	private LinkedList!Process _processes;

	private DeviceType _type;
	private string _identifier;
	private long _version;
	private long _id;

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

	@property public long Handle() {
		return _id;
	}

	@property public DeviceType Type() {
		return _type;
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
			Log.WriteLine("Process ", Task.CurrentProcess.ID, " tried to use resource without attaching them first");
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

	protected ~this() {
		delete _mutex;
		delete _callTables;

		ResourceManager.Unregister(this);
	}

	public void AttachProcess(Process process) {
		if (_processes.Contains(process) == -1)
			return;

		_processes.Add(process);
	}

	public bool DetachProcess(Process process) {
		_processes.Remove(process);

		if (!_processes.Count)
			return true;

		return false;
	}

	protected void AddCallTables(const CallTable[] callTables) {
		foreach (x; callTables)
			_callTables.Add(cast(CallTable *)&x);
	}

	public static long StaticCallback(long param1, long param2, long param3, long param4, long param5) {
		return -1;
	}
}