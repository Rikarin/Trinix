@echo off

"D:\Instalacky\plink.exe" -ssh -l root -i G:/private2.ppk 192.168.0.107 cd /zlozka/;%*