#
# Kernel Core Makefile
#
# TODO:
#	o Generate .dep files
#

-include ../Makefile.cfg
-include Architectures/$(ARCH)/Makefile
-include Makefile.BuildNum

KERNEL_DFLAGS  += -I../
KERNEL_LDFLAGS += --script=Architectures/$(ARCH)/Kernel.ld -Map=../Linker.$(ARCH).map

ifeq ($(PLATFORM),default)
	OBJ_DIR := obj-$(ARCH)
	BIN     := ../System.$(ARCH).bin
	GZBIN   := ../System.$(ARCH).gz
else
	OBJ_DIR := obj-$(ARCH)-$(PLATFORM)
	BIN     := ../System.$(ARCH)-$(PLATFORM).bin
	GZBIN   := ../System.$(ARCH)-$(PLATFORM).gz
endif

ifeq ($(BUILD_TYPE),debug)
	LDFLAGS += -g
	DFLAGS  += -g -d-debug=
	CFLAGS  += -g
endif

BUILDINFO_OBJ := $(OBJ_DIR)/BuildInfo.c.o
BUILDINFO_SRC := $(OBJ_DIR)/BuildInfo.c
#SYMBOLS_OBJ   := $(OBJ_DIR)/Symbols.s.o
#SYMBOLS_SRC   := $(OBJ_DIR)/Symbols.s

OBJ := $(addsuffix .o,$(shell find Architectures/$(ARCH) -name "*.[d|c|s]"))
OBJ	+= $(addsuffix .o,$(shell find * -name "*.[c|s]" -not -path "*Architectures*"))
OBJ := $(filter-out $(BUILDINFO_OBJ), $(OBJ))
OBJ := $(filter-out $(SYMBOLS_OBJ), $(OBJ))
OBJ := $(addprefix $(OBJ_DIR)/, $(OBJ))
OBJ += $(BUILDINFO_OBJ)

DEPFILES   := $(OBJ:%=%.dep)
MODS       += $(addprefix ../Modules/, $(addsuffix .xo.$(ARCH),$(MODULES)))

IMPORT_DIR := ../Import
#IMPORT	  := $(shell find * -name "*.d")
#IMPORT    := $(addprefix $(IMPORTDIR), $(IMPORT))

DOC_DIR   := ../APIDoc
DOCFLAGS  := -D -Dd=$(DOC_DIR)

.PHONY: all clean install import

all: $(BIN)
	@true

clean:
	@$(RM) $(BIN) $(GZBIN) $(OBJ_DIR) $(BIN).dsm ../Linker.$(ARCH).map
	@$(RM) $(DOC_DIR) $(IMPORT_DIR) $(ROOT_DIR)/System/System.gz

install: $(BIN)
	@echo --- Kernel was installed into System/System.gz
	@cp $(GZBIN) $(ROOT_DIR)/System/System.gz

#$(IMPORTDIR)%.d: %.d
#	@echo --- Generating import $@
#	@$(MKDIR) $(dir $@)
#	@$(DD) $(DFLAGS) -c -fintfc -fintfc-file=$@ $< -o /dev/null

$(BIN): $(OBJ) $(OBJ_DIR)/Core.o $(MODS) Architectures/$(ARCH)/LinkerScript.ld Makefile ../../BuildConf/$(ARCH)/Makefile.cfg ../../BuildConf/$(ARCH)/$(PLATFORM).mk
	@echo --- LD -o $(BIN)
	@$(LD) $(KERNEL_LDFLAGS) -o $(BIN) $(shell find $(OBJ_DIR) -name "*.[o]") $(MODS) $(SYSTEM_DIR)/Tools/libdruntime-ldc.a
	@echo BUILD_NUM = $$(( $(BUILD_NUM) + 1 )) > Makefile.BuildNum
	@$(STRIP) $(BIN)
	@$(GZIP) $(GZBIN) $(BIN)

$(OBJ_DIR)/%.d.o: %.d
	@echo --- DD -o $@
	@$(MKDIR) $(dir $@)
	@$(DD) $(KERNEL_DFLAGS) -of=$@ -c -deps=$@.o.dep $<

$(OBJ_DIR)/%.s.o: %.s
	@echo --- AS -o $@
	@$(MKDIR) $(dir $@)
	@$(AS) $(KERNEL_ASFLAGS) -o $@ $<
#@$(CC) $(CFLAGS) -M -MT $@ -MP -o $@.o.dep $<

$(OBJ_DIR)/%.c.o: %.c
	@echo --- CC -o $@
	@$(MKDIR) $(dir $@)
	@$(CC) $(KERNEL_CFLAGS) -o $@ -c $<
#@$(CC) $(CFLAGS) -M -MT $@ -MP -o $@.o.dep $<

%.xo.$(ARCH):
	@make -C $* all BUILDTYPE=static

$(OBJ_DIR)/Core.o: $(shell find * -name "*.d" -not -path "*Architectures*")
	@echo --- DD zrob bynarku cype
	@$(MKDIR) $(dir $@)
	@$(DD) $(KERNEL_DFLAGS) -oq -od=$(OBJ_DIR) -c $<

# Build-time information (git hash and build number)
$(BUILDINFO_SRC): $(filter-out $(BUILDINFO_OBJ), $(OBJ)) $(MODS)
	$(eval _GITHASH=$(shell git log -n 1 | head -n 1 | awk '{print $$2}'))
	$(eval _GITCHANGED=$(shell git status --porcelain | grep -c '^ M '))
	@echo "const char* gsGitHash   = \"$(_GITHASH)\";" > $@
	@echo "const int giBuildNumber = $(BUILD_NUM);" >> $@
	@echo "const char* gsBuildInfo = \"Trinix v$(SYSTEM_VERSION) $(ARCH)-$(PLATFORM)\\\\r\\\\n\"" >> $@
	@echo " \"Build $(shell hostname --fqdn):$(BUILD_NUM) Git $(_GITHASH) - $(_GITCHANGED) modified\";" >> $@

# Compile rule for buildinfo (needs a special one because it's not a general source file)
$(BUILDINFO_OBJ): $(BUILDINFO_SRC)
	@echo --- CC -o $@
	@$(CC) $(KERNEL_CFLAGS) -o $@ -c $<

#$(SYMBOLS_SRC):
#	@echo --- Generating symbols table
#	@$(DD) $(KERNEL_DFLAGS) $(LDFLAGS) -o $(BIN) $(filter-out $(SYMBOLS_SRC), $(shell find * -name "*.d" -not -path "*Architectures*")) $(OBJ) $(MODS) $(DRUNTIME)
#	$(OBJCOPY) -R .tbss $(BIN)
#	@nm $(BIN) -g | python2 ../../Tools/generate_symbols.py > $@


#$(SYMBOLS_OBJ): $(SYMBOLS_SRC)
#	@echo --- AS -o $@
#	@$(AS) $(KERNEL_ASFLAGS) -o $@ $<

-include $(DEPFILES)
