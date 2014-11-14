module Architecture.Linker;


private extern(C) __gshared {
	ubyte iKernelBase;
	ubyte iKernelEnd;
	ubyte iKernelModules;
	ubyte iKernelModulesEnd;
	ubyte iKernelSymbols;
	ubyte iKernelSymbolsEnd;
}


public abstract final class LinkerScript {
	@property {
		public static void* KernelBase() {
			return &iKernelBase;
		}
		
		public static void* KernelEnd() {
			return &iKernelEnd;
		}
		
		public static void* KernelModules() {
			return &iKernelModulesEnd;
		}
		
		public static void* KernelModulesEnd() {
			return &iKernelModulesEnd;
		}
		
		public static void* KernelSymbols() {
			return &iKernelSymbols;
		}
		
		public static void* KernelSymbolsEnd() {
			return &iKernelSymbolsEnd;
		}
	}
}