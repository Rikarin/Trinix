module System.Convert;

import System;


class Convert {
static:
	bool ToBoolean(bool value)   { return value; }
	bool ToBoolean(char value)   { throw new InvalidCastException(); }
	bool ToBoolean(double value) { return value != 0; }
	bool ToBoolean(float value)  { return value != 0; }
	bool ToBoolean(ubyte value)  { return value != 0; }
	bool ToBoolean(ushort value) { return value != 0; }
	bool ToBoolean(uint value)   { return value != 0; }
	bool ToBoolean(ulong value)  { return value != 0; }
	bool ToBoolean(byte value)   { return value != 0; }
	bool ToBoolean(short value)  { return value != 0; }
	bool ToBoolean(int value)    { return value != 0; }
	bool ToBoolean(long value)   { return value != 0; }
	bool ToBoolean(string value) { return value.length != 0; }

	byte ToByte(bool value)   { return value ? 1 : 0; }
	byte ToByte(char value)   { return cast(byte)value; }
	byte ToByte(double value) { return cast(byte)value; }
	byte ToByte(float value)  { return cast(byte)value; }
	byte ToByte(ubyte value)  { return cast(byte)value; }
	byte ToByte(ushort value) { return cast(byte)value; }
	byte ToByte(uint value)   { return cast(byte)value; }
	byte ToByte(ulong value)  { return cast(byte)value; }
	byte ToByte(byte value)   { return cast(byte)value; }
	byte ToByte(short value)  { return cast(byte)value; }
	byte ToByte(int value)    { return cast(byte)value; }
	byte ToByte(long value)   { return cast(byte)value; }
	byte ToByte(string value, int fromBase = 10) { return ConvertFromString!byte(value, fromBase); }

	char ToChar(bool value)   { throw new InvalidCastException(); }
	char ToChar(char value)   { return cast(char)value; }
	char ToChar(double value) { throw new InvalidCastException(); }
	char ToChar(float value)  { throw new InvalidCastException(); }
	char ToChar(ubyte value)  { return cast(char)value; }
	char ToChar(ushort value) { return cast(char)value; }
	char ToChar(uint value)   { return cast(char)value; }
	char ToChar(ulong value)  { return cast(char)value; }
	char ToChar(byte value)   { return cast(char)value; }
	char ToChar(short value)  { return cast(char)value; }
	char ToChar(int value)    { return cast(char)value; }
	char ToChar(long value)   { return cast(char)value; }
	char ToChar(string value, int fromBase = 10) { return cast(char)value[0]; }

	double ToDouble(bool value)   { return value ? 1 : 0; }
	double ToDouble(char value)   { throw new InvalidCastException(); }
	double ToDouble(double value) { return cast(double)value; }
	double ToDouble(float value)  { return cast(double)value; }
	double ToDouble(ubyte value)  { return cast(double)value; }
	double ToDouble(ushort value) { return cast(double)value; }
	double ToDouble(uint value)   { return cast(double)value; }
	double ToDouble(ulong value)  { return cast(double)value; }
	double ToDouble(byte value)   { return cast(double)value; }
	double ToDouble(short value)  { return cast(double)value; }
	double ToDouble(int value)    { return cast(double)value; }
	double ToDouble(long value)   { return cast(double)value; }
	double ToDouble(string value, int fromBase = 10) { return ConvertFromString!double(value, fromBase); }

	short ToInt16(bool value)   { return value ? 1 : 0; }
	short ToInt16(char value)   { return cast(short)value; }
	short ToInt16(double value) { return cast(short)value; }
	short ToInt16(float value)  { return cast(short)value; }
	short ToInt16(ubyte value)  { return cast(short)value; }
	short ToInt16(ushort value) { return cast(short)value; }
	short ToInt16(uint value)   { return cast(short)value; }
	short ToInt16(ulong value)  { return cast(short)value; }
	short ToInt16(byte value)   { return cast(short)value; }
	short ToInt16(short value)  { return cast(short)value; }
	short ToInt16(int value)    { return cast(short)value; }
	short ToInt16(long value)   { return cast(short)value; }
	short ToInt16(string value, int fromBase = 10) { return ConvertFromString!short(value, fromBase); }

	int ToInt32(bool value)   { return value ? 1 : 0; }
	int ToInt32(char value)   { return cast(int)value; }
	int ToInt32(double value) { return cast(int)value; }
	int ToInt32(float value)  { return cast(int)value; }
	int ToInt32(ubyte value)  { return cast(int)value; }
	int ToInt32(ushort value) { return cast(int)value; }
	int ToInt32(uint value)   { return cast(int)value; }
	int ToInt32(ulong value)  { return cast(int)value; }
	int ToInt32(byte value)   { return cast(int)value; }
	int ToInt32(short value)  { return cast(int)value; }
	int ToInt32(int value)    { return cast(int)value; }
	int ToInt32(long value)   { return cast(int)value; }
	int ToInt32(string value, int fromBase = 10) { return ConvertFromString!int(value, fromBase); }

