module System.Windows.Window;

import System.IO.FileStream;
import Userspace.Libs.Graphics;


class Window {
private:
	Graphics ctx;


public:
	this() {
		ctx = new Graphics(true);

//		auto fs = new FileStream("/dev/compositor");
//		fs.Write(cast(byte[])"hovno vole naser si", 0);

		FormStyle.RenderDecorationSimple(ctx);
	}


private:
	class FormStyle {
	static:
		void RenderDecorationSimple(Graphics ctx) {
			short height = 500;
			short width = 500;

			foreach (i; 0 .. height) {
				ctx.Pixel(0, i) = 0x3E3E3E;
				ctx.Pixel(height - 1, i) = 0x3E3E3E;
			}

			foreach (i; 1 .. 24) {
				foreach (j; 1 .. width - 1) {
					ctx.Pixel(j, i) = 0xB4B4B4;
				}
			}

			foreach (i; 0 .. width) {
				ctx.Pixel(i, 0) = 0x3E3E3E;
				ctx.Pixel(i, 24 - 1) = 0x3E3E3E;
				ctx.Pixel(i, height - 1) = 0x3E3E3E;
			}
		}
	}
}