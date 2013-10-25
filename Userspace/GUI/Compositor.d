module Userspace.GUI.Compositor;

import Userspace.Libs.Graphics;
import System.IO.Directory;


class Compositor {
private:
	Graphics ctx;
	Graphics selectCtx;


public:
	this() {
		ctx = new Graphics();
		selectCtx = new Graphics(true);

		auto pipe = Directory.CreatePipe();
		//init request system

		while (true) { }
	}
}


/* Main class for every program */
class Application {
	public static long Main(string[] args) {
		new Compositor();
		return 0;
	}
}



/** this will be automaticaly compiled to every program */
long construct(ulong* pointer) {
	string[] args = (cast(string *)pointer[0])[0 .. pointer[1]];
	return Application.Main(args);
}