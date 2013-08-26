module VFS.BlockCache;

import Devices.BlockDeviceProto;
import Architectures.Timing;

import System.Collections.Generic.All;


class BlockCache {
private:
	struct CachedBlock {
		ulong id = 0;
		Time LastUse = cast(Time)0;
		bool Dirty = false;
		byte[] Data;
	}

	BlockDeviceProto dev;
	List!(CachedBlock) cache;


	bool GetCache(ulong block, out byte[] data) {
		for (ulong i = 0; i < cache.Count; i++) {
			if (cache[i].id == block && cache[i].LastUse != cast(Time)0) {
				cache[i].LastUse = Timing.CurrentTime();
				data = cache[i].Data;
				return true;
			}
		}
		return false;
	}

	bool SetCache(ulong block, in byte[] data, bool dirty = false) {
		CachedBlock* best;

		foreach (x; cache) {
			if (x.id == block) {
				best = &x;
				break;
			}

			if (x.LastUse < best.LastUse)
				best = &x;
		}

		if (best.Dirty && (best.id != block || !dirty))
			dev.Write(best.id, best.Data);

		best.id = block;
		best.LastUse = Timing.CurrentTime();
		best.Dirty = dirty;
		best.Data = cast(byte[])data;
		return true;
	}


public:
	this(BlockDeviceProto dev) {
		this.dev = dev;
		cache = new List!(CachedBlock)();
	}

	~this() {
		Sync();
		//delete...
	}

	void Sync() {
		foreach (x; cache) {
			if (x.Dirty) {
				dev.Write(x.id, x.Data);
			}
		}
	}

	bool Read(ulong start, out byte[] data) {
		if (data.length <= dev.BlockSize()) {
			if (GetCache(start, data))
				return true;

			if (!dev.Read(start, data))
				return false;

			SetCache(start, data);
			return true;
		} else
			return dev.Read(start, data);
	}

	bool Write(ulong start, in byte[] data) {
		if (data.length <= dev.BlockSize()) {
			if (!SetCache(start, data, true))
				return dev.Write(start, data);
			return true;
		} else
			return dev.Write(start, data);
	}
}