	long ToInt64(bool value)   { return value ? 1 : 0; }
	long ToInt64(char value)   { return cast(long)value; }
	long ToInt64(double value) { return cast(long)value; }
	long ToInt64(float value)  { return cast(long)value; }
	long ToInt64(ubyte value)  { return cast(long)value; }
	long ToInt64(ushort value) { return cast(long)value; }
	long ToInt64(uint value)   { return cast(long)value; }
	long ToInt64(ulong value)  { return cast(long)value; }
	long ToInt64(byte value)   { return cast(long)value; }
	long ToInt64(short value)  { return cast(long)value; }
	long ToInt64(int value)    { return cast(long)value; }
	long ToInt64(long value)   { return cast(long)value; }
	long ToInt64(string value, int fromBase = 10) { return ConvertFromString!long(value, fromBase); }

	ubyte ToUByte(bool value)   { return value ? 1 : 0; }
	ubyte ToUByte(char value)   { return cast(ubyte)value; }
	ubyte ToUByte(double value) { return cast(ubyte)value; }
	ubyte ToUByte(float value)  { return cast(ubyte)value; }
	ubyte ToUByte(ubyte value)  { return cast(ubyte)value; }
	ubyte ToUByte(ushort value) { return cast(ubyte)value; }
	ubyte ToUByte(uint value)   { return cast(ubyte)value; }
	ubyte ToUByte(ulong value)  { return cast(ubyte)value; }
	ubyte ToUByte(byte value)   { return cast(ubyte)value; }
	ubyte ToUByte(short value)  { return cast(ubyte)value; }
	ubyte ToUByte(int value)    { return cast(ubyte)value; }
	ubyte ToUByte(long value)   { return cast(ubyte)value; }
	ubyte ToUByte(string value, int fromBase = 10) { return ConvertFromString!ubyte(value, fromBase); }
	
	ushort ToUInt16(bool value)   { return value ? 1 : 0; }
	ushort ToUInt16(char value)   { return cast(ushort)value; }
	ushort ToUInt16(double value) { return cast(ushort)value; }
	ushort ToUInt16(float value)  { return cast(ushort)value; }
	ushort ToUInt16(ubyte value)  { return cast(ushort)value; }
	ushort ToUInt16(ushort value) { return cast(ushort)value; }
	ushort ToUInt16(uint value)   { return cast(ushort)value; }
	ushort ToUInt16(ulong value)  { return cast(ushort)value; }
	ushort ToUInt16(byte value)   { return cast(ushort)value; }
	ushort ToUInt16(short value)  { return cast(ushort)value; }
	ushort ToUInt16(int value)    { return cast(ushort)value; }
	ushort ToUInt16(long value)   { return cast(ushort)value; }
	ushort ToUInt16(string value, int fromBase = 10) { return ConvertFromString!ushort(value, fromBase); }

	uint ToUInt32(bool value)   { return value ? 1 : 0; }
	uint ToUInt32(char value)   { return cast(uint)value; }
	uint ToUInt32(double value) { return cast(uint)value; }
	uint ToUInt32(float value)  { return cast(uint)value; }
	uint ToUInt32(ubyte value)  { return cast(uint)value; }
	uint ToUInt32(ushort value) { return cast(uint)value; }
	uint ToUInt32(uint value)   { return cast(uint)value; }
	uint ToUInt32(ulong value)  { return cast(uint)value; }
	uint ToUInt32(byte value)   { return cast(uint)value; }
	uint ToUInt32(short value)  { return cast(uint)value; }
	uint ToUInt32(int value)    { return cast(uint)value; }
	uint ToUInt32(long value)   { return cast(uint)value; }
	uint ToUInt32(string value, int fromBase = 10) { return ConvertFromString!uint(value, fromBase); }

	ulong ToUInt64(bool value)   { return value ? 1 : 0; }
	ulong ToUInt64(char value)   { return cast(ulong)value; }
	ulong ToUInt64(double value) { return cast(ulong)value; }
	ulong ToUInt64(float value)  { return cast(ulong)value; }
	ulong ToUInt64(ubyte value)  { return cast(ulong)value; }
	ulong ToUInt64(ushort value) { return cast(ulong)value; }
	ulong ToUInt64(uint value)   { return cast(ulong)value; }
	ulong ToUInt64(ulong value)  { return cast(ulong)value; }
	ulong ToUInt64(byte value)   { return cast(ulong)value; }
	ulong ToUInt64(short value)  { return cast(ulong)value; }
	ulong ToUInt64(int value)    { return cast(ulong)value; }
	ulong ToUInt64(long value)   { return cast(ulong)value; }
	ulong ToUInt64(string value, int fromBase = 10) { return ConvertFromString!ulong(value, fromBase); }


