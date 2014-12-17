-include $(dir $(lastword $(MAKEFILE_LIST)))../../Makefile.cfg

DD   = ../druntime/dmd-2.066/src/dmd
NAME = Runtime.elf
SRC += $(shell find -name "*.d")

DFLAGS = -g -defaultlib=


$(NAME):
	@echo "[ D ] Compiling Runtime..."
	$(DD) $(SRC) -of=$(NAME) $(DFLAGS)	

clean:
	@echo "Cleaning..."
	@rm -rf $(NAME)