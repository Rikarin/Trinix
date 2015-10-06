#
# Makefile
#

-include ../../Makefile.cfg

OUTPUT = $(TRXROOT)/System/Library/Frameworks/Kappa.framework/crt
BIN    = $(OUTPUT)/crt0.o $(OUTPUT)/crt0S.o $(OUTPUT)/crti.o $(OUTPUT)/crtn.o

.PHONY: all clean install


all: $(BIN)
install: $(BIN)

clean:
	@$(RM) $(BIN)
	
	
$(OUTPUT)/%S.o: %S.c Makefile
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@ -fPIC
	
$(OUTPUT)/%.o: %.c Makefile
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@
	
$(OUTPUT)/%.o: %.s
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@