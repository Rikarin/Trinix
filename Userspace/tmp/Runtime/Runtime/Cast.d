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