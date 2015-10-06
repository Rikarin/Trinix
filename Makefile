#
# Trinix Core Makefile
#
# TODO:
#	o Add some test (for travis etc)

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
$(eval $(call targetclasses,DYNMODS))
$(eval $(call targetclasses,MODULES))
$(eval $(call targetclasses,USERLIBS))
$(eval $(call targetclasses,USERBINS))
$(eval $(call targetclasses,USERAPPS))
$(eval $(call targetclasses,USERFRAMEWORKS))
$(eval $(call targetclasses,USERBUNDLES))

targetvars := $$(AI_$1) $$(ALL_$1) $$(CLEAN_$1) $$(INSTALL_$1)

.PHONY: all clean install \
ai-kmode all-kmode clean-kmode install-kmode \
ai-user all-user clean-user install-user \
allinstall-Kernel all-Kernel clean-Kernel install-Kernel \
$(call targetvars,DYNMODS) \
$(call targetvars,MODULES) \
$(call targetvars,USRLIBS) \
$(call targetvars,USERBINS) \
$(call targetvars,USERAPPS) \
$(call targetvars,USERFRAMEWORKS) \
$(call targetvars,USERBUNDLES) \
$(addprefix clean.KernelLand/Modules/, $(MODULES))


#TODO: make core.dynlib as a .o and link it with kernel?
ai-kmode:      $(AI_MODULES)      $(AI_KERNEL)         $(AI_DYNMODS)
all-kmode:     $(ALL_MODULES)     $(ALL_KERNEL)        $(ALL_DYNMODS)
clean-kmode:   $(CLEAN_MODULES)   $(CLEAN_KERNEL)      $(CLEAN_DYNMODS)
install-kmode: $(INSTALL_MODULES) $(INSTALL_KERNEL)    $(INSTALL_DYNMODS)

ai-user:       $(AI_USERLIBS)      $(AI_USERBINS)      $(AI_USERAPPS)      $(AI_USERFRAMEWORKS)      $(AI_USERBUNDLES)
all-user:      $(ALL_USERLIBS)     $(ALL_USERBINS)     $(ALL_USERAPPS)     $(ALL_USERFRAMEWORKS)     $(ALL_USERBUNDLES)
clean-user:    $(CLEAN_USERLIBS)   $(CLEAN_USERBINS)   $(CLEAN_USERAPPS)   $(CLEAN_USERFRAMEWORKS)   $(CLEAN_USERBUNDLES)
install-user:  $(INSTALL_USERLIBS) $(INSTALL_USERBINS) $(INSTALL_USERAPPS) $(INSTALL_USERFRAMEWORKS) $(INSTALL_USERBUNDLES)

all:           all-user all-kmode
all-install:   install-FileSystem ai-user ai-kmode
clean:         clean-user clean-kmode
install:       install-FileSystem install-user install-kmode


_build_dynmod := BUILDTYPE=dynamic $(SUBMAKE) -C KernelLand/Modules/
_build_stmod  := BUILDTYPE=static $(SUBMAKE) -C KernelLand/Modules/
_build_kernel := $(SUBMAKE) -C KernelLand/

define rules
$$(ALL_$1): all-%: #$(DD)
	+@echo === $2 && $3 all
$$(AI_$1): allinstall-%: #$(DD)
	+@echo === $2 && $3 all install
$$(CLEAN_$1): clean-%: #$(DD)
	+@echo === $2 && $3 clean
$$(INSTALL_$1): install-%: #$(DD)
	+@echo === $2 && $3 install
endef

$(eval $(call rules,KERNEL,Kernel,$(_build_kernel)$$*))
$(eval $(call rules,DYNMODS,Dynamic Module: $$*,$(_build_dynmod)$$*))
$(eval $(call rules,MODULES,Static Module: $$*,$(_build_stmod)$$*))
$(eval $(call rules,USERLIBS,User Library: $$*,$(SUBMAKE) -C Userspace/Library/$$*_src))
$(eval $(call rules,USERBINS,User Binary: $$*,$(SUBMAKE) -C Userspace/Binary/$$*_src))
$(eval $(call rules,USERAPPS,User Application: $$*,$(SUBMAKE) -C Userspace/Application/$$*_src))
$(eval $(call rules,USERFRAMEWORKS,User Framework: $$*,$(SUBMAKE) -C Userspace/Framework/$$*_src))
$(eval $(call rules,USERBUNDLES,User Bundle: $$*,$(SUBMAKE) -C Userspace/Bundle/$$*_src))

install-FileSystem:
	@$(SUBMAKE) install -C Userspace/FileSystem


echo:
	@echo Version: $(TRINIX_VERSION)
	@echo ARCH: $(ARCH)
	@echo ARCHDIR: $(ARCHDIR)
	@echo BUILD_TYPE: $(BUILD_TYPE)
#TODO: check this @echo $(call targetvars,MODULES)











#### TODO DEPRECATED, REMOVE THIS QUICKLY
IMG := Trinix.img

install42:
	@make -C KernelLand/Kernel install
	@kpartx -a $(IMG)
	@sleep 1
	
	@$(MKDIR) mount-tmp
	@mount /dev/mapper/loop0p1 mount-tmp
	
	@cp -Rf Root/* mount-tmp

	@umount mount-tmp
	@$(RM) mount-tmp
	@kpartx -d $(IMG)

image42:
	@dd if=/dev/zero of=/opt/$(IMG) bs=512 count=100000
	@parted --script /opt/$(IMG) mktable msdos mkpart p ext2 1 40 set 1 boot on
	@kpartx -a /opt/$(IMG)
	@sleep 1
	@mkfs.ext2 /dev/mapper/loop0p1
	
	@$(MKDIR) mount-tmp
	@mount /dev/mapper/loop0p1 mount-tmp
	
	@grub2-install --no-floppy --boot-directory=mount-tmp/System/Boot /dev/loop0

	@umount mount-tmp
	@$(RM) mount-tmp
	@kpartx -d /opt/$(IMG)
	@mv /opt/$(IMG) $(IMG)

	
clean42: $(addprefix clean.KernelLand/Modules/, $(MODULES))
	@make -C KernelLand/Kernel clean
	
$(addprefix clean.KernelLand/Modules/, $(MODULES))42: clean.%:
	@make -C $* clean
	

test42: $(ALL_SYSLIBsS) $(CC)
	@echo $(ARCH) $(ARCHDIR) $(TRIPLET)
	@echo aa
	
	
	
	
#TODO: call install script
ifeq ($(ARCHDIR),native)
.PHONY: $(CC) $(DD)
else
$(CC):
	@echo ---
	@echo $(CC) does not exist, recompiling
	@echo ---
	make -C Externals/CrossCompiler/
	
$(DD):
	@echo ---
	@echo $(DD) does not exist, recompiling
	@echo ---
	make -C Externals/CrossCompiler/
endif