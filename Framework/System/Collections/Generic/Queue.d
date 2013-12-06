module System.Collections.Generic.Queue;


class Queue(T) {
	private T[] array;
	private long count;

	@property long Count() { return count; }


	int opApply(int delegate(ref T) dg) {
		int result;

		for (long i = 0; i < count; i++) {
			result = dg(array[i]);
			if (result)
				break;
		}

		return result;
	}

	
	private void Resize() {
		T[] newArray = new T[array.length * 2];
		newArray[0 .. array.length] = array[0 .. $];

		//delete array;
		array = newArray;
	}


	this() {
		array = new T[4];
	}	
	
	void Enqueue(T item) {
		if (Count == array.length)
			Resize();
			
		array[count++] = item;
	}

	T Dequeue() {
		while (!Count) { }
			
		T ret = array[0];
		array[0 .. $ - 1] = array[1 .. $];
		count--;

		return ret;
	}
}