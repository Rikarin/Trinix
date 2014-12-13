/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 * 
 * TODO:
 *      o Move this file to Framework.so
 */

module Library.Termios;


struct WindowSize {
	ushort Row;
	ushort Col;
	ushort X;
	ushort Y;
}

struct Termios {
	uint InputFlags;
	uint OutputFlags;
	uint ControlFlags;
	uint LocalFlags;
	char[32] ControlChars;
}

enum Commands : ubyte {
	VEOF = 1, /* ^D (end of file) */
	VEOL, /* NULL (end of line) */
	VERASE, /* ^H (backspace/del) */
	VINTR, /* ^C (interrupt) */
	VKILL, /* ^U (erase input buffer) */
	VMIN, /* minimum number of characters for non-canonical read */
	VQUIT, /* ^\ send SIGQUIT */
	VSTART, /* ^Q restart STOPped input */
	VSTOP, /* ^S stop input */
	VSUSP, /* ^Z suspend foreground applicatioan (send SIGTSTP) */
	VTIME, /* Timeout for non-canonical read, deciseconds */
}

enum InputModes : uint {
	BRKINT = 1,
	ICRNL = 2,
	IGNBRK = 4,
	IGNCR = 10,
	IGNPAR = 20,
	INLCR = 40,
	INPCK = 100,
	ISTRIP = 200,
	IUCLC = 400,
	IXANY = 1000,
	IXOFF = 2000,
	IXON = 4000,
	PARMRK = 10000
}

enum OutputModes : uint {
	OPOST = 1,
	OLCUC = 2,
	ONLCR = 4,
	OCRNL = 10,
	ONOCR = 20,
	ONLRET = 40,
	OFILL = 100,
	OFDEL = 200,
	NLDLY = 400,
	NL0 = 0,
	NL1 = 400,
	CRDLY = 3000,
	CR0 = 0,
	CR1 = 1000,
	CR2 = 2000,
	CR3 = 3000,
	TABDLY = 14000,
	TAB0 = 0,
	TAB1 = 4000,
	TAB2 = 10000,
	TAB3 = 14000,
	BSDLY = 20000,
	BS0 = 0,
	BS1 = 20000,
	FFDLY = 100000,
	FF0 = 0,
	FF1 = 100000,
	VTDLY = 40000,
	VT0 = 0,
	VT1 = 40000
}

enum BaudRates : uint {
	B0,
	B50,
	B75,
	B110,
	B134,
	B150,
	B200,
	B300,
	B600,
	B1200,
	B1800,
	B2400,
	B4800,
	B9600,
	B19200,
	B38400
}

enum ControlModes : uint {
	CSIZE = 60,
	CS5 = 0,
	CS6 = 20,
	CS7 = 40,
	CS8 = 60,
	CSTOPB = 100,
	CREAD = 200,
	PARENB = 400,
	PARODD = 1000,
	HUPCL = 2000,
	CLOCAL = 4000
}

enum LocalModes : uint {
	ISIG = 1,
	ICANON = 2,
	XCASE = 4,
	ECHO = 10,
	ECHOE = 20,
	ECHOK = 40,
	ECHONL = 100,
	NOFLSH = 200,
	TOSTOP = 400,
	IEXTEN = 1000
}

enum TermAttributes : uint {
	TCSANOW = 0x0001,
	TCSADRAIN = 0x0002,
	TCSAFLUSH = 0x0004,
	TCIFLUSH = 0x0001,
	TCIOFLUSH = 0x0003,
	TCOFLUSH = 0x0002,
	TCIOFF = 0x0001,
	TCION = 0x0002,
	TCOOFF = 0x0004,
	TCOON = 0x0008,
}
/+
enum IOCTL_Commands : uint {
	TCGETS = 0x4000, /* Get termios struct */
	TCSETS = 0x4001, /* Set termios struct */
	TCSETSW = 0x4002, /* Set, but let drain first */
	TCSETSF = 0x4003, /* Set, but let flush first */
	TCGETA = TCGETS,
	TCSETA = TCSETS,
	//TCGETAW = TCGETSW,
	//TCGETAF = TCGETSF,
	TCSBRK = 0x4004,
	TCXONC = 0x4005,
	TCFLSH = 0x4006,
	TIOCEXCL = 0x4007,
	TIOCNXCL = 0x4008,
	TIOCSCTTY = 0x4009,
	TIOCGPGRP = 0x400A,
	TIOCSPGRP = 0x400B,
	TIOCOUTQ = 0x400C,
	TIOCSTI = 0x400D,
	TIOCGWINSZ = 0x400E,
	TIOCSWINSZ = 0x400F,
	TIOCMGET = 0x4010,
	TIOCMBIS = 0x4011,
	TIOCMBIC = 0x4012,
	TIOCMSET = 0x4013,
	TIOCGSOFTCAR = 0x4014,
	TIOCSSOFTCAR = 0x4015
}+/