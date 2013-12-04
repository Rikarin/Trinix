module MemoryManager.Heap;

import Architectures;
import MemoryManager;

import System.Threading;


class Heap {
private:
	enum Magic = 0xDEADC0DE;
	
	struct Header {
		uint Magic;
		bool IsHole;
		ulong Size;
	}
	
	struct Footer {
		uint Magic;
		Header *Head;
	}
	
	struct Index {
		Header** Data;
		ulong Size;
	}
	
	ulong free, start, end;
	Index index;
	Paging page;
	Mutex mutex;
	

public:
	enum MinSize = 0x200000;


	this(ulong offset, ulong size, ulong indexSize, Paging paging) {
		mutex = new Mutex();

		start = offset + indexSize;
		end   = offset + size;
		page  = paging;
		
		for (ulong i = offset; i < end; i += 0x1000)
			page.AllocFrame(cast(VirtualAddress)i, false, true);
		page.Install();

		index.Data = cast(Header **)offset;
		index.Size = 0;

		Header *hole = cast(Header *)start;
		hole.Size    = end - start;
		hole.Magic   = Magic;
		hole.IsHole  = true;

		Footer *holeFooter = cast(Footer *)end - Footer.sizeof;
		holeFooter.Head    = hole;
		holeFooter.Magic   = Magic;

		InsertIntoIndex(hole);
		free = end - start;
	}
	
	~this() {
		delete mutex;
		//Free Pages....
	}
	
	void *Alloc(ulong size, bool noExpand = false) { 
		mutex.WaitOne();
		ulong newSize = size + Header.sizeof + Footer.sizeof;
		
		ulong iter = 0;
		for (; iter < index.Size; iter++)
			if (index.Data[iter].Size >= newSize)
				break;
				
		if (iter == index.Size) {
			if (noExpand) {
				mutex.Release();
				return null;
			}
			
			Expand(size);
			mutex.Release();
			return Alloc(size, true);
		}
		
		Header *header = index.Data[iter];
		Footer *footer = cast(Footer *)(header + header.Size - Footer.sizeof);
		header.IsHole  = false;
		
		RemoveFromIndex(header);
		if (header.Size > (newSize + Header.sizeof + Footer.sizeof)) {
			Footer *newFooter = cast(Footer *)(header + newSize - Footer.sizeof);
			newFooter.Head    = header;
			newFooter.Magic   = Magic;
			
			Header *newHeader = cast(Header *)(header + newSize);
			newHeader.IsHole  = true;
			newHeader.Magic   = Magic;
			newHeader.Size    = cast(ulong)footer - cast(ulong)newHeader + newSize;

			header.Size   = newSize;			
			footer.Head   = newHeader;
			footer.Magic  = Magic;
			
			InsertIntoIndex(newHeader);
		}
		
		free -= header.Size;
		mutex.Release();
		
		return cast(void *)(header + Header.sizeof);
	}
	
	void Free(void *ptr) {
		if (ptr is null)
			return;
			
		Header *header = cast(Header *)(ptr - Header.sizeof);
		if(header.Magic != Magic)
			return;
			
		Footer *footer = cast(Footer *)(header + header.Size - Footer.sizeof);
		if (footer.Magic != Magic)
			return;
			
		mutex.WaitOne();
		free += header.Size;
		
		Footer *prevFooter = cast(Footer *)(cast(ulong)header - Footer.sizeof);
		if (prevFooter.Magic == Magic && prevFooter.Head.IsHole) {
			header = prevFooter.Head;
			RemoveFromIndex(header);
			
			footer.Head = header;
			header.Size = (cast(ulong)footer - cast(ulong)header + Footer.sizeof);
		}
		
		Header *nextHeader = cast(Header *)(footer - Footer.sizeof);
		if (nextHeader.Magic == Magic && nextHeader.IsHole) {
			RemoveFromIndex(nextHeader);
			footer = cast(Footer *)(footer + nextHeader.Size);
			
			footer.Head = header;
			header.Size = (cast(ulong)footer - cast(ulong)header + Footer.sizeof);
		}
		
		header.IsHole = true;
		InsertIntoIndex(header);
		
		if (cast(ulong)footer == (end - Footer.sizeof) && header.Size >= 0x2000 && (end - start > MinSize))
			Contract();
			
		mutex.Release();
	}

	void Expand(ulong quantity) {
		if (quantity & 0xFFF)
			quantity = (quantity & ~0xFFFUL) + 0x1000;

		ulong newEnd = end + quantity;

		for (ulong i = end; i < newEnd; i += 0x1000)
			page.AllocFrame(cast(VirtualAddress)i, false, true);

		Footer *lastFooter = cast(Footer *)end - Footer.sizeof;
		Header *lastHeader = lastFooter.Head;

		if (lastHeader.IsHole) {
			RemoveFromIndex(lastHeader);
			lastHeader.Size += quantity;

			lastFooter = cast(Footer *)newEnd - Footer.sizeof;
			lastFooter.Magic = Magic;
			lastFooter.Head  = lastHeader;

			InsertIntoIndex(lastHeader);
		} else {
			lastHeader = cast(Header *)end;
			lastFooter = cast(Footer *)newEnd - Footer.sizeof;

			lastHeader.IsHole = true;
			lastHeader.Magic  = Magic;
			lastHeader.Size   = quantity;

			lastFooter.Magic = Magic;
			lastFooter.Head  = lastHeader;

			InsertIntoIndex(lastHeader);
		}

		end = newEnd;
		free += quantity;
	}

	void Contract() {
		Footer *lastFooter = cast(Footer *)end - Footer.sizeof;
		Header *lastHeader = lastFooter.Head;

		if (!lastHeader.IsHole)
			return;

		ulong quantity = 0;
		while ((end - start) - quantity > MinSize && (lastHeader.Size - quantity) > 0x1000)
			quantity += 0x1000;

		if (!quantity)
			return;

		ulong newEnd = end - quantity;
		free -= quantity;

		RemoveFromIndex(lastHeader);
		lastHeader.Size -= quantity;
		lastFooter      -= quantity;
		lastFooter.Magic = Magic;
		lastFooter.Head  = lastHeader;
		InsertIntoIndex(lastHeader);

		for (ulong i = newEnd; i < end; i += 0x1000)
			page.FreeFrame(cast(VirtualAddress)i);

		end = newEnd;
	}


	private void RemoveFromIndex(uint idx) {
		index.Size--;
		while (idx < index.Size)
			index.Data[idx] = index.Data[++idx];
	}

	private void RemoveFromIndex(Header *header) {
		uint idx = FindIndexEntry(header);
		if (idx != ~0U)
			RemoveFromIndex(idx);
	}

	private uint FindIndexEntry(Header *header) {
		for (uint i = 0; i < index.Size; i++)
			if (index.Data[i] == header)
				return i;

		return ~0U;
	}

	private void InsertIntoIndex(Header *header) {
		if ((index.Size * (Header *).sizeof + cast(ulong)index.Data) >= start)
			return;

		ulong iter = 0;
		while (iter < index.Size && index.Data[iter].Size < header.Size)
			if (index.Data[iter++] == header)
				return;

		if (iter == index.Size)
			index.Data[index.Size++] = header;
		else {
			ulong pos = iter;
			iter = index.Size;

			while (iter > pos)
				index.Data[iter] = index.Data[--iter];

			index.Size++;
			index.Data[pos] = header;
		}
	}
}