@echo off

echo -- Projet metrics --
powershell "\"\""

echo Files
powershell "\"  Sources: \" + (dir ..\KernelLand *.d -recurse).Count"
powershell "\"\""

echo Lines
powershell "\"  Total: \" + ((dir ..\KernelLand -include *.d -recurse | select-string .).Count)"
powershell "\"  Comments: \" + ((dir ..\KernelLand -include *.d -recurse | select-string \"//\").Count)"
powershell "\"  Brackets: \" + ((dir ..\KernelLand -include *.d -recurse | select-string \"[{}]\").Count)"
powershell "\"\""

pause