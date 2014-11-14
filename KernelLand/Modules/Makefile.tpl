DFLAGS = -c -O -de -wi -m64 -release -inline -property -fPIC -I../../../druntime/src -I../../../Kernel -I../../../Kernel/Architectures/x86_64

ifneq ($(CATEGORY),)
	FULLNAME := $(CATEGORY)_$(NAME)
else
	FULLNAME := $(NAME)
endif

all: install
	
$(FULLNAME).kext: $(FULLNAME).o
	@ld --allow-shlib-undefined -shared -nostdlib --oformat elf64-x86-64 -o $@ $(LDFLAGS) $+

$(FULLNAME).o: $(SRC)
	@echo [ D ] Compiling module: $(CATEGORY)/$(NAME)
	@dmd $+ -of$(FULLNAME).o $(DFLAGS)
	
install: $(FULLNAME).kext
	@echo Installing module: $(CATEGORY)/$(NAME) to /System/Modules/$+
	@cp $(FULLNAME).kext ../../../../Root/System/Modules

clean:
	@echo "Cleaning..."
	@rm -rf $(FULLNAME).o
	@rm -rf $(FULLNAME).kext
	@rm -rf ../../../../Root/System/Modules/$(FULLNAME).kext