/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.Storage.ATA.ATAController;

static import Architecture;

import VFSManager;
import TaskManager;
import Modules.Storage.ATA.ATADrive;


class ATAController {
    private uint m_base;
    private ubyte m_number;
    private ATADrive[2] m_drives;
    private Mutex m_mutex;

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
        m_mutex.WaitOne();
    }

    package void Unlock() {
        m_mutex.Release();
    }

    package T Read(T)(short port) {
        return cast(T)Architecture.Port.Read!T(cast(short)(m_base + port));
    }

    package void Write(T)(short port, T value) {
        Architecture.Port.Write!T(cast(short)(m_base + port), value);
    }

    private this(uint base, ubyte number) {
        m_mutex  = new Mutex();
        m_base   = base;
        m_number = number;

        Identity(false);
        Identity(true);
    }

    ~this() {
        delete m_drives[0];
        delete m_drives[1];
        delete m_mutex;
    }

    private void Identity(bool isSlave) {
        if (m_drives[isSlave ? 1 : 0])
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
            m_drives[isSlave ? 1 : 0] = new ATADrive(this, isSlave, blocks, data);
        else
            delete data;
    }

    static ATAController[2] Detect() {
        ATAController[2] c;
        c[0] = new ATAController(Base.Bus1, 0);
        c[1] = new ATAController(Base.Bus2, 1);

        foreach (x; c) {
            foreach (y; x.m_drives) {
                if (y !is null)
                    Partition.ReadTable(y);
            }
        }

        return c;
    }
}