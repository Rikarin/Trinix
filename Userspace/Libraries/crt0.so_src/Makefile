#
# Makefile
#

-include ../Makefile.cfg


BIN = $(OUTPUTDIR)Library/crt0.o $(OUTPUTDIR)Library/crt0S.o $(OUTPUTDIR)Library/crti.o $(OUTPUTDIR)Library/crtn.o
CFLAGS := -std=c99

.PHONY: all clean install


all: $(BIN)
install: $(BIN)

clean:
	$(RM) $(BIN)
	
	
$(OUTPUTDIR)Library/%S.o: %S.c Makefile
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@ -fPIC
	
$(OUTPUTDIR)Library/%.o: %.c Makefile
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@
	
$(OUTPUTDIR)Library/%.o: %.s
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@