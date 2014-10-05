module Runtime.Core.Exception;


alias AssertHandler = void function(string file, size_t line, string msg) nothrow;
private __gshared AssertHandler _assertHandler = null;


@property AssertHandler AssertHandle() @trusted nothrow {
	return _assertHandler;
}

@property void AssertHandle(AssertHandler handler) @trusted nothrow {
	_assertHandler = handler;
}




public class RangeError : Error {
	public @safe pure nothrow this(string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("Range violation", file, line, next);
	}
}


public class AssertError : Error {
	public @safe pure nothrow this(string file, size_t line) {
		this(cast(Throwable)null, file, line);
	}
	
	public @safe pure nothrow this(Throwable next, string file = __FILE__, size_t line = __LINE__) {
		this("Assertion failure", file, line, next);
	}
	
	public @safe pure nothrow this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super(message, file, line, next);
	}
}


public class FinalizeError : Error {
	private ClassInfo _info;
	
	public @safe pure nothrow this(ClassInfo ci, Throwable next, string file = __FILE__, size_t line = __LINE__) {
		this(ci, file, line, next);
	}
	
	public @safe pure nothrow this(ClassInfo ci, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("Assertion failure", file, line, next);
		_info = ci;
	}

	public @safe override const string ToString() {
		return "An exception was thrown while finalizing an instance of class " ~ _info.Name;
	}
}


public class HiddenFuncError : Error {
	public @safe pure nothrow this(ClassInfo ci) {
		super("Hidden method called for " ~ ci.Name);
	}
}


public class OutOfMemoryError : Error {
	public @safe pure nothrow this(string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("Memory allocation failed", file, line, next);
	}
	
	public @trusted override const string ToString() {
		return _message.ptr ? (cast()super).ToString() : "Memory allocation failed";
	}
}


public class InvalidMemoryOperationError : Error {
	public @safe pure nothrow this(string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("Invalid memory operation", file, line, next);
	}
	
	public @trusted override const string ToString() {
		return _message.ptr ? (cast()super).ToString() : "Invalid memory operation";
	}
}


public class SwitchError : Error {
	public @safe pure nothrow this(string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("No appropriate switch clause found", file, line, next);
	}
}


public class UnicodeException : Exception {
	private size_t _idx;
	
	public this(string msg, size_t idx, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @safe pure nothrow {
		super(msg, file, line, next);
		_idx = idx;
	}
}


//======================================================================================================================
//                                        ====== Overridable Callbacks ======
//======================================================================================================================
extern (C) void OnAssertError(string file = __FILE__, size_t line = __LINE__) nothrow {
	if(_assertHandler is null)
		throw new AssertError(file, line);
	_assertHandler(file, line, null);
}

extern (C) void OnAssertErrorMessage(string file, size_t line, string message) nothrow {
	if(_assertHandler is null)
		throw new AssertError(message, file, line);
	_assertHandler(file, line, message);
}

extern (C) void OnUnittestErrorMessage(string file, size_t line, string message) nothrow {
	OnAssertErrorMessage(file, line, message);
}


//                                                         .                                                           .
//======================================================================================================================
//                                          ====== Internal Callbacks ======
//======================================================================================================================
extern (C) void OnRangeError(string file = __FILE__, size_t line = __LINE__) @safe pure nothrow {
	throw new RangeError(file, line, null);
}

extern (C) void OnFinalizeError(ClassInfo info, Exception e, string file = __FILE__, size_t line = __LINE__) @safe pure nothrow {
	throw new FinalizeError(info, file, line, e);
}

extern (C) void OnHiddenFuncError(Object o) @safe pure nothrow {
	throw new HiddenFuncError(typeid(o));
}
extern (C) void OnOutOfMemoryError() @trusted pure nothrow {
	throw cast(OutOfMemoryError)cast(void *)typeid(OutOfMemoryError).init;
}

extern (C) void OnInvalidMemoryOperationError() @trusted pure nothrow {
	throw cast(InvalidMemoryOperationError)cast(void *)typeid(InvalidMemoryOperationError).init;
}

extern (C) void OnSwitchError(string file = __FILE__, size_t line = __LINE__) @safe pure nothrow {
	throw new SwitchError(file, line, null);
}

extern (C) void onUnicodeError(string message, size_t idx, string file = __FILE__, size_t line = __LINE__) @safe pure {
	throw new UnicodeException(message, idx, file, line);
}

extern(C) {
	void _d_assertm(ModuleInfo* m, uint line) {
		OnAssertError(m.name, line);
	}
	
	void _d_assert_msg(string msg, string file, uint line) {
		OnAssertErrorMessage(file, line, msg);
	}
	
	void _d_assert(string file, uint line) {
		OnAssertError(file, line);
	}

	void _d_unittestm(ModuleInfo* m, uint line) {
		_d_unittest(m.name, line);
	}
	
	void _d_unittest_msg(string msg, string file, uint line) {
		OnUnittestErrorMessage(file, line, msg);
	}
	
	void _d_unittest(string file, uint line) {
		_d_unittest_msg("unittest failure", file, line);
	}

	void _d_array_bounds(ModuleInfo* m, uint line) {
		OnRangeError(m.name, line);
	}
	
	void _d_arraybounds(string file, uint line) {
		OnRangeError(file, line);
	}

	void _d_switch_error(ModuleInfo* m, uint line){
		OnSwitchError(m.name, line);
	}
	
	void _d_hidden_func() {
		Object o;

		asm {
			mov o, RDI;
		}
		
		OnHiddenFuncError(o);
	}
}