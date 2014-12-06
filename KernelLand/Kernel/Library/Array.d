module Library.Array;


public static class Array {
	public static T Find(T, U)(U array, bool delegate(T obj) predicate) {
		foreach (x; array)
			if (predicate(x))
				return x;

		return null;
	}
}