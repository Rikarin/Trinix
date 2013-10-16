module Userspace.Init;

import System.IO.FileStream;

class Init {
	public static long Main(string[] args) {
		auto fs = new FileStream("/dev/pajpa");
		fs.Write(cast(byte[])"Test from Init lol!", 0);

	//	while (true) { }
		return 0;
	}
}



/*

ulong curproc = ResourceCaller.StaticCall(IFace.Process.OBJECT, [IFace.Process.CURRENT]);
auto res = new ResourceCaller(curproc, IFace.Process.OBJECT);

res.Call(IFace.Process.SET_HANDLER, [8, cast(ulong)&signalHandler]);
res.Call(IFace.Process.SEND_SIGNAL, [8]);


void signalHandler() {

}

*/