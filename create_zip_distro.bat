rem   Colosseum distribution .zip file maker

mkdir __distro_7z_temp__
mkdir __distro_7z_temp__\art
mkdir __distro_7z_temp__\data
mkdir __distro_7z_temp__\fonts
mkdir __distro_7z_temp__\levels
mkdir __distro_7z_temp__\sound
mkdir __distro_7z_temp__\user

copy Colosseum.exe              __distro_7z_temp__
copy art\*.png                  __distro_7z_temp__\art
copy data\*.colosseum_data      __distro_7z_temp__\data
copy fonts\*.ttf                __distro_7z_temp__\fonts
copy levels\*.colosseum_level   __distro_7z_temp__\levels
copy sound\*.ogg                __distro_7z_temp__\sound
copy user_release\*.colosseum_* __distro_7z_temp__\user

cd __distro_7z_temp__

7z a -r -tzip ../distros/colosseum__win.zip *.*

cd ..
rmdir /S /Q __distro_7z_temp__

