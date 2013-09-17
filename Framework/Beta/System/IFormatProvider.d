module System.IFormatProvider;

import System.Objecto;
import System.Type;


interface IFormatProvider {
	Objecto GetFormat(Type formatType);
}