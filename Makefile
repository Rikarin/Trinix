#
# Trinix Core Makefile
#

-include Makefile.cfg

.PHONY: all clean install image

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
$(call targetvars,USRAPPS) \
$(addprefix clean.KernelLand/Modules/, $(MODULES))

IMG := Trinix.img


install:
	@make -C KernelLand/Kernel install
	@kpartx -a $(IMG)
	@sleep 1
	
	@$(MKDIR) mount-tmp
	@mount /dev/mapper/loop0p1 mount-tmp
	
	@cp -Rf Root/* mount-tmp

	@umount mount-tmp
	@$(RM) mount-tmp
	@kpartx -d $(IMG)

image:
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

	
clean: $(addprefix clean.KernelLand/Modules/, $(MODULES))
	@make -C KernelLand/Kernel clean
	
$(addprefix clean.KernelLand/Modules/, $(MODULES)): clean.%:
	@make -C $* clean
	

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