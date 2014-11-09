module Handle;


public final class Handle {
	private long _id;
	private long _type;
	
	private this(long id) {
		_id = id;
	}

	public this() {} //testing...
	
	@property public long Type() { //TODO: use enum against long
		if (!_type)
			_type = Call(0);

		new int[50];
		
		return _type;
	}
	
	public long Call(long id, long param1 = 0, long param2 = 0, long param3 = 0, long param4 = 0, long param5 = 0) {
		return _Call(_id, id, param1, param2, param3, param4, param5);
	}
	
	public static Handle StaticCall(long id, long param1 = 0, long param2 = 0, long param3 = 0, long param4 = 0, long param5 = 0) {
		long handle = _Call(0xFFFFFFFF_FFFFFFFF, id, param1, param2, param3, param4, param5);
		
		if (handle != -1 && handle)
			return new Handle(handle);
		
		return null;
	}
	
	private static ulong _Call(long resource, long id, long param1, long param2, long param3, long param4, long param5) {
		asm {
			"mov R9, %0" : : "r"(resource);
			"mov R8, %0" : : "r"(id);
			"syscall" : "=a"(resource) : "D"(param1), "S"(param2), "d"(param3), "b"(param4), "a"(param5) : "r8", "r9";
		}
		
		return resource;
	}
}