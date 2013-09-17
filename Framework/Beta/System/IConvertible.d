module System.IConvertible;

import System.Type;
import System.String;
import System.Objecto;
import System.TypeCode;
import System.Infinite;
import System.DateTime;
import System.IFormatProvider;


interface IConvertible {
	TypeCode GetTypeCode();

	bool ToBoolean(IFormatProvider provider);
	char ToChar(IFormatProvider provider);

	byte ToByte(IFormatProvider provider);
	ubyte ToUByte(IFormatProvider provider);

	short ToInt16(IFormatProvider provider);
	ushort ToUInt16(IFormatProvider provider);

	int ToInt32(IFormatProvider provider);
	uint ToUInt32(IFormatProvider provider);

	long ToInt64(IFormatProvider provider);
	ulong ToUInt64(IFormatProvider provider);

	//cent ToInt128(IFormatProvider provider);
	//ucent ToUInt128(IFormatProvider provider);

	float ToFloat(IFormatProvider provider);
	double ToDouble(IFormatProvider provider);
	real ToReal(IFormatProvider provider);

	DateTime ToDateTime(IFormatProvider provider);
	Infinite ToInfinite(IFormatProvider provider);
	String ToString(IFormatProvider provider);
	Objecto ToType(Type conversionType, IFormatProvider provider);
}