module Library.Array;


static class Array {
	static T Find(T, U)(U array, bool delegate(T obj) predicate) {
		foreach (x; array)
			if (predicate(x))
				return x;

		return null;
	}
}