	string ToString(bool value)   { return value ? "True" : "False"; }
	string ToString(char value)   { return "" ~ value; }
	//string ToString(double value, int toBase = 10) { return ConvertToString(value, toBase); }
	//string ToString(float value, int toBase = 10)  { return ConvertToString(value, toBase); }
	string ToString(ubyte value, int toBase = 10)  { return ConvertToString(value, toBase); }
	string ToString(ushort value, int toBase = 10) { return ConvertToString(value, toBase); }
	string ToString(uint value, int toBase = 10)   { return ConvertToString(value, toBase); }
	string ToString(ulong value, int toBase = 10)  { return ConvertToString(value, toBase); }
	string ToString(byte value, int toBase = 10)   { return ConvertToString(value, toBase); }
	string ToString(short value, int toBase = 10)  { return ConvertToString(value, toBase); }
	string ToString(int value, int toBase = 10)    { return ConvertToString(value, toBase); }
	string ToString(long value, int toBase = 10)   { return ConvertToString(value, toBase); }
	string ToString(string value) { return value; }


	byte[] ToByteArray(long[] array) {
		return (cast(byte *)array.ptr)[0 .. array.length * 8];
	}

	byte[] ObjectToByteArray(T)(ref T object) {
		return cast(byte[])(cast(byte *)&object)[0 .. T.sizeof];
	}

	long[] ToInt64Array(byte[] array)  {
		return (cast(long *)array.ptr)[0 .. array.length / 8];
	}


	private T ConvertFromString(T)(string value, int fromBase) {
		T ret = 0;
		bool neg = false;
		int dotPos = 0;

		foreach (int i, x; value) {
			switch (x) {
				case '-':
					neg = true;

				case 'x':
					continue;

				case '.':
				case ',':
					dotPos = i;
					continue;

				default:
			}

			uint num = number(x);
			if (num == 0xFFFF)
				break;

			ret = cast(T)(ret * fromBase + num);
		}

		if (neg)
			ret *= -1;

		
		static if (is(T == float) || is(T == double)) {
			while (dotPos--)
				ret /= 10.0f;
		}

		return ret;
	}

	private uint number(char c) {
		if (c >= '0' && c <= '9')
			return c - '0';

		if (c >= 'A' && c <= 'F')
			return c - 'A';

		if (c >= 'a' && c <= 'f')
			return c - 'a';

		return 0xFFFF;
	}

	private string ConvertToString(T)(T value, int toBase) {
		string ret;

		static if (!is(T == ubyte) && !is(T == ushort) && !is(T == uint) && !is(T == ulong)) {
			if (value < 0) {
				ret = ret ~ "-";
				value *= -1;
		  	}
		}

		switch (toBase) {
			case 2:
				ret = ret ~ "0b";
				break;

			case 8:
				ret = ret ~ "0";
				break;

			case 16:
				ret = ret ~ "0x";
				break;

			default:
		}

		string tmp;
		string digits = "0123456789ABCDEF";

		do
			tmp = digits[value % toBase] ~ tmp;
		while (value /= toBase);
		ret = ret ~ tmp;

		/*static if (is(T == float) || is(T == double)) {
			ret = ret ~ ".";


			do
				tmp = digits[value % toBase] ~ tmp;
			while (value /= toBase);

			ret = ret ~ '0f';
		}*/

		return ret;
	}


	union DelegateToLong {
		struct {
			long Value1;
			long Value2;
		}

		void delegate() Delegate;
	}


	/+
	private string ConvertToString(T)(T value, int toBase) {
		char[256] num;
		short p = 235;
		string digits = "0123456789ABCDEF";

		do
			num[p--] = 'z';//digits[value % toBase];
		while (value /= toBase);

	/*	switch (toBase) {
			case 2:
				num[p--] = 'b';
				num[p--] = '0';
				break;

			case 8:
				num[p--] = '0';
				break;

			case 16:
				num[p--] = 'x';
				num[p--] = '0';
				break;

			default:
		}

		static if (!is(T == ubyte) && !is(T == ushort) && !is(T == uint) && !is(T == ulong)) {
			if (value < 0) {
				num[p--] = '-';
		  	}
		}

		*/

		/*static if (is(T == float) || is(T == double)) {
			ret = ret ~ ".";


			do
				tmp = digits[value % toBase] ~ tmp;
			while (value /= toBase);

			ret = ret ~ '0f';
		}*/

		return num[p .. $];
	}

	+/
}