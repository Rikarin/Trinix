#
# Trinix Core Makefile
#

-include Makefile.cfg

.PHONY: all clean install

SYSLIBS := crt0.o

SYSBINS := cock007


define targetclasses
	AI_$1		:= $$(addprefix allinstall-,$$($1))
	ALL_$1		:= $$(addprefix all-,$$($1))
	CLEAN_$1	:= $$(addprefix clean-,$$($1))
	INSTALL_$1	:= $$(addprefix install-,$$($1))
endef

$(eval $(call targetclasses,DYNMODS))
$(eval $(call targetclasses,MODULES))
$(eval $(call targetclasses,SYSLIBS))
$(eval $(call targetclasses,EXTLIBS))
$(eval $(call targetclasses,SYSBINS))

targetvars := $$(AI_$1) $$(ALL_$1) $$(CLEAN_$1) $$(INSTALL_$1)

.PHONY: $(call targetvars,DYNMODS) \
$(call targetvars,MODULES) \
$(call targetvars,USRLIBS) \
$(call targetvars,EXTLIBS) \
$(call targetvars,USRAPPS)


test: $(ALL_SYSLIBsS) $(CC)
	@echo $(ARCH) $(ARCHDIR) $(TRIPLET)
	@echo aa
	
	
	
	
	
	
ifeq ($(ARCHDIR),native)
.PHONY: $(CC) $(D)
else
$(CC):
	@echo ---
	@echo $(CC) does not exist, recompiling
	@echo ---
	make -C Externals/CrossCompiler/
	
$(DD):
	@echo ---
	@echo $(D) does not exist, recompiling
	@echo ---
	make -C Externals/CrossCompiler/
endif