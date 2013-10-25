module Userspace.GUI.GraphicsTest;


class GraphicsTest { //dedit z window triedy
	this() {

	}
}


/* Main class for every program */
class Application {
	public static long Main(string[] args) {
	//	new GraphicsTest();
		return 0;
	}
}



/** this will be automaticaly compiled to every program */
long construct(ulong* pointer) {
	string[] args = (cast(string *)pointer[0])[0 .. pointer[1]];
	return Application.Main(args);
}