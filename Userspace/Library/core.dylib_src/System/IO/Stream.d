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
 *      o Make async calls in Stream, NullStream, SyncStream
 */

module System.IO.Stream;

import System;
import System.IO;
import System.Threading;


abstract class Stream {
    static immutable Stream Null = new NullStream();

    private enum DefaultCopyBufferSize = 81920;

    @property {
        bool CanRead() pure;
        bool CanSeek() pure;
        bool CanWrite() pure;
        bool CanTimeout() pure { return false; }

        long Length();
        void Length(long value);
        long Position();
        void Position(long value);

        long ReadTimeout()            { throw new InvalidOperationException(Environment.GetResourceString("InvalidOperation_TimeoutsNotSupported")); }
        void ReadTimeout(long value)  { throw new InvalidOperationException(Environment.GetResourceString("InvalidOperation_TimeoutsNotSupported")); }
        long WriteTimeout()           { throw new InvalidOperationException(Environment.GetResourceString("InvalidOperation_TimeoutsNotSupported")); }
        void WriteTimeout(long value) { throw new InvalidOperationException(Environment.GetResourceString("InvalidOperation_TimeoutsNotSupported")); }
    }

    void CopyTo(Stream destination, int bufferSize = DefaultCopyBufferSize) {
        byte[] buffer = new byte[bufferSize];
        scope(exit) delete buffer;

        long read;
        while ((read = Read(buffer)) != 0)
               destination.Write(buffer[0 .. read]);
    }

    long Seek(long offset, SeekOrigin origin);
    void Flush();
    long Read(byte[] buffer);
    void Write(byte[] buffer);

    long ReadByte() {
        byte[1] array;
        
        if (!Read(array))
            return -1;

        return array[0];
    }

    void WriteByte(byte value) {
        byte[1] array;
        array[0] = value;

        Write(array);
    }


    Task!Object CopyToAsync(Stream destination, int bufferSize = DefaultCopyBufferSize, CancellationToken ct = CancellationToken.None) {
        return null;
    }

    IAsyncResult BeginRead(byte[] buffer, AsyncCallback callback, Object state) {
        return null;
    }

    IAsyncResult BeginWrite(byte[] buffer, AsyncCallback callback, Object state) {
        return null;
    }

    int EndRead(IAsyncResult asyncResult) {
        return 0;
    }

    int EndWrite(IAsyncResult asyncResult) {
        return 0;
    }

    Task!Object FlushAsync(CancellationToken ct = CancellationToken.None) {
        return null;
    }

    Task!long ReadAsync(byte[] buffer, CancellationToken ct = CancellationToken.None) {
        return null;
    }

    Task!long WriteAsync(byte[] buffer, CancellationToken ct = CancellationToken.None) {
        return null;
    }


    static Stream Synchronized(Stream stream) in {
        if (stream is null)
            throw new ArgumentNullException("stream");
    } body {
        if (cast(SyncStream)stream !is null)
            return stream;

        return new SyncStream(stream);
    }
}


class NullStream : Stream {
    @property {
        override bool CanRead() pure       { return true; }
        override bool CanSeek() pure       { return true; }
        override bool CanWrite() pure      { return true; }

        override long Length()             { return 0;    }
        override long Position()           { return 0;    }
        override void Length(long value)   { }
        override void Position(long value) { }
    }

    override long ReadByte() {
        return -1;
    }

    override void WriteByte(byte value) {
        
    }

    override long Seek(long offset, SeekOrigin origin) {
        return 0;
    }

    override void Flush() {
    
    }

    override long Read(byte[] buffer) {
        return 0;
    }

    override void Write(byte[] buffer) {

    }
}


class SyncStream : Stream {
    private Mutex m_lock;
    private Stream m_stream;

    this(Stream stream) {
        m_lock   = new Mutex();
        m_stream = stream;
    }

    ~this() {
        m_lock.WaitOne();

        delete m_stream;
        delete m_lock;
    }

    @property {
        override bool CanRead() pure    { return m_stream.CanRead();  }
        override bool CanSeek() pure    { return m_stream.CanSeek;    }
        override bool CanWrite() pure   { return m_stream.CanWrite;   }
        override bool CanTimeout() pure { return m_stream.CanTimeout; }
        
        override long Length() {
            m_lock.WaitOne();
            scope(exit) m_lock.Release();

            return m_stream.Length;
        }

        override void Length(long value) {
            m_lock.WaitOne();
            m_stream.Length = value;
            m_lock.Release();
        }

        override long Position() {
            m_lock.WaitOne();
            scope(exit) m_lock.Release();
            
            return m_stream.Position;
        }

        override void Position(long value) {
            m_lock.WaitOne();
            m_stream.Position = value;
            m_lock.Release();
        }
        
        override long ReadTimeout() {
            m_lock.WaitOne();
            scope(exit) m_lock.Release();
            
            return m_stream.ReadTimeout;
        }

        override void ReadTimeout(long value) {
            m_lock.WaitOne();
            m_stream.ReadTimeout = value;
            m_lock.Release();
        }

        override long WriteTimeout() {
            m_lock.WaitOne();
            scope(exit) m_lock.Release();
            
            return m_stream.WriteTimeout;
        }

        override void WriteTimeout(long value) {
            m_lock.WaitOne();
            m_stream.WriteTimeout = value;
            m_lock.Release();
        }
    }

    override long Seek(long offset, SeekOrigin origin) {
        m_lock.WaitOne();
        scope(exit) m_lock.Release();

        return m_stream.Seek(offset, origin);
    }

    override void Flush() {
        m_lock.WaitOne();
        scope(exit) m_lock.Release();

        m_stream.Flush();
    }

    override long Read(byte[] buffer) {
        m_lock.WaitOne();
        scope(exit) m_lock.Release();

        return m_stream.Read(buffer);
    }

    override void Write(byte[] buffer) {
        m_lock.WaitOne();
        scope(exit) m_lock.Release();

        m_stream.Write(buffer);
    }
    
    override long ReadByte() {
        m_lock.WaitOne();
        scope(exit) m_lock.Release();

        return m_stream.ReadByte();
    }
    
    override void WriteByte(byte value) {
        m_lock.WaitOne();
        scope(exit) m_lock.Release();

        m_stream.WriteByte(value);
    }
}


/*
    @property {
        override bool CanRead() pure  { return true; }
        override bool CanSeek() pure  { return true; }
        override bool CanWrite() pure { return true; }
        
        override long Length();
        override void Length(long value);
        override long Position();
        override void Position(long value);
    }

    override long Seek(long offset, SeekOrigin origin);
    override void Flush();
    override long Read(byte[] buffer);
    override void Write(byte[] buffer);
    */