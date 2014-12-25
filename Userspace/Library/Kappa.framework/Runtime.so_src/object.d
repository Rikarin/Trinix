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
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module object;

import Runtime.Monitor;

alias ulong size_t;
alias TypeInfo_Class ClassInfo;

alias immutable(char)[]  string;
alias immutable(wchar)[] wstring;
alias immutable(dchar)[] dstring;


class Object {
	string ToString() {
		return typeid(this)._name;
	}

	size_t GetHashCode() @trusted nothrow {
		return cast(size_t)cast(void *)this;
	}

	int opCmp(Object o) {
		throw new Exception("Need opCmp for class " ~ typeid(this)._name);
	}

	bool opEquals(Object o) {
		return this is o; //TODO
	}
	
	interface Monitor {
		void Lock();
		void Unlock();
	}

	static bool ReferenceEquals(Object objA, Object objB) {
		return objA is objB;
	}
	
	static bool Equals(Object objA, Object objB) {
		if (objA is objB)
			return true;
		
		if (objA is null || objB is null)
			return false;
		
		if (typeid(objA) is typeid(objB) || typeid(objA).opEquals(typeid(objB)))
			return objA.opEquals(objB);

		return objA.opEquals(objB) && objB.opEquals(objA);
	}

	static Object Factory(string classname) {
		auto ci = TypeInfo_Class.Find(classname);
		if (ci)
			return ci.Create();

		return null;
	}
}


bool opEquals(const Object objA, const Object objB) {
	return Object.Equals(cast()objA, cast()objB);
}


bool opEquals(Object objA, Object objB) {
	return Object.Equals(objA, objB);
}


struct Interface {
	private TypeInfo_Class _classinfo;
	private void*[] _vtbl;
	private ulong _offset;

	@property ulong Offset() @safe nothrow pure const {
		return _offset;
	}

	@property void*[] VirtualTable() @safe nothrow pure {
		return _vtbl;
	}

	@property TypeInfo_Class ClassInfo() @safe nothrow pure {
		return _classinfo;
	}
}


struct OffsetTypeInfo {
	private ulong _offset;
	private TypeInfo _ti;
}


class TypeInfo {
    private alias getHash = GetHash;

	override string ToString() const {
		return (cast()super).ToString();
	}
	
	override size_t GetHashCode() @trusted const {
			return cast(size_t)cast(void*)this; //TODO
	}
	
	override int opCmp(Object obj) {
		if (this is obj)
			return 0;
		
		TypeInfo ti = cast(TypeInfo)obj;
		if (ti is null)
			return 1;
		
		return -1; //TODO: dstrcmp
	}
	
	override bool opEquals(Object obj) {
		if (this is obj)
			return true;
		
		auto ti = cast(const TypeInfo)obj;
		return ti && ToString() == ti.ToString();
	}

	size_t GetHash(in void* p) @trusted nothrow const {
		return cast(size_t)p;
	}

	bool Equals(in void* p1, in void* p2) const {
		return p1 == p2;
	}

	int Compare(in void* p1, in void* p2) const {
		return 0;
	}

	@property size_t TSize() nothrow pure const @safe {
		return 0;
	}

	void Swap(void* p1, void* p2) const {
		size_t n = TSize;
		for (size_t i = 0; i < n; i++) {
			byte t = (cast(byte *)p1)[i];
			(cast(byte*)p1)[i] = (cast(byte*)p2)[i];
			(cast(byte*)p2)[i] = t;
		}
	}

	@property inout(TypeInfo) Next() nothrow pure inout {
		return null;
	}

	@property const(void)[] Init() nothrow pure const @safe {
		return null;
	}

	@property uint Flags() nothrow pure const @safe {
		return 0;
	}

	const(OffsetTypeInfo)[] OffTi() const {
		return null;
	}

	void Destroy(void* p) const {

	}

	void Postblit(void* p) const {

	}

	@property size_t TAlign() nothrow pure const @safe {
		return TSize;
	}

	int ArgTypes(out TypeInfo arg1, out TypeInfo arg2) @safe nothrow {
		arg1 = this;
		return 0;
	}

	@property immutable(void)* RTInfo() nothrow pure const @safe {
		return null;
	}
}


class TypeInfo_Typedef : TypeInfo {
	private TypeInfo _base;
	private string _name;
	private void[] _init;

	override string ToString() const {
		return _name;
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto c = cast(const TypeInfo_Typedef)o;
		return c && this._name == c._name && _base == c._base;
	}
	
	/*override size_t GetHash(in void* p) const { return base.GetHash(p); }
	override bool Equals(in void* p1, in void* p2) const { return base.Equals(p1, p2); }
	override int Compare(in void* p1, in void* p2) const { return base.Compare(p1, p2); }
	override @property size_t TSize() nothrow pure const { return base.TSize; }
	override void Swap(void* p1, void* p2) const { return base.Swap(p1, p2); }
	
	override @property inout(TypeInfo) Next() nothrow pure inout { return base.Next; }
	override @property uint Flags() nothrow pure const { return base.Flags; }*/
	@property override const(void)[] Init() nothrow pure const @safe {
		return _init.Length ? _init : _base.Init;
	}
	
	//override @property size_t TAlign() nothrow pure const { return base.TAlign; }
	
	/*override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2)
	{
		return base.ArgTypes(arg1, arg2);
	}
	
	override @property immutable(void)* RTInfo() const { return base.RTInfo; }*/
}


