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

_SRC += $(wildcard Kernel/Drivers/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Bus/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Bus/PCI/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Common/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Disk/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Disk/IDE/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Disk/SCSI/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Disk/SCSI/AHCI/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Graphics/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Graphics/VESA/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Input/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Input/Keyboard/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Input/Mouse/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Port/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Power/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/Timer/*.[c|s])
_SRC += $(wildcard Kernel/Drivers/TTY/*.[c|s])

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

_D += $(wildcard Kernel/Drivers/*.d)
_D += $(wildcard Kernel/Drivers/Bus/*.d)
_D += $(wildcard Kernel/Drivers/Bus/PCI/*.d)
_D += $(wildcard Kernel/Drivers/Common/*.d)
_D += $(wildcard Kernel/Drivers/Disk/*.d)
_D += $(wildcard Kernel/Drivers/Disk/IDE/*.d)
_D += $(wildcard Kernel/Drivers/Disk/SCSI/*.d)
_D += $(wildcard Kernel/Drivers/Disk/SCSI/AHCI/*.d)
_D += $(wildcard Kernel/Drivers/Graphics/*.d)
_D += $(wildcard Kernel/Drivers/Graphics/VESA/*.d)
_D += $(wildcard Kernel/Drivers/Input/*.d)
_D += $(wildcard Kernel/Drivers/Input/Keyboard/*.d)
_D += $(wildcard Kernel/Drivers/Input/Mouse/*.d)
_D += $(wildcard Kernel/Drivers/Port/*.d)
_D += $(wildcard Kernel/Drivers/Power/*.d)
_D += $(wildcard Kernel/Drivers/Timer/*.d)
_D += $(wildcard Kernel/Drivers/TTY/*.d)


######################
#   Userspace apps   #
######################
_D += $(wildcard Userspace/*.d)
_D += $(wildcard Userspace/GUI/*.d)
_D += $(wildcard Userspace/Libs/*.d)

OBJS = $(patsubst %,$(OBJ_DIR)/%,$(_SRC:=.o))



#############
#   Flags   #
#############
DFLAGS = -c -O -de -wi -m64 -release -property -Idruntime/import -IKernel -IFramework -IKernel/Architectures/x86_64 -debug=only -vtls -g -allinst
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
	-vga vmware -monitor stdio -device ahci,id=ahci0
	


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
	@cd Framework; make

#druntime/lib/libdruntime-linux64.a:
runtime:
	@echo "[ D ] Compiling D runtime library..."
	@cd druntime; make -f posix.mak MODEL=64