CFLAGS += -std=gnu99 -g
LDFLAGS += -L $(TRXDIR)/Externals/Output/$(ARCHDIR)/Library
LDFLAGS += -L $(OUTPUTDIR)Library

CRTI := $(OUTPUTDIR)Library/crti.o
CRTBEGIN := $(shell $(CC) $(CFLAGS) -print-file-name=crtbegin.o 2> /dev/null)
CRTBEGINS := $(shell $(CC) $(CFLAGS) -print-file-name=crtbeginS.o 2> /dev/null)
CRT0 := $(OUTPUTDIR)Library/crt0.o
CRT0S := $(OUTPUTDIR)Library/crt0S.o
CRTEND := $(shell $(CC) $(CFLAGS) -print-file-name=crtend.o 2>/dev/null)
CRTENDS := $(shell $(CC) $(CFLAGS) -print-file-name=crtendS.o 2> /dev/null)
CRTN := $(OUTPUTDIR)Library/crtn.o
LIBGCC_PATH = $(shell $(CC) -print-libgcc-file-name 2>/dev/null)