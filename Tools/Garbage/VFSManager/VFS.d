﻿/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module VFSManager.VFS;

import Core;
import Library;
import FileSystem;
import VFSManager;
import TaskManager;
import ObjectManager;
import MemoryManager;

import System.Runtime;
    

struct FSDriver {
    string Name;
    bool function(Partition partition) Detect;
    IFileSystem function(DirectoryNode mountpoint, Partition partition) Mount;
    void function(Partition partition) Create;
}

abstract final class VFS {
    private enum IDENTIFIER = "com.trinix.VFSManager";

    __gshared DirectoryNode Root;
    private __gshared LinkedList!FSDriver m_drivers;


    static void Initialize() {
        m_drivers = new LinkedList!FSDriver();

        Root = new DirectoryNode(null, FileAttributes("/"));
        DirectoryNode system = new DirectoryNode(Root, FileAttributes("System"));

        DeviceManager.DevFS = new DirectoryNode(system, FileAttributes("Devices"));
        DevFS.Mount(DeviceManager.DevFS);
        TmpFS.Mount(new DirectoryNode(system, FileAttributes("Temp")));

        new NullDev(DeviceManager.DevFS, "null");
        new ZeroDev(DeviceManager.DevFS, "zero");
        new RandomDev(DeviceManager.DevFS, "random");

        ResourceManager.AddCallTable(IDENTIFIER, &StaticCallback);
    }

    static void Finalize() {
        foreach (x; m_drivers)
            delete x;

        delete m_drivers;
    }

    static T Find(T)(string path, DirectoryNode start = null) {
        FSNode node = start is null ? Root : start;
        scope List!string list = path.Split('/');

        if (list[0] is null)
            node = Root;

        foreach (x; list) {
            if (x == "..")
                node = node.Parent;
            else if (x !is null && x != "." && x != "") {
                if (node.Attributes.Type & (FileType.Directory | FileType.Mountpoint))
                    node = (cast(DirectoryNode)node)[x];
                else
                    return null;
            }
        }

        return cast(T)node;
    }

    debug static void PrintTree(DirectoryNode path, long p = 1) {
        foreach (x; path.Childrens) {
            foreach (i; 0 .. p)
                Logger.Write(" ");
            
            Logger.Write("- %s ", x.Value.Attributes.Name);
            switch (x.Value.Attributes.Type) {
                case FileType.Directory:
                    Logger.Write("(D)");
                    break;
                case FileType.Mountpoint:
                    Logger.Write("(M)");
                    break;
                case FileType.Pipe:
                    Logger.Write("(P)");
                    break;
                case FileType.CharDevice:
                    Logger.Write("(C)");
                    break;
                case FileType.BlockDevice:
                    Logger.Write("(B)");
                    break;
                case FileType.File:
                    Logger.Write("(F)");
                    break;
                case FileType.SymLink:
                    Logger.Write("(S)");
                    break;
                default:
                    Logger.Write("(ERROR)");
            }
            Logger.Write("\n");
            
            if (x.Value.Attributes.Type & (FileType.Directory | FileType.Mountpoint))
                PrintTree(cast(DirectoryNode)x.Value, p + 1);
        }
    }

    static void AddDriver(FSDriver driver) {
        if (m_drivers.Contains(driver))
            return;

        Log("Adding driver %s", driver.Name);
        m_drivers.Add(driver);
    }

    static void RemoveDriver(string name) {
        m_drivers.Remove(Array.Find(m_drivers, (LinkedListNode!FSDriver o) => o.Value.Name == name));
    }

    static FSDriver GetFSDriver(string name) {
        auto drv = Array.Find(m_drivers, (LinkedListNode!FSDriver o) => o.Value.Name == name);
        return drv !is null ? drv.Value : cast(FSDriver)null;
    }

    static IFileSystem Mount(lazy DirectoryNode mountpoint, Partition partition, string fsName) {
        FSDriver drv = GetFSDriver(fsName);
        if (drv == cast(FSDriver)null)
            return null;

        if (!drv.Detect(partition))
            return null;

        return drv.Mount(mountpoint, partition);
    }

    /* TODO: implement flags... */
    static void MapIn(FSNode node, v_addr start, size_t length, ulong offset) {
        for (v_addr i = start; i < start + length; i += Paging.PAGE_SIZE)
            VirtualMemory.KernelPaging.AllocFrame(i, AccessMode.DefaultKernel);

        node.Read(offset, (cast(byte *)start)[0 .. length]);
    }


    /**
    * Callback used by userspace apps for obtaining instance of speciffic
    * classes by calling this static syscall
    * 
    * Params:
    *      param1  =       TODO
    *      param2  =       TODO
    *      param3  =       TODO
    *      param4  =       TODO
    *      param5  =       TODO
    * 
    * Returns:
    *      SyscallReturn.Error     on failure
    */
    static long StaticCallback(long param1, long param2, long param3, long param4, long param5) {
        switch (param1) {
            case FileHandle.StaticCommands.Create:
                if (!Resource.IsValidAddress(param2))
                    return SyscallReturn.Error;

                auto name    = (cast(char *)param2).ToString();
                auto attribs = FileAttributes(name, cast(FileType)param3);
                auto node    = Process.Current.WorkingDirectory.Create(attribs);

                if (node is null)
                    return SyscallReturn.Error;

                if (cast(DirectoryNode)node !is null)
                    return SyscallReturn.Successful;

                Process.Current.AttachResource(node);
                return node.Handle;

            case FileHandle.StaticCommands.Open:
                if (!Resource.IsValidAddress(param2))
                    return SyscallReturn.Error;

                auto name  = (cast(char *)param2).ToString();
                auto found = VFS.Find!FSNode(name, Process.Current.WorkingDirectory);

                if (found is null || cast(DirectoryNode)found !is null)
                    return SyscallReturn.Error;

                Process.Current.AttachResource(found);
                return found.Handle;

            default:
        }

        return SyscallReturn.Error;
    }
}