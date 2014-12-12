module Core.Multiboot;

import Core;
import Architecture;
import MemoryManager;


enum MultibootTagType {
	Align = 8,
	End = 0,
	CmdLine,
	BootLoaderName,
	Module,
	BasicMemInfo,
	BootDev,
	MemoryMap,
	VBE,
	FrameBuffer,
	ElfSections,
	APM,
	EFI32,
	EFI64,
	SMBIOS,
	ACPIOld,
	ACPINew,
	Network,
	EFIMemoryMap,
	EFIBS
}

enum MultibootFramebufferType {
	Indexed,
	RGB,
	EGAText
}

enum MultibootMemoryType {
	Avaiable = 1,
	Reserved,
	ACPIReclaimable,
	NVS,
	BadRAM
}

struct MultibootColor {
	ubyte Red;
	ubyte Green;
	ubyte Blue;
}

struct MultibootMemoryMap {
align(1):
	ulong Address;
	ulong Length;
	uint Type;
	private uint _zero;
}

struct MultibootTag {
	uint Type;
	uint Size;
}

struct MultibootTagString {
	uint Type;
	uint Size;
	char String;
}

struct MultibootTagModule {
	uint Type;
	uint Size;
	uint ModStart;
	uint ModEnd;
	char String;
}

struct MultibootTagBasicMemInfo {
	uint Type;
	uint Size;
	uint Lower;
	uint Upper;
}

struct MultibootTagBootDev {
	uint Type;
	uint Size;
	uint BiosDev;
	uint Slice;
	uint Part;
}

struct MultibootTagMemoryMap {
	uint Type;
	uint Size;
	uint EntrySize;
	uint EntryVersion;
	MultibootMemoryMap Entry;
}

struct MultibootTagFramebufferCommon {
	uint Type;
	uint Size;

	ulong Address;
	uint Pitch;
	uint Width;
	uint Height;
	ubyte Bpp;
	ubyte FramebufferType;
	private ushort _reserved;
}

struct MultibootTagFramebuffer {
	MultibootTagFramebufferCommon Common;

	union {
		struct {
			ushort PaletteNumColors;
			MultibootColor Palette;
		}

		struct {
			ubyte RedFieldPos;
			ubyte RedMaskSize;
			ubyte GreenFieldPos;
			ubyte GreenMaskSize;
			ubyte BlueFieldPos;
			ubyte BlueMaskSize;
		}
	}
}


abstract final class Multiboot {
	__gshared MultibootTagModule*[256] Modules;
	__gshared int ModulesCount;

	private enum {
		HeaderMagic = 0xE85250D6,
		BootloaderMagic = 0x36D76289
	}

