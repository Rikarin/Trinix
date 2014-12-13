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

module Library.Queue;


class Queue(T) {
	private T[] _array;
	private long _count;

	@property long Count() {
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

	this() {
		_array = new T[4];
	}

	~this() {
		delete _array;
	}

	void Enqueue(T item) {
		if (Count == _array.length)
			Resize();

		_array[_count++] = item;
	}

	T Dequeue() {
		while (!_count) { } //TODO

		T ret = _array[0];
		_array[0 .. $ - 1] = _array[1 .. $];
		_count--;
		return ret;
	}

	private void Resize() {
		T[] newArray = new T[_array.length * 2];
		newArray[0 .. _array.length] = _array[0 .. $];

		delete _array;
		_array = newArray;
	}
}