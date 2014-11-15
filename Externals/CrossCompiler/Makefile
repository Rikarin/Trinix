#
# CrossCompiler Makefile
#

-include ../config.mk

GCC			:= gcc-4.9.2
BINUTILS	:= binutils-2.24

test: $(BINUTILS)
	echo testing...
	
	
$(GCC).tar.bz2:
	@echo --- Downloading GCC
	@wget http://gcc.fyxm.net/releases/$(GCC)/$(GCC).tar.bz2
	
$(BINUTILS).tar.bz2:
	@echo --- Downloading Binutils
	@wget http://ftp.gnu.org/gnu/binutils/$(BINUTILS).tar.bz2
	
$(BINUTILS) $(GCC): %: %.tar.bz2
	@echo --- Unpacking $<
	@tar -xvf $<