module System.Collections.ICollection;

import System.Objecto;
import System.Collections.IEnumerable;


interface ICollection : IEnumerable {
	@property long Count();
	@property bool IsSynchronized();
	@property Objecto SyncRoot();

	//void CopyTo(Array array, long index);
}

interface ICollectionT(T) : IEnumerableT!T, IEnumerable {
	@property long Count();
	@property bool IsReadOnly();

	void Clear();
	void Add(T item);
	bool Remove(T item);
	bool Contains(T item);

	//void CopyTo(Array array, long index);
}