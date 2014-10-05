void _d_invariant(Object o) {
	ClassInfo c;
	assert(o !is null);
	
	c = typeid(o);
	do {
		if (c.ClassInvariant) {
			(*c.ClassInvariant)(o);
		}
		c = c.Base;
	} while (c);
}
