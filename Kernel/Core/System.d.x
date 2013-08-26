module Core.System;

import Architectures.Port;

class System
{
static:
public:
	//flags from keyboard controller
	const auto BIT_K_DATA = 0x00;
	const auto BIT_U_DATA = 0x01;
	const auto IO		  = 0x60;
	const auto INTERFACE  = 0x64;
	const auto RESET	  = 0xFE;
	
	void Restart()
	{
		ubyte tmp;
		Port.Cli();

		do
		{
			tmp = Port.Read!(ubyte)(INTERFACE);
			if (CheckFlag(tmp, BIT_K_DATA))
				Port.Read!(ubyte)(IO);
		}
		while (CheckFlag(tmp, BIT_U_DATA));

		Port.Write!(ubyte)(INTERFACE, RESET);
		while (true) {}
	}
}

private:
	ubyte CheckFlag(ubyte flags, ubyte n)
	{
		return flags & (1 << n);
	}
