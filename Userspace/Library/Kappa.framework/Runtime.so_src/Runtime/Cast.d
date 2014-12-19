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

module Runtime.Cast;


extern(C) Object _d_toObject(void* p) {
	if(!p)
		return null;
	
	Object o = cast(Object)p;
	ClassInfo oc = typeid(o);
	Interface* pi = **cast(Interface ***)p;

	if (pi.Offset < 0x10000)
		return cast(Object)(p - pi.Offset);
	return o;
}

extern(C) void* _d_interface_cast(void* p, ClassInfo c) {
	if(!p)
		return null;
	
	Interface* pi = **cast(Interface ***)p;
	return _d_dynamic_cast(cast(Object)(p - pi.Offset), c);
}

extern(C) void* _d_dynamic_cast(Object o, ClassInfo c) {
	void* res = null;
	size_t offset = 0;
	if (o && _d_isbaseof2(typeid(o), c, offset))
		res = cast(void *) o + offset;

	return res;
}

extern(C) int _d_isbaseof2(ClassInfo oc, ClassInfo c, ref size_t offset) {
	if(oc is c)
		return true;
	
	do {
		if (oc.Base is c)
			return true;
		
		foreach (iface; oc.Interfaces) {
			if (iface.ClassInfo is c) {
				offset = iface.Offset;
				return true;
			}
		}
		
		foreach (iface; oc.Interfaces) {
			if (_d_isbaseof2(iface.ClassInfo, c, offset)) {
				offset = iface.Offset;
				return true;
			}
		}
		oc = oc.Base;
	} while (oc);
	
	return false;
}

extern(C) int _d_isbaseof(ClassInfo oc, ClassInfo c) {
	if (oc is c)
		return true;
	
	do {
		if (oc.Base is c)
			return true;
		
		foreach (iface; oc.Interfaces)
			if (iface.ClassInfo is c || _d_isbaseof(iface.ClassInfo, c))
				return true;
		
		oc = oc.Base;
	} while (oc);
	
	return false;
}

extern(C) void* _d_interface_vtbl(ClassInfo ic, Object o) {
	assert(o);
	
	foreach (iface; typeid(o).Interfaces)
		if (iface.ClassInfo is ic)
			return cast(void *)iface.VirtualTable;
	
	assert(0);
}