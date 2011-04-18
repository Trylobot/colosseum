REM   colosseum distribution .zip file maker

set FLAGS=/E /C /I /Y
set TEMPDIR=__distro_7z_temp__

mkdir %TEMPDIR%
mkdir %TEMPDIR%\art
mkdir %TEMPDIR%\data
mkdir %TEMPDIR%\levels
mkdir %TEMPDIR%\sound

copy  colosseum.exe              %TEMPDIR%        
xcopy art\*.png                  %TEMPDIR%\art    %FLAGS%
xcopy data\*.media.json          %TEMPDIR%\data   %FLAGS%
xcopy levels\*.level.json        %TEMPDIR%\levels %FLAGS%
xcopy levels\*.preview.png       %TEMPDIR%\levels %FLAGS%
xcopy sound\*.ogg                %TEMPDIR%\sound  %FLAGS%

mkdir distros
cd %TEMPDIR%
7z a -r -tzip ../distros/colosseum.zip *.*
cd ..
rmdir /S /Q %TEMPDIR%