	static void ParseHeader(uint magic, void* info) {
		if (magic != Multiboot.BootloaderMagic) {
			Log.WriteJSON("error", "Bad multiboot2 magic");
			Log.WriteJSON("value", magic);
			Port.Halt();
		}
		
		if (cast(ulong)info & 7) {
			Log.WriteJSON("error", "Unaligned MBI");
			Port.Halt();
		}

		Log.WriteJSON("size", *cast(ulong *)info, 16);
		Log.WriteJSON("params", "[");

		MultibootTag* mbt = cast(MultibootTag *)(cast(long)info + cast(long)LinkerScript.KernelBase + 8);
		for (; mbt.Type != MultibootTagType.End; mbt = cast(MultibootTag *)(cast(ulong)mbt + ((mbt.Size + 7UL) & ~7UL))) {
			Log.WriteJSON("{");
			Log.WriteJSON("tag", "{");
			Log.WriteJSON("type", mbt.Type);
			Log.WriteJSON("size", mbt.Size);
			Log.WriteJSON("}");
			
			switch (mbt.Type) {
				case MultibootTagType.CmdLine:
					auto tmp = cast(MultibootTagString *)mbt;
					char* str = &tmp.String;

					Log.WriteJSON("name", "CmdLine");
					Log.WriteJSON("value", cast(string)str[0 .. tmp.Size - 9]);
					break;
					
				case MultibootTagType.BootLoaderName:
					auto tmp = cast(MultibootTagString *)mbt;
					char* str = &tmp.String;

					Log.WriteJSON("name", "BootLoaderName");
					Log.WriteJSON("value", cast(string)str[0 .. tmp.Size - 9]);
					break;
					
				case MultibootTagType.Module:
					auto tmp = cast(MultibootTagModule *)mbt;
					PhysicalMemory.MemoryStart = (((tmp.ModEnd & ~cast(ulong)LinkerScript.KernelEnd)) + 0xFFF) & 0xFFFFFFFFFFFFF000;
					char* str = &tmp.String;
					Modules[ModulesCount++] = tmp;

					Log.WriteJSON("name", "Module");
					Log.WriteJSON("start", tmp.ModStart);
					Log.WriteJSON("end", tmp.ModEnd);
					Log.WriteJSON("cmd", cast(string)str[0 .. tmp.Size - 17]);
					break;
					
				case MultibootTagType.BasicMemInfo:
					auto tmp = cast(MultibootTagBasicMemInfo *)mbt;

					Log.WriteJSON("name", "BasicMemInfo");
					Log.WriteJSON("lower", tmp.Lower);
					Log.WriteJSON("upper", tmp.Upper);
					break;
					
				case MultibootTagType.BootDev:
					auto tmp = cast(MultibootTagBootDev *)mbt;

					Log.WriteJSON("name", "BootDev");
					Log.WriteJSON("device", tmp.BiosDev);
					Log.WriteJSON("slice", tmp.Slice);
					Log.WriteJSON("part", tmp.Part);
					break;
					
				case MultibootTagType.MemoryMap:
					Log.WriteJSON("name", "MemoryMap");
					Log.WriteJSON("value", "[");

					for (auto tmp = &(cast(MultibootTagMemoryMap *)mbt).Entry;
					     cast(void *)tmp < (cast(void *)mbt + mbt.Size);
					     tmp = cast(MultibootMemoryMap *)(cast(ulong)tmp + (cast(MultibootTagMemoryMap *)mbt).EntrySize)) {
						Log.WriteJSON("{");
						Log.WriteJSON("base_addr", tmp.Address);
						Log.WriteJSON("length", tmp.Length);
						Log.WriteJSON("type", tmp.Type);
						Log.WriteJSON("}");
					}

					Log.WriteJSON("]");
					break;

				case MultibootTagType.VBE:
					break;
					
				case MultibootTagType.FrameBuffer:
					uint color;
					auto tmp = cast(MultibootTagFramebuffer *)mbt;
					
					switch (tmp.Common.FramebufferType) {
						case MultibootFramebufferType.Indexed:
							uint distance;
							uint bestDistance = 4 * 256 * 256;
							auto palette = &tmp.Palette;
							
							for (int i = 0; i < tmp.PaletteNumColors; i++) {
								distance = (0xFF - palette[i].Blue) * (0xFF - palette[i].Blue) +
									palette[i].Red * palette[i].Red +
									palette[i].Green * palette[i].Green;
								
								if (distance < bestDistance) {
									color = i;
									bestDistance = distance;
								}
							}
							break;
							
						case MultibootFramebufferType.RGB:
							color = ((1 << tmp.BlueMaskSize) - 1) << tmp.BlueFieldPos;
							break;
							
						case MultibootFramebufferType.EGAText:
							color = '\\' | 0x0100;
							break;
							
						default:
							color = 0xFFFFFFFF;
							break;
					}
					break;

				case MultibootTagType.ElfSections:
					break;

				case MultibootTagType.APM:
					break;

				case MultibootTagType.EFI32:
					break;

				case MultibootTagType.EFI64:
					break;

				case MultibootTagType.SMBIOS:
					break;

				case MultibootTagType.ACPIOld:
					break;

				case MultibootTagType.ACPINew:
					break;

				case MultibootTagType.Network:
					break;

				case MultibootTagType.EFIMemoryMap:
					break;

				case MultibootTagType.EFIBS:
					break;
					
				default:
					break;
			}

			Log.WriteJSON("}");
		}

		Log.WriteJSON("]");
	}
}