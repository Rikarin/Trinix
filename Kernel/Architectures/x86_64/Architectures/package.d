module Architectures;

public import Architectures.CPU;
public import Architectures.Main;
public import Architectures.Multiprocessor;
public import Architectures.Paging;
public import Architectures.Port;

public import Architectures.x86_64.Linker;
public import Architectures.x86_64.Core.GDT;
public import Architectures.x86_64.Core.IDT;
public import Architectures.x86_64.Core.TSS;
public import Architectures.x86_64.Core.PIC;
public import Architectures.x86_64.Core.Info;
public import Architectures.x86_64.Core.IOAPIC;
public import Architectures.x86_64.Core.LocalAPIC;
public import Architectures.x86_64.Core.Descriptor;