class TypeInfo_Enum : TypeInfo_Typedef {
	
}


class TypeInfo_Pointer : TypeInfo {
	private TypeInfo _next;

	override string ToString() const {
		return _next.ToString() ~ "*";
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto c = cast(const TypeInfo_Pointer)o;
		return c && _next == c._next;
	}
	
	override size_t GetHash(in void* p) @trusted const {
		return cast(size_t) * cast(void **)p;
	}
	
	override bool Equals(in void* p1, in void* p2) const {
		return *cast(void **)p1 == *cast(void **)p2;
	}
	
	override int Compare(in void* p1, in void* p2) const {
		if (*cast(void**)p1 < *cast(void**)p2)
			return -1;
		else if (*cast(void**)p1 > *cast(void**)p2)
			return 1;
		else
			return 0;
	}
	
	override @property size_t TSize() nothrow pure const {
		return (void *).sizeof;
	}
	
	override void Swap(void* p1, void* p2) const {
		void* tmp = *cast(void **)p1;
		*cast(void **)p1 = *cast(void **)p2;
		*cast(void **)p2 = tmp;
	}
	
	@property override inout(TypeInfo) Next() nothrow pure inout { return _next; }
	@property override uint Flags() nothrow pure const { return 1; }
}


class TypeInfo_Array : TypeInfo {
	private TypeInfo _value;

	override string ToString() const {
		return _value.ToString() ~ "[]";
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto c = cast(const TypeInfo_Array)o;
		return c && _value == c._value;
	}
	
	override size_t GetHash(in void* p) @trusted const {
		void[] a = *cast(void[] *)p;
		return 0; //TODO
	}
	
	override bool Equals(in void* p1, in void* p2) const {
		void[] a1 = *cast(void[] *)p1;
		void[] a2 = *cast(void[] *)p2;

		if (a1.Length != a2.Length)
			return false;

		size_t sz = _value.TSize;
		for (size_t i = 0; i < a1.length; i++)
			if (!_value.Equals(a1.ptr + i * sz, a2.ptr + i * sz))
				return false;

		return true;
	}
	
	override int Compare(in void* p1, in void* p2) const {
		void[] a1 = *cast(void[] *)p1;
		void[] a2 = *cast(void[] *)p2;
		size_t sz = _value.TSize;
		size_t len = a1.length;
		
		if (a2.length < len)
			len = a2.length;

		for (size_t u = 0; u < len; u++) {
			int result = _value.Compare(a1.ptr + u * sz, a2.ptr + u * sz);
			if (result)
				return result;
		}
		return cast(int)a1.length - cast(int)a2.length;
	}
	
	override @property size_t TSize() nothrow pure const {
		return (void[]).sizeof;
	}
	
	override void Swap(void* p1, void* p2) const {
		void[] tmp = *cast(void[] *)p1;
		*cast(void[] *)p1 = *cast(void[] *)p2;
		*cast(void[] *)p2 = tmp;
	}
	
	override @property inout(TypeInfo) Next() nothrow pure inout {
		return _value;
	}
	
	override @property uint Flags() nothrow pure const {
		return 1;
	}
	
	override @property size_t TAlign() nothrow pure const {
		return (void[]).alignof;
	}
	
	override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2) {
		arg1 = typeid(size_t);
		arg2 = typeid(void *);
		return 0;
	}
}


class TypeInfo_StaticArray : TypeInfo {
	private TypeInfo _value;
	private size_t _length;

	override string ToString() const {
		return "TODO"; //TODO
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto c = cast(const TypeInfo_StaticArray)o;
		return c && _length == c._length && _value == c._value;
	}
	
	override size_t GetHash(in void* p) @trusted const {
		size_t sz = _value.TSize;
		size_t hash = 0;

		for (size_t i = 0; i < _length; i++)
			hash += _value.GetHash(p + i * sz);

		return hash;
	}
	
	override bool Equals(in void* p1, in void* p2) const {
		size_t sz = _value.TSize;
		
		for (size_t u = 0; u < _length; u++) {
			if (!_value.Equals(p1 + u * sz, p2 + u * sz))
				return false;
		}

		return true;
	}
	
	override int Compare(in void* p1, in void* p2) const {
		size_t sz = _value.TSize;
		
		for (size_t u = 0; u < _length; u++) {
			int result = _value.Compare(p1 + u * sz, p2 + u * sz);
			if (result)
				return result;
		}

		return 0;
	}
	
	override @property size_t TSize() nothrow pure const {
		return _length * _value.TSize;
	}
	
	override void Swap(void* p1, void* p2) const {
		void* tmp;
		size_t sz = _value.TSize;
		ubyte[16] buffer;
		void* pbuffer;
		
		if (sz < buffer.sizeof)
			tmp = buffer.ptr;
		else
			tmp = pbuffer = (new void[sz]).ptr;

		/*for (size_t u = 0; u < len; u += sz) { TODO
			size_t o = u * sz;
			memcpy(tmp, p1 + o, sz);
			memcpy(p1 + o, p2 + o, sz);
			memcpy(p2 + o, tmp, sz);
		}
		if (pbuffer)
			GC.free(pbuffer); */
	}
	
	@property override const(void)[] Init() nothrow pure const {
		return _value.Init;
	}

	@property override inout(TypeInfo) Next() nothrow pure inout {
		return _value;
	}

	@property override uint Flags() nothrow pure const {
		return _value.Flags;
	}
	
