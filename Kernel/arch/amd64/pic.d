/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.pic;

import io.ioport;


final abstract class PIC {
static:
@safe: nothrow: @nogc:
	private enum MasterPort = 0x21;
	private enum SlavePort  = 0xA1;
		
	ref bool isEnabled() @trusted {
		__gshared bool enabled = true;
		return enabled;
	}
	
	void disable() {
		outPort!ubyte(MasterPort, 0xFF);
		outPort!ubyte(SlavePort, 0xFF);
		
		isEnabled = false;
	}
}
