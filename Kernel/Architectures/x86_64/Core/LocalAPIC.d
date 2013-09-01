module Architectures.x86_64.Core.LocalAPIC;

import Core.Log;
import MemoryManager.Memory;
import System.Threading.All;

import Architectures.Port;
import Architectures.Paging;
import Architectures.x86_64.Core.Info;

class LocalAPIC {
public:
static:
	bool Init() {
		curCoreId = 0;
		logicalIDToAPICId[] = 0;
		APICIdToLogicalID[] = 0;

		apLock = new Mutex(false);
		InitLocalAPIC(Info.LocalAPICAddress);
		Install();
		return true;
	}
	
	void StartCores() {
		StartAPs();
	}
	
	void Install() {
		Port.Write!(byte)(0x22, 0x70);
		Port.Write!(byte)(0x23, 0x01);
		
		apicRegisters.LogicalDestination    = (1 << GetLocalAPICId()) << 24;
		apicRegisters.DestinationFormat     = 0xFFFFFFFF;
		apicRegisters.TaskPriority          = 0x0;
		apicRegisters.SpuriousIntVector    |= 0x10F;
		apicRegisters.Lint0LocalVectorTable = 0x722;
		apicRegisters.Lint1LocalVectorTable = 0x422;
		
		EOI();

		if (!curCoreId) {
			logicalIDToAPICId[0] = GetLocalAPICId();
			APICIdToLogicalID[GetLocalAPICId()] = 0;
			curCoreId++;
		}
	}
	
	bool ReportCore() {
		if (!curCoreId)
			return true;

		logicalIDToAPICId[curCoreId] = GetLocalAPICId();
		APICIdToLogicalID[GetLocalAPICId()] = curCoreId;
		curCoreId++;

		return true;
	}
	
	@property uint Identifier() {
		return APICIdToLogicalID[GetLocalAPICId()];
	}
	
	@property uint id() {
		return GetLocalAPICId();
	}
	
	void EOI() {
		apicRegisters.EOI = 0;
	}

private:
	__gshared Mutex apLock;
	__gshared uint curCoreId;

	__gshared uint[256] logicalIDToAPICId;
	__gshared uint[256] APICIdToLogicalID;


	enum DeliveryMode {
		Fixed,
		LowestPriority,
		SMI,
		Reserved,
		NonMaskedInterrupt,
		INIT,
		Startup,
	}

	
	void InitLocalAPIC(PhysicalAddress localAPICAddr) {
		ulong MSRValue = Port.ReadMSR(0x1B);
		MSRValue |= (1 << 11);
		Port.WriteMSR(0x1B, MSRValue);

		apicRegisters = cast(ApicRegisterSpace *)Paging.KernelPaging.MapRegion(localAPICAddr, ApicRegisterSpace.sizeof);
	}

	uint GetLocalAPICId() {
		if (apicRegisters is null)
			return 0;

		uint ID = apicRegisters.LocalApicId;
		return ID >> 24;
	}
	
	void StartAPs() {
		foreach (localAPIC; Info.LAPICs[0 .. Info.NumLAPICs]) {
				if (localAPIC.Enabled && localAPIC.ID != GetLocalAPICId())
					StartAP(localAPIC.ID);
		}
	}

	void StartAP(ubyte apicID) {
		Log.Print(" - LocalAPIC: Starting AP");
		apLock.WaitOne();

		ulong p;
		for (ulong i = 0; i < 10000; i++)
			p = i << 5 + 10;
		SendINIT(apicID);

		for (ulong i = 0; i < 10000; i++)
			p = i << 5 + 10;
		SendStartup(apicID);

		for (ulong i = 0; i < 10000; i++)
			p = i << 5 + 10;
		SendStartup(apicID);

		for (ulong i = 0; i < 10000; i++)
			p = i << 5 + 10;

		apLock.Release();
		Log.Result(true);
	}

	void SendINIT(ubyte ApicID) {
		SendIPI(0, DeliveryMode.INIT, 0, 0, ApicID);
	}

	void SendStartup(ubyte ApicID) {
		SendIPI(0, DeliveryMode.Startup, 0, 0, ApicID);
	}

	void SendIPI(ubyte vectorNumber, DeliveryMode dmode, bool destinationMode, ubyte destinationShorthand, ubyte destinationField) {
		uint hiword = cast(uint)destinationField << 24;

		apicRegisters.InterruptCommandHi = hiword;
		uint loword = cast(uint)vectorNumber;
		loword |= cast(uint)dmode << 8;

		if (destinationMode)
			loword |= (1 << 11);

		loword |= cast(uint)destinationShorthand << 18;
		apicRegisters.InterruptCommandLo = loword;
	}