	override void Destroy(void* p) const {
		auto sz = _value.TSize;
		p += sz * _length;

		foreach (i; 0 .. _length) {
			p -= sz;
			_value.Destroy(p);
		}
	}
	
	override void Postblit(void* p) const {
		auto sz = _value.TSize;

		foreach (i; 0 .. _length) {
			_value.Postblit(p);
			p += sz;
		}
	}
	
	override @property size_t TAlign() nothrow pure const {
		return _value.TAlign;
	}
	
	override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2) {
		arg1 = typeid(void *);
		return 0;
	}
}


class TypeInfo_AssociativeArray : TypeInfo {
	private TypeInfo _value;
	private TypeInfo _key;
	private TypeInfo _impl;

	override string ToString() const {
		return cast(string)(Next.ToString() ~ "[" ~ _key.ToString() ~ "]");
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto c = cast(const TypeInfo_AssociativeArray)o;
		return c && _key == c._key && _value == c._value;
	}
	
	override bool Equals(in void* p1, in void* p2) @trusted const {
		return !!_aaEqual(this, *cast(const void **) p1, *cast(const void **) p2);
	}
	
	override size_t GetHash(in void* p) nothrow @trusted const {
		return _aaGetHash(cast(void *)p, this);
	}
	
	@property override size_t TSize() nothrow pure const {
		return (char[int]).sizeof;
	}
	
	@property override inout(TypeInfo) Next() nothrow pure inout {
		return _value;
	}

	@property override uint Flags() nothrow pure const {
		return 1;
	}
	
	@property override size_t TAlign() nothrow pure const {
		return (char[int]).alignof;
	}
	
	override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2) {
		arg1 = typeid(void *);
		return 0;
	}
}


class TypeInfo_Vector : TypeInfo {
	private TypeInfo _base;

	override string ToString() const {
		return "__vector(" ~ _base.ToString() ~ ")";
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;
		auto c = cast(const TypeInfo_Vector)o;
		return c && _base == c._base;
	}
	
	/*override size_t GetHash(in void* p) const { return base.GetHash(p); }
	override bool Equals(in void* p1, in void* p2) const { return base.Equals(p1, p2); }
	override int Compare(in void* p1, in void* p2) const { return base.Compare(p1, p2); }
	override @property size_t TSize() nothrow pure const { return base.TSize; }
	override void Swap(void* p1, void* p2) const { return base.Swap(p1, p2); }
	
	override @property inout(TypeInfo) Next() nothrow pure inout { return base.Next; }
	override @property uint Flags() nothrow pure const { return base.Flags; }
	@property override const(void)[] Init() nothrow pure const { return base.Init; }*/
	
	@property override size_t TAlign() nothrow pure const { return 16; }
	
	/*override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2)
	{
		return base.ArgTypes(arg1, arg2);
	}*/
}


class TypeInfo_Function : TypeInfo {
	private TypeInfo _next;
	private string _deco;

	override string ToString() const {
		return cast(string)(_next.ToString() ~ "()");
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto c = cast(const TypeInfo_Function)o;
		return c && _deco == c._deco;
	}
	
	@property override size_t TSize() nothrow pure const {
		return 0;
	}
}


class TypeInfo_Delegate : TypeInfo {
	private TypeInfo _next;
	private string _deco;

	override string ToString() const {
		return cast(string)(_next.ToString() ~ " delegate()");
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto c = cast(const TypeInfo_Delegate)o;
		return c && _deco == c._deco;
	}
	
	@property override size_t TSize() nothrow pure const {
		alias int delegate() dg;
		return dg.sizeof;
	}
	
	@property override uint Flags() nothrow pure const {
		return 1;
	}
	
	@property override size_t TAlign() nothrow pure const {
		alias int delegate() dg;
		return dg.alignof;
	}
	
	override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2) {
		arg1 = typeid(void *);
		arg2 = typeid(void *);
		return 0;
	}
}


class TypeInfo_Class : TypeInfo {
	private byte[] _init;
	private string _name;
	private void*[] _vtbl;
	private Interface[] _interfaces;
	private TypeInfo_Class _base;
	private void* _destructor;
	private void function(Object) _classInvariant;
	private ClassFlags _flags;
	private void* _deallocator;
	private OffsetTypeInfo[] _offTi;
	private void function(Object) _defaultCtor;
	private immutable(void)* _RTInfo;

	private enum ClassFlags : uint {
		IsCOMClass    = 0x01,
		NoPointers    = 0x02,
		HasOffTi      = 0x04,
		HasCtor       = 0x08,
		HasGetMembers = 0x10,
		HasTypeInfo   = 0x20,
		IsAbstract    = 0x40,
		IsCPPClass    = 0x80
	}

	override string ToString() const {
		return Info._name;
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto c = cast(const TypeInfo_Class)o;
		return c && Info._name == c.Info._name;
	}
	
	override size_t GetHash(in void* p) @trusted const {
		auto o = *cast(Object *)p;
		return o ? o.GetHashCode() : 0;
	}
	
	override bool Equals(in void* p1, in void* p2) const {
		Object o1 = *cast(Object *)p1;
		Object o2 = *cast(Object *)p2;
		
		return (o1 is o2) || (o1 && o1.opEquals(o2));
	}
	
