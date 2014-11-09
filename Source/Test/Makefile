
NAME = ../../Root/Test.elf
SRC += $(shell find -name "*.d")

DFLAGS = -c -Wall -m64 -frelease -finline-functions -I../druntime/src -I../Framework -masm=intel
LDFLAGS = -nostdlib -L/os/Root/Library -l :Framework.so -e _d_run_main


$(NAME):
	@echo "[ D ] Compiling test..."
	@gdc $(SRC) -o obj.o $(DFLAGS)
	
	@ld -o $@ $(LDFLAGS) obj.o $+
	@rm -rf obj.o
	

clean:
	@echo "Cleaning..."
	@rm -rf $(NAME)