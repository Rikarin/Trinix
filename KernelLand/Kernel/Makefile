#
# Kernel Core Makefile
#

-include ../Makefile.cfg
-include Architectures/$(ARCHDIR)/Makefile
-include Makefile.BuildNum.$(ARCH)


ifeq ($(BUILD_NUM),)
	BUILD_NUM = 0
endif

KERNEL_VERSION = $(TRINIX_VERSION)


ASFLAGS		+= -D ARCHDIR_IS_$(ARCHDIR)=1 -D PLATFORM_is_$(PLATFORM)=1
DFLAGS		+= -g -fversion=LogUserFriendly -D _MODULE_NAME_=\"Kernel\" -femit-templates
DFLAGS		+= -I$(TRXDIR)/Userspace/tmp/druntime/src #DRuntime
DFLAGS		+= -IArchitectures/$(ARCHDIR) -D KERNEL_VERSION=$(KERNEL_VERSION)
DFLAGS		+= -D ARCH=$(ARCH) -D ARCHDIR=$(ARCHDIR) -D PLATFORM=\"$(PLATFORM)\" -D ARCHDIR_IS_$(ARCHDIR)=1 -D PLATFORM_is_$(PLATFORM)=1
CFLAGS		+= -g -fno-stack-protector
LDFLAGS		+= -T Architectures/$(ARCHDIR)/Linker.ld
DRUNTIME	:= $(TRXDIR)/Userspace/tmp/druntime/lib/libdruntime-linux64.a

ifeq ($(PLATFORM),default)
	OBJDIR	:= obj-$(ARCH)/
	BIN		:= ../Trinix.$(ARCH).bin
	GZBIN	:= ../Trinix.$(ARCH).gz
else
	OBJDIR	:= obj-$(ARCH)-$(PLATFORM)/
	BIN		:= ../Trinix.$(ARCH)-$(PLATFORM).bin
	GZBIN	:= ../Trinix.$(ARCH)-$(PLATFORM).gz
endif

ifeq ($(DEBUG_BUILD),yes)
	LDFLAGS += -g
	DFLAGS 	+= -g
	CFLAGS 	+= -g
endif

BUILDINFO_OBJ := $(OBJDIR)buildinfo.c.o
BUILDINFO_SRC := $(OBJDIR)buildinfo.c

OBJ := $(A_OBJ)
OBJ	+= $(addsuffix .o,$(shell find * -name "*.[d|c|s]" -not -path "*Architectures*"))
OBJ := $(filter-out $(BUILDINFO_OBJ), $(OBJ))
OBJ := $(addprefix $(OBJDIR), $(OBJ))
OBJ += $(BUILDINFO_OBJ)

DEPFILES := $(OBJ:%=%.dep)
MODS += $(addprefix ../Modules/, $(addsuffix .kext.$(ARCH),$(MODULES)))

IMPORTDIR	:= ../Import/
IMPORT		:= $(shell find * -name "*.d")
IMPORT		:= $(addprefix $(IMPORTDIR), $(IMPORT))

DOCDIR	:= ../APIdoc/
DOC		:= $(patsubst %d,%html,$(shell find * -name "*.d"))
DOC		:= $(addprefix $(DOCDIR), $(DOC))

.PHONY: all clean install import apidoc


all:	$(BIN)
import: $(IMPORT)
apidoc: $(DOC)

clean:
	@$(RM) $(BIN) $(GZBIN) $(OBJDIR) $(BIN).dsm ../Linker.$(ARCH).map
	@$(RM) $(DOCDIR) $(IMPORTDIR) $(DISTROOT)/System/Trinix.gz
	
install: $(BIN)
	@echo --- Kernel was installed to System/Trinix.gz
	@cp $(GZBIN) $(DISTROOT)/System/Trinix.gz
	
$(IMPORTDIR)%.d: %.d
	@echo --- Generating import $@
	@$(MKDIR) $(dir $@)
	@$(DD) $(DFLAGS) -c -fintfc -fintfc-file=$@ $< -o /dev/null
	
	
$(DOCDIR)%.html: %.d
	@echo --- Generating documentation file $@
	@$(MKDIR) $(dir $@)
	@$(DD) $(DFLAGS) -c -fdoc -fdoc-file=$@ $< -o /dev/null
	
$(BIN): $(OBJ) $(MODS) $(DRUNTIME) Architectures/$(ARCHDIR)/Linker.ld Makefile ../../BuildConf/$(ARCH)/Makefile.cfg ../../BuildConf/$(ARCH)/$(PLATFORM).mk
	@echo --- LD -o $(BIN)
	@$(LD) $(LDFLAGS) -r -o $(BIN) --start-group $(OBJ) --end-group $(MODS) $(DRUNTIME) --defsym __buildnum=$$(( $(BUILD_NUM) + 1 )) -Map ../Linker.$(ARCH).map
	@$(OBJDUMP) -d -S $(BIN) > $(BIN).dsm
	@echo BUILD_NUM = $$(( $(BUILD_NUM) + 1 )) > Makefile.BuildNum.$(ARCH)
	@$(STRIP) $(BIN)
	@gzip -c $(BIN) > $(GZBIN)
	
$(OBJDIR)%.d.o: %.d
	@echo --- DD -o $@
	@$(MKDIR) $(dir $@)
	@$(DD) $(DFLAGS) -o $@ -c -fmake-mdeps=$@.o.dep $<
	
$(OBJDIR)%.s.o: %.s
	@echo --- AS -o $@
	@$(MKDIR) $(dir $@)
	@$(AS) $(ASFLAGS) -o $@ $<
	@$(CC) $(CFLAGS) -M -MT $@ -MP -o $@.o.dep $<
	
$(OBJDIR)%.c.o: %.c
	@echo --- CC -o $@
	@$(MKDIR) $(dir $@)
	@$(CC) $(CFLAGS) -o $@ -c $<
	@$(CC) $(CFLAGS) -M -MT $@ -MP -o $@.o.dep $<
	
%.kext.$(ARCH):
	echo test: $*
	@make -C $* all BUILDTYPE=static
	
# Build-time information (git hash and build number)
$(BUILDINFO_SRC): $(filter-out $(BUILDINFO_OBJ), $(OBJ)) $(MODS)
	$(eval _GITHASH=$(shell git log -n 1 | head -n 1 | awk '{print $$2}'))
	$(eval _GITCHANGED=$(shell git status --porcelain | grep -c '^ M '))
	@echo "const char gsGitHash[] = \"$(_GITHASH)\";" > $@
	@echo "const int giBuildNumber = $(BUILD_NUM);" >> $@
	@echo "const char gsBuildInfo[] = \"Trinix v$(KERNEL_VERSION) $(ARCH)-$(PLATFORM)\\\\r\\\\n\"" >> $@
	@echo " \"Build $(shell hostname --fqdn):$(BUILD_NUM) Git $(_GITHASH) - $(_GITCHANGED) modified\";" >> $@
	
# Compile rule for buildinfo (needs a special one because it's not a general source file)
$(BUILDINFO_OBJ): $(BUILDINFO_SRC)
	@echo --- CC -o $@
	@$(CC) $(CFLAGS) -o $@ -c $<
	
	
-include $(DEPFILES)