Rem
	load_images.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

Global img_help:TImage = LoadImage( "art/help.png" )
SetImageHandle( img_help, 0, 0 )

Global img_arena_bg:TImage = LoadImage( "art/arena_bg.png" )
SetImageHandle( img_arena_bg, 0, 0 )
Const arena_w% = 500
Const arena_h% = 500
Const arena_offset% = 25

Global img_player_tank_chassis:TImage = LoadImage( "art/player_tank_chassis.png" )
SetImageHandle( img_player_tank_chassis, 17, 12 )
Global img_player_tank_turret:TImage = LoadImage( "art/player_tank_turret.png" )
SetImageHandle( img_player_tank_turret, 12, 12 )
Global img_player_mgun_turret:TImage = LoadImage( "art/player_tank_mgun_turret.png" )
SetImageHandle( img_player_mgun_turret, 12, 12 )
Global img_muzzle_flash:TImage = LoadImage( "art/muzzle_flash.png" )
SetImageHandle( img_muzzle_flash, 1, 12 )
Global img_mgun_muzzle_flash:TImage = LoadImage( "art/mgun_muzzle_flash.png" )
SetImageHandle( img_mgun_muzzle_flash, 1, 5 )
Global img_projectile:TImage = LoadImage( "art/projectile.png" )
SetImageHandle( img_projectile, 2, 3 )
Global img_mgun:TImage = LoadImage( "art/mgun.png" )
SetImageHandle( img_mgun, 1, 1 )
Global img_hit:TImage = LoadImage( "art/hit.png" )
SetImageHandle( img_hit, 14, 14 )
Global img_mgun_hit:TImage = LoadImage( "art/mgun_hit.png" )
SetImageHandle( img_mgun_hit, 9, 9 )

Global img_enemy_agent:TImage = LoadImage( "art/enemy_agent.png" )
SetImageHandle( img_enemy_agent, 8, 8 )

Global img_health_bar:TImage = LoadImage( "art/health_bar.png" )
SetImageHandle( img_health_bar, 0, 0 )
Global img_health_pip:TImage = LoadImage( "art/health_pip.png" )
SetImageHandle( img_health_pip, 0, 0 )

AutoMidHandle( True )
Global imglib_debris_tiny:TImage[5]
imglib_debris_tiny[0] = LoadImage( "art/tiny1.png" )
imglib_debris_tiny[1] = LoadImage( "art/tiny2.png" )
imglib_debris_tiny[2] = LoadImage( "art/tiny3.png" )
imglib_debris_tiny[3] = LoadImage( "art/tiny4.png" )
imglib_debris_tiny[4] = LoadImage( "art/tiny5.png" )
AutoMidHandle( False )