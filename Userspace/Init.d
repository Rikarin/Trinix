module Userspace.Init;

import System.IO.FileStream;

import System.IFace;
import System.ResourceCaller;


class Init {
	public static long Main(string[] args) {
		auto fs = new FileStream("/dev/pajpa");
		
		foreach (x; args)
			fs.Write(cast(byte[])("\n args: " ~ x), 0);


//		ulong master, slave;
//		ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.CREATETTY, cast(ulong)&master, cast(ulong)&slave]);

//		auto m = new FileStream(master);
//		auto s = new FileStream(slave);

//		m.Write(cast(byte[])"Test from Init!", 0);

		//byte[10] bb;
		//m.Read(bb, 0);

		while (true) { }
		return 0;
	}
}


long construct(ulong* pointer) {
	string[] args = (cast(string *)pointer[0])[0 .. pointer[1]];
	return Init.Main(args);
}


/*

ulong curproc = ResourceCaller.StaticCall(IFace.Process.OBJECT, [IFace.Process.CURRENT]);
auto res = new ResourceCaller(curproc, IFace.Process.OBJECT);

res.Call(IFace.Process.SET_HANDLER, [8, cast(ulong)&signalHandler]);
res.Call(IFace.Process.SEND_SIGNAL, [8]);


void signalHandler() {

}

*/