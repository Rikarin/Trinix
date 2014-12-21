import fileinput

def formatLine(line):
    _, _, name = line.strip().split(" ")
    if name == "abs":
        return
    if name == "iKernelSymbols" or name == "iKernelSymbolsEnd":
        return
    zeroes = ", 0" # * (1 + 4 - ((len(name) + 1) % 4))
    print """
    extern %s
    dd %s
    db '%s'%s""" % (name, name, name, zeroes)


print "SECTION .symbols"

print "global iKernelSymbols"
print "iKernelSymbols:"
for line in fileinput.input():
    formatLine(line)

print "global iKernelSymbolsEnd"
print "iKernelSymbolsEnd:"


