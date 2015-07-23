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
 * 
 * TODO:
 *      o Implement Identifier and add multiCPU support
 *      o In PrintCacheInfo we can use automatic serialization
 */

module Architecture.CPU;

import Core;
import Architecture;
import ObjectManager;
import MemoryManager;
import Architectures.x86_64.Core;


abstract final class CPU {
    //TODO: deprecated private __gshared ubyte*[256] m_stacks;
    private __gshared ProcessorInfo[256] m_processorInfo;

    @property static int Identifier()             { return 0;         }
    @property static TaskStateSegment* TSSTable() { return TSS.Table; }

    static void Initialize() {
        Logger.Write("SSE, ");
        Port.InitializeSSE();
        Port.EnableSSE();

        Logger.Write("GDT, ");
        GDT.Initialize();

        Logger.Write("TSS, ");
        TSS.Initialize();

        Log("IDT");
        IDT.Initialize();

        Log("CacheInfo of processor #%d", Identifier);
        GetCacheInfo();
        PrintCacheInfo(Identifier);
    }

    private static void GetCacheInfo() {
        uint eax, ebx, ecx, edx;
        uint count, temp;
        ulong saveRBX;
        
        asm {
            mov saveRBX, RBX;
        }
		
        eax   = Port.cpuidAX(0x02);
        count = eax & 0xFF;
		
        asm {
            mov ebx, EBX;
            mov ecx, ECX;
            mov edx, EDX;
        }

        for (uint i = 0; i < count; i++) {
            temp = (eax >> 31) & 1;
            if (!temp)
                ExamineRegister(eax);
            
            temp = (ebx >> 31) & 1;
            if (!temp)
                ExamineRegister(ebx);
            
            temp = (ecx >> 31) & 1;
            if (!temp)
                ExamineRegister(ecx);
            
            temp = (edx >> 31) & 1;
            if (!temp)
                ExamineRegister(edx);
                
            eax = Port.cpuidAX(0x02);
            asm {
                mov ebx, EBX;
                mov ecx, ECX;
                mov edx, EDX;
            }
        }
        
        asm {
            mov RBX, saveRBX;
        }
    }

