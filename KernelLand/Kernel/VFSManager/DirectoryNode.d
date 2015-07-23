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

module VFSManager.DirectoryNode;

import Library;
import VFSManager;


class DirectoryNode : FSNode {
    package IFileSystem m_fileSystem;
    private LinkedList!FSNode m_childrens;
    private DirectoryNode m_mounted;
    private bool m_isLoaded;

    @property ref bool IsLoaded() {
        if (m_mounted)
            return m_mounted.IsLoaded;

        return m_isLoaded;
    }

    @property ref IFileSystem FileSystem() {
        if (m_mounted)
            return m_mounted.FileSystem;

        return m_fileSystem;
    }

    @property override FileAttributes Attributes() {
        if (m_attributes.Name == "/" && m_parent)
            return m_parent.Attributes;

        return m_attributes;
    }

    @property override void Attributes(FileAttributes value) {
        if (m_attributes.Name == "/" && m_parent)
            return m_parent.Attributes = value;
        else
            m_attributes = value;
    }

    @property override DirectoryNode Parent() {
        if (m_attributes.Name == "/" && m_parent)
            return m_parent.Parent;
        
        return m_parent;
    }

    @property LinkedList!FSNode Childrens() {
        if (m_mounted)
            return m_mounted.Childrens;

        LoadContent();
        return m_childrens;
    }

    @property bool IsMountpointable() {
        if (!LoadContent())
            return false;

        return !m_childrens.Count;
    }

    this(DirectoryNode parent, FileAttributes fileAttributes) {
        m_childrens  = new LinkedList!FSNode();
        m_attributes = fileAttributes;
        m_attributes.Type = FileType.Directory;

        if (parent)
            m_fileSystem = parent.m_fileSystem;

        super(parent);
        Identifier = "com.trinix.VFSManager.DirectoryNode";
    }

    ~this() {
        if (m_attributes.Name == "/" && m_parent)
            (cast(DirectoryNode)m_parent).Unmount();

        foreach (x; m_childrens)
            delete x;

        delete m_childrens;
    }

    void Unmount() {
        m_attributes.Type = FileType.Directory;
        m_mounted.m_parent = null;

        delete m_mounted;
        m_mounted = null;
    }

    bool Mount(DirectoryNode childRoot) {
        if (IsMountpointable && childRoot.m_parent is null) {
            m_mounted = childRoot;
            m_attributes.Type = FileType.Mountpoint;
            childRoot.m_parent = this;

            return true;
        }

        return false;
    }

    FSNode opIndex(string name) {
        if (m_mounted)
            return m_mounted[name];

        if (!LoadContent())
            return null;

        foreach (x; m_childrens)
            if (x.Value.Attributes.Name == name)
                return x.Value;

        return null;
    }

    FSNode Create(FileAttributes attributes) {
        if (m_mounted)
            return m_mounted.Create(attributes);

        if (m_fileSystem is null)
            return null;
            
        return m_fileSystem.Create(this, attributes);
    }

    private bool LoadContent() {
        if (m_mounted)
            return m_mounted.LoadContent();

        if (IsLoaded || m_fileSystem is null)
            return true;

        m_isLoaded = m_fileSystem.LoadContent(this);
        return m_isLoaded;
    }
}