module System.Collections.Generic.List;

import System.SystemException;
import System.Collections.Generic.Item;

class List(T) {
	private T[] array;
	private long count;

	//foreach
	@property T front()    { return array[0]; }
	@property T back()     { return array[count]; }
	@property bool empty() { return !count; }
	void popFront()        { RemoveAt(0); }
	void popBack()         { RemoveAt(count - 1); }
	

	@property long Capacity() 	{ return array.length; }
	@property long Count() 		{ return count; }


	void opIndexAssign(T value, long index) { array[index] = value; }
	T opIndex(long index) { return array[index]; }
	T[] opSlice(long i, long j) { return array[i .. j]; }
	long opDollar() { return count; }

	
	private void Resize() {
		T[] newArray = new T[Capacity * 2];
		newArray[] = array;

		delete array;
		array = newArray;
	}
	
	this() {
		array = new T[4];
	}
	
	this(long capacity) {
		array = new T[capacity];
	}
	
	~this() {
	//	foreach (x; array)
	//		delete x;

		delete array;
	}
	
	void Add(T item) {
		if (Count == Capacity)
			Resize();
			
		array[count++] = item;
	}
	
	void AddRange(List!T other) {
		if (other is null)
			throw new ArgumentNullException();
			
		long tmp = Capacity;
		while (Capacity < other.array.length + tmp)
			Resize();
			
		array[count .. (count + other.count)] = other.array[0 .. $];
		count += other.count;
	}
	
	long BinarySearch(T item) {
		return -1;
	}
	
	void Clear() {
	//	foreach (x; array)
	//		delete x;

		array[0 .. $] = null;
		count = 0;
	}
	
	bool Contains(T item) {
		for (long i = 0; i < count; i++)
			if (array[i] == item)
				return true;
		return false;
	}
	
	List!T GetRange(long index, long count) {
		if (count < 0 || index < 0)
			throw new ArgumentOutOfRangeException();
			
		if (this.count < count - index || this.count < index)
			throw new ArgumentException();
			
		List!T ret = new List!T(count);
		ret.array[0 .. $] = array[index .. index + count];
		return ret;
	}
	
	void Insert(long index, T item) {
		if (index < 0 || index > count)
			throw new ArgumentOutOfRangeException();
			
		if (Count == Capacity)
			Resize();
			
		array[index + 1 .. $] = array[index .. $];
		array[index] = item;
		count++;
	}
	
	void InsertRange(long index, List!T collection) {
		if (collection is null)
			throw new ArgumentNullException();
			
		if (index < 0 || index > count)
			throw new ArgumentOutOfRangeException();
			
		long tmp = Capacity;
		while (Capacity < collection.array.length + tmp)
			Resize();
			
		array[index + collection.Count .. $] = array[index .. $];
		array[index .. collection.Count] = collection.array[0 .. $];
		count += collection.Count;
	}
	
	bool Remove(T item) {
		long idx = IndexOf(item);
		if (idx == -1)
			return false;

		RemoveAt(idx);
		return true;
	}
	
	void RemoveAt(long index) {
		if (index < 0 || index > count)
			throw new ArgumentOutOfRangeException();
		
	//	delete array[index];

		array[index .. $] = array[index + 1 .. $];
		count--;
	}
	
	void RemoveRange(long index, long count) {
		if (count < 0 || index < 0)
			throw new ArgumentOutOfRangeException();
			
		if (this.count < count - index || this.count < index)
			throw new ArgumentException();
		

	//	foreach (i; index .. (index + count))
	//		delete array[i];

		array[index .. $] = array[index + count .. $];
		this.count -= count;
	}
	
	void Reverse() {
		for (long i = 0; i < count; i++) {
			T tmp = array[i];
			array[i] = array[count - i];
			array[count - i] = tmp;
		}
	}
	
	void Reverse(long index, long count) {
		if (index < 0 || count < 0)
			throw new ArgumentOutOfRangeException();
			
		if (this.count < count - index || this.count < index)
			throw new ArgumentException();
		
		for (long i = index; i < index + count; i++) {
			T tmp = array[i];
			array[i] = array[index + count - i];
			array[index + count - i] = tmp;
		}
	}
	
	void Sort() {
	
	}
	
	T Find(bool delegate(Item!(long, T)) match) {
		if (match is null)
			throw new ArgumentNullException();
			
		Item!(long, T) item = new Item!(long, T)();
		for (long i = 0; i < count; i++) {
			item.Set(i, array[i]);
			if (match(item) == true) {
				delete item;
				return array[i];
			}
		}
		
		delete item;
		throw new SystemNullException();
	}
	
	long FindIndex(bool delegate(Item!(long, T)) match) {
		return IndexOf(Find(match));
	}
	
	List!T FindAll(bool delegate(Item!(long, T)) match) {
		if (match is null)
			throw new ArgumentNullException();
	
		List!T ret = new List!(T);
		Item!(long, T) item = new Item!(long, T)();

		for (long i = 0; i < count; i++) {
			item.Set(i, array[i]);
			if (match(item) == true)
				ret.Add(array[i]);
		}
		
		delete item;
		return ret;
	}

	long IndexOf(T item) {
		for (long i = 0; i < count; i++) {
			if (array[i] == item)
				return i;
		}

		return -1;
	}
}
