module Userspace.GUI.Compositor;


class Compositor {
	public static long Main(string[] args) {
		return 0;
	}
}


long construct(ulong* pointer) {
	string[] args = (cast(string *)pointer[0])[0 .. pointer[1]];
	return Compositor.Main(args);
}