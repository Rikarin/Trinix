/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Modules.Storage.ATA.ATAController;

static import Architecture;

import VFSManager;
import TaskManager;
import Modules.Storage.ATA.ATADrive;


class ATAController {
    private uint _base;
    private ubyte _number;
    private ATADrive[2] _drives;
    private Mutex _mutex;

    package enum Base {
        Bus1 = 0x1F0,
        Bus2 = 0x170
    }
    
    package enum Port : short {
        Data,
        FeaturesError,
        SectCount,
        Partial1,
        Partial2,
        Partial3,
        DriveSelect,
        Command
    }
    
    package enum Cmd {
        Identify = 0xEC,
        Read     = 0x20,
        Write    = 0x30
    }

    package void Lock() {
        _mutex.WaitOne();
    }

    package void Unlock() {
        _mutex.Release();
    }

    package T Read(T)(short port) {
        return cast(T)Architecture.Port.Read!T(cast(short)(_base + port));
    }

    package void Write(T)(short port, T value) {
        Architecture.Port.Write!T(cast(short)(_base + port), value);
    }

    private this(uint base, ubyte number) {
        _mutex  = new Mutex();
        _base   = base;
        _number = number;

        Identity(false);
        Identity(true);
    }

    ~this() {
        delete _drives[0];
        delete _drives[1];
        delete _mutex;
    }

    private void Identity(bool isSlave) {
        if (_drives[isSlave ? 1 : 0])
            return;

        Write!byte(Port.DriveSelect, cast(byte)(isSlave ? 0xB0 : 0xA0));
        Write!byte(Port.Command, cast(byte)Cmd.Identify);
        byte ret = Read!byte(Port.Command);

        if (!ret)
            return;

        while ((ret & 0x88) != 0x08 && (ret & 1) != 1)
            ret = Read!byte(Port.Command);

        if ((ret & 1) == 1)
            return;

        short[] data = new short[256];
        foreach (ref x; data)
            x = Read!short(Port.Data);

        uint blocks = (data[61] << 16) | data[60];
        if (blocks)
            _drives[isSlave ? 1 : 0] = new ATADrive(this, isSlave, blocks, data);
        else
            delete data;
    }

    static ATAController[2] Detect() {
        ATAController[2] c;
        c[0] = new ATAController(Base.Bus1, 0);
        c[1] = new ATAController(Base.Bus2, 1);

        foreach (x; c) {
            foreach (y; x._drives) {
                if (y !is null)
                    Partition.ReadTable(y);
            }
        }

        return c;
    }
}