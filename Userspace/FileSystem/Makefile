#
# Trinix FyleSystem creator
#

-include ../Makefile.cfg

.PHONY: install

IMG := $(TRXDIR)/Trinix.img

install: $(IMG)
	@kpartx -a $(IMG)
	@sleep 1
	
	@$(MKDIR) mount-tmp
	@mount /dev/mapper/loop0p1 mount-tmp
	
	@cp -Rf $(TRXDIR)/Root/* mount-tmp

	@umount mount-tmp
	@$(RM) mount-tmp
	@kpartx -d $(IMG)

$(IMG):
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