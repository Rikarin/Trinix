module Core.Log;

import Architectures.Port;
import Devices.Port.SerialPort;


class Log {
public:
static:
	private __gshared ushort* address;
	private __gshared uint pos;
	private __gshared LogSerialPort sp;
	
	
	void Init() {
		//Hide cursor
		Port.Write!(byte)(0x3D4, 0x0F);
		Port.Write!(byte)(0x3D5, 0);
		Port.Write!(byte)(0x3D4, 0x0E);
		Port.Write!(byte)(0x3D5, 0);
		
		sp = new LogSerialPort(SerialPort.COM1);
		address = cast(ushort *)0xB8000;
		pos = 0;
		
		foreach (i; 0 .. 2000)
			address[i] = 0;

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

	void PrintSP(string text) { sp.Write(text); }
}

class LogSerialPort : SerialPort {
	this(short port) {
		SetPort(port);
		Open();
	}

	new(ulong add) { return cast(void *)0x10000; } //this is for Log init...
}