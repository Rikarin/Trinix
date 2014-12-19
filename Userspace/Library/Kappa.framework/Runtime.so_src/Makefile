-include $(dir $(lastword $(MAKEFILE_LIST)))../../Makefile.cfg

OUTPUT 	= $(TRXROOT)/System/Library/Frameworks/Kappa.framework
NAME 	= DRuntime.so.0.1.0
SRC    += $(shell find -name "*.d")
BIN		= $(OUTPUT)/$(NAME)

IMPORTDIR	:= $(OUTPUT)/Import/
IMPORT		:= $(addprefix $(IMPORTDIR), $(SRC))

DFLAGS 	= -c -Wall -m64 -frelease -finline-functions -masm=intel -fPIC -shared
LDFLAGS = -shared --export-dynamic -soname DRuntime.so.0.1

.PHONY: all clean install

install: all $(IMPORT)
all: $(BIN)

clean:
	@echo "Cleaning..."
	@rm -rf $(OUTPUT)
	
	
$(BIN):
	@echo "[ D ] Compiling D Runtime..."
	@$(MKDIR) $(OUTPUT)
	@$(DD) $(SRC) -o obj.o $(DFLAGS)
	
	@ld -o $@ $(LDFLAGS) obj.o $+
	@rm -rf obj.o
	
$(IMPORTDIR)%.d: %.d
	@echo --- Generating import $@
	@$(MKDIR) $(dir $@)
	@$(DD) $(DFLAGS) -c -fintfc -fintfc-file=$@ $< -o /dev/null