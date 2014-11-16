#
# CrossCompiler Makefile
#

-include ../config.mk

GMP			:= gmp-6.0.0
#ISL			:= isl-0.11.2

GCC			:= gcc-4.9.2
BINUTILS	:= binutils-2.24

BINUTILS_CHANGES := config.sub bfd/config.bfd gas/configure.tgt ld/configure.tgt ld/emulparams/elf_x86_64_trinix.sh ld/Makefile.in

TARGET 			:= $(HOST)
PREFIX 			:= $(OUTDIR)-BUILD
#sem sa to mrdne ked sa to skompiluje

BDIR_GMP		:= build-$(ARCH)/gmp
BDIR_ISL		:= build-$(ARCH)/isl

BDIR_BINUTILS 	:= build-$(ARCH)/binutils
#tu sa to bude kompilovat



.PHONY: test include gmp binutils


test: binutils
	@echo testing...
	@cp -R ../Output ../Outpu
	@$(RM) ../Output
	@mv ../Outpu ../Output
	
include:
	@echo --- Creating include files
	@$(MKDIR) $(PREFIX)
	@$(MKDIR) $(SYSROOT)/usr
	
clean:
	@$(RM) build-* ../Output $(BINUTILS) $(ISL) $(GMP)
	

gmp: $(GMP) $(SYSROOT)/usr/lib/libgmp.a
#isl: $(ISL) $(SYSROOT)/usr/lib/libisl.a
	
binutils: $(BINUTILS) $(PREFIX)/bin/$(TARGET)-ld
	
	
$(GCC).tar.bz2:
	@echo --- Downloading GCC
	@wget http://gcc.fyxm.net/releases/$(GCC)/$(GCC).tar.bz2
	
$(BINUTILS).tar.bz2:
	@echo --- Downloading Binutils
	@wget http://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2
	
$(GMP).tar.bz2:
	@echo --- Downloading GMP
	@wget https://gmplib.org/download/gmp/$(GMP).tar.bz2
	
#$(ISL).tar.bz2:
#	@echo --- Downloading ISL
#	@wget http://isl.gforge.inria.fr/$(ISL).tar.bz2
	

#$(ISL)
$(GMP) $(BINUTILS) $(GCC): % : %.tar.bz2
	@echo --- Unpacking $<
	@tar -xvf $<
	
$(BINUTILS)/%: Patches/Binutils/%.patch
	@echo --- Patch $@
	@patch -s $@ $<
	
$(BINUTILS)/%: Patches/Binutils/%
	@echo --- CP $@
	@cp $< $@
	
	
	
	
	
	
$(BDIR_GMP)/Makefile:
	@mkdir -p $(BDIR_GMP)
	@cd $(BDIR_GMP) && ../../$(GMP)/configure --prefix=$(SYSROOT)/usr "--with-sysroot=$(SYSROOT)"	
	
#$(BDIR_ISL)/Makefile:
#	@mkdir -p $(BDIR_ISL)
#	@cd $(BDIR_ISL) && ../../$(ISL)/configure --prefix=$(SYSROOT)/usr "--with-sysroot=$(SYSROOT)"
	
$(BDIR_BINUTILS)/Makefile: $(addprefix $(BINUTILS)/,$(BINUTILS_CHANGES))
	@mkdir -p $(BDIR_BINUTILS)
	@cd $(BDIR_BINUTILS) && ../../$(BINUTILS)/configure --target=$(TARGET) --prefix=$(PREFIX) --disable-nls "--with-sysroot=$(SYSROOT)" --without-docdir

	
	
$(SYSROOT)/usr/lib/libgmp.a: $(BDIR_GMP)/Makefile
	@make -C $(BDIR_GMP) all -j $(PARLEVEL)
	@make -C $(BDIR_GMP) install
	
#$(SYSROOT)/usr/lib/libisl.a: $(BDIR_ISL)/Makefile
#	@make -C $(BDIR_ISL) -j $(PARLEVEL)
#	@make -C $(BDIR_ISL) install
	
	
	
$(PREFIX)/bin/$(TARGET)-ld: $(BDIR_BINUTILS)/Makefile
	@make -C $(BDIR_BINUTILS) all -j $(PARLEVEL)
	@make -C $(BDIR_BINUTILS) install
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	