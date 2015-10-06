@echo off

echo -- Projet metrics Kernel --
powershell "\"\""

echo Files
powershell "\"  Sources: \" + (dir ..\KernelLand *.d -recurse).Count"
powershell "\"\""

echo Lines
powershell "\"  Total: \" + ((dir ..\KernelLand -include *.d -recurse | select-string .).Count)"
powershell "\"  Comments: \" + ((dir ..\KernelLand -include *.d -recurse | select-string \"//\").Count)"
powershell "\"  Brackets: \" + ((dir ..\KernelLand -include *.d -recurse | select-string \"[{}]\").Count)"
powershell "\"\""


echo -- Projet metrics Userspace --
powershell "\"\""

echo Files
powershell "\"  Sources: \" + (dir ..\Userspace *.d -recurse).Count"
powershell "\"\""

echo Lines
powershell "\"  Total: \" + ((dir ..\Userspace -include *.d -recurse | select-string .).Count)"
powershell "\"  Comments: \" + ((dir ..\Userspace -include *.d -recurse | select-string \"//\").Count)"
powershell "\"  Brackets: \" + ((dir ..\Userspace -include *.d -recurse | select-string \"[{}]\").Count)"
powershell "\"\""


pause