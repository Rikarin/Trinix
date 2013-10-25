module Userspace.Libs.Graphics;


class Graphics {
private:
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

		ulong size = width * height;
		if (ownBuffer) {
			buffer     = (cast(byte *)0xFE000000)[0 .. size];
			backBuffer = buffer;
		} else {
			buffer     = new byte[size * int.sizeof];
			backBuffer = new byte[size * int.sizeof];
		}
	}
}