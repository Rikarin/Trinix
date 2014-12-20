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
 * Matsumoto Satoshi <satoshi@gshost.eu>
 */
module Linker.BinaryLoader;

import Core;
import Linker;
import Library;
import VFSManager;


struct BinaryLoaderType {
    uint Magic;
    uint Mask;
    BinaryLoader function(FSNode node) Load;
}

struct BinarySection {
    ulong Offset;
    ulong VirtualAddress;
    ulong FileSize;
    ulong MemorySize;
    uint Flags;
}

class BinaryLoader {
    private __gshared LinkedList!BinaryLoader _binaries;
    private __gshared LinkedList!BinaryLoaderType _loaders;

    private FSNode _node;
    private long _referenceCount;

    protected ulong _base;
    protected ulong _entry;
    protected string _interpreter;
    protected BinarySection[] _sections;


 /*   @property ref long ReferenceCount() {
        return _referenceCount;
    }*/


    protected this() {
        _binaries.Add(this);
    }

    ~this() {
        _binaries.Remove(this);
    }

    bool Relocate() {
        Log("BinaryLoader: Relocation not supported!");
        return false;
    }

    static void Initialize() {
        _binaries = new LinkedList!BinaryLoader();
        _loaders  = new LinkedList!BinaryLoaderType();

        //TODO: move to elf initialization
        BinaryLoaderType elf = { 0x464C457F, 0xFFFFFFFF, &ElfLoader.Load };
        _loaders.Add(elf);
    }

    static void Finalize() {
        delete _binaries;
        delete _loaders;
    }

    static BinaryLoader LoadKernel(FSNode node) {
        BinaryLoader bin = FindLoadedBinary(node);

        if (bin !is null) /* Already loaded */
            return bin;

        bin = DoLoad(node);
        if (bin is null)
            return null;
            
        bin._referenceCount++; /* This will be never unloaded */
        //_base = MapIn  

        _binaries.Add(bin);
        return bin;
    }

    private static BinaryLoader FindLoadedBinary(FSNode node) {
        auto bin = Array.Find(_binaries, (LinkedListNode!BinaryLoader o) => o.Value._node is node);

        if (bin is null)
            return null;

        return bin.Value;
    }

    private static BinaryLoader DoLoad(FSNode node) {
        BinaryLoader ret;
        uint magic;
        node.Read(0, magic.ToArray());

        foreach (x; _loaders) {
            if (x.Value.Magic == (magic & x.Value.Mask)) {
                ret = x.Value.Load(node);
                break;
            }
        }

        if (ret is null) {
            Log("BinaryLoader: '%s' is an unknown file type", node.Location);
        }

        debug {
            Log("Interpreter: %s", ret._interpreter);
            Log("Base: %x, Entry: %x", ret._base, ret._entry);
            Log("NumSections: %d", ret._sections.length);
        }

        return ret;
    }
}