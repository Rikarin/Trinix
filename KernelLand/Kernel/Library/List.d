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
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Library.List;


class List(T) {
	private T[] _array;
	private long _count;

	@property long Capacity() {
		return _array.length;
	}

	@property long Count() {
		return _count;
	}

	void opIndexAssign(T value, long index) {
		_array[index] = value;
	}

	T opIndex(long index) {
		return _array[index];
	}

	T[] opSlice(long i, long j) {
		return _array[i .. j];
	}

	long opDollar() {
		return _count;
	}

	int opApply(int delegate(ref T) dg) {
		int result;
		
		foreach (i; 0 .. _count) {
			result = dg(_array[i]);
			if (result)
				break;
		}
		
		return result;
	}
	
	int opApplyReverse(int delegate(ref T) dg) {
		int result;
		
		for (long i = _count; i >= 0; i--) {
			result = dg(_array[i]);
			if (result)
				break;
		}
		
		return result;
	}

	this(long capacity = 4) {
		_array = new T[capacity];
	}

	~this() {
		delete _array;
	}

	void Add(T item) {
		if (Count == Capacity)
			Resize();
		
		_array[_count++] = item;
	}

	void AddRange(List!T other) in {
		if (other is null)
			assert(false);
	} body {
		long tmp = other._array.length + Capacity;
		while (Capacity < tmp)
			Resize();

		_array[_count .. (_count + other._count)] = other._array[0 .. $];
		_count += other._count;
	}
	
	void Clear() {
		_array[] = null;
		_count = 0;
	}
	
	bool Contains(T item) {
		for (long i = 0; i < _count; i++)
			if (_array[i] == item)
				return true;

		return false;
	}
	
	bool Remove(T item) {
		long idx = IndexOf(item);
		if (idx == -1)
			return false;
		
		RemoveAt(idx);
		return true;
	}
	
	void RemoveAt(long index) in {
		if (index < 0 || index > _count)
			assert(false);
	} body {		
		_array[index .. $] = _array[index + 1 .. $];
		_count--;
	}
	
	void RemoveRange(long index, long count) in {
		if (count < 0 || index < 0)
			assert(false);

		if (_count < count - index || _count < index)
			assert(false);
	} body {
		_array[index .. $] = _array[index + count .. $];
		_count -= count;
	}
	
	void Reverse() {
		for (long i = 0; i < _count; i++) {
			T tmp = _array[i];
			_array[i] = _array[_count - i];
			_array[_count - i] = tmp;
		}
	}
	
	void Reverse(long index, long count) in {
		if (index < 0 || count < 0)
			assert(false);
		
		if (_count < count - index || _count < index)
			assert(false);
	} body {
		for (long i = index; i < index + _count; i++) {
			T tmp = _array[i];
			_array[i] = _array[index + count - i];
			_array[index + count - i] = tmp;
		}
	}
	
	long IndexOf(T item) {
		foreach (i; 0 .. _count)
			if (_array[i] == item)
				return i;
		
		return -1;
	}

	private void Resize() {
		T[] newArray = new T[Capacity * 2];
		newArray[0 .. _array.length] = _array[0 .. $];
		
		delete _array;
		_array = newArray;
	}
}