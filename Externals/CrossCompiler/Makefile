#
# CrossCompiler Makefile
#
# PREFIX  - make install destination
# TARGET  - GCC/Binutils architecture target
# SYSROOT - Source directory for libs, etc.
# BDIR    - Configuration directory
#
# @TODO: treba spravit patche aj na GMP, MPFR a MPC | -trinix* \
#

-include ../config.mk

GMP			:= gmp-6.0.0
MPFR		:= mpfr-3.1.2
MPC			:= mpc-1.0.2
GCC			:= gcc-4.9.2
BINUTILS	:= binutils-2.24

BINUTILS_CHANGES := config.sub bfd/config.bfd gas/configure.tgt ld/configure.tgt ld/emulparams/elf_x86_64_trinix.sh ld/Makefile.in
GCC_CHANGES		 := config.sub gcc/config.gcc gcc/config/trinix.h libgcc/config.host libstdc++-v3/crossconfig.m4 config/override.m4 fixincludes/mkfixinc.sh

TARGET 			:= $(HOST)
PREFIX 			:= $(OUTDIR)-BUILD

BDIR_GMP		:= build-$(ARCH)/gmp
BDIR_MPFR		:= build-$(ARCH)/mpfr
BDIR_MPC		:= build-$(ARCH)/mpc
BDIR_GCC		:= build-$(ARCH)/gcc
BDIR_BINUTILS 	:= build-$(ARCH)/binutils

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
	@$(MKDIR) $(PREFIX)
	@$(MKDIR) $(SYSROOT)/usr
	
clean:
	@$(RM) build-* ../Output $(BINUTILS) $(GMP) $(MPFR) $(MPC) $(GCC)
	
	
gmp: $(SYSROOT)/usr/lib/libgmp.so
mpfr: $(SYSROOT)/usr/lib/libmpfr.so
mpc: $(SYSROOT)/usr/lib/libmpc.so
gcc: $(PREFIX)/bin/$(TARGET)-gcc
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
	
$(MPFR).tar.bz2:
	@echo --- Downloading MPFR
	@wget http://www.mpfr.org/mpfr-current/$(MPFR).tar.bz2
	
$(MPC).tar.bz2:
	@echo --- Downloading MPC
	@wget ftp://ftp.gnu.org/gnu/mpc/$(MPC).tar.gz
	@mv $(MPC).tar.gz $(MPC).tar.bz2


#%/configure: %.tar.bz2
$(GCC) $(BINUTILS) $(GMP) $(MPFR) $(MPC): %: %.tar.bz2
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
	@cd $(BDIR_GMP) && ../../$(GMP)/configure --prefix=$(SYSROOT)/usr "--with-sysroot=$(SYSROOT)" --without-docdir
	
$(BDIR_MPFR)/Makefile: $(MPFR) $(SYSROOT)/usr/lib/libgmp.so
	@mkdir -p $(BDIR_MPFR)
	@cd $(BDIR_MPFR) && ../../$(MPFR)/configure --prefix=$(SYSROOT)/usr "--with-sysroot=$(SYSROOT)" --without-docdir
	
$(BDIR_MPC)/Makefile: $(MPC) $(SYSROOT)/usr/lib/libmpfr.so
	@mkdir -p $(BDIR_MPC)
	@cd $(BDIR_MPC) && ../../$(MPC)/configure --prefix=$(SYSROOT)/usr "--with-sysroot=$(SYSROOT)" --without-docdir	
	
$(BDIR_BINUTILS)/Makefile: $(BINUTILS) $(addprefix $(BINUTILS)/,$(BINUTILS_CHANGES))
	@mkdir -p $(BDIR_BINUTILS)
	@cd $(BDIR_BINUTILS) && ../../$(BINUTILS)/configure --target=$(TARGET) --prefix=$(PREFIX) --disable-nls "--with-sysroot=$(SYSROOT)" --without-docdir
	
$(BDIR_GCC)/Makefile: $(SYSROOT)/usr/lib/libmpc.so $(GCC) $(addprefix $(GCC)/,$(GCC_CHANGES)) $(GCC)/libstdc++-v3/configure
	@mkdir -p $(BDIR_GCC)
	@cd $(BDIR_GCC) && PATH=$(PREFIX)/bin:$$PATH ../../$(GCC)/configure --prefix=$(PREFIX) --disable-nls --enable-langs=c,c++ \
	--without-docdir --without-headers \
	--disable-multilib --with-gmp=$(SYSROOT)/usr --with-mpfr=$(SYSROOT)/usr --with-mpc=$(SYSROOT)/usr
	@echo "MAKEINFO = :" >> $(BDIR_GCC)/Makefile
#"--with-sysroot=$(SYSROOT)" \

	
$(SYSROOT)/usr/lib/libgmp.so: $(BDIR_GMP)/Makefile
	@make -C $(BDIR_GMP) all -j $(PARLEVEL)
	@make -C $(BDIR_GMP) install
	
$(SYSROOT)/usr/lib/libmpfr.so: $(BDIR_MPFR)/Makefile
	@make -C $(BDIR_MPFR) all -j $(PARLEVEL)
	@make -C $(BDIR_MPFR) install
	
$(SYSROOT)/usr/lib/libmpc.so: $(BDIR_MPC)/Makefile
	@make -C $(BDIR_MPC) all -j $(PARLEVEL)
	@make -C $(BDIR_MPC) install
	
$(PREFIX)/bin/$(TARGET)-ld: $(BDIR_BINUTILS)/Makefile
	@make -C $(BDIR_BINUTILS) all -j $(PARLEVEL)
	@make -C $(BDIR_BINUTILS) install
	
$(PREFIX)/bin/$(TARGET)-gcc: $(BDIR_GCC)/Makefile
	@PATH=$(PREFIX)/bin:$$PATH make -C $(BDIR_GCC) all -j $(PARLEVEL)
	@PATH=$(PREFIX)/bin:$$PATH make -C $(BDIR_GCC) install