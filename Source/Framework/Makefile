
NAME = ../../Root/Library/Framework.so
SRC += $(shell find -name "*.d")

DFLAGS = -c -Wall -m64 -frelease -finline-functions -I../druntime/src -masm=intel -fPIC -shared
LDFLAGS = -shared --export-dynamic -soname Framework.so.1


$(NAME): ../Kernel/obj/Core/Runtime.c.o ../druntime/lib/libdruntime-linux64.a
	@echo "[ D ] Compiling Framework..."
	@gdc $(SRC) -o obj.o $(DFLAGS)
	
	@ld -o $@ $(LDFLAGS) obj.o $+
	@rm -rf obj.o


clean:
	@echo "Cleaning..."
	@rm -rf $(NAME)