/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 *
 * This file is part of Trinix Operating System and is released under Trinix
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 *
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 *
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Core.Multiboot;

import Core;
import Architecture;
import MemoryManager;


enum MultibootTagType {
    Align = 8,
    End   = 0,
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
    Available = 1,
    Reserved,
    ACPIReclaimable,
    NVS,
    BadRAM
}

struct MultibootColor {
align(1):
    ubyte Red;
    ubyte Green;
    ubyte Blue;
}

struct MultibootMemoryMap {
align(1):
    ulong Address;
    ulong Length;
    uint Type;
    private uint m_zero;
}

struct MultibootTag {
align(1):
    uint Type;
    uint Size;
}

struct MultibootTagString {
align(1):
    uint Type;
    uint Size;
    char String;
}

struct MultibootTagModule {
align(1):
    uint Type;
    uint Size;
    uint ModStart;
    uint ModEnd;
    char String;
}

struct MultibootTagBasicMemInfo {
align(1):
    uint Type;
    uint Size;
    uint Lower;
    uint Upper;
}

struct MultibootTagBootDev {
align(1):
    uint Type;
    uint Size;
    uint BiosDev;
    uint Slice;
    uint Part;
}

struct MultibootTagMemoryMap {
align(1):
    uint Type;
    uint Size;
    uint EntrySize;
    uint EntryVersion;
    MultibootMemoryMap Entry;
}

struct MultibootTagFramebufferCommon {
align(1):
    uint Type;
    uint Size;

    ulong Address;
    uint Pitch;
    uint Width;
    uint Height;
    ubyte Bpp;
    ubyte FramebufferType;
    private ushort m_reserved;
}

struct MultibootTagFramebuffer {
align(1):
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
    private enum {
        HEADER_MAGIC     = 0xE85250D6,
        BOOTLOADER_MAGIC = 0x36D76289
    }

    __gshared MultibootTagModule*[256] Modules;
    __gshared int ModulesCount;

    static void ParseHeader(uint magic, void* info) {
        if (magic != BOOTLOADER_MAGIC) {
            Log("Error: Bad multiboot 2 magic: %d", magic);
            Port.Halt();
        }

        if (info & 7) {
            Log("Error: Unaligned MBI");
            Port.Halt();
        }

        Log("Size: %x", *cast(ulong *)info);
        Log("-----------------");
        MultibootTag* mbt = cast(MultibootTag *)(info + LinkerScript.KernelBase + 8);
        for (; mbt.Type != MultibootTagType.End; mbt = cast(MultibootTag *)(cast(ulong)mbt + ((mbt.Size + 7UL) & ~7UL))) {
            Log("Type %x, Size: %d", mbt.Type, mbt.Size);

            switch (mbt.Type) {
                case MultibootTagType.CmdLine:
                    auto tmp = cast(MultibootTagString *)mbt;
                    char* str = &tmp.String;

                    Log("Name: CMDLine, Value: %s", cast(string)str[0 .. tmp.Size - 9]);
                    break;

                case MultibootTagType.BootLoaderName:
                    auto tmp = cast(MultibootTagString *)mbt;
                    char* str = &tmp.String;

                    Log("Name: BootLoaderName, Value: %s", cast(string)str[0 .. tmp.Size - 9]);
                    break;

                case MultibootTagType.Module:
                    auto tmp = cast(MultibootTagModule *)mbt;
                    if (((tmp.ModEnd + 0xFFF) & ~0xFFFUL) > PhysicalMemory.MemoryStart)
                        PhysicalMemory.MemoryStart = (tmp.ModEnd + 0xFFF) & ~0xFFFUL;

                    char* str = &tmp.String;
                    Modules[ModulesCount++] = tmp;

                    Log("Name: Module, Start: %x, End: %x, CMD: %s", tmp.ModStart, tmp.ModEnd, cast(string)str[0 .. tmp.Size - 17]);
                    break;

                case MultibootTagType.BasicMemInfo:
                    auto tmp = cast(MultibootTagBasicMemInfo *)mbt;
                    Log("Name: BasicMemInfo, Lower: %x, Upper: %x", tmp.Lower, tmp.Upper);
                    break;

                case MultibootTagType.BootDev:
                    auto tmp = cast(MultibootTagBootDev *)mbt;
                    Log("Name: BootDev, Device: %x, Slice: %x, Part: %x", tmp.BiosDev, tmp.Slice, tmp.Part);
                    break;

                case MultibootTagType.MemoryMap:
                    Log("MemoryMap ---->");

                    for (auto tmp = &(cast(MultibootTagMemoryMap *)mbt).Entry;
                         cast(void *)tmp < (cast(void *)mbt + mbt.Size);
                         tmp = cast(MultibootMemoryMap *)(cast(ulong)tmp + (cast(MultibootTagMemoryMap *)mbt).EntrySize)) {
                        RegionInfo regInfo;
                        regInfo.Start  = tmp.Address;
                        regInfo.Length = tmp.Length;
                        regInfo.Type   = cast(RegionType)tmp.Type;

                        PhysicalMemory.AddRegion(regInfo);
                        Log("BaseAddr: %x, Length: %x, Type: %x", tmp.Address, tmp.Length, tmp.Type);
                    }

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
                    Log("Multiboot2 Error tag type");
                    break;
            }
        }
    }
}
