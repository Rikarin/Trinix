#############
#   Flags   #
#############
DFLAGS = -c -Wall -m64 -frelease -finline-functions -I../druntime/src -I../Kernel -I./Architectures/x86_64 -mcmodel=kernel -masm=intel -fversion=LogUserFriendly
CFLAGS = -m64 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -c -fPIC
LDFLAGS = -T Architectures/x86_64/Linker.ld -Map Linker.map
ASFLAGS = -f elf64

SRC += $(shell find -name "*.d")
SRC_SC += $(shell find -name "*.c")
SRC_SC += $(shell find -name "*.s")

OBJS += obj/Kernel.o
OBJS += $(patsubst %,obj/%,$(SRC_SC:=.o))


##############
#   Linker   #
##############
../../Root/System/Kernel: $(OBJS) ../druntime/lib/libdruntime-linux64.a
	@echo $$(($$(cat buildnum) + 1)) > buildnum
	@printf module\ Core.BuildInfo\;\\nenum\ BuildNumber\ =\ $$(($$(cat buildnum) + 1))\; > Core/BuildInfo.d
	@echo "Build number:" $$(cat buildnum)
	@ld -o $@ $(LDFLAGS) $+

clean:
	@echo "Cleaning..."
	@rm -rf obj
	@rm -rf ../../Root/System/Kernel


###############
#   Generic   #
###############
obj/Kernel.o: $(SRC)
	@echo "[ D ] Compiling kernel..."
	@mkdir -p $(@D)
	@gdc $(SRC) -o $@ $(DFLAGS)
	
obj/%.s.o: ./%.s
	@echo "[ASM]   " $< " ---> " $@
	@mkdir -p $(@D)
	@nasm -o $@ $< $(ASFLAGS)
	
obj/%.c.o: %.c
	@echo "[ C ]   " $< " ---> " $@
	@mkdir -p $(@D)
	@gcc -o $@ $< $(CFLAGS)