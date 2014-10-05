module MemoryManager.Heap;

import Core : Log;
import Library;
import MemoryManager;


public final class Heap {
	private enum Magic = 0xDEADC0DE;
	public enum MinSize = 0x200000;

	private ulong _start;
	private ulong _end;
	private ulong _free;

	private Index _index;
	private SpinLock _spinLock; //TODO: mutex?

	public this(ulong offset, long size, long indexSize) {
		_spinLock = new SpinLock();
		_start    = offset + indexSize;
		_end      = offset + size;
		_free     = _end - _start;

		Header* header = cast(Header *)_start;
		header.Size    = _free;
		header.Magic   = Magic;
		header.IsHole  = true;

		Footer* footer = cast(Footer *)_end - Footer.sizeof;
		footer.Head    = header;
		footer.Magic   = Magic;

		_index.Data = cast(Header **)offset;
		InsertIntoIndex(header);
	}

	~this() {
		delete _spinLock;
	}

	public void* Alloc(long size, bool expandable = true) {
		_spinLock.WaitOne();
		scope(exit) _spinLock.Release();

		long newSize = size + Header.sizeof + Footer.sizeof;
		long i;
		for (; i < _index.Size && _index.Data[i].Size < newSize; i++) {}

		if (i == _index.Size) {
			if (expandable) {
				Expand((size + 0xFFF) & 0xFFFFFFFFFFFFF000);
				return Alloc(size, false);
			} else
				assert(false);
		}

		Header* header = _index.Data[i];
		Footer* footer = cast(Footer *)(cast(ulong)header + header.Size - Footer.sizeof);
		header.IsHole = false;
		RemoveFromIndex(header);

		if (header.Size > (newSize + Header.sizeof + Footer.sizeof)) {
			Footer* newFooter = cast(Footer *)(cast(ulong)header + newSize - Footer.sizeof);
			newFooter.Head    = header;
			newFooter.Magic   = Magic;

			Header* newHeader = cast(Header *)(cast(ulong)header + newSize);
			newHeader.IsHole  = true;
			newHeader.Magic   = Magic;
			newHeader.Size    = cast(long)footer - cast(long)newHeader + Footer.sizeof;

			header.Size  = newSize;
			footer.Head  = newHeader;
			footer.Magic = Magic;

			InsertIntoIndex(newHeader);
		}

		_free -= header.Size;
		return cast(void *)(cast(ulong)header + Header.sizeof);
	}

	public void Free(void* ptr) {
		if (ptr is null)
			return;

		Header* header = cast(Header *)(cast(ulong)ptr - Header.sizeof);
		if (header.Magic != Magic)
			return;

		Footer* footer = cast(Footer *)(cast(ulong)header + header.Size - Footer.sizeof);
		if (footer.Magic != Magic)
			return;

		_spinLock.WaitOne();
		scope(exit) _spinLock.Release();

		_free += header.Size;
		Footer* prevFooter = cast(Footer *)(cast(ulong)header - Footer.sizeof);
		if (prevFooter.Magic == Magic && prevFooter.Head.IsHole) {
			header = prevFooter.Head;
			RemoveFromIndex(header);

			footer.Head = header;
			header.Size = cast(ulong)footer - cast(ulong)header + Footer.sizeof;
		}

		Header* nextHeader = cast(Header *)(cast(ulong)footer - Footer.sizeof);
		if (nextHeader.Magic == Magic && nextHeader.IsHole) {
			RemoveFromIndex(nextHeader);

			footer = cast(Footer *)(cast(ulong)footer + nextHeader.Size);
			footer.Head = header;
			header.Size = cast(ulong)footer - cast(ulong)header + Footer.sizeof;
		}

		header.IsHole = true;
		InsertIntoIndex(header);

		if (cast(ulong)footer == cast(ulong)_end - Footer.sizeof && header.Size >= 0x2000 && cast(ulong)_end - _start > MinSize)
			Contract();
	}

	private void Expand(ulong quantity) {
		if (quantity & 0xFFF)
			quantity = (quantity & ~0xFFFUL) + 0x1000;

		ulong newEnd = _end + quantity;

		Footer* lastFooter = cast(Footer *)(cast(ulong)_end - Footer.sizeof);
		Header* lastHeader = lastFooter.Head;

		if (lastHeader.IsHole) {
			RemoveFromIndex(lastHeader);
			lastHeader.Size += quantity;

			lastFooter       = cast(Footer *)(cast(ulong)newEnd - Footer.sizeof);
			lastFooter.Magic = Magic;
			lastFooter.Head  = lastHeader;

			InsertIntoIndex(lastHeader);
		} else {
			lastHeader = cast(Header *)_end;
			lastFooter = cast(Footer *)(cast(ulong)newEnd - Footer.sizeof);

			lastHeader.IsHole = true;
			lastHeader.Magic  = Magic;
			lastHeader.Size   = quantity;

			lastFooter.Magic = Magic;
			lastFooter.Head  = lastHeader;

			InsertIntoIndex(lastHeader);
		}

		_end = newEnd;
		_free += quantity;
	}

	private void Contract() {
		Footer* lastFooter = cast(Footer *)(cast(ulong)_end - Footer.sizeof);
		Header *lastHeader = lastFooter.Head;

		if (!lastHeader.IsHole)
			return;

		ulong quantity;
		while (_end - _start - quantity > MinSize && lastHeader.Size - quantity > 0x1000)
			quantity += 0x1000;

		if (!quantity)
			return;

		ulong newEnd = _end - quantity;
		_free -= quantity;

		RemoveFromIndex(lastHeader);
		lastHeader.Size -= quantity;
		lastFooter       = cast(Footer *)(cast(ulong)lastFooter - quantity);
		lastFooter.Magic = Magic;
		lastFooter.Head  = lastHeader;

		_end = newEnd;
	}

	private void RemoveFromIndex(long index) {
		_index.Size--;

		while(index < _index.Size)
			_index.Data[index] = _index.Data[++index];
	}

	private void RemoveFromIndex(Header* header) {
		long index = FindIndexEntry(header);

		if (index != -1)
			RemoveFromIndex(index);
	}

	private long FindIndexEntry(Header* header) {
		foreach (i; 0 .. _index.Size)
			if (_index.Data[i] == header)
				return i;

		return -1;
	}

	private void InsertIntoIndex(Header* header) {
		if ((_index.Size * (Header *).sizeof + cast(ulong)_index.Data) >= _start)
			return;

		long i;
		for (; i < _index.Size && _index.Data[i].Size < header.Size; i++)
			if (_index.Data[i] == header)
				return;


		if (i == _index.Size)
			_index.Data[_index.Size++] = header;
		else {
			long pos = i;
			i = _index.Size;

			while (i > pos)
				_index.Data[i] = _index.Data[--i];

			_index.Size++;
			_index.Data[pos] = header;
		}
	}

	public static ulong CalculateIndexSize(ulong size) {
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