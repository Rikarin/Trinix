# Staticaly linked into Kernel
MODULES += Storage/ATA
MODULES += FileSystem/Ext2
MODULES += Input/PS2KeyboardMouse Input/Keyboard Input/Mouse

#MODULES += Terminal/VTY

# Shared Libs copied to System/Module dir and dynamically loaded while booting
DYNMODS +=