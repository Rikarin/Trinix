module System.SystemException;

class SystemException : Exception {
	this() {
		super("null");
	}
}

class SystemNullException : SystemException { }
class MemoryException : SystemException { }
class ArgumentException : SystemException { }
class ArgumentNullException : ArgumentException { }
class ArgumentOutOfRangeException : ArgumentException { }
class BadPageTable : SystemException { }
class InvalidCastException : SystemException { }
class IndexOutOfRangeException : SystemException { }