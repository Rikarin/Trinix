module Architecture.Linker;

import ObjectManager;

private extern(C) __gshared {
	ubyte iKernelBase;
	ubyte iKernelEnd;
	ubyte iKernelSymbols;
	ubyte iKernelSymbolsEnd;

	ubyte iKernelModules;
	ubyte iKernelModulesEnd;
}


abstract final class LinkerScript {
	@property {
		static void* KernelBase() {
			return &iKernelBase;
		}
		
		static void* KernelEnd() {
			return &iKernelEnd;
		}
	
		static void* KernelSymbols() {
			return &iKernelSymbols;
		}
		
		static void* KernelSymbolsEnd() {
			return &iKernelSymbolsEnd;
		}

		static void* KernelModules() {
			return &iKernelModules;
		}

		static void* KernelModulesEnd() {
			return &iKernelModulesEnd;
		}
	}
}