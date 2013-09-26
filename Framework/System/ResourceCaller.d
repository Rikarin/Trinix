module System.ResourceCaller;


class ResourceCaller {
	private ulong id, type;

	@property ulong ResID() { return id; }
	@property ulong ResType() { return type; }


	private ulong SysCall(ulong res, ulong id, ulong[] data) {
		ulong pointer = cast(ulong)data.ptr;
		ulong length = data.length;

		asm {
		/*	push RAX;
			push RBX;

			mov RAX, res;
			mov RBX, id;
			push length;
			push pointer;
		*/
			
			syscall;

			a:
			nop;
			jmp a;
			
			/*mov res, RAX;

			ccbbf58
			ccbbf18

			pop RBX;
			pop RBX;
			pop RBX;
			pop RAX;*/
		}

		return 0;
	}

	protected this(ulong id, ulong type) {
		this.id = id;
		this.type = 1;
		this.type = Call(0);

		if (this.type != type)
			this.type = 0;
	}

	ulong Call(ulong call, ulong[] data = null) {
		if (!type)
			return ~0UL;

		return SysCall(id, call, data);
	}
}