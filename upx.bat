@echo off
delete Colosseum.exe
copy COLOSSEUM_PROJECT.exe Colosseum.exe
"C:\Program Files\UPX\upx.exe" -9 Colosseum.exe
