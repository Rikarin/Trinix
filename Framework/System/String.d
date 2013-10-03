module System.String;

import System.SystemException;


class String {
	char[] str;

	@property ulong Length() { return str.length; }

	char opIndex(long index) {
		if (index >= Length)
			throw new IndexOutOfRangeException();
		return str[index];
	}

	void opAssign(immutable(char)[] value) {
		delete str;
		str = new char[value.length];
		str[] = value[0 .. $];
	}


	void opOpAssign(string op)(string value) {
		char[] tmp = new char[value.length];
		tmp[0 .. str.length] = str[0 .. $];
		tmp[str.length .. $] = value[0 .. $];

		delete str;
		str = tmp;
	}

	//this() {}

/*	this(const char* value) {
		str = new char[StringLength(value)];
		str[] = value[0 .. str.length];
	}
*/
	this(immutable(char)[] value) {
		str = new char[value.length];
		str[] = value[0 .. $];
	}

/*	this(char c, long count) {
		str = new char[count];
		str[] = c;
	}*/
	
	//====================== STATIC ==========================
static:
	long Compare(String strA, String strB) {
		return 0;
	}



	import System.Collections.Generic.All;

	List!string Split(string str, char delimiter) {
		auto ret = new List!string();

		long a = 0;
		foreach (i, x; str) {
			if (x == delimiter) {
				ret.Add(str[a .. i]);
				a = i + 1;
			}
		}

		ret.Add(str[a .. $]);
		return ret;
	}

	long LastIndexOf(string str, char value) {
		foreach_reverse (i, x; str)
			if (x == value)
				return i;
			
		return -1;
	}

	string Substring(string str, long startIndex) {
		return str[startIndex .. $];
	}



	static long StringLength(const char* value) {
		long i = 0;
		while (value[i] != '\0')
			i++;

		return i;
	}
}