	override int Compare(in void* p1, in void* p2) const {
		Object o1 = *cast(Object *)p1;
		Object o2 = *cast(Object *)p2;
		int c = 0;

		if (o1 !is o2) {
			if (o1) {
				if (!o2)
					c = 1;
				else
					c = o1.opCmp(o2);
			} else
				c = -1;
		}
		return c;
	}

	@property string Name() @safe nothrow pure const {
		return _name;
	}

	@property void function(Object) ClassInvariant() @safe nothrow pure const {
		return _classInvariant;
	}

	@property TypeInfo_Class Base() @safe nothrow pure {
		return _base;
	}

	@property Interface[] Interfaces() @safe nothrow pure {
		return _interfaces;
	}

	@property override size_t TSize() nothrow pure const {
		return Object.sizeof;
	}
	
	@property override uint Flags() nothrow pure const {
		return 1;
	}
	
	@property override const(OffsetTypeInfo)[] OffTi() nothrow pure const {
		return _offTi;
	}
	
	@property auto Info() @safe nothrow pure const {
		return this;
	}

	@property auto Typeinfo() @safe nothrow pure const {
		return this;
	}

	@property override immutable(void)* RTInfo() const {
		return _RTInfo;
	}

	static const(TypeInfo_Class) Find(in char[] classname) {
		foreach (m; ModuleInfo) {
			if (m) {
				foreach (c; m.localClasses) {
					if (c._name == classname)
						return c;
				}
			}
		}
		return null;
	}

	Object Create() const {
		if (_flags & 8 && !_defaultCtor)
			return null;

		if (_flags & 64)
			return null;

		/* TODO
		Object o = _d_newclass(this);
		if (m_flags & 8 && defaultConstructor)
			defaultConstructor(o);
		return o;
		*/
		assert (0);
	}
}


class TypeInfo_Interface : TypeInfo {
	private TypeInfo_Class _info;

	override string ToString() const {
		return _info._name;
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto c = cast(const TypeInfo_Interface)o;
		return c && _info._name == typeid(c)._name;
	}
	
	override size_t GetHash(in void* p) @trusted const {
		Interface* pi = **cast(Interface ***)*cast(void **)p;
		Object o = cast(Object)(*cast(void **)p - pi._offset);

		assert(o);
		return o.GetHashCode();
	}
	
	override bool Equals(in void* p1, in void* p2) const {
		Interface* pi = **cast(Interface ***)*cast(void **)p1;
		Object o1 = cast(Object)(*cast(void **)p1 - pi._offset);
		pi = **cast(Interface ***)*cast(void **)p2;
		Object o2 = cast(Object)(*cast(void **)p2 - pi._offset);
		
		return o1 == o2 || (o1 && o1.opCmp(o2) == 0);
	}

	override int Compare(in void* p1, in void* p2) const {
		Interface* pi = **cast(Interface ***)*cast(void **)p1;
		Object o1 = cast(Object)(*cast(void **)p1 - pi._offset);
		pi = **cast(Interface ***)*cast(void **)p2;
		Object o2 = cast(Object)(*cast(void **)p2 - pi._offset);
		int c = 0;

		if (o1 != o2) {
			if (o1) {
				if (!o2)
					c = 1;
				else
					c = o1.opCmp(o2);
			} else
				c = -1;
		}
		return c;
	}
	
	@property override size_t TSize() nothrow pure const {
		return Object.sizeof;
	}
	
	@property override uint Flags() nothrow pure const {
		return 1;
	}
}


class TypeInfo_Struct : TypeInfo {
	private string _name;
	private void[] _init;
	
	@safe pure nothrow {
		private ulong function(in void*) _xtoHash;
		private bool function(in void*, in void*) _xopEquals;
		private int function(in void*, in void*) _xopCmp;
		private char[] function(in void*) _xtoString;
		
		private StructFlags _flags;
	}
	
	private void function(void*) _xdtor;
	private void function(void*) _xpostblit;
	private uint _align;
	
	private TypeInfo _arg1;
	private TypeInfo _arg2;
	private immutable(void)* _RTInfo;
	
	
	enum StructFlags : uint {
		HasPointers = 0x01
	}

	override string ToString() const {
		return _name;
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;

		auto s = cast(const TypeInfo_Struct)o;
		return s && _name == s._name && Init.Length == s.Init.Length;
	}
	
	override size_t GetHash(in void* p) @safe pure nothrow const {
		assert(p);

		/*if (_xtoHash) TODO
			return (*_xtoHash)(p);
		else
			return HashOf(p, Init.Length);*/

		assert(false);
	}
	
	override bool Equals(in void* p1, in void* p2) @trusted pure nothrow const {
		if (!p1 || !p2)
			return false;

		else if (_xopEquals)
			return (*_xopEquals)(p1, p2);
	
		else if (p1 == p2)
			return true;

		assert(false);//TODO: return memcmp(p1, p2, init().length) == 0;
	}
	
	override int Compare(in void* p1, in void* p2) @trusted pure nothrow const {
		if (p1 != p2) {
			if (p1) {
				if (!p2)
					return true;

				else if (_xopCmp)
					return (*_xopCmp)(p2, p1);

				assert(false);//TODO return memcmp(p1, p2, init().length);
			} else
				return -1;
		}
		return 0;
	}
	
	@property override size_t TSize() nothrow pure const {
		return Init.Length;
	}
	
	@property override const(void)[] Init() nothrow pure const @safe {
		return _init;
	}
	
	@property override uint Flags() nothrow pure const {
		return _flags;
	}
	
