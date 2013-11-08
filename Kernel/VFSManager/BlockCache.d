module VFSManager.BlockCache;

import Devices.BlockDeviceProto;
import System.DateTime;


class BlockCache {
private:
	struct CachedBlock {
		ulong ID;
		DateTime LastUse;
		bool Dirty;
		byte[] Data;
	}

	BlockDeviceProto dev;
	CachedBlock[] cache;


	bool GetCache(ulong offset, byte[] data) {
		foreach (x; cache) {
			if (x.ID == offset && x.LastUse !is null) {
				x.LastUse = DateTime.Now;
				data[] = x.Data[0 .. $];
				return true;
			}
		}

		return false;
	}

	bool SetCache(ulong offset, byte[] data, bool dirty = false) {
		CachedBlock* best;

		foreach (ref x; cache) {
			if (x.ID == offset) {
				best = &x;
				break;
			}

			if (x.LastUse.Ticks < best.LastUse.Ticks)
				best = &x;
		}

		if (best.Dirty && (best.ID != offset || !dirty))
			dev.Write(best.ID, best.Data);

		best.ID      = offset;
		best.LastUse = DateTime.Now;
		best.Dirty   = dirty;
		best.Data    = data;
		return true;
	}


public:
	this(BlockDeviceProto dev, ulong size) {
		this.dev = dev;
		cache = new CachedBlock[size];
	}

	~this() {
		Sync();
		delete cache;
	}

	void Sync() {
		foreach (x; cache)
			if (x.Dirty)
				dev.Write(x.ID, x.Data);
	}

	ulong Read(ulong offset, byte[] data) {
		if (data.length <= dev.BlockSize()) {
			if (GetCache(offset, data))
				return 0;

			if (!dev.Read(offset, data))
				return 0;

			SetCache(offset, data);
			return data.length;
		} else
			return dev.Read(offset, data);
	}

	ulong Write(ulong offset, byte[] data) {
		if (data.length <= dev.BlockSize()) {
			if (!SetCache(offset, data, true))
				return dev.Write(offset, data);

			return data.length;
		} else
			return dev.Write(offset, data);
	}
}