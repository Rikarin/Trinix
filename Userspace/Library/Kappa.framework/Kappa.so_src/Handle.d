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

module Handle;


final class Handle {
	private long _id;
	private long _type;
	
	private this(long id) {
		_id = id;
	}

	this() {} //testing...
	
	@property long Type() { //TODO: use enum against long
		if (!_type)
			_type = Call(0);

		new int[50];
		
		return _type;
	}
	
	long Call(long id, long param1 = 0, long param2 = 0, long param3 = 0, long param4 = 0, long param5 = 0) {
		return _Call(_id, id, param1, param2, param3, param4, param5);
	}
	
	static Handle StaticCall(long id, long param1 = 0, long param2 = 0, long param3 = 0, long param4 = 0, long param5 = 0) {
		long handle = _Call(0xFFFFFFFF_FFFFFFFF, id, param1, param2, param3, param4, param5);
		
		if (handle != -1 && handle)
			return new Handle(handle);
		
		return null;
	}
	
	private static ulong _Call(long resource, long id, long param1, long param2, long param3, long param4, long param5) {
		asm {
			"mov R9, %0" : : "r"(resource);
			"mov R8, %0" : : "r"(id);
			"syscall" : "=a"(resource) : "D"(param1), "S"(param2), "d"(param3), "b"(param4), "a"(param5) : "r8", "r9";
		}
		
		return resource;
	}
}