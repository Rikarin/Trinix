module Userspace.GUI.Compositor;

import Userspace.Libs.Graphics;
import System.IO.Directory;
import System.IO.FileStream;

import System.Threading.Thread;
import System.Diagnostics.Process;
import System.Diagnostics.ProcessStartInfo;
import System.Windows.Window;
import System.Collections.Generic.List;
import System.Convert;

static import Userspace.GUI.GraphicsTest;

class Compositor {
private:
	ulong wid = 1;

	Graphics ctx;
	Graphics selectCtx;
	FileStream requestPipe;
	List!(Window.ProcessWindows) procWins;


public:
	@property ulong NewWID() { return wid++; }

	this() {
		ctx            = new Graphics();
		ctx.Width      = 800;
		ctx.Height     = 600;
		ulong size     = ctx.Width * ctx.Height * ctx.Depth;
		ctx.Buffer     = (cast(byte *)0xE0000000)[0 .. size];
		ctx.BackBuffer = new byte[size];

		//selectCtx   = new Graphics(true); todo
		procWins    = new List!(Window.ProcessWindows)();
		requestPipe = Directory.CreatePipe("/dev/compositor");

		/** Mouse hanlder */
		//(new Thread(&MouseHandler)).Start();


		auto startInfo = new ProcessStartInfo();
		startInfo.ThreadEntry = &Userspace.GUI.GraphicsTest.construct;
		Process.Start(startInfo);

		while (true) {
			ProcessRequest();
			ProcessCommands();
			Process.Switch();
		}
	}


private:
	void ProcessRequest() {
		if (!requestPipe.Length)
			return;

		byte data[24];
		long i;

		while (i != data.length)
			i += requestPipe.Read(data, 0);

		Window.ProcessWindows pwin;
		long[] d         = Convert.ToInt64Array(data);
		pwin.ID          = new Process(d[0]);
		pwin.EventPipe   = new FileStream(d[1]);
		pwin.CommandPipe = new FileStream(d[2]);
		//pwin.windows   = new List!bte;

		pwin.EventPipe.Write(Convert.ToByteArray([Process.Current.ResID()]), 0);
		procWins.Add(pwin);
	}

	void ProcessCommands() {
		foreach (x; procWins) {
			if (!x.CommandPipe.Length)
				continue;

			Window.PacketHeader header;
			Window.WWindow packet;

			x.CommandPipe.Read(Convert.ObjectToByteArray(header), 0);
			if (header.Magic != Window.PACKET_MAGIC) {
				byte[0x256] tresh;
				x.CommandPipe.Read(tresh, 0);
				continue;
			}

			x.CommandPipe.Read(Convert.ObjectToByteArray(packet), 0);
			switch (header.CommandType) {
				case Window.Commands.NewWindow:
					packet.ID = NewWID;
					SendEvent(x, Window.Events.WindowNew, packet);
					break;
				default:
					break;
			}
		}
	}

	void SendEvent(Window.ProcessWindows pw, Window.Events event, Window.WWindow packet) {
		Window.PacketHeader header;
		header.Magic = Window.PACKET_MAGIC;
		header.CommandType = event;
		header.PacketSize = Window.WWindow.sizeof;

		if (pw.EventPipe.Length + Window.WWindow.sizeof + Window.PacketHeader.sizeof <= 0x2000) {
			pw.EventPipe.Write(Convert.ObjectToByteArray(header), 0);
			pw.EventPipe.Write(Convert.ObjectToByteArray(packet), 0);
			pw.ID.SendSignal(SigNum.SIGWINEVENT);
		} else {
			//kill process...
			pw.ID.SendSignal(SigNum.SIGWINEVENT);
		}
	}


	void MouseHandler() {
		auto mousePipe = new FileStream("/dev/mouse");

		while (true) {
		}
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