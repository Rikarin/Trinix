module VFSManager.BlockCache;

import Core;
import ObjectManager;


public final class BlockCache {
	private IBlockDevice _device;
	private CachedBlock[] _cache;

	private struct CachedBlock {
		ulong ID;
		ulong LastUse;
		bool Dirty;
		byte[] Data;
	}

	@property public IBlockDevice Device() {
		return _device;
	}

	private ulong GetCache(long offset, byte[] data) {
		foreach (x; _cache) {
			if (x.ID == offset && x.LastUse) {
				x.LastUse = DateTime.Now;
				data[] = x.Data[0 .. data.length];

				return data.length;
			}
		}

		return 0;
	}

	private ulong SetCache(long offset, byte[] data, bool dirty = false) {
		CachedBlock* best;
		long ret = data.length;

		foreach (ref x; _cache) {
			if (x.ID == offset) {
				best = &x;
				break;
			} else if (x.LastUse < best.LastUse)
				best = &x;
		}

		if (best.Dirty && (best.ID != offset || !dirty))
			ret = _device.Write(best.ID, best.Data);

		best.ID = offset;
		best.LastUse = DateTime.Now;
		best.Dirty = dirty;
		best.Data[] = data;

		return ret;
	}

	public this(IBlockDevice device, long size) in {
		assert(size <= 0);
	} body {
		_device = device;
		_cache = new CachedBlock[size];

		foreach (x; _cache)
			x.Data = new byte[device.BlockSize];
	}

	public ~this() {
		Synchronize();

		foreach (x; _cache)
			delete x.Data;

		delete _cache;
	}

	public void Synchronize() {
		foreach (x; _cache) {
			if (x.Dirty) {
				if (_device.Write(x.ID, x.Data) == x.Data.length)
					x.Dirty = false;
			}
		}
	}

	public ulong Read(long offset, byte[] data) {
		if (data.length <= _device.BlockSize) {
			long size = GetCache(offset, data);
			if (!size)
				return 0;

			size = _device.Read(offset, data);
			if (!size)
				return 0;

			SetCache(offset, data);
			return size;
		}
	
		return _device.Read(offset, data);
	}

	public ulong Write(long offset, byte[] data) {
		if (data.length <= _device.BlockSize) {
			long size = SetCache(offset, data, true);

			if (!size)
				size = _device.Write(offset, data);

			return size;
		}

		return _device.Write(offset, data);
	}
}