	@property override size_t TAlign() nothrow pure const {
		return _align;
	}
	
	override void Destroy(void* p) const {
		if (_xdtor)
			(*_xdtor)(p);
	}
	
	override void Postblit(void* p) const {
		if (_xpostblit)
			(*_xpostblit)(p);
	}

	@property override immutable(void)* RTInfo() const {
		return _RTInfo;
	}

	override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2) {
		arg1 = _arg1;
		arg2 = _arg2;
		return 0;
	}
}


class TypeInfo_Tuple : TypeInfo {
	private TypeInfo[] _elements;
	
	override string ToString() const {
		string s = "(";
		foreach (i, element; _elements) {
			if (i)
				s ~= ',';
			s ~= element.ToString();
		}
		s ~= ")";
		return s;
	}
	
	override bool opEquals(Object o) {
		if (this is o)
			return true;
		
		auto t = cast(const TypeInfo_Tuple)o;
		if (t && _elements.Length == t._elements.Length) {
			for (size_t i = 0; i < _elements.Length; i++) {
				if (_elements[i] != t._elements[i])
					return false;
			}
			return true;
		}
		return false;
	}
	
	override size_t GetHash(in void* p) const {
		assert(false);
	}
	
	override bool Equals(in void* p1, in void* p2) const {
		assert(false);
	}
	
	override int Compare(in void* p1, in void* p2) const {
		assert(false);
	}
	
	@property override size_t TSize() nothrow pure const {
		assert(false);
	}
	
	override void Swap(void* p1, void* p2) const {
		assert(false);
	}
	
	override void Destroy(void* p) const {
		assert(false);
	}
	
	override void Postblit(void* p) const {
		assert(false);
	}
	
	@property override size_t TAlign() nothrow pure const {
		assert(false);
	}
	
	override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2) {
		assert(false);
	}
}


class TypeInfo_Const : TypeInfo {
	TypeInfo _base;

	override string ToString() const {
		return cast(string)("const(" ~ _base.ToString() ~ ")");
	}

	override bool opEquals(Object o) {
		if (this is o)
			return true;
		
		if (typeid(this) != typeid(o))
			return false;
		
		auto t = cast(TypeInfo_Const)o;
		return _base.opEquals(t._base);
	}
	
	/*override size_t GetHash(in void *p) const { return base.GetHash(p); }
	override bool Equals(in void *p1, in void *p2) const { return base.Equals(p1, p2); }
	override int Compare(in void *p1, in void *p2) const { return base.Compare(p1, p2); }
	override @property size_t TSize() nothrow pure const { return base.TSize; }
	override void Swap(void *p1, void *p2) const { return base.Swap(p1, p2); }
	
	override @property inout(TypeInfo) Next() nothrow pure inout { return base.Next; }
	override @property uint Flags() nothrow pure const { return base.Flags; }
	@property override const(void)[] Init() nothrow pure const { return base.Init; }
	
	override @property size_t TAlign() nothrow pure const { return base.TAlign; }
	
	override int ArgTypes(out TypeInfo arg1, out TypeInfo arg2)
	{
		return base.ArgTypes(arg1, arg2);
	}*/
}


class TypeInfo_Invariant : TypeInfo_Const {
	override string ToString() const {
		return cast(string)("immutable(" ~ _base.ToString() ~ ")");
	}
}


class TypeInfo_Shared : TypeInfo_Const {
	override string ToString() const {
		return cast(string)("shared(" ~ _base.ToString() ~ ")");
	}
}


class TypeInfo_Inout : TypeInfo_Const {
	override string ToString() const {
		return cast(string)("inout(" ~ _base.ToString() ~ ")");
	}
}


//======================================================================================================================
//                                             ====== MemberInfo ======
//======================================================================================================================
abstract class MemberInfo {
	@property string Name() nothrow pure;
}


class MemberInfo_field : MemberInfo {
	private string _name;
	private TypeInfo _typeinfo;
	private size_t _offset;

	this(string name, TypeInfo ti, size_t offset) {
		_name     = name;
		_typeinfo = ti;
		_offset   = offset;
	}
	
	@property override string Name() nothrow pure {
		return _name;
	}

	@property TypeInfo Typeinfo() nothrow pure {
		return _typeinfo;
	}

	@property size_t Offset() nothrow pure {
		return _offset;
	}
}


class MemberInfo_function : MemberInfo {
	private string _name;
	private TypeInfo _typeinfo;
	private void* _fp;
	private uint _flags;

	this(string name, TypeInfo ti, void* fp, uint flags) {
		_name     = name;
		_typeinfo = ti;
		_fp       = fp;
		_flags    = flags;
	}
	
	@property override string Name() nothrow pure {
		return _name;
	}

	@property TypeInfo Typeinfo() nothrow pure {
		return _typeinfo;
	}

	@property void* FP() nothrow pure {
		return _fp;
	}

	@property uint Flags() nothrow pure {
		return _flags;
	}
}


//======================================================================================================================
//                                              ====== Throwable ======
//======================================================================================================================
alias Throwable.TraceInfo function(void* ptr) TraceHandler;
private __gshared TraceHandler traceHandler = null;


class Throwable : Object {
	protected string _message;
	protected string _file;
	protected size_t _line;
	protected TraceInfo _info;
	protected Throwable _next;

