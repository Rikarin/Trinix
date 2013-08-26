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








	static long StringLength(const char* value) {
		long i = 0;
		while (value[i] != '\0')
			i++;

		return i;
	}
}
