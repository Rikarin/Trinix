#
# Kernel Core Makefile
#

-include ../Makefile.cfg
-include Architectures/$(ARCHDIR)/Makefile
-include Makefile.BuildNum.$(ARCH)


ifeq ($(BUILD_NUM),)
	BUILD_NUM = 0
endif


DFLAGS		+= -fdebug -D _MODULE_NAME_=\"Kernel\"
DFLAGS		+= -IArchitectures/$(ARCHDIR) -I../ -J../../
CFLAGS		+= -fno-stack-protector
LDFLAGS		:= -Wl,-T -Wl,Architectures/$(ARCHDIR)/Linker.ld -Wl,-Map -Wl,../Linker.$(ARCH).map
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
SYMBOLS_OBJ   := $(OBJDIR)symbols.s.o
SYMBOLS_SRC   := $(OBJDIR)symbols.s

OBJ := $(A_OBJ)
#TODO D
OBJ	+= $(addsuffix .o,$(shell find * -name "*.[c|s]" -not -path "*Architectures*"))
OBJ := $(filter-out $(BUILDINFO_OBJ), $(OBJ))
OBJ := $(addprefix $(OBJDIR), $(OBJ))
OBJ += $(BUILDINFO_OBJ)

DEPFILES := $(OBJ:%=%.dep)
MODS += $(addprefix ../Modules/, $(addsuffix .xo.$(ARCH),$(MODULES)))

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
	
$(BIN): $(OBJ) $(MODS) $(DRUNTIME) $(shell find * -name "*.d" -not -path "*Architectures*") Architectures/$(ARCHDIR)/Linker.ld Makefile ../../BuildConf/$(ARCH)/Makefile.cfg ../../BuildConf/$(ARCH)/$(PLATFORM).mk $(SYMBOLS_OBJ)
	@echo --- LD -o $(BIN)
#$(DD) $(LDFLAGS) -o $(BIN) -femit-templates -Wl,--defsym -Wl,__buildnum=$$(( $(BUILD_NUM) + 1 )) -Wl,-Map -Wl,../Linker.$(ARCH).map $(OBJ) $(MODS)  $(DRUNTIME)
	
	@$(DD) $(DFLAGS) $(LDFLAGS) -o $(BIN) $(shell find * -name "*.d" -not -path "*Architectures*") $(OBJ) $(MODS) $(DRUNTIME) $(SYMBOLS_OBJ)
	@$(OBJDUMP) -d -S $(BIN) > $(BIN).dsm
	@echo BUILD_NUM = $$(( $(BUILD_NUM) + 1 )) > Makefile.BuildNum.$(ARCH)
#@$(STRIP) $(BIN)
	@$(GZIP) $(GZBIN) $(BIN)
	
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
	
%.xo.$(ARCH):
	@make -C $* all BUILDTYPE=static
	
# Build-time information (git hash and build number)
$(BUILDINFO_SRC): $(filter-out $(BUILDINFO_OBJ), $(OBJ)) $(MODS)
	$(eval _GITHASH=$(shell git log -n 1 | head -n 1 | awk '{print $$2}'))
	$(eval _GITCHANGED=$(shell git status --porcelain | grep -c '^ M '))
	@echo "const char gsGitHash[] = \"$(_GITHASH)\";" > $@
	@echo "const int giBuildNumber = $(BUILD_NUM);" >> $@
	@echo "const char gsBuildInfo[] = \"Trinix v$(TRINIX_VERSION) $(ARCH)-$(PLATFORM)\\\\r\\\\n\"" >> $@
	@echo " \"Build $(shell hostname --fqdn):$(BUILD_NUM) Git $(_GITHASH) - $(_GITCHANGED) modified\";" >> $@
	
# Compile rule for buildinfo (needs a special one because it's not a general source file)
$(BUILDINFO_OBJ): $(BUILDINFO_SRC)
	@echo --- CC -o $@
	@$(CC) $(CFLAGS) -o $@ -c $<
	
$(SYMBOLS_SRC):
	@echo --- Generating symbols table
	@$(DD) $(DFLAGS) $(LDFLAGS) -o $(BIN) $(filter-out $(SYMBOLS_SRC), $(shell find * -name "*.d" -not -path "*Architectures*")) $(OBJ) $(MODS) $(DRUNTIME)
	nm $(BIN) -g | python2 ../../Tools/generate_symbols.py > $@


$(SYMBOLS_OBJ): $(SYMBOLS_SRC)
	@echo --- AS -o $@
	@$(AS) $(ASFLAGS) -o $@ $<
	
	
-include $(DEPFILES)