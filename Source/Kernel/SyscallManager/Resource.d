module SyscallManager.Resource;

import Core;
import Library;
import TaskManager;
import SyscallManager;


public abstract class Resource {
	private Mutex _mutex;
	private LinkedList!(CallTable *) _callTables;
	private LinkedList!Process _processes;

	private SyscallTypes _type;
	private long _id;

	protected struct CallTable {
		long ID;
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

	// Called from ResourceManager
	package long Call(long id, long param1, long param2, long param3, long param4, long param5) {
		if (!id)
			return _type;

		_mutex.WaitOne();
		scope(exit) _mutex.Release();

		if (id == 0xFFFFFFFF_FFFFFFFF)
			return StaticCallback(param1, param2, param3, param4, param5);
			
		if (!_processes.Contains(Task.CurrentProcess)) {
			Log.WriteLine("Process ", Task.CurrentProcess.ID, " tryied to use resource without attaching them first");
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

	protected this(SyscallTypes type, const CallTable[] callTables) {
		_callTables = new LinkedList!(CallTable *)();
		_processes  = new LinkedList!Process();
		_mutex      = new Mutex();
		_type       = type;
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

	protected static long StaticCallback(long param1, long param2, long param3, long param4, long param5) {
		return -1;
	}
}