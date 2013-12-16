module Core.Log;

import Architectures;
import Drivers.Port.SerialPort;


class Log {
public:
static:
	private __gshared ushort* address;
	private __gshared uint pos;
	private __gshared LogSerialPort sp;
	
	
	void Init() {
		//Hide cursor
		Port.Write!byte(0x3D4, 0x0F);
		Port.Write!byte(0x3D5, 0);
		Port.Write!byte(0x3D4, 0x0E);
		Port.Write!byte(0x3D5, 0);

		debug (only)
			sp = new LogSerialPort(SerialPort.COM1);

		address = cast(ushort *)0xC0B8000;
		pos = 0;
		
		foreach (i; 0 .. 2000)
			address[i] = 0;

		debug (only)
			sp.WriteLine("\nBooting...");
	}
	
	void Print(string msg, ushort color = 0x700) {
		foreach (char s; msg) {
			if (pos >= 2000) {
				address[0 .. 1920] = address[80 .. 2000];
				address[1920 .. 2000] = 0;
				pos -= 80;
			}
			address[pos++] = s | color;
		}

		debug (only)
			sp.Write(msg);
	}
	
	void Result(bool val) {
		uint p = 65 - (pos % 80);
	
		for (uint i = 0; i < p; i++)
			Print(".");
		
		if (val) {
			Print("[ ");
			Print("OK", 0x200);
			Print(" ]         ");
		} else {
			Print("[ ");
			Print("ERR", 0x400);
			Print(" ]        ");
		}
	}

	debug (only) {
		void PrintSP(string text) { sp.Write(text); }
		
		void Debug(string text) {
			sp.Write("[ DEBUG ]");
			sp.WriteLine(text);
		}
	}
}

class LogSerialPort : SerialPort {
	this(short port) {
		SetPort(port);
		Open();
	}

	new(ulong add) { return cast(void *)0xC010000; } //this is for Log init...
}