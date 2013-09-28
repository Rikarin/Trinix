module System.ResourceCaller;


class ResourceCaller {
	private ulong id, type;

	@property ulong ResID() { return id; }
	@property ulong ResType() { return type; }


	private ulong SysCall(ulong res, ulong id, ulong[] data) {
		ulong pointer = cast(ulong)data.ptr;
		ulong length = data.length;

		asm {
			mov RAX, res;
			mov RBX, id;
			mov R10, length;
			mov R11, pointer;
			
			syscall;			
			mov res, RAX;
		}

		return res;
	}

	protected this(ulong id, ulong type) {
		this.id = id;
		this.type = 1;
		this.type = Call(0);

		if (this.type != type)
			this.type = 0;
	}

	ulong Call(ulong call, ulong[] data = null) {
		//if (!type)
		//	return ~0UL;

		return SysCall(id, call, data);
	}
}