	interface TraceInfo {
		int opApply(scope int delegate(ref const(char[]))) const;
		int opApply(scope int delegate(ref size_t, ref const(char[]))) const;
		string ToString() const;
	}
	
	@safe pure nothrow this(string message, Throwable next = null) {
		_message = message;
		_next = next;
	}
	
	@safe pure nothrow this(string message, string file, size_t line, Throwable next = null) {
		this(message, next);
		_file = file;
		_line = line;
	}

	override string ToString() {
		assert(false); //TODO
	}
}


extern (C) void  rt_setTraceHandler(TraceHandler h) {
	traceHandler = h;
}

extern (C) TraceHandler rt_getTraceHandler() {
	return traceHandler;
}

extern (C) Throwable.TraceInfo _d_traceContext(void* ptr = null) {
	if (traceHandler is null)
		return null;

	return traceHandler(ptr);
}


class Exception : Throwable {
	@safe pure nothrow this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super(message, file, line, next);
	}
	
	@safe pure nothrow this(string message, Throwable next, string file = __FILE__, size_t line = __LINE__) {
		super(message, file, line, next);
	}
}


class Error : Throwable {
	private Throwable _bypassedException;

	@safe pure nothrow this(string message, Throwable next = null) {
		super(message, next);
		_bypassedException = null;
	}
	
	@safe pure nothrow this(string message, string file, size_t line, Throwable next = null) {
		super(message, file, line, next);
		_bypassedException = null;
	}
}


//======================================================================================================================
//                                             ====== ModuleInfo ======
//======================================================================================================================
enum {
	MIctorstart       = 0x01,
	MIctordone        = 0x02,
	MIstandalone      = 0x04,
	MItlsctor         = 0x08,
	MItlsdtor         = 0x10,
	MIctor            = 0x20,
	MIdtor            = 0x40,
	MIxgetMembers     = 0x80,
	MIictor           = 0x100,
	MIunitTest        = 0x200,
	MIimportedModules = 0x400,
	MIlocalClasses    = 0x800,
	MIname            = 0x1000
}


struct ModuleInfo {
	alias int delegate(ref ModuleInfo*) ApplyDg;
	private uint _flags;
	private uint _index;
	
	private void* AddrOf(int flag) nothrow pure in {
		assert(flag >= MItlsctor && flag <= MIname);
		assert(!(flag & (flag - 1)) && !(flag & ~(flag - 1) << 1));
	} body {
		void* p = cast(void*)&this + ModuleInfo.sizeof;
		
		if (_flags & MItlsctor) {
			if (flag == MItlsctor)
				return p;

			p += typeof(TlsCtor).sizeof;
		}

		if (_flags & MItlsdtor) {
			if (flag == MItlsdtor)
				return p;

			p += typeof(TlsDtor).sizeof;
		}

		if (_flags & MIctor) {
			if (flag == MIctor)
				return p;

			p += typeof(Ctor).sizeof;
		}

		if (_flags & MIdtor) {
			if (flag == MIdtor)
				return p;

			p += typeof(Dtor).sizeof;
		}

		if (_flags & MIxgetMembers) {
			if (flag == MIxgetMembers)
				return p;

			p += typeof(XGetMembers).sizeof;
		}

		if (_flags & MIictor) {
			if (flag == MIictor)
				return p;

			p += typeof(ICtor).sizeof;
		}

		if (_flags & MIunitTest) {
			if (flag == MIunitTest)
				return p;

			p += typeof(UnitTest).sizeof;
		}

		if (_flags & MIimportedModules) {
			if (flag == MIimportedModules)
				return p;

			p += size_t.sizeof + *cast(size_t *)p * typeof(importedModules[0]).sizeof;
		}

		if (_flags & MIlocalClasses) {
			if (flag == MIlocalClasses)
				return p;

			p += size_t.sizeof + *cast(size_t *)p * typeof(localClasses[0]).sizeof;
		}

		if (true || _flags & MIname) {
			if (flag == MIname)
				return p;

			//TODO p += strlen(cast(immutable char*)p);
		}

		assert(false);
	}
	
	@property uint Index() nothrow pure {
		return _index;
	}

	@property void Index(uint i) nothrow pure {
		_index = i;
	}
	
	@property uint Flags() nothrow pure {
		return _flags;
	}

	@property void Flags(uint f) nothrow pure {
		_flags = f;
	}
	
	@property void function() TlsCtor() nothrow pure {
		return _flags & MItlsctor ? *cast(typeof(return) *)AddrOf(MItlsctor) : null;
	}
	
	@property void function() TlsDtor() nothrow pure {
		return _flags & MItlsdtor ? *cast(typeof(return) *)AddrOf(MItlsdtor) : null;
	}
	
	@property void* XGetMembers() nothrow pure {
		return _flags & MIxgetMembers ? *cast(typeof(return) *)AddrOf(MIxgetMembers) : null;
	}

	@property void function() Ctor() nothrow pure {
		return _flags & MIctor ? *cast(typeof(return) *)AddrOf(MIctor) : null;
	}
	
	@property void function() Dtor() nothrow pure {
		return _flags & MIdtor ? *cast(typeof(return) *)AddrOf(MIdtor) : null;
	}
	
	@property void function() ICtor() nothrow pure {
		return _flags & MIictor ? *cast(typeof(return) *)AddrOf(MIictor) : null;
	}
	
	@property void function() UnitTest() nothrow pure {
		return _flags & MIunitTest ? *cast(typeof(return) *)AddrOf(MIunitTest) : null;
	}
	
