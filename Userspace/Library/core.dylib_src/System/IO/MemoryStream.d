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
 * 
 * TODO:
 *      o Implement async operations
 */

module System.IO.MemoryStream;

import System;
import System.IO;


class MemoryStream : Stream {
    private byte[] m_buffer;
    private long m_position;
    private long m_length;

    private bool m_expandable;
    private bool m_writable;
    private bool m_exposable;

    this(long capacity = 0) in {
        if (capacity < 0)
            throw new ArgumentOutOfRangeException("capacity", Environment.GetResourceString("ArgumentOutOfRange_NegativeCapacity"));
    } body {
        m_buffer     = new byte[capacity];
        m_expandable = true;
        m_writable   = true;
        m_exposable  = true;
    }

    this(byte[] buffer, bool writable = true) in {
        if (buffer is null)
            throw new ArgumentNullException("buffer", Environment.GetResourceString("ArgumentNull_Buffer"));
    } body {
        m_buffer   = buffer;
        m_length   = m_buffer.length;
        m_writable = writable;
    }

    ~this() {
        if (m_exposable)
            delete m_buffer;
    }

    @property {
        override bool CanRead() pure  { return true; }
        override bool CanSeek() pure  { return true; }
        override bool CanWrite() pure { return true; }
        
        override long Length()        { return m_length;   }
        override long Position()      { return m_position; }

        override void Position(long value) in {
            if (value < 0)
                throw new ArgumentOutOfRangeException("value", Environment.GetResourceString("ArgumentOutOfRange_NeedNonNegNum"));
        } body {
            m_position = value;
        }

        override void Length(long value) in {
            if (value < 0)
                throw new ArgumentOutOfRangeException("value", Environment.GetResourceString("ArgumentOutOfRange_StreamLength"));

            if (!CanWrite)
                throw new NotSupportedException(Environment.GetResourceString("NotSupported_UnwritableStream"));
        } body {
            if (!EnsureCapacity(value) && value > m_length)
                m_buffer[m_length .. value - m_length] = 0;

            m_length = value;
            if (m_position > m_length)
                m_position = m_length;
        }

        long Capacity() {
            return m_buffer is null ? 0 : m_buffer.length;
        }

        void Capacity(long value) in {
            if (value < Length)
                throw new ArgumentOutOfRangeException("value", Environment.GetResourceString("ArgumentOutOfRange_SmallCapacity"));
        } body {
            if (value != Capacity) {
                if (!m_expandable)
                    throw new NotSupportedException(Environment.GetResourceString("NotSupported_MemStreamNotExpandable"));

                if (value > 0) {
                    byte[] newbuffer = new byte[value];
                    newbuffer[0 .. Length] = m_buffer[0 .. Length];

                    delete m_buffer;
                    m_buffer = newbuffer;
                } else {
                    delete m_buffer;
                    m_buffer = null;
                }
            }
        }
    }

    byte[] GetBuffer() {
        if (!m_exposable)
            throw new UnauthorizedAccessException(Environment.GetResourceString("UnauthorizedAccess_MemStreamBuffer"));

        return m_buffer;
    }

    //TODO: check if this can be out
    bool TryGetBuffer(out byte[] buffer) {
        if(!m_exposable)
            return false;

        buffer = m_buffer;
        return true;
    }

    byte[] ToArray() {
        byte[] ret = new byte[m_length];
        ret[]      = m_buffer[0 .. m_length];

        return ret;
    }

    override long Seek(long offset, SeekOrigin origin) {
        switch (origin) {
            case SeekOrigin.Begin:
                if (offset < 0)
                    throw new IOException(Environment.GetResourceString("IO.IO_SeekBeforeBegin"));

                m_position = offset;
                break;

            case SeekOrigin.Current:
                if (m_position + offset < 0)
                    throw new IOException(Environment.GetResourceString("IO.IO_SeekBeforeBegin"));

                m_position += offset;
                break;

            case SeekOrigin.End:
                if (m_length + offset < 0)
                    throw new IOException(Environment.GetResourceString("IO.IO_SeekBeforeBegin"));

                m_position = m_length + offset;
                break;

            default:
        }

        return m_position;
    }

    override void Flush() {

    }

    override long Read(byte[] buffer) in {
        if (buffer is null)
            throw new ArgumentNullException("buffer", Environment.GetResourceString("ArgumentNull_Buffer"));

        if (!buffer.length)
            throw new ArgumentOutOfRangeException("count", Environment.GetResourceString("ArgumentOutOfRange_NeedNonNegNum"));
    } body {
        long read = m_length - m_position;
        if (read > buffer.length)
            read = buffer.length;

        buffer[]    = m_buffer[m_position .. m_position + read];
        m_position += read;
        return read;
    }

    override void Write(byte[] buffer)  in {
        if (buffer is null)
            throw new ArgumentNullException("buffer", Environment.GetResourceString("ArgumentNull_Buffer"));
        
        if (!buffer.length)
            throw new ArgumentOutOfRangeException("count", Environment.GetResourceString("ArgumentOutOfRange_NeedNonNegNum"));
    } body {
        if (!CanWrite)
            throw new NotSupportedException(Environment.GetResourceString("NotSupported_UnwritableStream"));

        long write = m_position + buffer.length;
        if (write < 0)
            throw new IOException(Environment.GetResourceString("IO.IO_StreamTooLong"));

        if (write > Length) {
            bool mustZero = m_position > m_length;

            if (write > buffer.length) {
                if (EnsureCapacity(write))
                    mustZero = false;
            }

            if (mustZero)
                m_buffer[m_length .. write] = 0;

            m_length = write;
        }

        m_buffer[m_position .. m_position + buffer.length] = buffer;
        m_position += write;
    }

    private bool EnsureCapacity(long capacity) in {
        if (capacity < 0)
            throw new IOException(Environment.GetResourceString("IO.IO_StreamTooLong"));
    } body {
        if (capacity > m_buffer.length) {
            if (capacity < 256)
                capacity = 256;

            if (capacity < m_buffer.length * 2)
                capacity = m_buffer.length * 2;
                
            Capacity = capacity;
            return true;
        }

        return false;
    }
}