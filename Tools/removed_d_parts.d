
void LoadModules() {
    new DirectoryNode(DeviceManager.DevFS, FileAttributes("BootModules"));

    Log("Multiboot modules count: %d", Multiboot.ModulesCount);
    foreach (tmp; Multiboot.Modules[0 .. Multiboot.ModulesCount]) {
        char* str    = &tmp.String;
        ulong addr   = tmp.ModStart | LinkerScript.KernelBase;
        ulong length = tmp.ModEnd - tmp.ModStart;

        Log("Start: %16x, Length: %16x, CMD: %s", addr, length, cast(string)str[0 .. tmp.Size - 17]);

        if (!ModuleManager.LoadMemory((cast(byte *)addr)[0 .. length], cast(string)str[0 .. tmp.Size - 17]))
            Log("Module: Unable to load module located at %x", addr);
        else
            Log("Module: module was successfuly loaded");


        /*  auto elf = Elf.Load(cast(void *)(cast(ulong)LinkerScript.KernelBase | cast(ulong)tmp.ModStart), "/System/Modules/lol.html");
        if (elf)
            elf.Relocate(null);*/
    }
}