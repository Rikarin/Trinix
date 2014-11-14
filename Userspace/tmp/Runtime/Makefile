#############
#   Flags   #
#############
DFLAGS = -c -O -de -wi -m64 -g -inline -property -vtls -fPIC
CFLAGS = -m64 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -c -fPIC
LDFLAGS = -executable -Map Linker.map
ASFLAGS = -f elf64

SRC += $(shell find -name "*.d")
SRC_SC += $(shell find -name "*.c")
SRC_SC += $(shell find -name "*.s")

OBJS += obj/Runtime.o
OBJS += $(patsubst %,obj/%,$(SRC_SC:=.o))


##############
#   Linker   #
##############
Runtime.a: $(OBJS)
	@ld -o $@ $(LDFLAGS) $+

clean:
	@echo "Cleaning..."
	@rm -rf obj


###############
#   Generic   #
###############
obj/Runtime.o: $(SRC)
	@echo "[ D ] Compiling runtime..."
	@dmd $(SRC) -of$@ $(DFLAGS)
	
obj/%.s.o: ./%.s
	@echo "[ASM]   " $< " ---> " $@
	@mkdir -p $(@D)
	@nasm -o $@ $< $(ASFLAGS)
	
obj/%.c.o: %.c
	@echo "[ C ]   " $< " ---> " $@
	@mkdir -p $(@D)
	@gcc -o $@ $< $(CFLAGS)