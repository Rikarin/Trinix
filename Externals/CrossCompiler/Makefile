#
# Build cross compiler
#
# TODO:
#	o Make new patches for binutils 2.25
#	o Include LLVM, LDC2, CLANG??
#
-include ../../Makefile.cfg

PREFIX    := $(SYS_DIR)/Externals/Output
PARLEVEL  := 4
BUILD_DIR := build-$(EXTERNAL_TARGET)

BINUTILS  := binutils-2.25
LLVM      := llvm-3.7.0.src
CLANG     := cfe-3.7.0.src
LLVM_RT   := compiler-rt-3.7.0.src
LDC2      := ldc-0.17.0-alpha1-src

#BINUTILS_CHANGES := config.sub bfd/config.bfd gas/configure.tgt ld/configure.tgt ld/emulparams/elf_x86_64_trinix.sh ld/Makefile.in

.PHONY: all clean binutils llvm ldc2

all: binutils llvm ldc2

clean:
	@$(RM) $(BINUTILS) $(LLVM) $(LDC2)

binutils: $(BINUTILS) $(PREFIX)/bin/$(EXTERNAL_TARGET)-ld
llvm: $(LLVM) $(PREFIX)/bin/$(EXTERNAL_TARGET)-clang
ldc2: $(LDC2) $(PREFIX)/bin/$(EXTERNAL_TARGET)-ldc2

# Download
$(BINUTILS).tar.bz2:
	@echo --- Downloading Binutils
	@curl -O http://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2

$(LLVM).tar.xz $(CLANG).tar.xz $(LLVM_RT).tar.xz:
		@echo --- Downloading $@
		@curl -O http://llvm.org/releases/3.7.0/$@

$(LDC2).tar.bz2:
		@echo --- Downloading LDC2
		@curl -O https://github.com/ldc-developers/ldc/releases/download/v0.17.0-alpha1/$(LDC2).tar.bz2

# Unpack
$(BINUTILS): %: %.tar.bz2
	@echo --- Unpacking $<
	@tar -xvf $<

$(LLVM): %: %.tar.xz $(CLANG).tar.xz $(LLVM_RT).tar.xz
		@echo --- Unpacking $<
		@tar -xvf $<
		@tar -xvf $(CLANG).tar.xz -C $@/tools
		@tar -xvf $(LLVM_RT).tar.xz -C $@/projects
		@mv $@/tools/$(CLANG) $@/tools/clang
		@mv $@/projects/$(LLVM_RT) $@/projects/compiler-rt

$(LDC2): %: %.tar.bz2
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
#TODO: apply patch  $(addprefix $(BINUTILS)/,$(BINUTILS_CHANGES))
$(BINUTILS)/$(BUILD_DIR)/Makefile: $(BINUTILS)
	@mkdir -p $(BINUTILS)/$(BUILD_DIR)
	@cd $(BINUTILS)/$(BUILD_DIR) && ../configure --target=$(EXTERNAL_TARGET) --prefix=$(PREFIX) --disable-nls

$(LLVM)/$(BUILD_DIR)/Makefile: $(LLVM)
		@mkdir -p $(LLVM)/$(BUILD_DIR)
		@cd $(LLVM)/$(BUILD_DIR) && ../configure --target=$(EXTERNAL_TARGET) --prefix=$(PREFIX) --enable-optimized --disable-assertions --enable-targets=x86_64

$(LDC2)/$(BUILD_DIR)/Makefile: $(LDC2)
				@mkdir -p $(LDC2)/$(BUILD_DIR)
				@cd $(LDC2)/$(BUILD_DIR) && ../cmake -DLLVM_ROOT_DIR=$(PREFIX) -DCMAKE_INSTALL_PREFIX=$(PREFIX)

# Make
$(PREFIX)/bin/$(EXTERNAL_TARGET)-ld: $(BINUTILS)/$(BUILD_DIR)/Makefile
	@make -C $(BINUTILS)/$(BUILD_DIR) all -j $(PARLEVEL)
	@make -C $(BINUTILS)/$(BUILD_DIR) install

$(PREFIX)/bin/$(EXTERNAL_TARGET)-clang: $(LLVM)/$(BUILD_DIR)/Makefile
		@make -C $(LLVM)/$(BUILD_DIR) -j $(PARLEVEL)
		@make -C $(LLVM)/$(BUILD_DIR) install

$(PREFIX)/bin/$(EXTERNAL_TARGET)-ldc2: $(LDC2)/$(BUILD_DIR)/Makefile
				@make -C $(LDC2)/$(BUILD_DIR) all -j $(PARLEVEL)
				@make -C $(LDC2)/$(BUILD_DIR) install
