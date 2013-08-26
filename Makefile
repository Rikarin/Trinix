#
# Trinix Core Makefile
#

-include Makefile.cfg

.DEFAULT_GOAL := all

# Commands
SUBMAKE = $(MAKE) --no-print-directory
KERNEL  := Kernel


define targetclasses
	AI_$1	   := $$(addprefix allinstall-,$$($1))
	ALL_$1	   := $$(addprefix all-,$$($1))
	CLEAN_$1   := $$(addprefix clean-,$$($1))
	INSTALL_$1 := $$(addprefix install-,$$($1))
endef

$(eval $(call targetclasses,KERNEL))
$(eval $(call targetclasses,LIBRARIES))
$(eval $(call targetclasses,BINARIES))
$(eval $(call targetclasses,APPLICATIONS))
$(eval $(call targetclasses,FRAMEWORKS))
$(eval $(call targetclasses,BUNDLES))

targetvars := $$(AI_$1) $$(ALL_$1) $$(CLEAN_$1) $$(INSTALL_$1)

.PHONY: all clean install install-fs \
ai-kernel all-kernel clean-kernel install-kernel \
ai-user all-user clean-user install-user \
$(call targetvars,LIBRARIES) \
$(call targetvars,USERBINS) \
$(call targetvars,USERAPPS) \
$(call targetvars,USERFRAMEWORKS) \
$(call targetvars,USERBUNDLES) \
$(addprefix clean.KernelLand/Modules/, $(MODULES))


ai-kernel:      $(AI_KERNEL)
all-kernel:     $(ALL_KERNEL)
clean-kernel:   $(CLEAN_KERNEL)
install-kernel: $(INSTALL_KERNEL)

ai-user:       $(AI_LIBRARIES)      $(AI_BINARIES)      $(AI_APPLICATIONS)      $(AI_FRAMEWORKS)      $(AI_BUNDLES)
all-user:      $(ALL_LIBRARIES)     $(ALL_BINARIES)     $(ALL_APPLICATIONS)     $(ALL_FRAMEWORKS)     $(ALL_BUNDLES)
clean-user:    $(CLEAN_LIBRARIES)   $(CLEAN_BINARIES)   $(CLEAN_APPLICATIONS)   $(CLEAN_FRAMEWORKS)   $(CLEAN_BUNDLES)
install-user:  $(INSTALL_LIBRARIES) $(INSTALL_BINARIES) $(INSTALL_APPLICATIONS) $(INSTALL_FRAMEWORKS) $(INSTALL_BUNDLES)

all:           all-kernel all-user
all-install:   ai-kernel ai-user install-fs
clean:         clean-kernel clean-user
install:       install-kernel install-user install-fs

define rules
$$(ALL_$1): all-%: #$(DD)
	+@echo Building version ${SYSTEM_VERSION}
	+@echo === $2 && $3 all
$$(AI_$1): allinstall-%: #$(DD)
	+@echo === $2 && $3 all install
$$(CLEAN_$1): clean-%:
	+@echo === $2 && $3 clean
$$(INSTALL_$1): install-%: #$(DD)
	+@echo === $2 && $3 install
endef

$(eval $(call rules,KERNEL,Kernel,$(SUBMAKE) -C $$*))
$(eval $(call rules,USERLIBS,User Library: $$*,$(SUBMAKE) -C Userspace/Library/$$*_src))
$(eval $(call rules,USERBINS,User Binary: $$*,$(SUBMAKE) -C Userspace/Binary/$$*_src))
$(eval $(call rules,USERAPPS,User Application: $$*,$(SUBMAKE) -C Userspace/Application/$$*_src))
$(eval $(call rules,USERFRAMEWORKS,User Framework: $$*,$(SUBMAKE) -C Userspace/Framework/$$*_src))
$(eval $(call rules,BUNDLES,User Bundle: $$*,$(SUBMAKE) -C Userspace/Bundle/$$*_src))

install-fs:
	@$(SUBMAKE) install -C Userspace/FileSystem

echo:
	@echo Version: $(SYSTEM_VERSION)
	@echo ARCH: $(ARCH)
	@echo ARCHDIR: $(ARCH_DIR)
	@echo BUILD_TYPE: $(BUILD_TYPE)
	@echo RC_VERSION: $(RC_VERSION)
	@echo $(DD)


$(DD):
	@echo ---
	@echo $(CC) or $(DD) does not exist, recompiling
	@echo ---
	make -C Externals/CrossCompiler/
