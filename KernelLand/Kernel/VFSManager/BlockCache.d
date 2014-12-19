/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 * 
 * TODO:
 *      o Debug and fix this class
 */

module VFSManager.BlockCache;

import Architecture;
import ObjectManager;


final class BlockCache {
	private IBlockDevice _device;
	private CachedBlock[] _cache;

	private struct CachedBlock {
		ulong ID;
		ulong LastUse;
		bool Dirty;
		byte[] Data;
	}

	@property IBlockDevice Device() {
		return _device;
	}

	this(IBlockDevice device, long size) {
		_device = device;
		/*_cache = new CachedBlock[size];

		foreach (x; _cache)
			x.Data = new byte[device.BlockSize];*/
	}

	~this() {
	/*	Synchronize();

		foreach (x; _cache)
			delete x.Data;

		delete _cache;*/
	}

	void Synchronize() {
		foreach (x; _cache) {
			if (x.Dirty) {
				if (_device.Write(x.ID, x.Data) == x.Data.length)
					x.Dirty = false;
			}
		}
	}

	ulong Read(long offset, byte[] data) {
		/*if (data.length <= _device.BlockSize) {
			long size = GetCache(offset, data);
			if (!size)
				return 0;

			size = _device.Read(offset, data);
			if (!size)
				return 0;

			SetCache(offset, data);
			return size;
		}*/
	
		return _device.Read(offset, data);
	}

	ulong Write(long offset, byte[] data) {
		/*if (data.length <= _device.BlockSize) {
			long size = SetCache(offset, data, true);

			if (!size)
				size = _device.Write(offset, data);

			return size;
		}*/

		return _device.Write(offset, data);
	}

    private ulong GetCache(long offset, byte[] data) {
        foreach (x; _cache) {
            if (x.ID == offset && x.LastUse) {
                x.LastUse = Time.Now;
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
        best.LastUse = Time.Now;
        best.Dirty = dirty;
        best.Data[] = data;
        
        return ret;
    }
}