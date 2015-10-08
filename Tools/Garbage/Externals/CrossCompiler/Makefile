#
# CrossCompiler Makefile
#
# PREFIX  - make install destination
# TARGET  - GCC/Binutils architecture target
# SYSROOT - Source directory for libs, etc.
# BDIR    - Configuration directory
#
# @TODO: treba spravit patche aj na GMP, MPFR a MPC | -trinix* \
# @TODO: Pridat HOST
# cross-compiler:  HOST=linux,  TARGET=trinix
# hosted-compiler: HOST=trinix, TARGET=trinix
#

-include ../config.mk

GMP		:= gmp-6.0.0
MPFR		:= mpfr-3.1.2
MPC		:= mpc-1.0.2
GCC		:= gcc-4.9.2
GDC		:= GDC-2.064.2_gcc4.9
BINUTILS	:= binutils-2.24

BINUTILS_CHANGES := config.sub bfd/config.bfd gas/configure.tgt ld/configure.tgt ld/emulparams/elf_x86_64_trinix.sh ld/Makefile.in
GCC_CHANGES	 := config.sub gcc/config.gcc gcc/config/trinix.h libgcc/config.host config/override.m4 fixincludes/mkfixinc.sh

BDIR_GMP	:= build-$(ARCH)/gmp
BDIR_MPFR	:= build-$(ARCH)/mpfr
BDIR_MPC	:= build-$(ARCH)/mpc
BDIR_GCC	:= build-$(ARCH)/gcc
BDIR_BINUTILS 	:= build-$(ARCH)/binutils

GCC_TARGETS	:= gcc target-libgcc
PREFIX		:= $(SYSROOT)/System

.PHONY: all install clean include gmp mpfr mpc binutils gcc smbhack


all: binutils gcc

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
	@$(RM) build-* ../Output $(BINUTILS) $(GMP) $(MPFR) $(MPC) $(GCC)
	
	
gmp: $(PREFIX)/Library/libgmp.a
mpfr: $(PREFIX)/Library/libmpfr.a
mpc: $(PREFIX)/Library/libmpc.a
gcc: $(PREFIX)/Binary/$(TARGET)-gcc
binutils: $(BINUTILS) $(PREFIX)/Binary/$(TARGET)-ld
	
	
$(GCC).tar.bz2:
	@echo --- Downloading GCC
	@curl -O http://gcc.fyxm.net/releases/$(GCC)/$(GCC).tar.bz2
	
$(GDC).tar.bz2:
	@echo --- Downloading GDC
	@curl --location -o $(GDC).tar.bz2 https://github.com/D-Programming-GDC/GDC/archive/v2.064.2_gcc4.9.tar.gz
	
$(BINUTILS).tar.bz2:
	@echo --- Downloading Binutils
	@curl -O http://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2
	
$(GMP).tar.bz2:
	@echo --- Downloading GMP
	@curl -O https://gmplib.org/download/gmp/$(GMP).tar.bz2
	
$(MPFR).tar.bz2:
	@echo --- Downloading MPFR
	@curl -O http://www.mpfr.org/mpfr-current/$(MPFR).tar.bz2
	
$(MPC).tar.bz2:
	@echo --- Downloading MPC
	@curl -o $(MPC).tar.bz2 ftp://ftp.gnu.org/gnu/mpc/$(MPC).tar.gz


$(GCC) $(BINUTILS) $(GMP) $(MPFR) $(MPC) $(GDC): %: %.tar.bz2
	@echo --- Unpacking $<
	@tar -xvf $<
	
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
	
	
$(GCC)/libstdc++-v3/configure: $(GCC)/libstdc++-v3/crossconfig.m4
	@cd $(GCC)/libstdc++-v3/ && autoconf
	
$(BDIR_GMP)/Makefile: $(GMP)
	@mkdir -p $(BDIR_GMP)
	@cd $(BDIR_GMP) && ../../$(GMP)/configure --prefix=$(PREFIX) $(OUTPFX) "--with-sysroot=$(SYSROOT)"
	
