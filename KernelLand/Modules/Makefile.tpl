#
# Trinix Module Templater Makefile
#

_DFLAGS := $(DFLAGS)

-include $(dir $(lastword $(MAKEFILE_LIST)))../Makefile.cfg


DFLAGS := -I$(TRXDIR)/KernelLand/Kernel -I$(TRXDIR)/KernelLand/Kernel/Architectures/$(ARCHDIR) -I$(TRXDIR)/KernelLand/Modules
DFLAGS += -D ARCH=$(ARCH) -D ARCHDIR=$(ARCHDIR) -D PLATFORM=\"$(PLATFORM)\" -D ARCHDIR_IS_$(ARCHDIR)=1 -D PLATFORM_is_$(PLATFORM)=1
DFLAGS += $(_DFLAGS)
DFLAGS += -g 

ifneq ($(CATEGORY),)
	FULLNAME := $(CATEGORY)_$(NAME)
else
	FULLNAME := $(NAME)
endif

DFLAGS += -D _MODULE_NAME_=\"$(FULLNAME)\"

ifneq ($(BUILDTYPE),static)
	_SUFFIX	:= dyn-$(ARCH)
	KEXT	:= ../$(FULLNAME).kext
	BIN		:= $(KEXT).$(ARCH)
	DFLAGS	+= $(DYNMOD_DFLAGS)
else
	_SUFFIX := st-$(ARCH)
	BIN := ../$(FULLNAME).xo.$(ARCH)
	DFLAGS += $(KERNEL_DFLAGS)
endif

OBJ 	 := $(addprefix obj_$(_SUFFIX)/,$(OBJ))
DEPFILES := $(OBJ:%=%.dep)

.PHONY: all clean install


all: $(BIN)

clean:
	@$(RM) $(BIN) $(BIN).dsm obj_st-* obj_dyn-* ../$(FULLNAME).*
	@$(RM) $(DISTROOT)/System/Modules/$(FULLNAME).kext.gz

install: $(BIN)
ifneq ($(BUILDTYPE),static)
	@echo --- Module $(NAME) was installed to System/Modules/$(KEXT).gz
	@$(MKDIR) $(DISTROOT)/System/Modules
	@cp $(BIN) $(KEXT)
	@gzip -c $(KEXT) > $(KEXT).gz
	@$(RM) $(KEXT)
	@cp $(KEXT).gz $(DISTROOT)/System/Modules/$(FULLNAME).kext.gz
else
	@true
endif

ifneq ($(BUILDTYPE),static)
$(BIN): $(OBJ)
	@echo --- $(LD) -o $@
	@$(LD) --allow-shlib-undefined -shared -nostdlib -o $@ $(OBJ) -defsym=DriverInfo=_DriverInfo_$(FULLNAME) $(LDFLAGS)
	@$(OBJDUMP) -d -S $(BIN) > $(BIN).dsm
else
$(BIN): %.xo.$(ARCH): $(OBJ)
	@echo --- LD -o $@
	@$(LD) -r -o $@ $(OBJ) $(LDFLAGS)
endif
	
obj_$(_SUFFIX)/%.d.o: %.d
	@echo --- DD -o $@
	@$(MKDIR) $(dir $@)
	@$(DD) $(DFLAGS) -o $@ -c -fmake-mdeps=$@.o.dep $<

	
-include $(DEPFILES)