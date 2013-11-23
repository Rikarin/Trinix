module MemoryManager.Heap;

import Architectures;
import MemoryManager;

import System.Threading;


class Heap {
private:
	const uint MAGIC = 0xDEADC0D;
	
	struct Header {
		uint magic;
		bool isHole;
		ulong size;
	}
	
	struct Footer {
		uint magic;
		Header *header;
	}
	
	struct Index {
		Header** data;
		ulong size;
	}
	
	ulong free, start, end;
	bool usable;
	Index index;
	Paging page;
	Mutex mutex;
	

public:
	__gshared const uint MIN_SIZE = 0x200000;


	this() {
		mutex = new Mutex();
		usable = false;
		index.data = null;
		index.size = 0;
	}
	
	~this() {
		delete mutex;
		//Free Pages....
	}
	
	void *Alloc(ulong size, bool noExpand = false) { 
		mutex.WaitOne();
		ulong newSize = size + Header.sizeof + Footer.sizeof;
		
		ulong iter = 0;
		for (; iter < index.size; iter++)
			if (index.data[iter].size >= newSize)
				break;
				
		if (iter == index.size) {
			if (noExpand) {
				mutex.Release();
				return null;
			}
			
			Expand(size);
			mutex.Release();
			return Alloc(size, true);
		}
		
		Header *header = index.data[iter];
		Footer *footer = cast(Footer *)(header + header.size - Footer.sizeof);
		header.isHole = false;
		
		RemoveFromIndex(header);
		if (header.size > (newSize + Header.sizeof + Footer.sizeof)) {
			Footer *newFooter = cast(Footer *)(header + newSize - Footer.sizeof);
			newFooter.header = header;
			newFooter.magic = MAGIC;
			
			Header *newHeader = cast(Header *)(header + newSize);
			newHeader.isHole = true;
			newHeader.magic = MAGIC;
			newHeader.size = header.size - newSize;

			header.size = newSize;			
			footer.header = newHeader;
			footer.magic = MAGIC;
			
			InsertIntoIndex(newHeader);
		}
		
		free -= header.size;
		mutex.Release();
		
		return cast(void *)(header + Header.sizeof);
	}
	
	void Free(void *ptr) {
		if (ptr is null)
			return;
			
		Header *header = cast(Header *)(ptr - Header.sizeof);
		if(header.magic != MAGIC)
			return;
			
		Footer *footer = cast(Footer *)(header + header.size - Footer.sizeof);
		if (footer.magic != MAGIC)
			return;
			
		mutex.WaitOne();
		free += header.size;
		
		Footer *prevFooter = cast(Footer *)(cast(ulong)header - Footer.sizeof);
		if (prevFooter.magic == MAGIC && prevFooter.header.isHole) {
			header = prevFooter.header;
			RemoveFromIndex(header);
			
			footer.header = header;
			header.size = (cast(ulong)footer - cast(ulong)header + Footer.sizeof);
		}
		
		Header *nextHeader = cast(Header *)(footer - Footer.sizeof);
		if (nextHeader.magic == MAGIC && nextHeader.isHole) {
			RemoveFromIndex(nextHeader);
			footer = cast(Footer *)(footer + nextHeader.size);
			
			footer.header = header;
			header.size = (cast(ulong)footer - cast(ulong)header + Footer.sizeof);
		}
		
		header.isHole = true;
		InsertIntoIndex(header);
		
		if (cast(ulong)footer == (end - Footer.sizeof) && header.size >= 0x2000 && (end - start > MIN_SIZE))
			Contract();
			
		mutex.Release();
	}
	
	void Create(ulong start, ulong size, ulong indexSize, Paging page) {
		if (usable)
			return;
			
			this.start = start + indexSize;
			this.end = start + size;
			this.page = page;
			
			for (ulong i = start; i < end; i += 0x1000)
				page.AllocFrame(cast(VirtualAddress)i, false, true);
			page.Install();

			index.data = cast(Header **)start;
			index.size = 0;

			Header *hole = cast(Header *)this.start;
			hole.size = end - this.start;
			hole.magic = MAGIC;
			hole.isHole = true;

			Footer *holeFooter = cast(Footer *)end - Footer.sizeof;
			holeFooter.header = hole;
			holeFooter.magic = MAGIC;

			InsertIntoIndex(hole);

			usable = true;
			free = end - this.start;
	}

	void Expand(ulong quantity) {
		if (quantity & 0xFFF)
			quantity = (quantity & ~0xFFFUL) + 0x1000;

		ulong newEnd = end + quantity;

		for (ulong i = end; i < newEnd; i += 0x1000)
			page.AllocFrame(cast(VirtualAddress)i, false, true);

		Footer *lastFooter = cast(Footer *)end - Footer.sizeof;
		Header *lastHeader = lastFooter.header;
		if (lastHeader.isHole) {
			RemoveFromIndex(lastHeader);
			lastHeader.size += quantity;

			lastFooter = cast(Footer *)newEnd - Footer.sizeof;
			lastFooter.magic = MAGIC;
			lastFooter.header = lastHeader;

			InsertIntoIndex(lastHeader);
		} else {
			lastHeader = cast(Header *)end;
			lastFooter = cast(Footer *)newEnd - Footer.sizeof;

			lastHeader.isHole = true;
			lastHeader.magic = MAGIC;
			lastHeader.size = quantity;

			lastFooter.magic = MAGIC;
			lastFooter.header = lastHeader;

			InsertIntoIndex(lastHeader);
		}

		end = newEnd;
		free += quantity;
	}

	void Contract() {
		Footer *lastFooter = cast(Footer *)end - Footer.sizeof;
		Header *lastHeader = lastFooter.header;

		if (!lastHeader.isHole)
			return;

		ulong quantity = 0;
		while ((end - start) - quantity > MIN_SIZE && (lastHeader.size - quantity) > 0x1000)
			quantity += 0x1000;

		if (!quantity)
			return;

		ulong newEnd = end - quantity;
		free -= quantity;

		RemoveFromIndex(lastHeader);
		lastHeader.size -= quantity;
		lastFooter = lastFooter - quantity;
		lastFooter.magic = MAGIC;
		lastFooter.header = lastHeader;
		InsertIntoIndex(lastHeader);

		for (ulong i = newEnd; i < end; i += 0x1000)
			page.FreeFrame(cast(VirtualAddress)i);

		end = newEnd;
	}


	private void RemoveFromIndex(uint idx) {
		index.size--;
		while (idx < index.size)
			index.data[idx] = index.data[++idx];
	}

	private void RemoveFromIndex(Header *header) {
		uint idx = FindIndexEntry(header);
		if (idx != ~0U)
			RemoveFromIndex(idx);
	}

	private uint FindIndexEntry(Header *header) {
		for (uint i = 0; i < index.size; i++)
			if (index.data[i] == header)
				return i;
		return ~0U;
	}

	private void InsertIntoIndex(Header *header) {
		if ((index.size * (Header *).sizeof + cast(ulong)index.data) >= start)
			return;

		uint iter = 0;
		while (iter < index.size && cast(ulong)index.data[iter] < header.size)
			if (index.data[iter++] == header)
				return;

		if (iter == index.size)
			index.data[index.size++] = header;
		else {
			uint pos = iter;
			iter = cast(uint)index.size;

			while (iter > pos)
				index.data[iter] = index.data[--iter];

			index.size++;
			index.data[pos] = header;
		}
	}
}