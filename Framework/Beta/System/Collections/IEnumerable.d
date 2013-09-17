module System.Collections.IEnumerable;

import System.Collections.Generic.IEnumerator;


interface IEnumerable {
	IEnumerator GetEnumerator();
}

interface IEnumerableT(T) : IEnumerable {
	IEnumeratorT!T GetEnumerator();
}