@echo off

echo -- Projet metrics --
powershell "\"\""

echo Files
powershell "\"  Sources: \" + (dir ..\Source\Kernel *.d -recurse).Count"
powershell "\"\""

echo Lines
powershell "\"  Total: \" + ((dir ..\Source\Kernel -include *.d -recurse | select-string .).Count)"
powershell "\"  Comments: \" + ((dir ..\Source\Kernel -include *.d -recurse | select-string \"//\").Count)"
powershell "\"  Brackets: \" + ((dir ..\Source\Kernel -include *.d -recurse | select-string \"[{}]\").Count)"
powershell "\"\""

pause