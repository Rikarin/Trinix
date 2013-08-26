module Devices.Display.VGATextOutput;

import Architectures.Port;
import Devices.Display.DisplayProto;
import DeviceManager.Device;
import DeviceManager.Display;

import System.ConsoleColor;

class VGATextOutput : DisplayProto {
	private ushort columns;
	private ushort* Address = cast(ushort *)0xB8000;


	this() {
		columns = 80;
		Device.RegisterDevice(this, DeviceInfo("Standard VGA text output", DeviceType.Display));
	}

	 override DisplayMode[] GetModes() {
	 	DisplayMode mode[1];
		mode[0].TextCols      = 80;
		mode[0].TextRows      = 25;
		mode[0].Identifier    = 1;
		mode[0].GraphicWidth  = 0;
		mode[0].GraphicHeight = 0;
		mode[0].GraphicDepth  = 0;
		mode[0].Dev           = this;
	 	return mode[];
	 }

	 override bool SetMode(DisplayMode mode) {
	 	if (mode.Dev == this && (mode.Identifier == 3 || mode.Identifier == 1)) {
	 		//set mode via V86 todo...
	 	}
	 	return true;
	 }

	 override void PutChar(ushort line, ushort column, wchar c, ConsoleColor color, ConsoleColor bgColor) {
	 	Address[columns * line + column] = cast(ushort)(((bgColor << 4) | (color & 0x0F)) << 8) | (c & 0xFF);
	 }

	 override void GetChar(ushort line, ushort column, out wchar c, out ConsoleColor color, out ConsoleColor bgColor) {
	 	ushort tmp = Address[columns * line + column];
	 	c = tmp & 0xFF;
	 	color = cast(ConsoleColor)((tmp >> 8) & 0x0F);
	 	bgColor = cast(ConsoleColor)(tmp >> 12);
	 }

	 override void MoveCursor(ushort line, ushort column) {
	 	uint csrLocation = line * columns + column;

	 	Port.Write!(ubyte)(0x3D4, 14);
	 	Port.Write!(ubyte)(0x3D5, csrLocation >> 8);
	 	Port.Write!(ubyte)(0x3D4, 15);
	 	Port.Write!(ubyte)(0x3D5, csrLocation & 0xFF);
	 }

	 override void Clear() {
	 	Address[0 .. 2000] = 0;
	 }

}