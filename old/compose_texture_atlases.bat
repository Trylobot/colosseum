@echo off
REM prepare all colosseum texture atlases from the following file lists:
REM   texture_filtered.dat
REM   texture_raw.dat


set name=texture_atlas_filtered
del art\%name%.png
dir art\*.png /s /b | find /v "fonts" | find /v "texture_atlas_" | python atlasgen\atlasgen.py -o art\%name%.png -c data\%name%.media.json --filtered
echo %name% done.

set name=texture_atlas_raw
del art\%name%.png
dir art\*.png /s /b | find "fonts" | find /v "texture_atlas_" | python atlasgen\atlasgen.py -o art\%name%.png -c data\%name%.media.json
echo %name% done.