$(BDIR_MPFR)/Makefile: $(MPFR) $(PREFIX)/Library/libgmp.a
	@mkdir -p $(BDIR_MPFR)
	@cd $(BDIR_MPFR) && ../../$(MPFR)/configure --prefix=$(PREFIX) $(OUTPFX) --with-gmp-include=$(PREFIX)/include \
	--with-gmp-lib=$(PREFIX)/Library
	
$(BDIR_MPC)/Makefile: $(MPC) $(PREFIX)/Library/libmpfr.a
	@mkdir -p $(BDIR_MPC)
	@cd $(BDIR_MPC) && ../../$(MPC)/configure --prefix=$(PREFIX) $(OUTPFX) "--with-sysroot=$(SYSROOT)" --with-gmp-include=$(PREFIX)/include \
	--with-gmp-lib=$(PREFIX)/Library --with-mpfr-include=$(PREFIX)/include --with-mpfr-lib=$(PREFIX)/Library
	
$(BDIR_BINUTILS)/Makefile: $(BINUTILS) $(addprefix $(BINUTILS)/,$(BINUTILS_CHANGES))
	@mkdir -p $(BDIR_BINUTILS)
	@cd $(BDIR_BINUTILS) && ../../$(BINUTILS)/configure --target=$(TARGET) --prefix=$(PREFIX) $(OUTPFX) --disable-nls "--with-sysroot=$(SYSROOT)" \
	--without-docdir --disable-werror
	
$(BDIR_GCC)/Makefile: $(PREFIX)/Library/libmpc.a $(GCC) $(GDC) $(addprefix $(GCC)/,$(GCC_CHANGES)) $(GCC)/libstdc++-v3/configure
	@mkdir -p $(BDIR_GCC)
	@cd $(GDC) && ./setup-gcc.sh ../$(GCC)
	@cd $(BDIR_GCC) && ../../$(GCC)/configure --target=$(TARGET) --prefix=$(PREFIX) $(OUTPFX) --disable-nls --enable-languages=c,c++,d \
	--without-docdir --without-headers --disable-libssp --disable-multilib --disable-libphobos --with-gnu-as --with-gnu-ld \
	--with-gmp=$(PREFIX) --with-mpfr=$(PREFIX) --with-mpc=$(PREFIX) --with-build-sysroot=$(SYSROOT) \
	--with-gmp-lib=$(PREFIX)/Library --with-mpfr-lib=$(PREFIX)/Library --with-mpc-lib=$(PREFIX)/Library
	
	@echo "MAKEINFO = :" >> $(BDIR_GCC)/Makefile
#"--with-sysroot=$(SYSROOT)" \

	
$(PREFIX)/Library/libgmp.a: $(BDIR_GMP)/Makefile
	@make -C $(BDIR_GMP) all -j $(PARLEVEL)
	@make -C $(BDIR_GMP) install
	
$(PREFIX)/Library/libmpfr.a: $(BDIR_MPFR)/Makefile
	@make -C $(BDIR_MPFR) all -j $(PARLEVEL)
	@make -C $(BDIR_MPFR) install
	
$(PREFIX)/Library/libmpc.a: $(BDIR_MPC)/Makefile
	@make -C $(BDIR_MPC) all -j $(PARLEVEL)
	@make -C $(BDIR_MPC) install
	
$(PREFIX)/Binary/$(TARGET)-ld: $(BDIR_BINUTILS)/Makefile
	@make -C $(BDIR_BINUTILS) all -j $(PARLEVEL)
	@make -C $(BDIR_BINUTILS) install
	
$(PREFIX)/Binary/$(TARGET)-gcc: $(BDIR_GCC)/Makefile
	@make -C $(BDIR_GCC) $(GCC_TARGETS:%=all-%) -j $(PARLEVEL)
	@make -C $(BDIR_GCC) $(GCC_TARGETS:%=install-%)