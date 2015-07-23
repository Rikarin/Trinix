#
# Trinix Kernel
# x86_64 Architecture Makefile
#

#MAX_CPUS = 4
# -D MAX_CPUS=$(MAX_CPUS) -D USE_MP=0

DFLAGS	:= $(KERNEL_DFLAGS)
CFLAGS	:= $(KERNEL_CFLAGS)
ASFLAGS	:= $(ASFLAGS)
LDFLAGS	:= -nodefaultlibs

A_OBJ 	:= $(addsuffix .o,$(shell find "$(dir $(lastword $(MAKEFILE_LIST)))" -name "*.[d|c|s]"))