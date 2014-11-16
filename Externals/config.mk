#
# Externals config.mk File
#

-include ../../Makefile.cfg


ifeq ($(ARCH),x86_64)
	BFD := x86_64
else
	$(error No BFD translation for $(ARCH) in Externals/config.mk)
endif


OUTDIR	= $(TRXDIR)/Externals/Output/$(ARCHDIR)
SYSROOT = $(TRXDIR)/Externals/Output/sysroot-$(BFD)

HOST	= $(BFD)-unknown-trinix
PATH	:= $(OUTDIR)-BUILD/bin:$(PATH)