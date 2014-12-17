#
# CrossCompiler Makefile
#

-include ../config.mk

LDC  = ldc-0.15.1-src
LLVM = llvm-3.5.0.src

LLVM_PATCH	:= config.sub bfd/config.bfd gas/configure.tgt ld/configure.tgt ld/emulparams/elf_x86_64_trinix.sh ld/Makefile.in

BDIR_LLVM	:= build-$(ARCH)/llvm
BDIR_LDC	:= build-$(ARCH)/ldc

PREFIX		:= $(OUTPUT)/LLVM.app

.PHONY: all install clean include llvm ldc


all: llvm ldc

install: all
#copy some shit from ../Output to ROOT dir...

smbhack:
	@echo Samba hacking hidden files v 1.0
	@cp -R ../Output ../rmp
	@$(RM) ../Output
	@mv ../rmp ../Output
	
include:
	@echo --- Creating include files
	@$(MKDIR) $(PREFIX)/Include/D
	@$(MKDIR) $(PREFIX)/Library/gcc/x86_64-unknown-trinix/4.9.2/include/d
	@cp -R ../../Userspace/tmp/druntime/import/* $(PREFIX)/Library/gcc/x86_64-unknown-trinix/4.9.2/include/d
	@cp -R ../../Userspace/Output/x86_64/Library/* $(PREFIX)/Library
	@cp -R ../../Userspace/Output/x86_64/Library/crt* $(PREFIX)/Library/gcc/x86_64-unknown-trinix/4.9.2
	
clean:
	@$(RM) build-* $(PREFIX) $(LLVM) $(LDC)
	
	
llvm: $(PREFIX)/bin/llvm.test
ldc: $(PREFIX)/bin/ldc.test
	
	
$(LLVM).tar.gz:
	@echo --- Downloading LLVM
	@curl  -o $(LLVM).tar.gz http://llvm.org/releases/3.5.0/llvm-3.5.0.src.tar.xz
	
$(LDC).tar.gz:
	@echo --- Downloading LDC
	@curl -LO https://github.com/ldc-developers/ldc/releases/download/v0.15.1/ldc-0.15.1-src.tar.gz

$(LLVM) $(LDC): %: %.tar.gz
	@echo --- Unpacking $<
	@tar -xvf $<
#--host=$(TRIPLET)
	
$(BINUTILS)/%: Patches/binutils/%.patch
	@echo --- Patch $@
	@patch -s $@ $<
	
$(BINUTILS)/%: Patches/binutils/%
	@echo --- CP $@
	@cp $< $@
	
$(GCC)/%: Patches/gcc/%.patch
	@echo --- Patch $@
	@patch -s $@ $<
	
$(GCC)/%: Patches/gcc/%
	@echo --- CP $@
	@cp $< $@
	
		
$(BDIR_LLVM)/Makefile: $(LLVM)
	@mkdir -p $(BDIR_LLVM)
	@cd $(BDIR_LLVM) && ../../$(LLVM)/configure --build=x86_64-unknown-linux-gnu \
	--enable-optimized --disable-assertions --enable-targets=x86 --prefix=$(PREFIX)
	
$(BDIR_LDC)/Makefile: $(LDC)
	@mkdir -p $(BDIR_LDC)
	@cd $(BDIR_LDC) && cmake -DLLVM_ROOT_DIR=$(PREFIX) -DCMAKE_INSTALL_PREFIX=$(PREFIX) ../../$(LDC)
	
$(PREFIX)/bin/llvm.test: $(BDIR_LLVM)/Makefile
	@make -C $(BDIR_LLVM) all -j $(PARLEVEL)
	@make -C $(BDIR_LLVM) install
	
$(PREFIX)/bin/ldc.test: $(BDIR_LDC)/Makefile
	@make -C $(BDIR_LDC) all -j $(PARLEVEL)
	@make -C $(BDIR_LDC) install