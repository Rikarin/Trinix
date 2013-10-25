module Userspace.GUI.Compositor;

import Userspace.Libs.Graphics;
import System.IO.Directory;
import System.IO.FileStream;

import System.Diagnostics.Process;
import System.Diagnostics.ProcessStartInfo;

static import Userspace.GUI.GraphicsTest;

class Compositor {
private:
	Graphics ctx;
	Graphics selectCtx;
	FileStream requestPipe;

public:
	this() {
		ctx = new Graphics();
		selectCtx = new Graphics(true);

		requestPipe = Directory.CreatePipe("/dev/compositor");



		auto startInfo = new ProcessStartInfo();
		startInfo.ThreadEntry = &Userspace.GUI.GraphicsTest.construct;
		Process.Start(startInfo);

		while (true) {
			ProcessRequest();
		}
	}



	private void ProcessRequest() {
		byte data[5];
		long i;
		while (i != data.length)
			i += requestPipe.Read(data[i .. $], 0);
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