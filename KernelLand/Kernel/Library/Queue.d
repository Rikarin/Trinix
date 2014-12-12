module Library.Queue;


class Queue(T) {
	private T[] _array;
	private long _count;

	@property long Count() {
		return count;
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
		array = new T[4];
	}

	~this() {
		delete _array;
	}

	void Enqueue(T item) {
		if (Count == _array.length)
			Resize();

		_array[count++] = item;
	}

	T Dequeue() {
		while (!Count) { }

		T ret = _array[0];
		_array[0 .. $ - 1] = _array[1 .. $];
		count--;
		return ret;
	}

	private void Resize() {
		T[] newArray = new T[_array.length * 2];
		newArray[0 .. _array.length] = _array[0 .. $];

		delete _array;
		_array = newArray;
	}
}