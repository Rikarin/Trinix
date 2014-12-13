/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Runtime.Core.Exception;


alias AssertHandler = void function(string file, size_t line, string msg) nothrow;
private __gshared AssertHandler _assertHandler = null;


@property AssertHandler AssertHandle() @trusted nothrow {
	return _assertHandler;
}

@property void AssertHandle(AssertHandler handler) @trusted nothrow {
	_assertHandler = handler;
}




class RangeError : Error {
	@safe pure nothrow this(string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("Range violation", file, line, next);
	}
}


class AssertError : Error {
	@safe pure nothrow this(string file, size_t line) {
		this(cast(Throwable)null, file, line);
	}
	
	@safe pure nothrow this(Throwable next, string file = __FILE__, size_t line = __LINE__) {
		this("Assertion failure", file, line, next);
	}
	
	@safe pure nothrow this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super(message, file, line, next);
	}
}


class FinalizeError : Error {
	private ClassInfo _info;
	
	@safe pure nothrow this(ClassInfo ci, Throwable next, string file = __FILE__, size_t line = __LINE__) {
		this(ci, file, line, next);
	}
	
	@safe pure nothrow this(ClassInfo ci, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("Assertion failure", file, line, next);
		_info = ci;
	}

	@safe override const string ToString() {
		return "An exception was thrown while finalizing an instance of class " ~ _info.Name;
	}
}


class HiddenFuncError : Error {
	@safe pure nothrow this(ClassInfo ci) {
		super("Hidden method called for " ~ ci.Name);
	}
}


class OutOfMemoryError : Error {
	@safe pure nothrow this(string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("Memory allocation failed", file, line, next);
	}
	
	@trusted override const string ToString() {
		return _message.ptr ? (cast()super).ToString() : "Memory allocation failed";
	}
}


class InvalidMemoryOperationError : Error {
	@safe pure nothrow this(string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("Invalid memory operation", file, line, next);
	}
	
	@trusted override const string ToString() {
		return _message.ptr ? (cast()super).ToString() : "Invalid memory operation";
	}
}


class SwitchError : Error {
	@safe pure nothrow this(string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("No appropriate switch clause found", file, line, next);
	}
}


class UnicodeException : Exception {
	private size_t _idx;
	
	this(string msg, size_t idx, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @safe pure nothrow {
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