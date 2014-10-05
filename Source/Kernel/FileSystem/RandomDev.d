module FileSystem.RandomDev;

import Core;
import VFSManager;


public final class RandomDev : CharNode {
	private __gshared ulong _number;

	public this(DirectoryNode parent, string name) {
		super(parent, NewAttributes(name));

		_attributes.Length = 1024;
	}
	
	public override ulong Read(long offset, byte[] data) {
		foreach (ref x; data) {
			_number = (Rand() - Rand2() + Rand3()) * DateTime.Now;
			x = cast(byte)(_number & 0xFF);
		}

		return data.length;
	}
	
	public override ulong Write(long offset, byte[] data) {
		return 0;
	}

	private ulong Rand() {
		return (_number * 125) % 2796203;
	}

	private ulong Rand2() {
		return (_number * 32719 + 3) % 32749;
	}

	private ulong Rand3() {
		return (((_number * 214013L + 2531011L) >> 16) & 32767);
	}
}