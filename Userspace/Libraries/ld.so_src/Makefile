#
# Makefile
#

-include ../Makefile.cfg


BIN = $(OUTPUTDIR)Library/libld.so
CFLAGS := -std=c99

.PHONY: all clean install


all: $(BIN)
install: $(BIN)

clean:
	$(RM) $(BIN)
	
$(OUTPUTDIR)Library/libld.so: main.c Makefile
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -shared $< -o $@ -nostdlib