	@property ModuleInfo*[] importedModules() nothrow pure {
		if (_flags & MIimportedModules) {
			auto p = cast(size_t *)AddrOf(MIimportedModules);
			return (cast(ModuleInfo **)(p + 1))[0 .. *p];
		}

		return null;
	}
	
	@property TypeInfo_Class[] localClasses() nothrow pure
	{
		if (_flags & MIlocalClasses)
		{
			auto p = cast(size_t*)AddrOf(MIlocalClasses);
			return (cast(TypeInfo_Class*)(p + 1))[0 .. *p];
		}
		return null;
	}
	
	@property string name() nothrow pure {
		/*
		if (true || flags & MIname) // always available for now
		{
			auto p = cast(immutable char*)addrOf(MIname);
			return p[0 .. .strlen(p)];
		}
		*/
		return null; //TODO
	}
	
	static int opApply(scope ApplyDg dg) {
		//return rt.minfo.moduleinfos_apply(dg);
		return 0; //TODO
	}
}


//======================================================================================================================
//                                               ====== Monitor ======
//======================================================================================================================
Monitor* GetMonitor(Object obj) pure nothrow {
	return cast(Monitor *) obj.__monitor;
}

void SetMonitor(Object obj, Monitor* monitor) pure nothrow {
	obj.__monitor = monitor;
}

/*void setSameMutex(shared Object ownee, shared Object owner) nothrow in {
	assert(ownee.__monitor is null);
} body {
	auto m = cast(shared(Monitor)*) owner.__monitor;
	
	if (m is null)
	{
		_d_monitor_create(cast(Object) owner);
		m = cast(shared(Monitor)*) owner.__monitor;
	}
	
	auto i = m._impl;
	if (i is null)
	{
		ownee.__monitor = owner.__monitor;
		return;
	}
	// If m.impl is set (ie. if this is a user-created monitor), assume
	// the monitor is garbage collected and simply copy the reference.
	ownee.__monitor = owner.__monitor;
}*/


extern (C) void _d_monitordelete(Object obj, bool det) {
	Monitor* m = GetMonitor(obj);
	
	if (m !is null) {
		IMonitor i = m.impl;
		if (i is null) {
			auto s = cast(shared(Monitor)*) m;

			/*if(!atomicOp!("-=")(s.refs, cast(ulong) 1)) { TODO
				_d_monitor_devt(m, obj);
				_d_monitor_destroy(obj);
				setMonitor(obj, null);
			}*/

			return;
		}

		SetMonitor(obj, null);
	}
}

extern (C) void _d_monitorenter(Object h) {
	Monitor* m = GetMonitor(h);
	
	if (m is null) {
		_d_monitor_create(h);
		m = GetMonitor(h);
	}
	
	IMonitor i = m.impl;
	if (i is null) {
		_d_monitor_lock(h);
		return;
	}
	i.Lock();
}

extern (C) void _d_monitorexit(Object h) {
	Monitor* m = GetMonitor(h);
	IMonitor i = m.impl;
	
	if (i is null) {
		_d_monitor_unlock(h);
		return;
	}
	i.Unlock();
}

extern (C) void _d_monitor_devt(Monitor* m, Object h) {
	if (m.devt.Length) {
		DEvent[] devt;
		
		synchronized (h) {
			devt = m.devt;
			m.devt = null;
		}

		foreach (v; devt) {
			if (v)
				v(h);
		}

		//TODO free(_devt.ptr);
	}
}

extern (C) void rt_attachDisposeEvent(Object h, DEvent e) {
	synchronized (h) {
		Monitor* m = GetMonitor(h);
		assert(m.impl is null);
		
		foreach (ref v; m.devt) {
			if (v is null || v == e) {
				v = e;
				return;
			}
		}
		
		auto len = m.devt.Length + 4;
		auto pos = m.devt.Length;
		auto p = cast(void *)null;//TODO: realloc(m.devt.ptr, DEvent.sizeof * len);
		m.devt = (cast(DEvent *)p)[0 .. len];
		m.devt[pos + 1 .. len] = null;
		m.devt[pos] = e;
	}
}

extern (C) void rt_detachDisposeEvent(Object h, DEvent e) {
	synchronized (h) {
		Monitor* m = GetMonitor(h);
		assert(m.impl is null);
		
		foreach (p, v; m.devt) {
			if (v == e) {
				/*memmove(&m.devt[p], TODO
				&m.devt[p+1],
				(m.devt.length - p - 1) * DEvent.sizeof);*/
				m.devt[$ - 1] = null;
				return;
			}
		}
	}
}

extern (C) { //TODO import....
	// from druntime/src/rt/aaA.d
	size_t _aaLen(in void* p) pure nothrow;
	void* _aaGetX(void** pp, const TypeInfo keyti, in size_t valuesize, in void* pkey);
	inout(void)* _aaGetRvalueX(inout void* p, in TypeInfo keyti, in size_t valuesize, in void* pkey);
	inout(void)[] _aaValues(inout void* p, in size_t keysize, in size_t valuesize) pure nothrow;
	inout(void)[] _aaKeys(inout void* p, in size_t keysize) pure nothrow;
	void* _aaRehash(void** pp, in TypeInfo keyti) pure nothrow;
	
	extern (D) alias scope int delegate(void *) _dg_t;
	int _aaApply(void* aa, size_t keysize, _dg_t dg);
	
	extern (D) alias scope int delegate(void *, void *) _dg2_t;
	int _aaApply2(void* aa, size_t keysize, _dg2_t dg);
	
	private struct AARange { void* impl, current; }
	AARange _aaRange(void* aa);
	bool _aaRangeEmpty(AARange r);
	void* _aaRangeFrontKey(AARange r);
	void* _aaRangeFrontValue(AARange r);
	void _aaRangePopFront(ref AARange r);
	
	int _aaEqual(in TypeInfo tiRaw, in void* e1, in void* e2);
	size_t _aaGetHash(in void* aa, in TypeInfo tiRaw) nothrow;
}


