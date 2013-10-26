module Userspace.GUI.Terminal;

import System.IFace;
import System.ResourceCaller;

import System.IO.FileStream;
import System.Threading.Thread;
import System.Diagnostics.Process;
import System.Diagnostics.ProcessStartInfo;


class Terminal {
	public static long Main(string[] args) {
		ulong m, s;
		ResourceCaller.StaticCall(IFace.FSNode.OBJECT, [IFace.FSNode.CREATETTY, cast(ulong)&m, cast(ulong)&s]);
		auto master = new FileStream(m);
		auto slave = new FileStream(s);


		auto startInfo = new ProcessStartInfo();
		startInfo.ThreadEntry = &test;
		startInfo.FileDescriptors = [slave, slave, slave];
		Process.Start(startInfo);

		//auto thr = new Thread(&HandleKeyboard);
		//thr.Start();


		auto o = new FileStream("/dev/pajpa");
		o.Write(cast(byte[])"Test from Terminal!    ", 0);

		byte bb[256];
		while (true) {
			long i = master.Read(bb, 0);
			o.Write(bb[0 .. i], 0);
		}

		return 0;
	}

	static void HandleKeyboard() {
		while (true) {
			
		}
	}
}


//      /\_/\
//     >(^.^)<
//     (")(")
//      |  |
//      |  |
//      |  |
long construct(ulong* pointer) {
	string[] args = (cast(string *)pointer[0])[0 .. pointer[1]];
	return Terminal.Main(args);
}//     |  |
//     (")(")
//        $


//new process
long test(ulong*) {
	ulong curproc = ResourceCaller.StaticCall(IFace.Process.OBJECT, [IFace.Process.CURRENT]);
	auto res = new ResourceCaller(curproc, IFace.Process.OBJECT);

	auto stdin  = new FileStream(res.Call(IFace.Process.GET_FD, [0]));
	auto stdout = new FileStream(res.Call(IFace.Process.GET_FD, [1]));
	auto stderr = new FileStream(res.Call(IFace.Process.GET_FD, [2]));

	stdout.Write(cast(byte[])"Any text from process to stdout", 0);
	return 0;
}