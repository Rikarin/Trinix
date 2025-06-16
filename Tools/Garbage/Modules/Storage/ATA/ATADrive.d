﻿/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.Storage.ATA.ATADrive;

import VFSManager;
import ObjectManager;
import Modules.Storage.ATA.ATAController;


class ATADrive : IBlockDevice {
    private ATAController m_controller;
    private bool m_isSlave;
    private uint m_blockCount;
    private short[] m_data;

    @property long Blocks() {
        return m_blockCount;
    }

    @property int BlockSize() {
        return 512;
    }

    package this(ATAController controlller, bool isSlave, uint blockCount, short[] data) {
        m_controller = controlller;
        m_isSlave    = isSlave;
        m_blockCount = blockCount;
        m_data       = data;
    }

    ~this() {
        foreach (x; DeviceManager.DevFS.Childrens) {
            Partition part = cast(Partition)x.Value;
            if (part !is null && part.Device == this)
                delete x.Value;
        }

        delete m_data;
    }

    ulong Read(long offset, byte[] data) {
        ulong blockCount = data.length / BlockSize + ((data.length % BlockSize) != 0 ? 1 : 0);

        if (offset + blockCount >= Blocks)
            return 0;
        
        m_controller.Lock();
        scope(exit) m_controller.Unlock();

        CmdCommon(offset, cast(byte)blockCount);
        m_controller.Write!byte(ATAController.Port.Command, ATAController.Cmd.Read);
        while (!(m_controller.Read!byte(ATAController.Port.Command) & 0x08)) { }
        
        long i;
        while (i < data.length) {
            short tmp = m_controller.Read!short(ATAController.Port.Data);
            data[i++] = cast(byte)(tmp & 0xFF);
            data[i++] = tmp >> 8;
        }

        //TODO: this is not needed for now
        //for (; i < blockCount; i += 2)
            //m_controller.Read!short(ATAController.Port.Data);

        return i;
    }

    ulong Write(long offset, byte[] data) {
        ulong blockCount = data.length / BlockSize + ((data.length % BlockSize) != 0);

        if (offset + blockCount > Blocks)
            return 0;
        
        m_controller.Lock();
        scope(exit) m_controller.Unlock();

        CmdCommon(offset, cast(byte)blockCount);
        m_controller.Write!byte(ATAController.Port.Command, ATAController.Cmd.Write);
        while (!(m_controller.Read!byte(ATAController.Port.Command) & 0x08)) { }
        
        for (long i; i < data.length;)
            m_controller.Write!short(ATAController.Port.Data, cast(byte)(data[i++] | (data[i++] << 8)));

        return data.length;
    }

    private void CmdCommon(ulong offset, byte count) {
        m_controller.Write!byte(ATAController.Port.FeaturesError, 0);
        m_controller.Write!byte(ATAController.Port.SectCount, count);
        
        m_controller.Write!byte(ATAController.Port.Partial1, cast(byte)(offset & 0xFF));
        m_controller.Write!byte(ATAController.Port.Partial2, cast(byte)((offset >> 8) & 0xFF));
        m_controller.Write!byte(ATAController.Port.Partial3, cast(byte)((offset >> 16) & 0xFF));
        
        m_controller.Write!byte(ATAController.Port.DriveSelect, cast(byte)(0xE0 | (m_isSlave ? 0x10 : 0) | ((offset >> 24) & 0x0F)));
    }
}