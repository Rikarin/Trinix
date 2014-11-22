#
# Externals config.mk File
#

-include ../../Makefile.cfg


ifeq ($(ARCH),x86_64)
	BFD := x86_64
else
	$(error No BFD translation for $(ARCH) in Externals/config.mk)
endif


SYSROOT	:= $(TRXDIR)/Externals/Output/$(ARCHDIR)/CrossCompiler
TARGET	:= $(BFD)-unknown-trinix
OUTPFX	:= --libdir=$(SYSROOT)/System/Library --bindir=$(SYSROOT)/System/Binary --libexecdir=$(SYSROOT)/System/Libexec \
			--includedir=$(SYSROOT)/System/Include --oldincludedir=$(SYSROOT)/System/Include --datarootdir=$(SYSROOT)/System/Share \
			--mandir=$(SYSROOT)/System/Share/Manual
PARLEVEL = 4