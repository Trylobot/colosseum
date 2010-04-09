REM   colosseum distribution .zip file maker

set FLAGS=/E /C /I /Y

mkdir __distro_7z_temp__
mkdir __distro_7z_temp__\art
mkdir __distro_7z_temp__\data
mkdir __distro_7z_temp__\fonts
mkdir __distro_7z_temp__\levels
mkdir __distro_7z_temp__\sound

copy  colosseum.exe              __distro_7z_temp__        
xcopy art\texture_atlas_*.png    __distro_7z_temp__\art    %FLAGS%
xcopy data\*.media.json          __distro_7z_temp__\data   %FLAGS%
xcopy fonts\*.ttf                __distro_7z_temp__\fonts  %FLAGS%
xcopy levels\*.level.json        __distro_7z_temp__\levels %FLAGS%
xcopy sound\*.ogg                __distro_7z_temp__\sound  %FLAGS%

mkdir distros
cd __distro_7z_temp__
7z a -r -tzip ../distros/colosseum.zip *.*
cd ..
rmdir /S /Q __distro_7z_temp__

