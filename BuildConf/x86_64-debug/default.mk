# Staticaly linked into Kernel
MODULES        += Storage/ATA
#MODULES       += FileSystem/Ext2
MODULES        += Input/PS2KeyboardMouse Input/Keyboard Input/Mouse
MODULES        += Display/BochsGA
#MODULES += Terminal/VTY

# Shared Libs copied to System/Module dir and dynamically loaded while booting
DYNMODS        += FileSystem/Ext2

# Libraries .dylib .a .o
USERLIBS       += crt0.o core.dylib

# Binaries
USERBINS       +=

# Applications .app (Compositor required)
USERAPPS       += 

# Frameworks .framework (Compositor required)
USERFRAMEWORKS += 

# Bundle .bundle (Autonomus system (bin, lib, doc, share, etc) for ported apps like llvm, ldc, etc.)
USERBUNDLES    +=