REM   Colosseum distribution .zip file maker

set FLAGS=/E /C /I /Y

mkdir __distro_7z_temp__
mkdir __distro_7z_temp__\art
mkdir __distro_7z_temp__\data
mkdir __distro_7z_temp__\fonts
mkdir __distro_7z_temp__\levels
mkdir __distro_7z_temp__\sound
REM mkdir __distro_7z_temp__\user

copy  colosseum.exe              __distro_7z_temp__        
REM xcopy art\*.png                  __distro_7z_temp__\art    %FLAGS%
xcopy art\atlas*.png             __distro_7z_temp__\art    %FLAGS%
xcopy data\*.colosseum_data      __distro_7z_temp__\data   %FLAGS%
xcopy fonts\*.ttf                __distro_7z_temp__\fonts  %FLAGS%
xcopy levels\*.colosseum_level   __distro_7z_temp__\levels %FLAGS%
xcopy sound\*.ogg                __distro_7z_temp__\sound  %FLAGS%
REM xcopy user_release\*.colosseum_* __distro_7z_temp__\user   %FLAGS%

mkdir distros
cd __distro_7z_temp__
7z a -r -tzip ../distros/colosseum.zip *.*
cd ..
rmdir /S /Q __distro_7z_temp__

