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


public abstract final class LinkerScript {
	@property {
		public static void* KernelBase() {
			return &iKernelBase;
		}
		
		public static void* KernelEnd() {
			return &iKernelEnd;
		}
	
		public static void* KernelSymbols() {
			return &iKernelSymbols;
		}
		
		public static void* KernelSymbolsEnd() {
			return &iKernelSymbolsEnd;
		}

		public static void* KernelModules() {
			return &iKernelModules;
		}

		public static void* KernelModulesEnd() {
			return &iKernelModulesEnd;
		}
	}
}