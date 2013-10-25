module Userspace.Libs.Graphics;


class Graphics {
public:
	ushort width;
	ushort height;
	ushort depth;
	byte[] buffer;
	byte[] backBuffer;


public:
	this(bool ownBuffer = false) {
		width      = 800;
		height     = 600;
		depth      = 4; //32 / 8

		ulong size = width * height * depth;
		if (ownBuffer) { //prerobit. Toto sa pouziva iba v kompozitore
			buffer     = (cast(byte *)0xE0000000)[0 .. size];
			backBuffer = buffer;
		} else {
			buffer     = new byte[size];
			backBuffer = new byte[size];
		}
	}

	ref uint Pixel(uint x, uint y) {
		return (cast(uint *)buffer)[width * y + x];
	}
}