	struct ApicRegisterSpace {
	align(1):
		/* 0000 */ uint Reserved0;				ubyte[12] padding0;
		/* 0010 */ uint Reserved1;				ubyte[12] padding1;
		/* 0020 */ uint LocalApicId;			ubyte[12] padding2;
		/* 0030 */ uint LocalApicIdVersion; 	ubyte[12] padding3;
		/* 0040 */ uint Reserved2;				ubyte[12] padding4;
		/* 0050 */ uint Reserved3;				ubyte[12] padding5;
		/* 0060 */ uint Reserved4;				ubyte[12] padding6;
		/* 0070 */ uint Reserved5;				ubyte[12] padding7;
		/* 0080 */ uint TaskPriority;			ubyte[12] padding8;
		/* 0090 */ uint ArbitrationPriority;	ubyte[12] padding9;
		/* 00a0 */ uint ProcessorPriority;		ubyte[12] padding10;
		/* 00b0 */ uint EOI;					ubyte[12] padding11;
		/* 00c0 */ uint Reserved6;				ubyte[12] padding12;
		/* 00d0 */ uint LogicalDestination;		ubyte[12] padding13;
		/* 00e0 */ uint DestinationFormat;		ubyte[12] padding14;
		/* 00f0 */ uint SpuriousIntVector;		ubyte[12] padding15;
		/* 0100 */ uint isr0;					ubyte[12] padding16;
		/* 0110 */ uint isr1;					ubyte[12] padding17;
		/* 0120 */ uint isr2;					ubyte[12] padding18;
		/* 0130 */ uint isr3;					ubyte[12] padding19;
		/* 0140 */ uint isr4;					ubyte[12] padding20;
		/* 0150 */ uint isr5;					ubyte[12] padding21;
		/* 0160 */ uint isr6;					ubyte[12] padding22;
		/* 0170 */ uint isr7;					ubyte[12] padding23;
		/* 0180 */ uint tmr0;					ubyte[12] padding24;
		/* 0190 */ uint tmr1;					ubyte[12] padding25;
		/* 01a0 */ uint tmr2;					ubyte[12] padding26;
		/* 01b0 */ uint tmr3;					ubyte[12] padding27;
		/* 01c0 */ uint tmr4;					ubyte[12] padding28;
		/* 01d0 */ uint tmr5;					ubyte[12] padding29;
		/* 01e0 */ uint tmr6;					ubyte[12] padding30;
		/* 01f0 */ uint tmr7;					ubyte[12] padding31;
		/* 0200 */ uint irr0;					ubyte[12] padding32;
		/* 0210 */ uint irr1;					ubyte[12] padding33;
		/* 0220 */ uint irr2;					ubyte[12] padding34;
		/* 0230 */ uint irr3;					ubyte[12] padding35;
		/* 0240 */ uint irr4;					ubyte[12] padding36;
		/* 0250 */ uint irr5;					ubyte[12] padding37;
		/* 0260 */ uint irr6;					ubyte[12] padding38;
		/* 0270 */ uint irr7;					ubyte[12] padding39;
		/* 0280 */ uint ErrorStatus;			ubyte[12] padding40;
		/* 0290 */ uint Reserved7;				ubyte[12] padding41;
		/* 02a0 */ uint Reserved8;				ubyte[12] padding42;
		/* 02b0 */ uint Reserved9;				ubyte[12] padding43;
		/* 02c0 */ uint Reserved10;				ubyte[12] padding44;
		/* 02d0 */ uint Reserved11;				ubyte[12] padding45;
		/* 02e0 */ uint Reserved12;				ubyte[12] padding46;
		/* 02f0 */ uint Reserved13;				ubyte[12] padding47;
		/* 0300 */ uint InterruptCommandLo;		ubyte[12] padding48;
		/* 0310 */ uint InterruptCommandHi;		ubyte[12] padding49;
		/* 0320 */ uint TmrLocalVectorTable;	ubyte[12] padding50;
		/* 0330 */ uint Reserved14;				ubyte[12] padding51;
		/* 0340 */ uint PerformanceCounterLVT;	ubyte[12] padding52;
		/* 0350 */ uint Lint0LocalVectorTable;	ubyte[12] padding53;
		/* 0360 */ uint Lint1LocalVectorTable;	ubyte[12] padding54;
		/* 0370 */ uint ErrorLocalVectorTable;	ubyte[12] padding55;
		/* 0380 */ uint tmrInitialCount;		ubyte[12] padding56;
		/* 0390 */ uint tmrCurrentCount;		ubyte[12] padding57;
		/* 03a0 */ uint Reserved15;				ubyte[12] padding58;
		/* 03b0 */ uint Reserved16;				ubyte[12] padding59;
		/* 03c0 */ uint Reserved17;				ubyte[12] padding60;
		/* 03d0 */ uint Reserved18;				ubyte[12] padding61;
		/* 03e0 */ uint tmrDivideConfiguration;	ubyte[12] padding62;
	}

	__gshared ApicRegisterSpace* apicRegisters;
}
