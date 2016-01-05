#
# Build cross compiler
#
# TODO:
#	o Make new patches for binutils 2.25
#	o Include LLVM, LDC2, CLANG??
#
-include ../../Makefile.cfg

PREFIX   := $(SYS_DIR)/Externals/Output
PARLEVEL := 4
#TRIPLET := x86_64-unknown-linux

BINUTILS   := binutils-2.24

BINUTILS_BDIR := build-$(TRIPLET)

BINUTILS_CHANGES := config.sub bfd/config.bfd gas/configure.tgt ld/configure.tgt ld/emulparams/elf_x86_64_trinix.sh ld/Makefile.in



.PHONY: all clean binutils

all: binutils

clean:
	@$(RM) build-* $(PREFIX)/$(BINUTILS) $(BINUTILS)


binutils: $(BINUTILS) $(PREFIX)/bin/$(TRIPLET)-ld


# Download
$(BINUTILS).tar.bz2:
	@echo --- Downloading Binutils
	@curl -O http://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2

# Unpack
$(BINUTILS): %: %.tar.bz2
	@echo --- Unpacking $<
	@tar -xvf $<

# Patch
$(BINUTILS)/%: Patches/binutils/%.patch
	@echo --- Patch $@
	@patch -s $@ $<

# Copy required files
$(BINUTILS)/%: Patches/binutils/%
	@echo --- CP $@
	@cp $< $@

# Configure
$(BINUTILS_BDIR)/Makefile: $(BINUTILS) $(addprefix $(BINUTILS)/,$(BINUTILS_CHANGES))
	@mkdir -p $(BINUTILS_BDIR)
	@cd $(BINUTILS_BDIR) && ../$(BINUTILS)/configure --target=$(TRIPLET) --prefix=$(PREFIX) --disable-nls

# Make
$(PREFIX)/bin/$(TRIPLET)-ld: $(BINUTILS_BDIR)/Makefile
	@make CFLAGS=-Wno-error  -C $(BINUTILS_BDIR) all -j $(PARLEVEL)
	@make -C $(BINUTILS_BDIR) install
