module System.TypeCode;

import System.String;
import System.DateTime;
import System.Infinite;


enum TypeCode {
	Empty,
	Object,
	DBNull,
	Boolean,
	Char,

	Byte,
	UByte,

	Int16,
	UInt16,

	Int32,
	UInt32,

	Int64,
	UInt64,

	Int128,
	UInt128,

	Float,
	Double,
	Real,

	Infinite,
	DateTime,
	String
}