    private static void ExamineRegister(uint reg) {
        for (uint i = 0; i < 4; i++) {
            uint temp = reg >> (8 * i);
            temp = temp & 0xFF;

            switch (temp) {
                case 0x06:
                    m_processorInfo[Identifier].L1ICache.Length = 8192;
                    m_processorInfo[Identifier].L1ICache.Associativity = 4;
                    m_processorInfo[Identifier].L1ICache.BlockSize = 32;
                    break;

                case 0x08:
                    m_processorInfo[Identifier].L1ICache.Length = 16384;
                    m_processorInfo[Identifier].L1ICache.Associativity = 4;
                    m_processorInfo[Identifier].L1ICache.BlockSize = 32;
                    break;

                case 0x09:
                    m_processorInfo[Identifier].L1ICache.Length = 16384;
                    m_processorInfo[Identifier].L1ICache.Associativity = 4;
                    m_processorInfo[Identifier].L1ICache.BlockSize = 64;
                    break;

                case 0x0A:
                    m_processorInfo[Identifier].L1DCache.Length = 8192;
                    m_processorInfo[Identifier].L1DCache.Associativity = 2;
                    m_processorInfo[Identifier].L1DCache.BlockSize = 32;
                    break;

                case 0x0C:
                    m_processorInfo[Identifier].L1DCache.Length = 16384;
                    m_processorInfo[Identifier].L1DCache.Associativity = 4;
                    m_processorInfo[Identifier].L1DCache.BlockSize = 32;
                    break;

                case 0x0D:
                    m_processorInfo[Identifier].L1DCache.Length = 16384;
                    m_processorInfo[Identifier].L1DCache.Associativity = 4;
                    m_processorInfo[Identifier].L1DCache.BlockSize = 64;
                    break;
                case 0x0E:
                    m_processorInfo[Identifier].L1DCache.Length = 24576;
                    m_processorInfo[Identifier].L1DCache.Associativity = 6;
                    m_processorInfo[Identifier].L1DCache.BlockSize = 64;
                    break;

                case 0x21:
                    m_processorInfo[Identifier].L2Cache.Length = 262144;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    break;

                case 0x2C:
                    m_processorInfo[Identifier].L1DCache.Length = 32768;
                    m_processorInfo[Identifier].L1DCache.Associativity = 8;
                    m_processorInfo[Identifier].L1DCache.BlockSize = 64;
                    break;

                case 0x30:
                    m_processorInfo[Identifier].L1ICache.Length = 32768;
                    m_processorInfo[Identifier].L1ICache.Associativity = 8;
                    m_processorInfo[Identifier].L1ICache.BlockSize = 64;
                    break;

                case 0x41:
                    m_processorInfo[Identifier].L2Cache.Length = 131072;
                    m_processorInfo[Identifier].L2Cache.Associativity = 4;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 32;
                    break;

                case 0x42:
                    m_processorInfo[Identifier].L2Cache.Length = 262144;
                    m_processorInfo[Identifier].L2Cache.Associativity = 4;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 32;
                    break;

                case 0x43:
                    m_processorInfo[Identifier].L2Cache.Length = 524288;
                    m_processorInfo[Identifier].L2Cache.Associativity = 4;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 32;
                    break;

                case 0x44:
                    m_processorInfo[Identifier].L2Cache.Length = 1048576;
                    m_processorInfo[Identifier].L2Cache.Associativity = 4;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 32;
                    break;

                case 0x45:
                    m_processorInfo[Identifier].L2Cache.Length = 2097152;
                    m_processorInfo[Identifier].L2Cache.Associativity = 4;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 32;
                    break;

                case 0x48:
                    m_processorInfo[Identifier].L2Cache.Length = 3145728;
                    m_processorInfo[Identifier].L2Cache.Associativity = 12;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    break;

                case 0x60:
                    m_processorInfo[Identifier].L1DCache.Length = 16384;
                    m_processorInfo[Identifier].L1DCache.Associativity = 8;
                    m_processorInfo[Identifier].L1DCache.BlockSize = 64;
                    break;

                case 0x66:
                    m_processorInfo[Identifier].L1DCache.Length = 8192;
                    m_processorInfo[Identifier].L1DCache.Associativity = 4;
                    m_processorInfo[Identifier].L1DCache.BlockSize = 64;
                    break;

                case 0x67:
                    m_processorInfo[Identifier].L1DCache.Length = 16384;
                    m_processorInfo[Identifier].L1DCache.Associativity = 4;
                    m_processorInfo[Identifier].L1DCache.BlockSize = 64;
                    break;

                case 0x68:
                    m_processorInfo[Identifier].L1DCache.Length = 32768;
                    m_processorInfo[Identifier].L1DCache.Associativity = 4;
                    m_processorInfo[Identifier].L1DCache.BlockSize = 64;
                    break;

                case 0x78:
                    m_processorInfo[Identifier].L2Cache.Length = 1048576;
                    m_processorInfo[Identifier].L2Cache.Associativity = 4;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    break;

                case 0x79:
                    m_processorInfo[Identifier].L2Cache.Length = 131072;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    m_processorInfo[Identifier].L2Cache.LinesPerSector = 2;
                    break;

                case 0x7A:
                    m_processorInfo[Identifier].L2Cache.Length = 262144;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    m_processorInfo[Identifier].L2Cache.LinesPerSector = 2;
                    break;

                case 0x7B:
                    m_processorInfo[Identifier].L2Cache.Length = 524288;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    m_processorInfo[Identifier].L2Cache.LinesPerSector = 2;
                    break;

                case 0x7C:
                    m_processorInfo[Identifier].L2Cache.Length = 1048576;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    m_processorInfo[Identifier].L2Cache.LinesPerSector = 2;
                    break;

                case 0x7D:
                    m_processorInfo[Identifier].L2Cache.Length = 2097152;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    break;

                case 0x7F:
                    m_processorInfo[Identifier].L2Cache.Length = 524288;
                    m_processorInfo[Identifier].L2Cache.Associativity = 2;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    break;

                case 0x80:
                    m_processorInfo[Identifier].L2Cache.Length = 524288;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    break;

                case 0x82:
                    m_processorInfo[Identifier].L2Cache.Length = 262144;
                    m_processorInfo[Identifier].L2Cache.Associativity = 3;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 32;
                    break;

                case 0x83:
                    m_processorInfo[Identifier].L2Cache.Length = 524288;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 32;
                    break;

                case 0x84:
                    m_processorInfo[Identifier].L2Cache.Length = 1048576;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 32;
                    break;

                case 0x85:
                    m_processorInfo[Identifier].L2Cache.Length = 2097152;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 32;
                    break;

                case 0x86:
                    m_processorInfo[Identifier].L2Cache.Length = 524288;
                    m_processorInfo[Identifier].L2Cache.Associativity = 4;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    break;

                case 0x87:
                    m_processorInfo[Identifier].L2Cache.Length = 1048576;
                    m_processorInfo[Identifier].L2Cache.Associativity = 8;
                    m_processorInfo[Identifier].L2Cache.BlockSize = 64;
                    break;

                case 0xFF:
                    Log("Not supported cache info for CPUID.EAX=0x02");
                    return;

                default:
            }
        }
    }

    private static void PrintCacheInfo(int identifier) {
        Log("Name: L1ICache");
        with (m_processorInfo[identifier].L1ICache)
            Log("Assoc = %x, Length = %x, BlockSize = %x, LinesPerSector = %x", Associativity, Length, BlockSize, LinesPerSector);

        Log("Name: L1DCache");
        with (m_processorInfo[identifier].L1DCache)
            Log("Assoc = %x, Length = %x, BlockSize = %x, LinesPerSector = %x", Associativity, Length, BlockSize, LinesPerSector);

        Log("Name: L2Cache");
        with (m_processorInfo[identifier].L2Cache)
            Log("Assoc = %x, Length = %x, BlockSize = %x, LinesPerSector = %x", Associativity, Length, BlockSize, LinesPerSector);

        Log("Name: L3Cache");
        with (m_processorInfo[identifier].L3Cache)
            Log("Assoc = %x, Length = %x, BlockSize = %x, LinesPerSector = %x", Associativity, Length, BlockSize, LinesPerSector);
    }

    struct Cache {
        uint Associativity;
        uint Length;
        uint BlockSize;
        uint LinesPerSector;
    }
    
    struct ProcessorInfo {
        Cache L1ICache;
        Cache L1DCache;
        Cache L2Cache;
        Cache L3Cache;
    }
}