_SRC += $(wildcard Kernel/Architectures/x86_64/*.[c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Boot/*.[c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Core/*.[c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Specs/*.[c|s])
_SRC += $(wildcard Kernel/Architectures/x86_64/Architectures/*.[c|s])

_SRC += $(wildcard Kernel/Core/*.[c|s])
_SRC += $(wildcard Kernel/FileSystem/*.[c|s])

_SRC += $(wildcard Kernel/VFSManager/*.[c|s])
_SRC += $(wildcard Kernel/TaskManager/*.[c|s])
_SRC += $(wildcard Kernel/MemoryManager/*.[c|s])
_SRC += $(wildcard Kernel/SyscallManager/*.[c|s])

_SRC += $(wildcard Kernel/Devices/*.[c|s])
_SRC += $(wildcard Kernel/Devices/PCI/*.[c|s])
_SRC += $(wildcard Kernel/Devices/Disk/*.[c|s])
_SRC += $(wildcard Kernel/Devices/Port/*.[c|s])
_SRC += $(wildcard Kernel/Devices/Mouse/*.[c|s])
_SRC += $(wildcard Kernel/Devices/Display/*.[c|s])
_SRC += $(wildcard Kernel/Devices/Keyboard/*.[c|s])



#====================================================================================
_D += $(wildcard Kernel/Architectures/x86_64/*.d)
_D += $(wildcard Kernel/Architectures/x86_64/Boot/*.d)
_D += $(wildcard Kernel/Architectures/x86_64/Core/*.d)
_D += $(wildcard Kernel/Architectures/x86_64/Specs/*.d)
_D += $(wildcard Kernel/Architectures/x86_64/Architectures/*.d)

_D += $(wildcard Kernel/Core/*.d)
_D += $(wildcard Kernel/FileSystem/*.d)

_D += $(wildcard Kernel/VFSManager/*.d)
_D += $(wildcard Kernel/TaskManager/*.d)
_D += $(wildcard Kernel/MemoryManager/*.d)
_D += $(wildcard Kernel/SyscallManager/*.d)

_D += $(wildcard Kernel/Devices/*.d)
_D += $(wildcard Kernel/Devices/PCI/*.d)
_D += $(wildcard Kernel/Devices/Disk/*.d)
_D += $(wildcard Kernel/Devices/Port/*.d)
_D += $(wildcard Kernel/Devices/Mouse/*.d)
_D += $(wildcard Kernel/Devices/Display/*.d)
_D += $(wildcard Kernel/Devices/Keyboard/*.d)



######################
#   Userspace apps   #
######################
#_SRC += $(wildcard Userspace/*.[c|s])
#_SRC += $(wildcard Userspace/GUI/*.[c|s])
#_SRC += $(wildcard Userspace/Libs/*.[c|s])

OBJS = $(patsubst %,$(OBJ_DIR)/%,$(_SRC:=.o))



#############
#   Flags   #
#############
DFLAGS = -c -O -de -w -m64 -release -property -Idruntime/import -IKernel -IFramework -IKernel/Architectures/x86_64 -debug=only -vtls -g -allinst
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
Disk/Trinix-Kernel: $(OBJS) $(OBJ_DIR)/Kernel.o druntime/lib/libdruntime-linux64.a $(OBJ_DIR)/Framework.lib
	@echo $$(($$(cat buildnum) + 1)) > buildnum
	@echo "Build number:" $$(cat buildnum)
	@ld $(LDFLAGS) $+



#############
#   Debug   #
#############
debug: all Trinix.img
	@${EMU} -hda Trinix.img -hdb disk.img -boot c -m 512 -serial /dev/ttyS0 \
	-vga vmware -monitor stdio
	


##################
#   Disk image   #
##################
$(DISK): Disk/Trinix-Kernel
	@echo "Generating a Hard Disk image..."
	@rm -f $(DISK)
	@grub-mkrescue -o $(DISK) Disk


fixme:
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
$(OBJ_DIR)/Kernel.o: $(_D)
	@echo "[ D ] Compiling kernel..."
	@dmd $(_D) -of$(OBJ_DIR)/Kernel.o $(DFLAGS)

$(OBJ_DIR)/%.c.o: $(SRC_DIR)/%.c
	@echo "[ C ]   " $< " ---> " $@
	@mkdir -p $(@D)
	@gcc -o $@ $< $(CFLAGS)

$(OBJ_DIR)/%.s.o: $(SRC_DIR)/%.s
	@echo "[ASM]   " $< " ---> " $@
	@mkdir -p $(@D)
	@nasm -o $@ $< $(ASFLAGS)

$(OBJ_DIR)/Framework.lib:
	@echo "[ D ] Compiling Framework..."
	cd Framework; make

druntime/lib/libdruntime-linux64.a:
	@echo "[ D ] Compiling D runtime library..."
	@cd druntime; make -f posix.mak MODEL=64