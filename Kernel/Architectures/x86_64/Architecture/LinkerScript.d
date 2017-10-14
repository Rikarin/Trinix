/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Architecture.LinkerScript;

import MemoryManager;


private extern(C) extern __gshared {
    ubyte __linker_kernel_start;
    ubyte __linker_kernel_end;
    ubyte __linker_symbols_start;
    ubyte __linker_symbols_end;
    ubyte __linker_modules_start;
    ubyte __linker_modules_end;
}

abstract final class LinkerScript {
    @property {
        static const(void *) KernelBase()       { return cast(void *)&__linker_kernel_start;  }
        static const(void *) KernelEnd()        { return cast(void *)&__linker_kernel_end;    }
        static const(void *) KernelSymbols()    { return cast(void *)&__linker_symbols_start; }
        static const(void *) KernelSymbolsEnd() { return cast(void *)&__linker_symbols_end;   }
        static const(void *) KernelModules()    { return cast(void *)&__linker_modules_start; }
        static const(void *) KernelModulesEnd() { return cast(void *)&__linker_modules_end;   }
    }
}
