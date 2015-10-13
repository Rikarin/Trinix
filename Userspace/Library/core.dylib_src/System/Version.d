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

module System.Version;

import System;


class Version : IComparable!Version, IEquatable!Version {
    private int m_major;
    private int m_minor;
    private int m_build    = -1;
    private int m_revision = -1;

    this(int major = 0, int minor = 0) in {
        if (major < 0)
            throw new ArgumentOutOfRangeException("major",Environment.GetResourceString("ArgumentOutOfRange_Version"));
        
        if (minor < 0)
            throw new ArgumentOutOfRangeException("minor",Environment.GetResourceString("ArgumentOutOfRange_Version"));
    } body {
        m_major    = major;
        m_minor    = minor;
    }

    this(int major = 0, int minor = 0, int build) in {
        if (major < 0)
            throw new ArgumentOutOfRangeException("major",Environment.GetResourceString("ArgumentOutOfRange_Version"));
        
        if (minor < 0)
            throw new ArgumentOutOfRangeException("minor",Environment.GetResourceString("ArgumentOutOfRange_Version"));
        
        if (build < 0)
            throw new ArgumentOutOfRangeException("build",Environment.GetResourceString("ArgumentOutOfRange_Version"));
    } body {
        m_major    = major;
        m_minor    = minor;
        m_build    = build;
    }

    this(int major = 0, int minor = 0, int build, int revision) in {
        if (major < 0)
            throw new ArgumentOutOfRangeException("major",Environment.GetResourceString("ArgumentOutOfRange_Version"));

        if (minor < 0)
            throw new ArgumentOutOfRangeException("minor",Environment.GetResourceString("ArgumentOutOfRange_Version"));

        if (build < 0)
            throw new ArgumentOutOfRangeException("build",Environment.GetResourceString("ArgumentOutOfRange_Version"));

        if (revision < 0)
            throw new ArgumentOutOfRangeException("revision",Environment.GetResourceString("ArgumentOutOfRange_Version"));
    } body {
        m_major    = major;
        m_minor    = minor;
        m_build    = build;
        m_revision = revision;
    }

    @property {
        int Major()           pure { return m_major;             }
        int Minor()           pure { return m_minor;             }
        int Build()           pure { return m_build;             }
        int Revision()        pure { return m_revision;          }
        short MajorRevision() pure { return m_revision >> 16;    }
        short MinorRevision() pure { return m_revision & 0xFFFF; }
    }

    bool opEquals(Version other) {
        return m_major == other.m_major && m_minor == other.m_minor && m_build == other.m_build && m_revision == other.m_revision;
    }

    int opCmp(Version other) {
        return (m_major - other.m_major) + (m_minor - other.m_minor) + (m_build - other.m_build) + (m_revision - other.m_revision);
    }

    string ToString() {
        return null; //TODO: String.Format()...
    }

    static Version Parse(string input) {
        auto ret = new Version();
        //TODO: String.TryParse(ver, "{0}.{1}.{2}.{3}", ret.m_major, ret.m_minor, ret.m_build, ret.m_revision);
        return ret;
    }

    static bool TryParse(string input, out Version ver) {
        ver = null;
        return false; //TODO
    }
}