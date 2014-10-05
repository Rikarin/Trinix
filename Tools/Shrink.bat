VMware\VDDK\vmware-mount Z: /d /f
VMware\VDDK\vmware-vdiskmanager -d ..\VMWare\Disk.vmdk
VMware\VDDK\vmware-mount Z: ..\VMWare\Disk.vmdk
VMware\VDDK\vmware-vdiskmanager -p Z:
VMware\VDDK\vmware-mount Z: /d /f
VMware\VDDK\vmware-vdiskmanager -k ..\VMWare\Disk.vmdk