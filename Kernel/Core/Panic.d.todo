module Core.Panic;

import Architectures.Core;
import Architectures.Port;
import VTManager.SimpleVT;
import DeviceManager.Display;
import VTManager.VT;
import System.Convert;


void Panic(string msg, ref InterruptStack stack) {
	Port.Cli();
	SimpleVT vt = new SimpleVT(Display.TextRows(), 60);
   // SimpleVT rt = new SimpleVT(Display.TextRows(), 29);
	VT.UnmapAll();
	vt.Map(0, 0);
    //rt.Map(5, 60);

	vt.SetColor(ConsoleColor.DarkRed);
	vt.WriteLine("\n");
	vt.WriteLine("                         ..-^~~~^-..");
	vt.WriteLine("                       .~           ~.");
    vt.WriteLine("                      (;:   BOOM!   :;)");
    vt.WriteLine("  ________             (:           :)");
    vt.WriteLine(" | PANIC! |              ':._   _.:'");
    vt.WriteLine(" |_  _____|                  | |");
    vt.WriteLine("   |/                      (=====)");
    vt.WriteLine(" _0_                         | |");
    vt.WriteLine("  |                          | |");
    vt.WriteLine(" / \\                      ((/   \\))");

    vt.SetColor(ConsoleColor.DarkGreen);
    vt.WriteLine("----------------------------------------------------");

    vt.SetColor(ConsoleColor.Gray);
    vt.Write("  Error: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    vt.WriteLine(msg);

    vt.SetColor(ConsoleColor.Gray);
    vt.WriteLine("  Dumping registers:");

//==============================================================================
    //ES
    vt.Write(" [ ES: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    ushort es;
    asm { mov es, ES; }
    WriteReg(vt, es, 2);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //CS
    vt.Write(" [ CS: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.CS, 2);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //SS
    vt.Write(" [ SS: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.SS, 2);
    vt.SetColor(ConsoleColor.Gray);
    vt.WriteLine(" ] ");

    //DS
    vt.Write(" [ DS: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    ushort ds;
    asm { mov ds, DS; }
    WriteReg(vt, ds, 2);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //FS
    vt.Write(" [ FS: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    ushort fs;
    asm { mov fs, ES; }
    WriteReg(vt, fs, 2);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //GS
    vt.Write(" [ GS: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    ushort gs;
    asm { mov gs, GS; }
    WriteReg(vt, gs, 2);
    vt.SetColor(ConsoleColor.Gray);
    vt.WriteLine(" ] ");

//==============================================================================
	//IntNumber
    vt.Write(" [ INT: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.IntNumber);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //ErrorCode
    vt.Write(" [ ERR: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.ErrorCode);
    vt.SetColor(ConsoleColor.Gray);
    vt.WriteLine(" ] ");

//==============================================================================
    //RAX
    vt.Write(" [ RAX: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.RAX);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //RBX
    vt.Write(" [ RBX: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.RBX);
    vt.SetColor(ConsoleColor.Gray);
    vt.WriteLine(" ] ");

    //RCX
    vt.Write(" [ RCX: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.RCX);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //RDX
    vt.Write(" [ RDX: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.RDX);
    vt.SetColor(ConsoleColor.Gray);
    vt.WriteLine(" ] ");

//==============================================================================
    //RSP
    vt.Write(" [ RSP: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.RSP);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //RBP
    vt.Write(" [ RBP: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.RBP);
    vt.SetColor(ConsoleColor.Gray);
    vt.WriteLine(" ] ");

    //RSI
    vt.Write(" [ RSI: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.RSI);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //RDI
    vt.Write(" [ RDI: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.RDI);
    vt.SetColor(ConsoleColor.Gray);
    vt.WriteLine(" ] ");

//==============================================================================
    //RIP
    vt.Write(" [ RIP: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.RIP);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

    //FLAGS
    vt.Write(" [ FLAGS: ");
    vt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(vt, stack.Flags);
    vt.SetColor(ConsoleColor.Gray);
    vt.Write(" ] ");

//==============================================================================
    //R8
 /*   rt.WriteLine("\n");
    rt.Write(" [ R8: ");
    rt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(rt, stack.R8);
    rt.SetColor(ConsoleColor.Gray);
    rt.Write(" ] ");

    //R9
    rt.Write(" [ R9: ");
    rt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(rt, stack.R9);
    rt.SetColor(ConsoleColor.Gray);
    rt.Write(" ] ");

    //R10
    rt.Write(" [ R10: ");
    rt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(rt, stack.R10);
    rt.SetColor(ConsoleColor.Gray);
    rt.Write(" ] ");

    //R11
    rt.Write(" [ R11: ");
    rt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(rt, stack.R11);
    rt.SetColor(ConsoleColor.Gray);
    rt.Write(" ] ");

    //R12
    rt.Write(" [ R12: ");
    rt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(rt, stack.R12);
    rt.SetColor(ConsoleColor.Gray);
    rt.Write(" ] ");

    //R13
    rt.Write(" [ R13: ");
    rt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(rt, stack.R13);
    rt.SetColor(ConsoleColor.Gray);
    rt.Write(" ] ");

    //R14
    rt.Write(" [ R14: ");
    rt.SetColor(ConsoleColor.DarkCyan);
    WriteReg(rt, stack.R14);
    rt.SetColor(ConsoleColor.Gray);
    rt.Write(" ] ");*/

    asm {
        hlt;
    }
}

void WriteReg(ref SimpleVT vt, ulong value, ulong length = 16) {
	string v = Convert.ToString(value, 16);

	vt.Write("0x");
	foreach (i; v.length .. length + 2)
		vt.Put('0', false);

	foreach (i; 2 .. v.length)
		vt.Put(v[i]);
}