module Userspace.Init;

import System.ResourceCaller;
import System.IFace;


class Init {
	public static long Main(string[] args) {
		ulong curproc = ResourceCaller.StaticCall(IFace.Process.OBJECT, [IFace.Process.CURRENT]);
		auto res = new ResourceCaller(curproc, IFace.Process.OBJECT);
		res.Call(IFace.Process.SEND_SIGNAL, [8]);

		import Core.Log;
		Log.Print(args[0]);

		while (true) { }
		return 0;
	}
}