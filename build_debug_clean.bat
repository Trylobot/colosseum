@echo off
bmk makeapp -a -d -o main.debug.exe main.bmx
del Colosseum.DEBUG.exe
rename main.debug.exe Colosseum.DEBUG.exe
