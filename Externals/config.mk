#
# Externals config.mk File
#

-include ../../Makefile.cfg


ifeq ($(ARCH),x86_64)
	BFD := x86_64
else
	$(error No BFD translation for $(ARCH) in Externals/config.mk)
endif


OUTPUT	:= $(TRXDIR)/Externals/Output/$(ARCHDIR)/
PARLEVEL = 4