module System.Collections.Generic.IEnumerator;

import System.Objecto;
import System.IDisposable;


interface IEnumerator {
	@property Objecto Current();

	bool MoveNext();
	void Reset();	
}

interface IEnumeratorT(T) : IDisposable, IEnumerator {
	@property T Current();
}