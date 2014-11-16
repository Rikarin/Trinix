#
# CrossCompiler Makefile
#

-include ../config.mk

GCC			:= gcc-4.9.2
BINUTILS	:= binutils-2.24

BINUTILS_CHANGES := config.sub bfd/config.bfd gas/configure.tgt ld/configure.tgt ld/emulparams/elf_x86_64_trinix.sh ld/Makefile.in

TARGET 			:= $(HOST)
PREFIX 			:= $(OUTDIR)-BUILD #sem sa to mrdne ked sa to skompiluje
BDIR_BINUTILS 	:= build-$(ARCH)/binutils #tu sa to bude kompilovat


.PHONY: test include binutils


test: include binutils
	echo testing...
	
include:
	@echo --- Creating include files
	@$(MKDIR) $(PREFIX)
	@$(MKDIR) $(SYSROOT)/usr
	
	
binutils: $(BINUTILS) $(PREFIX)/bin/$(TARGET)-ld
	
	
$(GCC).tar.bz2:
	@echo --- Downloading GCC
	@wget http://gcc.fyxm.net/releases/$(GCC)/$(GCC).tar.bz2
	
$(BINUTILS).tar.bz2:
	@echo --- Downloading Binutils
	@wget http://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2
	
$(BINUTILS) $(GCC): %: %.tar.bz2
	@echo --- Unpacking $<
	@tar -xvf $<
	
	
	
	
	
$(BINUTILS)/%: Patches/Binutils/%.patch
	@echo --- Patch $@
	@patch $@ $<
	
$(BINUTILS)/%: Patches/Binutils/%
	@echo --- CP $@
	@cp $< $@
	
	
	
$(BDIR_BINUTILS)/Makefile: $(addprefix $(BINUTILS)/,$(BINUTILS_CHANGES))
	@mkdir -p $(BDIR_BINUTILS)
	cd $(BDIR_BINUTILS) && ../../$(BINUTILS)/configure --target=$(TARGET) --prefix=$(PREFIX) --disable-nls "--with-sysroot=$(SYSROOT)" --enable-shared --without-docdir

$(PREFIX)/bin/$(TARGET)-ld: $(BDIR_BINUTILS)/Makefile
	make -C $(BDIR_BINUTILS) all -j $(PARLEVEL)
	make -C $(BDIR_BINUTILS) install
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	