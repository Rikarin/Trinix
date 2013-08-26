-include $(dir $(lastword $(MAKEFILE_LIST)))../../Makefile.cfg

NAME = Test.elf
SRC += $(shell find -name "*.d")

DFLAGS =  -I../druntime/src -I$(TRXROOT)/Library/Kappa.framework/Import/
DFLAGS += -L $(TRXROOT)/Library/Kappa.framework/ -lgcc -l:Kappa.so.0.1.0
#LDFLAGS = -nostdlib -L/os/Root/Library -l :Framework.so -e _d_run_main


$(NAME):
	@echo "[ D ] Compiling test..."
	$(DD) $(SRC) -o $(NAME) $(DFLAGS)	

clean:
	@echo "Cleaning..."
	@rm -rf $(NAME)