struct AssociativeArray(Key, Value) {
	private void* _p;

	@property size_t Length() const {
		return _aaLen(p);
	}
	
	Value[Key] ReHash() {
		auto p = _aaRehash(cast(void **) &p, typeid(Value[Key]));
		return *cast(Value[Key] *)(&p);
	}
	
	@property private inout(Value)[] inout_values() inout {
		auto a = _aaValues(p, Key.sizeof, Value.sizeof);
		return *cast(inout Value[] *) &a;
	}
	
	@property private inout(Key)[] inout_keys() inout {
		auto a = _aaKeys(p, Key.sizeof);
		return *cast(inout Key[] *) &a;
	}
	
	@property Value[] Values() {
		return inout_values;
	}
	
	@property Key[] Keys() {
		return inout_keys;
	}
	
	@property const(Value)[] Values() const {
		return inout_values;
	}
	
	@property const(Key)[] Keys() const {
		return inout_keys;
	}
	
	int opApply(scope int delegate(ref Key, ref Value) dg) {
		return _aaApply2(p, Key.sizeof, cast(_dg2_t)dg);
	}
	
	int opApply(scope int delegate(ref Value) dg) {
		return _aaApply(p, Key.sizeof, cast(_dg_t)dg);
	}
	
	Value Get(Key key, lazy Value defaultValue) {
		auto p = key in *cast(Value[Key] *)(&p);
		return p ? *p : defaultValue;
	}
	
	static if (is(typeof({
		ref Value Get();
		Value[Key] r;
		r[Key.init] = Get();
	}))) {
		Value[Key] Dup() {
			Value[Key] result;
			foreach (k, v; this)
				result[k] = v;

			return result;
		}
	} else
		@disable Value[Key] Dup();
	
	auto ByKey() {
		static struct Result {
			AARange r;
			
			@property bool Empty() {
				return _aaRangeEmpty(r);
			}

			@property ref Key Front() {
				return *cast(Key *)_aaRangeFrontKey(r);
			}

			void PopFront() {
				_aaRangePopFront(r);
			}

			Result Save() {
				return this;
			}
		}
		
		return Result(_aaRange(p));
	}
	
	auto ByValue() {
		static struct Result {
			AARange r;
			
			@property bool Empty() {
				return _aaRangeEmpty(r);
			}

			@property ref Value Front() {
				return *cast(Value *)_aaRangeFrontValue(r);
			}

			void PopFront() {
				_aaRangePopFront(r);
			}

			Result Save() {
				return this;
			}
		}
		
		return Result(_aaRange(p));
	}
}


void Destroy(T)(T obj) if (is(T == class)) {
	rt_finalize(cast(void *)obj);
}

void destroy(T)(T obj) if (is(T == interface)) {
	Destroy(cast(Object)obj);
}

void Destroy(T)(ref T obj) if (is(T == struct)) {
	typeid(T).Destroy(&obj);
	auto buf = (cast(ubyte *) &obj)[0 .. T.sizeof];
	auto init = cast(ubyte[])typeid(T).init();

	if(init.ptr is null)
		buf[] = 0;
	else
		buf[] = init[];
}

void Destroy(T : U[n], U, size_t n)(ref T obj) if (!is(T == struct)) {
	obj[] = U.init;
}

void Destroy(T)(ref T obj) if (!is(T == struct) && !is(T == interface) && !is(T == class) && !_isStaticArray!T) {
	obj = T.init;
}

template _isStaticArray(T : U[N], U, size_t N) {
	enum bool _isStaticArray = true;
}

template _isStaticArray(T) {
	enum bool _isStaticArray = false;
}

@property size_t Capacity(T)(T[] arr) pure nothrow {
	return _d_arraysetcapacity(typeid(T[]), 0, cast(void *)&arr);
}

size_t Reserve(T)(ref T[] arr, size_t newcapacity) pure nothrow @trusted
{
	return _d_arraysetcapacity(typeid(T[]), newcapacity, cast(void *)&arr);
}

auto ref inout(T[]) AssumeSafeAppend(T)(auto ref inout(T[]) arr) {
	_d_arrayshrinkfit(typeid(T[]), *(cast(void[] *)&arr));
	return arr;
}

bool _ArrayEq(T1, T2)(T1[] a1, T2[] a2) {
	if (a1.Length != a2.Length)
		return false;

	foreach(i, a; a1) {
		if (a != a2[i])
			return false;
	}
	return true;
}

bool _xopEquals(in void*, in void*) {
	throw new Exception("TypeInfo.equals is not implemented");
}

bool _xopCmp(in void*, in void*) {
	throw new Exception("TypeInfo.compare is not implemented");
}

template RTInfo(T) {
	enum RTInfo = null;
}

@property long Length(T)(T obj) {
	return obj.length;
}