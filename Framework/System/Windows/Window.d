module System.Windows.Window;

import System.IO.FileStream;
import System.IO.Directory;
import Userspace.Libs.Graphics;
import System.Collections.Generic.List;
import System.Diagnostics.Process;


class Window {
protected:
	Graphics ctx;
	ProcessWindows pwins; //static...

	FileStream eventPipe;
	FileStream mouseEventPipe;

	ushort Width;
	ushort Height;


	struct ProcessWindows {
		Process compositor;
		FileStream eventPipe;
		FileStream commandPipe;
		List!byte windows;
	}


public:
	this() {
		//connect root process
		if (pwins.windows is null) {
			pwins.windows     = new List!byte();
			pwins.eventPipe   = Directory.CreatePipe();
			pwins.commandPipe = Directory.CreatePipe();
			
			auto curProc      = Process.Current;
			auto compositor   = new FileStream("/dev/compositor");
			//compositor.Write(cast(byte[])[curProc.ResID(), pwins.eventPipe.ResID(), pwins.eventPipe.ResID()], 0);
			compositor.Write(cast(byte[])"hovno vole", 0);

			byte[4] pid;
		//	pwins.commandPipe.Read(pid, 0);
		//	pwins.compositor  = new Process(cast(ulong)*pid.ptr);

			curProc.SetSingalHanlder(SigNum.SIGWINEVENT, &SignalEvent);
		}

		ctx            = new Graphics(true);
		eventPipe      = Directory.CreatePipe();
		mouseEventPipe = Directory.CreatePipe();
	}


private:
	void SignalEvent() {

	}


	class FormStyle {
	static:
		void RenderDecorationSimple(Window win) {
			foreach (i; 0 .. win.Height) {
				win.ctx.Pixel(0, i) = 0x3E3E3E;
				win.ctx.Pixel(win.Width - 1, i) = 0x3E3E3E;
			}

			foreach (i; 1 .. 24) {
				foreach (j; 1 .. win.Width - 1) {
					win.ctx.Pixel(j, i) = 0xB4B4B4;
				}
			}

			foreach (i; 0 .. win.Width) {
				win.ctx.Pixel(i, 0) = 0x3E3E3E;
				win.ctx.Pixel(i, 24 - 1) = 0x3E3E3E;
				win.ctx.Pixel(i, win.Height - 1) = 0x3E3E3E;
			}
		}
	}
}