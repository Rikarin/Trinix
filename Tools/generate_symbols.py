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
    dq %s
    db '%s'%s""" % (name, name, name, zeroes)


print "SECTION .symbols"
for line in fileinput.input():
    formatLine(line)