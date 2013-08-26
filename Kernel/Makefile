#
# Kernel Core Makefile
#
-include ../Makefile.cfg

KERNEL_LDFLAGS += --script=arch/$(ARCH)/kernel.ld -Map=../linker.$(ARCH).map

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

BUILDINFO_OBJ := $(OBJ_DIR)/build_info.c.o
BUILDINFO_SRC := $(OBJ_DIR)/build_info.c

OBJ := $(addsuffix .o,$(shell find arch/$(ARCH) -name "*.[d|c|s]"))
OBJ	+= $(addsuffix .o,$(shell find * -name "*.[d|c|s]" -not -path "*arch*"))
OBJ := $(filter-out $(BUILDINFO_OBJ), $(OBJ))
OBJ := $(addprefix $(OBJ_DIR)/, $(OBJ))
OBJ += $(BUILDINFO_OBJ)

DEPFILES := $(OBJ:%=%.dep)

.PHONY: all clean install import

all: $(BIN)
	@true

clean:
	@$(RM) $(BIN) $(GZBIN) $(OBJ_DIR) $(BIN).dsm ../linker.$(ARCH).map
	@$(RM) $(ROOT_DIR)/System/System.gz

install: $(BIN)
	@echo --- Kernel was installed into System/System.gz
	@cp $(GZBIN) $(ROOT_DIR)/System/System.gz

$(BIN): $(OBJ) arch/$(ARCH)/kernel.ld
# ../../BuildConf/$(ARCH)/Makefile.cfg ../../BuildConf/$(ARCH)/$(PLATFORM).mk
	@echo --- LD -o $(BIN)
	@$(LD) $(KERNEL_LDFLAGS) -o $(BIN) $(shell find $(OBJ_DIR) -name "*.[o]")
	@$(STRIP) $(BIN)
	@$(GZIP) $(GZBIN) $(BIN)

$(OBJ_DIR)/%.d.o: %.d
	@echo --- DD $@
	@$(MKDIR) $(dir $@)
	@$(DD) $(KERNEL_DFLAGS) -of=$@ -c -deps=$@.o.dep $<

$(OBJ_DIR)/%.s.o: %.s
	@echo --- AS $@
	@$(MKDIR) $(dir $@)
	@$(AS) $(KERNEL_ASFLAGS) -o $@ $<
#@$(CC) $(CFLAGS) -M -MT $@ -MP -o $@.o.dep $<

$(OBJ_DIR)/%.c.o: %.c
	@echo --- CC $@
	@$(MKDIR) $(dir $@)
	@$(CC) $(KERNEL_CFLAGS) -o $@ -c $<
#@$(CC) $(CFLAGS) -M -MT $@ -MP -o $@.o.dep $<

#$(OBJ_DIR)/core.o: $(shell find * -name "*.d" -not -path "*arch*")
#	@echo --- DD Compile
#	@$(MKDIR) $(dir $@)
#	$(DD) $(KERNEL_DFLAGS) -oq -od=$(OBJ_DIR) -c $<

# Build-time information (git hash and build number)
$(BUILDINFO_SRC): $(filter-out $(BUILDINFO_OBJ), $(OBJ))
	@echo "const char* TrinixVersion = \"$(SYSTEM_VERSION)\";" >> $@

# Compile rule for buildinfo (needs a special one because it's not a generic source file)
$(BUILDINFO_OBJ): $(BUILDINFO_SRC)
	@echo --- CC -o $@
	@$(CC) $(KERNEL_CFLAGS) -o $@ -c $<

-include $(DEPFILES)
