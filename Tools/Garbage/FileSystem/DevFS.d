/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module FileSystem.DevFS;

import VFSManager;


final class DevFS : IFileSystem {
    private DirectoryNode m_rootNode;

    @property Partition GetPartition()   { return null; }
    @property bool IsWritable()          { return true; }
    @property DirectoryNode RootNode()   { return m_rootNode; }

    private this()                       { }
    bool Unmount()                       { return true; }
    bool LoadContent(DirectoryNode node) { return true; }

    FSNode Create(DirectoryNode parent, FileAttributes attributes) {
        switch (attributes.Type) {
            case FileType.Directory:
                return new DirectoryNode(parent, attributes);

            default:
                return null;
        }
    }

    bool Remove(FSNode node) {
        switch (node.Attributes.Type) {
            case FileType.Directory:
                if (!(cast(DirectoryNode)node).Childrens.Count) {
                    delete node;
                    return true;
                }
                break;

            default:
                delete node;
                return true;
        }

        return false;
    }

    static DevFS Mount(DirectoryNode mountpoint) {
        if (mountpoint is null || !mountpoint.IsMountpointable)
            return null;

        DevFS ret = new DevFS();
        ret.m_rootNode = new DirectoryNode(null, FileAttributes("/"));
        ret.m_rootNode.FileSystem = ret;

        if (!mountpoint.Mount(ret.m_rootNode)) {
            delete ret;
            return null;
        }

        return ret;
    }

    bool AddDevice(FSNode dev) {
        return false;
    }
}