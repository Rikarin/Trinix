module System.Windows.Window;

import System.IO.FileStream;
import System.IO.Directory;
import Userspace.Libs.Graphics;
import System.Collections.Generic.List;
import System.Diagnostics.Process;
import System.Convert;


class Window {
protected:
	Graphics ctx;
	ProcessWindows pwins; //static...

	FileStream eventPipe;
	FileStream mouseEventPipe;

	ushort Width;
	ushort Height;


public:
	enum Commands {
		NewWindow,
		Resize,
		Destroy,
		Damage,
		Redraw,
		Reorder,
		SetAlpha
	}

	enum Events {
		KeyDown       = 0x10,
		KeyUp         = 0x11,
		MouseMove     = 0x20,
		MouseEnter    = 0x21,
		MouseLeave    = 0x22,
		MouseClick    = 0x23,
		MouseUp       = 0x24,
		WindowNew     = 0x30,
		WindowResized = 0x31,
		WindowsClosed = 0x32,
		WindowRedrawn = 0x33,
		WindowsFocus  = 0x34,

		/** Groups */
		GroupMask     = 0xF0,
		KeyEvent      = 0x10,
		MouseEvent    = 0x20,
		WindowEvent   = 0x30
	}


	struct ProcessWindows {
		Process id;
		FileStream eventPipe;
		FileStream commandPipe;
		List!byte windows;
	}


	this() {
		//connect root process
		if (pwins.windows is null) {
			pwins.windows     = new List!byte();
			pwins.eventPipe   = Directory.CreatePipe();
			pwins.commandPipe = Directory.CreatePipe();
			
			auto curProc      = Process.Current;
			auto compositor   = new FileStream("/dev/compositor");
			compositor.Write(Convert.ToByteArray([curProc.ResID(), pwins.eventPipe.ResID(), pwins.commandPipe.ResID()]), 0);

			byte[8] id;
			pwins.commandPipe.Read(id, 0);
			pwins.id = new Process(Convert.ToInt64Array(id)[0]);

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