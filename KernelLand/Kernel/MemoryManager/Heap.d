/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module MemoryManager.Heap;

import Core;
import Library;
import MemoryManager;


final class Heap {
	enum MAGIC    = 0xDEADC0DE;
	enum MIN_SIZE = 0x200000;

	private ulong m_start;
	private ulong m_end;
	private ulong m_free;

	private Index m_index;
	private SpinLock m_spinLock;

	this(ulong offset, long size, long indexSize) {
		m_spinLock = new SpinLock();
		m_start    = offset + indexSize;
		m_end      = offset + size;
		m_free     = m_end - m_start;

		Header* header = cast(Header *)m_start;
		header.Size    = m_free;
		header.Magic   = MAGIC;
		header.IsHole  = true;

		Footer* footer = cast(Footer *)m_end - Footer.sizeof;
		footer.Head    = header;
        footer.Magic   = MAGIC;

		m_index.Data = cast(Header **)offset;
		InsertIntoIndex(header);
	}

	~this() {
		delete m_spinLock;
	}

	v_addr Alloc(long size, bool expandable = true) {
		m_spinLock.WaitOne();
		scope(exit) m_spinLock.Release();

		long newSize = size + Header.sizeof + Footer.sizeof;
		long i;
		for (; i < m_index.Size && m_index.Data[i].Size < newSize; i++) {}

		if (i == m_index.Size) {
			if (expandable) {
				Expand((size + 0xFFF) & 0xFFFFFFFFFFFFF000);
				return Alloc(size, false);
			} else
				assert(false);
		}

		Header* header = m_index.Data[i];
		Footer* footer = cast(Footer *)(cast(ulong)header + header.Size - Footer.sizeof);
		header.IsHole = false;
		RemoveFromIndex(header);

		if (header.Size > (newSize + Header.sizeof + Footer.sizeof)) {
			Footer* newFooter = cast(Footer *)(cast(ulong)header + newSize - Footer.sizeof);
			newFooter.Head    = header;
            newFooter.Magic   = MAGIC;

			Header* newHeader = cast(Header *)(cast(ulong)header + newSize);
			newHeader.IsHole  = true;
            newHeader.Magic   = MAGIC;
			newHeader.Size    = cast(long)footer - cast(long)newHeader + Footer.sizeof;

			header.Size  = newSize;
			footer.Head  = newHeader;
            footer.Magic = MAGIC;

			InsertIntoIndex(newHeader);
		}

		m_free -= header.Size;
		return cast(ulong)header + Header.sizeof;
	}

	void Free(v_addr ptr) {
		if (!ptr)
			return;

		Header* header = cast(Header *)(cast(ulong)ptr - Header.sizeof);
        if (header.Magic != MAGIC)
			return;

		Footer* footer = cast(Footer *)(cast(ulong)header + header.Size - Footer.sizeof);
        if (footer.Magic != MAGIC)
			return;

		m_spinLock.WaitOne();
		scope(exit) m_spinLock.Release();

		m_free += header.Size;
		Footer* prevFooter = cast(Footer *)(cast(ulong)header - Footer.sizeof);
        if (prevFooter.Magic == MAGIC && prevFooter.Head.IsHole) {
			header = prevFooter.Head;
			RemoveFromIndex(header);

			footer.Head = header;
			header.Size = cast(ulong)footer - cast(ulong)header + Footer.sizeof;
		}

		Header* nextHeader = cast(Header *)(cast(ulong)footer - Footer.sizeof);
        if (nextHeader.Magic == MAGIC && nextHeader.IsHole) {
			RemoveFromIndex(nextHeader);

			footer = cast(Footer *)(cast(ulong)footer + nextHeader.Size);
			footer.Head = header;
			header.Size = cast(ulong)footer - cast(ulong)header + Footer.sizeof;
		}

		header.IsHole = true;
		InsertIntoIndex(header);

		if (cast(ulong)footer == cast(ulong)m_end - Footer.sizeof && header.Size >= 0x2000 && cast(ulong)m_end - m_start > MIN_SIZE)
			Contract();
	}

	private void Expand(size_t quantity) {
		if (quantity & 0xFFF)
			quantity = (quantity & ~0xFFFUL) + 0x1000;

		ulong newEnd = m_end + quantity;

		Footer* lastFooter = cast(Footer *)(cast(ulong)m_end - Footer.sizeof);
		Header* lastHeader = lastFooter.Head;

		if (lastHeader.IsHole) {
			RemoveFromIndex(lastHeader);
			lastHeader.Size += quantity;

			lastFooter       = cast(Footer *)(cast(ulong)newEnd - Footer.sizeof);
            lastFooter.Magic = MAGIC;
			lastFooter.Head  = lastHeader;

			InsertIntoIndex(lastHeader);
		} else {
			lastHeader = cast(Header *)m_end;
			lastFooter = cast(Footer *)(cast(ulong)newEnd - Footer.sizeof);

			lastHeader.IsHole = true;
            lastHeader.Magic  = MAGIC;
			lastHeader.Size   = quantity;

            lastFooter.Magic = MAGIC;
			lastFooter.Head  = lastHeader;

			InsertIntoIndex(lastHeader);
		}

		m_end = newEnd;
		m_free += quantity;
	}

	private void Contract() {
		Footer* lastFooter = cast(Footer *)(cast(ulong)m_end - Footer.sizeof);
		Header *lastHeader = lastFooter.Head;

		if (!lastHeader.IsHole)
			return;

		ulong quantity;
		while (m_end - m_start - quantity > MIN_SIZE && lastHeader.Size - quantity > 0x1000)
			quantity += 0x1000;

		if (!quantity)
			return;

		ulong newEnd = m_end - quantity;
		m_free -= quantity;

		RemoveFromIndex(lastHeader);
		lastHeader.Size -= quantity;
		lastFooter       = cast(Footer *)(cast(ulong)lastFooter - quantity);
        lastFooter.Magic = MAGIC;
		lastFooter.Head  = lastHeader;

		m_end = newEnd;
	}

	private void RemoveFromIndex(long index) {
		m_index.Size--;

		while(index < m_index.Size)
			m_index.Data[index] = m_index.Data[++index];
	}

	private void RemoveFromIndex(Header* header) {
		long index = FindIndexEntry(header);

		if (index != -1)
			RemoveFromIndex(index);
	}

	private long FindIndexEntry(Header* header) {
		foreach (i; 0 .. m_index.Size)
			if (m_index.Data[i] == header)
				return i;

		return -1;
	}

	private void InsertIntoIndex(Header* header) {
		if ((m_index.Size * (Header *).sizeof + cast(ulong)m_index.Data) >= m_start)
			return;

		long i;
		for (; i < m_index.Size && m_index.Data[i].Size < header.Size; i++)
			if (m_index.Data[i] == header)
				return;


		if (i == m_index.Size)
			m_index.Data[m_index.Size++] = header;
		else {
			long pos = i;
			i = m_index.Size;

			while (i > pos)
				m_index.Data[i] = m_index.Data[--i];

			m_index.Size++;
			m_index.Data[pos] = header;
		}
	}

	static ulong CalculateIndexSize(ulong size) {
		return (size / 0x1000) * 64 + 0x1000;
	}

	private struct Header {
		uint Magic;
		bool IsHole;
		ulong Size;
	}
	
	private struct Footer {
		uint Magic;
		Header* Head;
	}
	
	private struct Index {
		Header** Data;
		long Size;
	}
}