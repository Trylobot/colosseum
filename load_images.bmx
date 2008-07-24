Rem
	load_images.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

AutoImageFlags( FILTEREDIMAGE | MIPMAPPEDIMAGE )

Global img_help:TImage = LoadImage( "art/help.png" )
SetImageHandle( img_help, 0, 0 )

Global img_arena_bg:TImage = LoadImage( "art/arena_bg.png" )
SetImageHandle( img_arena_bg, 0, 0 )
Const arena_w% = 500
Const arena_h% = 500
Const arena_offset% = 25

Global img_health_bar:TImage = LoadImage( "art/health_bar.png" )
SetImageHandle( img_health_bar, 0, 0 )
Global img_health_pip:TImage = LoadImage( "art/health_pip.png" )
SetImageHandle( img_health_pip, 0, 0 )


Global img_player_tank_chassis:TImage = LoadImage( "art/player_tank_chassis.png" )
SetImageHandle( img_player_tank_chassis, 16, 12 )
Global img_player_tank_turret:TImage = LoadImage( "art/player_tank_turret.png" )
SetImageHandle( img_player_tank_turret, 12, 12 )
Global img_player_mgun_turret:TImage = LoadImage( "art/player_tank_mgun_turret.png" )
SetImageHandle( img_player_mgun_turret, 12, 12 )
Global img_muzzle_flash:TImage = LoadImage( "art/muzzle_flash.png" )
SetImageHandle( img_muzzle_flash, 0, 12 )
Global img_mgun_muzzle_flash:TImage = LoadImage( "art/mgun_muzzle_flash.png" )
SetImageHandle( img_mgun_muzzle_flash, 0, 5 )
Global img_projectile:TImage = LoadImage( "art/projectile.png" )
SetImageHandle( img_projectile, 2, 3 )
Global img_projectile_shell_casing:TImage = LoadImage( "art/projectile_shell_casing.png" )
SetImageHandle( img_projectile_shell_casing, 5, 3 )
Global img_mgun:TImage = LoadImage( "art/mgun.png" )
SetImageHandle( img_mgun, 1, 1 )
Global img_mgun_shell_casing:TImage = LoadImage( "art/mgun_shell_casing.png" )
SetImageHandle( img_mgun_shell_casing, 3, 2 )
Global img_hit:TImage = LoadImage( "art/hit.png" )
SetImageHandle( img_hit, 14, 14 )
Global img_mgun_hit:TImage = LoadImage( "art/mgun_hit.png" )
SetImageHandle( img_mgun_hit, 9, 9 )
Global img_muzzle_smoke:TImage = LoadImage( "art/muzzle_smoke.png" )
SetImageHandle( img_muzzle_smoke, 15, 15 )
Global img_mgun_muzzle_smoke:TImage = LoadImage( "art/mgun_muzzle_smoke.png" )
SetImageHandle( img_mgun_muzzle_smoke, 8, 8 )
Global img_rocket:TImage = LoadImage( "art/rocket.png" )
SetImageHandle( img_rocket, 2, 4 )


Global img_enemy_stationary_emplacement_1_base:TImage = LoadImage( "art/enemy_stationary-emplacement-1_base.png" )
SetImageHandle( img_enemy_stationary_emplacement_1_base, 11, 11 )
Global img_enemy_stationary_emplacement_1_turret:TImage = LoadImage( "art/enemy_stationary-emplacement-1_turret.png" )
SetImageHandle( img_enemy_stationary_emplacement_1_turret, 11, 11 )


AutoMidHandle( True )
Global img_debris_tiny_0:TImage = LoadImage( "art/debris_tiny-1.png" )
Global img_debris_tiny_1:TImage = LoadImage( "art/debris_tiny-2.png" )
Global img_debris_tiny_2:TImage = LoadImage( "art/debris_tiny-3.png" )
Global img_debris_tiny_3:TImage = LoadImage( "art/debris_tiny-4.png" )
Global img_debris_tiny_4:TImage = LoadImage( "art/debris_tiny-5.png" )
Global img_trail_0:TImage = LoadImage( "art/trail-1.png" )
Global img_trail_1:TImage = LoadImage( "art/trail-2.png" )
Global img_trail_2:TImage = LoadImage( "art/trail-3.png" )
Global img_trail_3:TImage = LoadImage( "art/trail-4.png" )
Global img_trail_4:TImage = LoadImage( "art/trail-5.png" )
AutoMidHandle( False )


Global img_box:TImage = LoadImage( "art/box.png" )
SetImageHandle( img_box, 8, 8 )

