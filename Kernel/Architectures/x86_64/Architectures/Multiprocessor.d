module Architectures.Multiprocessor;

import Core;
import Drivers.Power;
import Architectures;


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
		Log.Result(IOAPIC.Init());

		Log.Print(" - Enabling interrupts");
		Port.Sti();
		return true;
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
