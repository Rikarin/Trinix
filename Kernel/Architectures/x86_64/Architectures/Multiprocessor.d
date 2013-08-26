module Architectures.Multiprocessor;

import Core.Log;

import Architectures.Port;
import Architectures.x86_64.Core.Info;
import Architectures.x86_64.Core.IOAPIC;
import Architectures.x86_64.Core.LocalAPIC;
import Architectures.x86_64.Specs.MP;
import Architectures.x86_64.Specs.ACPI;


class Multiprocessor {
static:
public:
	bool Init() {
		if (ACPI.FindTable() && ACPI.ReadTable()) {
			
		} else {
		//	if (!MP.FindTable())
		//		return false;

		//	if (!MP.ReadTable())
		//		return false;
			return false;
		}
		Log.Result(true);
		
		Log.Print(" - Local APIC Initialize");
		Log.Result(LocalAPIC.Init());

		Log.Print(" - IOAPIC Initialize");
		bool ret = IOAPIC.Init();

		Port.Sti();
		return ret;
	}

	@property uint CPUCount() {
		return Info.NumLAPICs;
	}
	
	bool BootCores() {
		LocalAPIC.StartCores();
		return true;
	}
	
	bool InstallCore() {
		LocalAPIC.Install();
		return true;
	}
}
