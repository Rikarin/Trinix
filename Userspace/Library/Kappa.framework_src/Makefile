-include $(dir $(lastword $(MAKEFILE_LIST)))../Makefile.cfg

OUTPUT 	= $(TRXROOT)/Library/Kappa.framework
NAME 	= Kappa.so.0.1.0
SRC    += $(shell find -name "*.d")
BIN		= $(OUTPUT)/$(NAME)

IMPORTDIR	:= $(OUTPUT)/Import/
IMPORT		:= $(addprefix $(IMPORTDIR), $(SRC))

DFLAGS 	= -c -Wall -m64 -frelease -finline-functions -I../druntime/src -masm=intel -fPIC -shared
LDFLAGS = -shared --export-dynamic -soname Kappa.so.0.1

.PHONY: all clean install

install: all $(IMPORT)
	
all: $(BIN)
	@make -C ../crt0.o_src

clean:
	@echo "Cleaning..."
	@rm -rf $(OUTPUT)
	@make clean -C ../crt0.o_src
	
	
$(BIN): ../../tmp/druntime/lib/libdruntime-linux64.a
	@echo "[ D ] Compiling Framework..."
	@$(MKDIR) $(OUTPUT)
	@$(DD) $(SRC) -o obj.o $(DFLAGS)
	
	@ld -o $@ $(LDFLAGS) obj.o $+
	@rm -rf obj.o
	
$(IMPORTDIR)%.d: %.d
	@echo --- Generating import $@
	@$(MKDIR) $(dir $@)
	@$(DD) $(DFLAGS) -c -fintfc -fintfc-file=$@ $< -o /dev/null