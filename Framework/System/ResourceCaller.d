module System.ResourceCaller;


class ResourceCaller {
	private ulong id, type;

	@property ulong ResID() { return id; }
	@property ulong ResType() { return type; }


	private static ulong SysCall(ulong res, ulong id, ulong[] data) {
		ulong pointer = cast(ulong)&data;

		asm {
			mov RAX, res;
			mov RBX, id;
			mov R10, pointer;
			
			syscall;
			mov pointer, RAX;
		}
		
		return pointer;
	}

	this(ulong id, ulong type) {
		this.id = id;
		this.type = SysCall(id, 0, null);

		if (this.type != type)
			this.type = 0;
	}

	ulong Call(ulong call, ulong[] data = null) {
		if (!type)
			return ~0UL;

		return SysCall(id, call, data);
	}

	static ulong StaticCall(ulong call, ulong[] data = null) {
		return SysCall(~1UL, call, data);
	}
}