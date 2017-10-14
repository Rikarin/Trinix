/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module VFSManager.BlockCache;

import Architecture;
import ObjectManager;


final class BlockCache {
    private IBlockDevice m_device;
    private CachedBlock[] m_cache;

    private struct CachedBlock {
        ulong ID;
        ulong LastUse;
        bool Dirty;
        byte[] Data;
    }

    @property IBlockDevice Device() {
        return m_device;
    }

    this(IBlockDevice device, long size) {
        m_device = device;
        /*_cache = new CachedBlock[size];

        foreach (x; _cache)
            x.Data = new byte[device.BlockSize];*/
    }

    ~this() {
    /*  Synchronize();

        foreach (x; _cache)
            delete x.Data;

        delete _cache;*/
    }

    void Synchronize() {
        foreach (x; m_cache) {
            if (x.Dirty) {
                if (m_device.Write(x.ID, x.Data) == x.Data.length)
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
    
        return m_device.Read(offset, data);
    }

    ulong Write(long offset, byte[] data) {
        /*if (data.length <= _device.BlockSize) {
            long size = SetCache(offset, data, true);

            if (!size)
                size = _device.Write(offset, data);

            return size;
        }*/

        return m_device.Write(offset, data);
    }

    private ulong GetCache(long offset, byte[] data) {
        foreach (x; m_cache) {
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
        
        foreach (ref x; m_cache) {
            if (x.ID == offset) {
                best = &x;
                break;
            } else if (x.LastUse < best.LastUse)
                best = &x;
        }
        
        if (best.Dirty && (best.ID != offset || !dirty))
            ret = m_device.Write(best.ID, best.Data);
        
        best.ID = offset;
        best.LastUse = Time.Now;
        best.Dirty = dirty;
        best.Data[] = data;
        
        return ret;
    }
}