module Devices.Port.SerialPort;

import Architectures.Port;


class SerialPort {
	private short port;
	private bool open;

	enum : short {
		COM1 = 0x3F8,
		COM2 = 0x2F8,
		COM3 = 0x3E8,
		COM4 = 0x2E8
	}

	@property bool IsOpen() { return open; }

	this() { }

	this(short port) {
		this.port = port;
		Open();
	}

	void SetPort(short port) {
		this.port = port;
	}

	void Open() {
		Port.Write!(byte)(cast(short)(port + 1), 0x00);
		Port.Write!(byte)(cast(short)(port + 3), 0x80);
		Port.Write!(byte)(cast(short)(port + 0), 0x03);
		Port.Write!(byte)(cast(short)(port + 1), 0x00);
		Port.Write!(byte)(cast(short)(port + 3), 0x03);
		Port.Write!(byte)(cast(short)(port + 2), 0xC7);
		Port.Write!(byte)(cast(short)(port + 4), 0x0B);
		
		open = true;
	}

	/*void Close() {
		open = false;
	}*/

	bool Recieved() {
		return (Port.Read!(byte)(cast(short)(port + 5)) & 1) != 0;
	}

	bool IsTransmitEmpty() {
		return (Port.Read!(byte)(cast(short)(port + 5)) & 0x20) != 0;
	}

	char Read() {
		while (!Recieved()) { }
		return Port.Read!(byte)(port);
	}

	string ReadLine() {
		string ret;
		char r;

		do {
			r = Read();
			ret = ret ~ r;
		} while (r != '\n');

		return ret;
	}

	void Write(char c) {
		while (!IsTransmitEmpty()) { }
		Port.Write!(byte)(port, c);
	}

	void Write(string text) {
		foreach (x; text)
			Write(x);
	}

	void WriteLine(string text) {
		Write(text);
		Write('\n');
	}
}