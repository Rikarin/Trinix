_SRC += $(wildcard Kernel/Architectures/x86_64/*.[d|c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Boot/*.[d|c|s])
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
_SRC += $(wildcard Kernel/Devices/PCI/*.[d|c|s])
_SRC += $(wildcard Kernel/Devices/ATA/*.[d|c|s])

_SRC += $(wildcard Kernel/Core/*.[d|c|s])
_SRC += $(wildcard Kernel/Resources/Keymaps/*.[d|c|s])

_SRC += $(wildcard Framework/System/*.[d|c|s])
_SRC += $(wildcard Framework/System/Collections/*.[d|c|s])
_SRC += $(wildcard Framework/System/Collections/Generic/*.[d|c|s])
_SRC += $(wildcard Framework/System/Diagnostics/*.[d|c|s])
_SRC += $(wildcard Framework/System/Drawing/*.[d|c|s])
_SRC += $(wildcard Framework/System/IO/*.[d|c|s])
_SRC += $(wildcard Framework/System/Threading/*.[d|c|s])
_SRC += $(wildcard Framework/System/Windows/*.[d|c|s])



######################
#   Userspace apps   #
######################
_SRC += $(wildcard Userspace/*.[d|c|s])
_SRC += $(wildcard Userspace/GUI/*.[d|c|s])
_SRC += $(wildcard Userspace/Libs/*.[d|c|s])



#_SRC += $(wildcard Framework/Beta/System/Collections/*.[d|c|s])
#_SRC += $(wildcard Framework/Beta/System/Collections/Generic/*.[d|c|s])
#_SRC += $(wildcard Framework/Beta/System/*.[d|c|s])

OBJS = $(patsubst %,$(OBJ_DIR)/%,$(_SRC:=.o))



#############
#   Flags   #
#############
DFLAGS = -c -O -m64 -release -property -Idruntime/import -IKernel -IFramework -IKernel/Architectures/x86_64 -debug=only -vtls
CFLAGS = -m64 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -c -g
LDFLAGS = -o Disk/Trinix-Kernel -T Kernel/Architectures/x86_64/Linker.ld -Map Linker.map
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
DISK = Trinix.img



all: Disk/Trinix-Kernel
img: Trinix.img



##############
#   Linker   #
##############
Disk/Trinix-Kernel: $(OBJS)
	@echo $$(($$(cat buildnum) + 1)) > buildnum
	@echo "Build number:" $$(cat buildnum)
	@ld $(LDFLAGS) $(OBJS) druntime/lib/libdruntime-linux64.a



#############
#   Debug   #
#############
debug: all Trinix.img
	@${EMU} -hda Trinix.img -boot c -m 512 -serial /dev/ttyS0 \
	-vga vmware -monitor stdio
	


#################
#   D runtime   #
#################
runtime:
	@cd druntime; make -f posix.mak MODEL=64



##################
#   Disk image   #
##################
$(DISK): Disk/Trinix-Kernel
	@echo "Generating a Hard Disk image..."
	@rm -f $(DISK)
	
	@-dito-generate $(DISK) 100M 50M
	@dito-format $(DISK):1 ext2
	@dito-format $(DISK):2 ext2

	@losetup /dev/loop0 $(DISK)
	@losetup -o 32256 /dev/loop1 $(DISK)

	@mkdir -p tmp
	@mount /dev/loop1 tmp
	@cp -rf Disk/* tmp/
	
	@-grub-install --recheck /dev/loop0

	@umount tmp
	@losetup -d /dev/loop1
	@losetup -d /dev/loop0
	@rm -rf tmp

	@echo "Hard disk image is ready!"


	
#############
#   Clean   #
#############
clean:
	@rm -rf $(OBJ_DIR)
	@rm -rf Trinix.img
	@rm -rf Disk/Trinix-Kernel



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
