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

import Library;
import VFSManager;



class BinaryLoader {
    private __gshared LinkedList!BinaryLoader _binaries;

    private FSNode _node;


    private this() {
        _binaries.Add(this);
    }

    ~this() {
        _binaries.Remove(this);
    }

    static void Initialize() {
        _binaries = new LinkedList!BinaryLoader();
    }

    static void LoadKernel(FSNode node) {
        BinaryLoader bin = FindLoadedBinary(node);

        if (bin is null) {
            //TODO load
        }
    }

    private static BinaryLoader FindLoadedBinary(FSNode node) {
        auto bin = Array.Find(_binaries, (LinkedListNode!BinaryLoader o) => o.Value._node is node);

        if (bin is null)
            return null;

        return bin.Value;
    }
}