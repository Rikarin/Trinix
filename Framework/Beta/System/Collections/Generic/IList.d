module System.Collections.Generic.IList;

import System.Objecto;
import System.Collections.ICollection;
import System.Collections.IEnumerable;


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