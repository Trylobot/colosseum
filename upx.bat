@echo off
delete Colosseum.exe
copy colosseum.blide_project.exe Colosseum.exe
"C:\Program Files\UPX\upx.exe" -9 Colosseum.exe
