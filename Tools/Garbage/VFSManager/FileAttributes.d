/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module VFSManager.FileAttributes;

import TaskManager;
import Architecture;


/**
 * Type of node
 * Used in FileAttributes
 * 
 */
enum FileType {
    File        = 0x01,
    Directory   = 0x02,
    CharDevice  = 0x04,
    BlockDevice = 0x08,
    Pipe        = 0x10,
    SymLink     = 0x20,
    Mountpoint  = 0x40,
    Socket      = 0x80
}


/**
 * Permissions of node.
 * Used in FileAttributes.
 * 
 */
enum FilePermissions {
    OtherExecute = 1,
    OtherWrite   = 2,
    OtherRead    = 4,
    GroupExecute = 8,
    GroupWrite   = 16,
    GroupRead    = 32,
    UserExecute  = 64,
    UserWrite    = 128,
    UserRead     = 256
}


/**
 * Attributes of each node in filesystem.
 * 
 */
struct FileAttributes {
    string Name;
    FileType Type;
    ulong Length;
    ulong UID;
    ulong GID;
    FilePermissions Permissions;
    ulong AccessTime;
    ulong CreateTime;
    ulong ModifyTime;

    static FileAttributes opCall(string name, FileType type = FileType.Directory) {
        FileAttributes ret;

        ret.Name        = name;
        ret.Type        = type;
        ret.Permissions = FilePermissions.UserRead  | FilePermissions.UserWrite 
                        | FilePermissions.GroupRead | FilePermissions.OtherRead;
        ret.UID         = Process.Current.UID;
        ret.GID         = Process.Current.GID;
        ret.AccessTime  = Time.Now;
        ret.ModifyTime  = ret.AccessTime;
        ret.CreateTime  = ret.AccessTime;
        
        return ret;
    }
}