module Disk.SCSI.AHCI.Defs;

import System.Collections;


enum CAP {
	S64A      = (1U << 31), // Supports 64-bit Addressing
	SNCQ      = (1 << 30),  // Supports Native Command Queuing
	SSNTF     = (1 << 29),  // Supports SNotification Register
	SMPS      = (1 << 28),  // Supports Mechanical Presence Switch
	SSS       = (1 << 27),  // Supports Staggered Spin-up
	SALP      = (1 << 26),  // Supports Aggressive Link Power Management
	SAL       = (1 << 25),  // Supports Activity LED
	SCLO      = (1 << 24),  // Supports Command List Override
	ISS_MASK  = 0xf,        // Interface Speed Support
	ISS_SHIFT = 20,
	SNZO      = (1 << 19),  // Supports Non-Zero DMA Offsets
	SAM       = (1 << 18),  // Supports AHCI mode only
	SPM       = (1 << 17),  // Supports Port Multiplier
	FBSS      = (1 << 16),  // FIS-based Switching Supported
	PMD       = (1 << 15),  // PIO Multiple DRQ Block
	SSC       = (1 << 14),  // Slumber State Capable
	PSC       = (1 << 13),  // Partial State Capable
	NCS_MASK  = 0x1f,       // Number of Command Slots (zero-based number)
	NCS_SHIFT = 8,
	CCCS      = (1 << 7),   // Command Completion Coalescing Supported
	EMS       = (1 << 6),   // Enclosure Management Supported
	SXS       = (1 << 5),   // Supports External SATA
	NP_MASK   = 0x1f,       // Number of Ports (zero-based number)
	NP_SHIFT  = 0
}

enum GHC {
	AE   = (1U << 31),      // AHCI Enable
	MRSM = (1 << 2),        // MSI Revert to Single Message
	IE   = (1 << 1),        // Interrupt Enable
	HR   = (1 << 0)         // HBA Reset **RW1**
}

enum INT {
	CPD = (1 << 31),        // Cold Port Detect Status/Enable
	TFE = (1 << 30),        // Task File Error Status/Enable
	HBF = (1 << 29),        // Host Bus Fatal Error Status/Enable
	HBD = (1 << 28),        // Host Bus Data Error Status/Enable
	IF  = (1 << 27),        // Interface Fatal Error Status/Enable
	INF = (1 << 26),        // Interface Non-fatal Error Status/Enable
	OF  = (1 << 24),        // Overflow Status/Enable
	IPM = (1 << 23),        // Incorrect Port Multiplier Status/Enable
	PRC = (1 << 22),        // PhyRdy Change Status/Enable
	DMP = (1 << 7),         // Device Mechanical Presence Status/Enable
	PC  = (1 << 6),         // Port Change Interrupt Status/Enable
	DP  = (1 << 5),         // Descriptor Processed Interrupt/Enable
	UF  = (1 << 4),         // Unknown FIS Interrupt/Enable
	SDB = (1 << 3),         // Set Device Bits Interrupt/Enable
	DS  = (1 << 2),         // DMA Setup FIS Interrupt/Enable
	PS  = (1 << 1),         // PIO Setup FIS Interrupt/Enable
	DHR = (1 << 0)          // Device to Host Register FIS Interrupt/Enable
};

enum PortCMD {
	ICC_ACTIVE  = (1 << 28),// Interface Communication control
	ICC_SLUMBER = (6 << 28),// Interface Communication control
	ICC_MASK    = (0xf<<28),// Interface Communication control
	ATAPI       = (1 << 24),// Device is ATAPI
	CR          = (1 << 15),// Command List Running (DMA active)
	FR          = (1 << 14),// FIS Receive Running
	FER         = (1 << 4), // FIS Receive Enable
	CLO         = (1 << 3), // Command List Override
	POD         = (1 << 2), // Power On Device
	SUD         = (1 << 1), // Spin-up Device
	ST          = (1 << 0)  // Start DMA
};

