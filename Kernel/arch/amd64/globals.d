/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.globals;


abstract final class LinkerScript {
@trusted: nothrow:
	static const(void *) kernelBase() {
		return cast(void *)&__linker_kernel_start;
	}
	
	static const(void *) kernelEnd() {
		return cast(void *)&__linker_kernel_end;
	}
}

private extern(C) extern __gshared {
    ubyte __linker_kernel_start;
    ubyte __linker_kernel_end;
}