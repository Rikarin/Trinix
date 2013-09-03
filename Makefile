DFLAGS = -c -m64 -release -property -Idruntime/import -IKernel -IFramework -IKernel/Architectures/x86_64 -debug=only
CFLAGS = -m64 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -c -g
LDFLAGS = -T Kernel/Architectures/x86_64/Linker.ld -Map Build/Linker.map
ASFLAGS = -f elf64

OBJ_DIR = Obj
SRC_DIR = .
OUT_DIR = Build

_SRC = Kernel/Start.s
_SRC += $(wildcard Kernel/Architectures/x86_64/*.[d|c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Core/*.[d|c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Specs/*.[d|c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Architectures/*.[d|c|s])

_SRC += $(wildcard Kernel/MemoryManager/*.[d|c|s])
_SRC += $(wildcard Kernel/DeviceManager/*.[d|c|s])
_SRC += $(wildcard Kernel/VTManager/*.[d|c|s])
_SRC += $(wildcard Kernel/SyscallManager/*.[d|c|s])

_SRC += $(wildcard Kernel/FileSystem/*.[d|c|s])

_SRC += $(wildcard Kernel/Devices/*.[d|c|s])
_SRC += $(wildcard Kernel/Devices/Keyboard/*.[d|c|s])
_SRC += $(wildcard Kernel/Devices/Display/*.[d|c|s])
_SRC += $(wildcard Kernel/Devices/Port/*.[d|c|s])

_SRC += $(wildcard Kernel/Core/*.[d|c|s])
_SRC += $(wildcard Kernel/VFS/*.[d|c|s])
_SRC += $(wildcard Kernel/Resources/Keymaps/*.[d|c|s])

_SRC += $(wildcard Framework/System/*.[d|c|s])
_SRC += $(wildcard Framework/System/Collections/*.[d|c|s])
_SRC += $(wildcard Framework/System/Collections/Generic/*.[d|c|s])
_SRC += $(wildcard Framework/System/Threading/*.[d|c|s])
_SRC += $(wildcard Framework/System/Drawing/*.[d|c|s])

OBJS = $(patsubst %,$(OBJ_DIR)/%,$(_SRC:=.o))


all: $(OBJS) link bloader
	@cat Build/BootLoader.bin > Build/Boot.bin
	@cat Build/Kernel.bin >> Build/Boot.bin
	@cat Build/Kernel.bin >> Build/Boot.bin

clean:
	@rm -rf $(OBJ_DIR) $(OUT_DIR)/*

link:
	@mkdir -p Build

	@echo $$(($$(cat buildnum) + 1)) > buildnum
	@echo "Build number:" $$(cat buildnum)

	@ld $(LDFLAGS) -o $(OUT_DIR)/Kernel.bin $(OBJS) druntime/lib/libdruntime-linux64.a

bloader:
	@cd BootLoader; make -s

debug: all
	@qemu-system-x86_64 -hda Build/Boot.bin -boot c -m 512 -serial /dev/ttyS0 \
	-vga std -monitor stdio #-smp 8 #-s -S
	
	
runtime:
	@cd druntime; make -f posix.mak MODEL=64
	

$(OBJ_DIR)/%.d.o: $(SRC_DIR)/%.d
	@echo "[ D ]   " $< " ---> " $@
	@mkdir -p $(@D)
	@dmd -of$@ $< $(DFLAGS)

$(OBJ_DIR)/%.c.o: $(SRC_DIR)/%.c
	@echo "[ C ]   " $< " ---> " $@
	@mkdir -p $(@D)
	@gcc -o $@ $< $(CFLAGS)

$(OBJ_DIR)/%.s.o: $(SRC_DIR)/%.s
	@echo "[ASM]   " $< " ---> " $@
	@mkdir -p $(@D)
	@nasm -o $@ $< $(ASFLAGS)