enum PortINT {
	CPD = (1 << 31),        // Cold Presence Detect Status/Enable
	TFE = (1 << 30),        // Task File Error Status/Enable
	HBF = (1 << 29),        // Host Bus Fatal Error Status/Enable
	HBD = (1 << 28),        // Host Bus Data Error Status/Enable
	IF  = (1 << 27),        // Interface Fatal Error Status/Enable
	INF = (1 << 26),        // Interface Non-fatal Error Status/Enable
	OF  = (1 << 24),        // Overflow Status/Enable
	IPM = (1 << 23),        // Incorrect Port Multiplier Status/Enable
	PRC = (1 << 22),        // PhyRdy Change Status/Enable
	DI  = (1 << 7),         // Device Interlock Status/Enable
	PC  = (1 << 6),         // Port Change Status/Enable
	DP  = (1 << 5),         // Descriptor Processed Interrupt
	UF  = (1 << 4),         // Unknown FIS Interrupt
	SDB = (1 << 3),         // Set Device Bits FIS Interrupt
	DS  = (1 << 2),         // DMA Setup FIS Interrupt
	PS  = (1 << 1),         // PIO Setup FIS Interrupt
	DHR = (1 << 0)          // Device to Host Register FIS Interrupt
};

enum ATA {
	BSY = 0x80,
	DF  = 0x20,
	DRQ = 0x08,
	ERR = 0x01
};

struct Port {
align(1):
	uint clb;               // Command List Base Address (alignment 1024 byte)
	uint clbu;              // Command List Base Address Upper 32-Bits
	uint fb;                // FIS Base Address (alignment 256 byte)
	uint fbu;               // FIS Base Address Upper 32-Bits
	uint iss;               // Interrupt Status **RWC**
	uint ie;                // Interrupt Enable
	uint cmd;               // Command and Status
	uint res1;              // Reserved
	uint tfd;               // Task File Data
	uint sig;               // Signature
	uint ssts;              // Serial ATA Status (SCR0: SStatus)
	uint sctl;              // Serial ATA Control (SCR2: SControl)
	uint serr;              // Serial ATA Error (SCR1: SError) **RWC**
	uint sact;              // Serial ATA Active (SCR3: SActive) **RW1**
	uint ci;                // Command Issue **RW1**
	uint sntf;              // SNotification
	uint res2;              // Reserved for FIS-based Switching Definition
	uint res[11];           // Reserved
	uint vendor[4];         // Vendor Specific
}

struct HBA {
align(1):
	uint cap;               // Host Capabilities
	uint ghc;               // Global Host Control
	uint iss;               // Interrupt Status
	uint pi;                // Ports Implemented
	uint vs;                // Version
	uint ccc_ctl;           // Command Completion Coalescing Control
	uint ccc_ports;         // Command Completion Coalsecing Ports
	uint em_loc;            // Enclosure Management Location
	uint em_ctl;            // Enclosure Management Control
	uint res[31];           // Reserved
	uint vendor[24];        // Vendor Specific registers
	Port port[32];
}

struct FIS {
align(1):
	ubyte dsfis[0x1c];      // DMA Setup FIS
	ubyte res1[0x04];
	ubyte psfis[0x14];      // PIO Setup FIS
	ubyte res2[0x0c];
	ubyte rfis[0x14];       // D2H Register FIS
	ubyte res3[0x04];
	ubyte sdbfis[0x08];     // Set Device Bits FIS
	ubyte ufis[0x40];       // Unknown FIS
	ubyte res4[0x60];
}

struct CommandListEntry {
align(1):
	union {
	align(1):
		struct {
		align(1):
			private ulong flags;
			ushort prdtl;

			mixin(Bitfield!(flags, "cfl", 5, "a", 1, "w", 1, "p", 1, "r", 1, "b", 1, "c", 1, "xxx", 1, "pmp", 4));
		}

		uint prdtl_flags_cfl;
	}

	uint prdbc;             // PRD Byte Count
	uint ctba;              // command table desciptor base address
	uint ctbau;             // command table desciptor base address upper
	ubyte res1[0x10];
}

struct CommandTable {
align(1):
	ubyte cfis[0x40];       // command FIS
	ubyte acmd[0x20];       // ATAPI command
	ubyte res[0x20];        // reserved
}

struct PRD {
align(1):
	uint dba;               // Data Base Address (2-byte aligned)
	uint dbau;              // Data Base Address Upper
	uint res;
	uint dbc;               // Bytecount (0-based, even, max 4MB)
}