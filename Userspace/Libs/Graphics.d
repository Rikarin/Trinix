module Userspace.Libs.Graphics;

import System.Windows.Window;


class Graphics {
public:
	ushort Width;
	ushort Height;
	ushort Depth = 4;
	byte[] Buffer;
	byte[] BackBuffer;


public:
	this() { }

	this(Window win) {
		Width      = win.Width; //add decoration width
		Height     = win.Height;
		ulong size = Width * Height * Depth;
		Buffer     = (cast(byte *)0xE0000000)[0 .. size];//win.Buffer
		BackBuffer = new byte[size];
	}

	void Flip() {
		Buffer[] = BackBuffer[0 .. $];
	}

	ref uint Pixel(uint x, uint y) {
		return (cast(uint *)BackBuffer)[Width * y + x];
	}

	void Fill(uint color) {
		foreach (x; 0 .. Width)
			foreach (y; 0 .. Height)
				Pixel(x, y) = color;
	}
}

/*
Buffer     = (cast(byte *)0xE0000000)[0 .. size];
BackBuffer = buffer;
*/