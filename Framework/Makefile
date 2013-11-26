_SRC += $(wildcard System/*.[d|c|s])
_SRC += $(wildcard System/Collections/*.[d|c|s])
_SRC += $(wildcard System/Collections/Generic/*.[d|c|s])
_SRC += $(wildcard System/Diagnostics/*.[d|c|s])
_SRC += $(wildcard System/Drawing/*.[d|c|s])
_SRC += $(wildcard System/IO/*.[d|c|s])
_SRC += $(wildcard System/Threading/*.[d|c|s])
_SRC += $(wildcard System/Windows/*.[d|c|s])


#############
#   Flags   #
#############
DFLAGS = -O -de -w -m64 -release -property -I../druntime/import -IFramework -lib -g


all:
	dmd $(_SRC) -of../Framework.lib $(DFLAGS)

clean:
	@rm -rf ../Framework.lib