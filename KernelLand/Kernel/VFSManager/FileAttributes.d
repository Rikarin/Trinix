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