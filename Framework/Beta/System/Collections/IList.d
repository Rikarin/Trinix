module System.Collections.IList;

import System.Objecto;
import System.Collections.ICollection;
import System.Collections.IEnumerable;


interface IList : ICollection, IEnumerable {
	@property bool IsFixedSize();
	@property bool IsReadOnly();

	void opIndexAssign(Objecto value, long index);
	Objecto opIndex(long index);

	void Clear();
	long Add(Objecto value);
	bool Contains(Objecto value);
	long IndexOf(Objecto value);
	void Insert(long index, Objecto value);
	void Remove(Objecto value);
	void RemoveAt(long index);
}

interface IListT(T) : ICollectionT!T, IEnumerableT!T, IEnumerable {
	void opIndexAssign(Objecto value, long index);
	Objecto opIndex(long index);

	void Clear();
	long Add(Objecto value);
	bool Contains(Objecto value);
	long IndexOf(Objecto value);
	void Insert(long index, Objecto value);
	void Remove(Objecto value);
	void RemoveAt(long index);
}