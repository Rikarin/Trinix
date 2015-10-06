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

module System.IO.Stream;

import System;
import System.IO;


abstract class Stream {
    static immutable Stream Null = new NullStream();

    private enum DEFAULT_COPY_BUFFER_SIZE = 81920;

    @property {
        bool CanRead();
        bool CanSeek();
        bool CanWrite();
        bool CanTimeout() { return false; }

        long Length();
        void Length(long value);
        long Position();
        void Position(long value);

        long ReadTimeout()            { return 0; /* TODO: throw */ }
        void ReadTimeout(long value)  {           /* TODO: throw */ }
        long WriteTimeout()           { return 0; /* TODO: throw */ }
        void WriteTimeout(long value) {           /* TODO: throw */ }
    }

    void CopyTo(Stream destination, int bufferSize = DEFAULT_COPY_BUFFER_SIZE) {
        byte[] buffer = new byte[bufferSize];
        scope(exit) delete buffer;

        int read;
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


    Task CopyToAsync(Stream destination, int bufferSize = DEFAULT_COPY_BUFFER_SIZE, CancellationToken ct = CancellationToken.None) {
        return null; //TODO: call copy to async internal
    }

    IAsyncResut BeginRead(byte[] buffer, AsyncCallback callback, Object state) { return null; } //TODO
    IAsyncResut BeginWrite(byte[] buffer, AsyncCallback callback, Object state) { return null; } //TODO
    int EndRead(IAsyncResult asyncResult) { return 0; } //TODO
    int EndWrite(IAsyncResult asyncResult) { return 0; } //TODO

    Task FlushAsync(CancellationToken ct = CancellationToken.None) { return null; } //TODO
    Task!long ReadAsync(byte[] buffer, CancellationToken ct = CancellationToken.None)  {} //TODO
    Task!long WriteAsync(byte[] buffer, CancellationToken ct = CancellationToken.None) {} //TODO


    static Stream Synchronized(Stream stream) {
        if (stream is null)
        {} //TODO: throw

        if (cast(SyncStream)stream !is null)
            return stream;

        return new SyncStream(stream);
    }
}


class NullStream : Stream {
    @property {
        bool CanRead()            { return true; }
        bool CanSeek()            { return true; }
        bool CanWrite()           { return true; }

        long Length()             { return 0;    }
        long Position()           { return 0;    }
        void Length(long value)   { }
        void Position(long value) { }

        long ReadTimeout()            { return 0; /* TODO: throw */ }
        void ReadTimeout(long value)  {           /* TODO: throw */ }
        long WriteTimeout()           { return 0; /* TODO: throw */ }
        void WriteTimeout(long value) {           /* TODO: throw */ }
    }

    override long ReadByte() {
        return -1;
    }

    override void WriteByte(byte value) {
        
    }

    long Seek(long offset, SeekOrigin origin) {
        return 0;
    }

    void Flush() {
    
    }

    long Read(byte[] buffer) {
        return 0;
    }

    void Write(byte[] buffer) {

    }
}


class SyncStream : Stream {
    this(Stream stream) {

    }
}