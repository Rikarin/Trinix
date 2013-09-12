#_SRC = Kernel/Boot.s Kernel/Start.s
_SRC += $(wildcard Kernel/Architectures/x86_64/*.[d|c|s])
_SRCa += $(wildcard Kernel/Architectures/x86_64/Boot/*.[d|c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Core/*.[d|c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Specs/*.[d|c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Architectures/*.[d|c|s])

_SRC += $(wildcard Kernel/MemoryManager/*.[d|c|s])
_SRC += $(wildcard Kernel/SyscallManager/*.[d|c|s])
_SRC += $(wildcard Kernel/TaskManager/*.[d|c|s])
_SRC += $(wildcard Kernel/VFSManager/*.[d|c|s])

_SRC += $(wildcard Kernel/FileSystem/*.[d|c|s])

_SRC += $(wildcard Kernel/Devices/*.[d|c|s])
_SRC += $(wildcard Kernel/Devices/Keyboard/*.[d|c|s])
_SRC += $(wildcard Kernel/Devices/Mouse/*.[d|c|s])
_SRC += $(wildcard Kernel/Devices/Display/*.[d|c|s])
_SRC += $(wildcard Kernel/Devices/Port/*.[d|c|s])

_SRC += $(wildcard Kernel/Core/*.[d|c|s])
_SRC += $(wildcard Kernel/Resources/Keymaps/*.[d|c|s])

_SRC += $(wildcard Framework/System/*.[d|c|s])
_SRC += $(wildcard Framework/System/Collections/*.[d|c|s])
_SRC += $(wildcard Framework/System/Collections/Generic/*.[d|c|s])
_SRC += $(wildcard Framework/System/Threading/*.[d|c|s])
_SRC += $(wildcard Framework/System/Drawing/*.[d|c|s])

OBJS = $(patsubst %,$(OBJ_DIR)/%,$(_SRCa:=.o))



#############
#   Flags   #
#############
DFLAGS = -c -m64 -release -property -Idruntime/import -IKernel -IFramework -IKernel/Architectures/x86_64 -debug=only
CFLAGS = -m64 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -c -g
LDFLAGS = -T Kernel/Architectures/x86_64/Linker.ld -Map Linker.map
ASFLAGS = -f elf64



###################
#   Directories   #
###################
OBJ_DIR = Obj
SRC_DIR = .
OUT_DIR = Build



#################
#   Variables   #
#################
EMU = qemu-system-x86_64
GENEXT = genext2fs
DISK_SIZE = 12207 #524288



all: $(OBJS) Disk/TrinityOS-Kernel



##############
#   Linker   #
##############
Disk/TrinityOS-Kernel: $(OBJS)
	@echo $$(($$(cat buildnum) + 1)) > buildnum
	@echo "Build number:" $$(cat buildnum)
	@ld $(LDFLAGS) -o Disk/TrinityOS-Kernel $(OBJS) druntime/lib/libdruntime-linux64.a



#############
#   Debug   #
#############
debug: all TrinityOS.img
	@${EMU} -hda TrinityOS.img -boot c -m 512 -serial /dev/ttyS0 \
	-vga std -monitor stdio #-smp 8 #-s -S
	


#################
#   D runtime   #
#################
runtime:
	@cd druntime; make -f posix.mak MODEL=64



##################
#   Disk image   #
##################
TrinityOS.img: Disk/TrinityOS-Kernel
	@echo "Generating a Hard Disk image..."
	@rm -f TrinityOS.img
	#@${GENEXT} -B 4096 -d Disk -q -b ${DISK_SIZE} -N 4096 TrinityOS.img
	@grub-mkrescue -o TrinityOS.img Disk
	@echo "Hard disk image is ready!"


	
#############
#   Clean   #
#############
clean:
	@rm -rf $(OBJ_DIR)



###############
#   Generic   #
###############
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