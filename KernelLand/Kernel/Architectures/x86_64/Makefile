#
# Trinix Kernel
# x86_64 Architecture Makefile
#

MAX_CPUS = 4

DFLAGS		:= $(KERNEL_DFLAGS)
# -D MAX_CPUS=$(MAX_CPUS) -D USE_MP=0
ASFLAGS		:= $(ASFLAGS) -D MAX_CPUS=$(MAX_CPUS) -D USE_MP=0
LDFLAGS		:= -nodefaultlibs

A_OBJ 		:= $(addsuffix .o,$(shell find "$(dir $(lastword $(MAKEFILE_LIST)))" -name "*.[d|s]"))