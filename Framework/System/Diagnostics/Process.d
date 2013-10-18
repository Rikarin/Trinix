module System.Diagnostics.Process;

import System.IFace;
import System.ResourceCaller;

import System.Diagnostics.ProcessStartInfo;


class Process {
	static Process Start(ProcessStartInfo startInfo) {
		ResourceCaller.StaticCall(IFace.Process.OBJECT, [IFace.Process.S_CREATE, cast(ulong)&startInfo]);

		return new Process();
	}
}