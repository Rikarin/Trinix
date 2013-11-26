module System.String;

import System;


class String {
	char[] str;

	@property ulong Length() { return str.length; }
	long opDollar() { return str.length; }

	char opIndex(long index) {
		if (index >= Length)
			throw new IndexOutOfRangeException();

		return str[index];
	}

	String opSlice(long i, long j) {
		//if (i >= Length || j >= Length)
		//	throw new IndexOutOfRangeException();

		return new String(cast(immutable(char)[])str[i .. j]);
	}

	void opAssign(immutable(char)[] value) {
		delete str;
		str = new char[value.length];
		str[] = value[0 .. $];
	}

	String opOpAssign(string op)(String value) {
		if (op == "~") {
			char[] tmp = new char[Length + value.Length];
			tmp[0 .. Length] = str[0 .. $];
			tmp[Length .. $] = value.str[0 .. $];

			delete str;
			str = tmp;

			return this;
		}
	}

	String opBinary(string op)(String value) {
		if (op == "~") {
			String ret = new String(' ', 0);

			ret.str = new char[Length + value.Length];
			ret.str[0 .. Length] = str[0 .. $];
			ret.str[Length .. $] = value.str[0 .. $];

			return ret;
		}
	}

/*	this(const char* value) {
		str = new char[StringLength(value)];
		str[] = value[0 .. str.length];
	}
*/
	this(immutable(char)[] value) {
		str = new char[value.length];
		str[] = value[0 .. $];
	}

	this(char c, long count) {
		str = new char[count];
		str[] = c;
	}

	bool Contains(String value) {
		return false;
	}

	long CompareTo(String value) {
		return Compare(this, value);
	}

	bool EndsWith(String value) {
		foreach_reverse (i, x; value.str)
			if (x != str[$ - value.Length + i])
				return false;

		return true;
	}

	bool Equals(String value) {
		return Equals(this, value);
	}

	long IndexOf(char value) {
		foreach (i, x; str)
			if (x == value)
				return i;

		return -1;
	}

	long IndexOf(String value) {
		long pointer;

		foreach (i, x; str) {
			if (x == value[pointer]) {
				pointer++;

				if (pointer == value.Length)
					return i - value.Length;
			} else
				pointer = 0;
		}

		return -1;
	}

	long IndexOfAny(char[] anyOf) {
		foreach (i, x; str)
			foreach (y; anyOf)
				if (x == y)
					return i;

		return -1;
	}

	String Insert(long startIndex, String value) {
		return (this[0 .. startIndex] ~ value) ~ this[startIndex .. $];
	}

	long LastIndexOf(char value) {
		foreach_reverse (i, x; str)
			if (x == value)
				return i;

		return -1;
	}

	long LastIndexOf(String value) {
		long pointer;

		foreach_reverse (i, x; str) {
			if (x == value[pointer]) {
				pointer++;

				if (pointer == value.Length)
					return i - value.Length;
			} else
				pointer = 0;
		}

		return -1;
	}

	long LastIndexOfAny(char[] anyOf) {
		foreach_reverse (i, x; str)
			foreach (y; anyOf)
				if (x == y)
					return i;

		return -1;
	}

	String PadLeft(long totalWidth) {
		return PadLeft(totalWidth, ' ');
	}

	String PadLeft(long totalWidth, char paddingChar) {
		return totalWidth > Length ? new String(paddingChar, totalWidth - Length) ~ this : this;
	}

	String PadRight(long totalWidth) {
		return PadRight(totalWidth, ' ');
	}

	String PadRight(long totalWidth, char paddingChar) {
		return totalWidth > Length ? this ~ new String(paddingChar, totalWidth - Length) : this;
	}

	String Replace(char oldChar, char newChar) {
		String ret = new String(cast(immutable(char)[])str);

		foreach (i, x; ret.str)
			if (x == oldChar)
				ret.str[i] = newChar;

		return ret;

	}

	String Replace(String oldValue, String newValue) {
		String ret = new String(cast(immutable(char)[])str);
		long idx = ret.IndexOf(oldValue);

		while (idx != -1) {
			ret.str[idx .. oldValue.Length] = newValue.str[0 .. $];
			idx = ret.IndexOf(oldValue);			
		}

		return ret;
	}
	

	String[] Split(char[] delimiter) { //TODO: FIX IT
		long idx;

		foreach (x; str) {
			foreach (y; delimiter) {
				if (x == y) {
					idx++;
					break;
				}
			}
		}
		
		String[] ret = new String[idx];

		long a, b;
		foreach (i, x; str) {
			foreach (y; delimiter) {
				if (x == y) {
					ret[b++] = cast(immutable(char)[])str[a .. i];
					a = i + 1;
					break;
				}
			}
		}

		ret[b] = new String(cast(immutable(char)[])str[a .. $]);
		return ret;
	}

	bool StartWith(String value) {
		foreach (i, x; value.str)
			if (x != str[i])
				return false;

		return true;
	}

	bool StartWith(String value, bool ignoreCase) {
		return ignoreCase ? ToLower().StartWith(value.ToLower()) : StartWith(value);
	}

	char[] ToCharArray() {
		return str[0 .. $];
	}

	String ToLower() {
		return this;
	}

	String ToUpper() {
		return this;
	}

	String Trim() {
		return this;
	}

	String Trim(char[] trimChars) {
		return this;
	}

	String TrimStart(char[] trimChars) {
		return this;
	}

	String TrimEnd(char[] trimChars) {
		return this;
	}

	
	//====================== STATIC ==========================
static:
	long Compare(String strA, String strB) {
		if (strA.Length != strB.Length)
			return strA.Length - strB.Length;

		foreach (i; 0 .. strA.Length)
			if (strA[i] != strB[i])
				return -1;

		return 0;
	}

	long Compare(String strA, String strB, bool ignoreCase) {
		return ignoreCase ? Compare(strA.ToLower(), strB.ToLower()) : Compare(strA, strB);
	}

	String Concat(String[] values) {
		String ret;

		foreach (x; values)
			ret ~= x;

		return ret;
	}

	String Concat(String strA, String strB) {
		return strA ~ strB;
	}

	String Concat(String strA, String strB, String strC) {
		return strA ~ strB ~ strC;
	}

	String Concat(String strA, String strB, String strC, String strD) {
		return strA ~ strB ~ strC ~ strD;
	}

	String Copy(String str) {
		return new String(cast(immutable(char)[])str.str);
	}

	bool Equals(String strA, String strB) {
		return !Compare(strA, strB);
	}

	bool IsNullOrEmpty(String value) {
		return value is null || !value.Length;
	}

	String Join(String separatior, String[] value) {
		String ret = value[0];

		foreach (x; value[1 .. $])
			ret ~= separatior ~ x;

		return ret;
	}





//====================================== OLD ==========================================================
	import System.Collections.Generic.List;

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
}
