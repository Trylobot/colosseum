Rem
	load_images.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
AutoImageFlags( FILTEREDIMAGE | MIPMAPPEDIMAGE )

Global image_path_prefix$ = "art/"
Function LoadImage_SetHandle:TImage( path$, x# = 0, y# = 0 )
	Local img:TImage = LoadImage( image_path_prefix + path )
	SetImageHandle( img, x, y )
	Return img
End Function

Global img_player_tank_chassis:TImage = LoadImage_SetHandle( "player_tank_chassis.png", 16, 12 )
Global img_player_tank_turret_base:TImage = LoadImage_SetHandle( "player_tank_turret_base.png", 6, 6 )
Global img_player_tank_turret_barrel:TImage = LoadImage_SetHandle( "player_tank_turret_barrel.png", 1, 3 )
Global img_player_mgun_turret:TImage = LoadImage_SetHandle( "player_tank_mgun_turret.png", 3, 3 )
Global img_muzzle_flash:TImage = LoadImage_SetHandle( "muzzle_flash.png", 0, 12 )
Global img_mgun_muzzle_flash:TImage = LoadImage_SetHandle( "mgun_muzzle_flash.png", 0, 7 )
Global img_projectile:TImage = LoadImage_SetHandle( "projectile.png", 2, 3 )
Global img_projectile_shell_casing:TImage = LoadImage_SetHandle( "projectile_shell_casing.png", 5, 3 )
Global img_mgun:TImage = LoadImage_SetHandle( "mgun.png", 1, 1 )
Global img_mgun_shell_casing:TImage = LoadImage_SetHandle( "mgun_shell_casing.png", 3, 2 )
Global img_hit:TImage = LoadImage_SetHandle( "hit.png", 14, 14 )
Global img_mgun_hit:TImage = LoadImage_SetHandle( "mgun_hit.png", 9, 9 )
Global img_muzzle_smoke:TImage = LoadImage_SetHandle( "muzzle_smoke.png", 15, 15 )
Global img_mgun_muzzle_smoke:TImage = LoadImage_SetHandle( "mgun_muzzle_smoke.png", 8, 8 )
Global img_enemy_stationary_emplacement_1_base:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-1_base.png", 11, 11 )
Global img_enemy_stationary_emplacement_1_turret:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-1_turret.png", 11, 11 )
Global img_rocket:TImage = LoadImage_SetHandle( "rocket.png", 0, 4 )
Global img_rocket_thrust:TImage = LoadImage_SetHandle( "rocket_thrust.png", 16, 6 )
Global img_rocket_explode:TImage = LoadImage_SetHandle( "rocket_explode.png", 14, 14 )
Global img_box:TImage = LoadImage_SetHandle( "box.png", 8, 8 )
Global img_pickup_ammo_main_5:TImage = LoadImage_SetHandle( "pickup_ammo_main_5.png", 16, 9 )
Global img_help:TImage = LoadImage_SetHandle( "help.png", 0, 0 )
'Global img_arena_bg:TImage = LoadImage_SetHandle( "arena_bg.png", 0, 0 )
'Global img_health_bar:TImage = LoadImage_SetHandle( "health_bar.png", 0, 0 )
'Global img_health_pip:TImage = LoadImage_SetHandle( "health_pip.png", 0, 0 )
Global img_icon_player_cannon_ammo:TImage = LoadImage_SetHandle( "icon_player_cannon_ammo.png", 0, 0 )
Global img_icon_infinity:TImage = LoadImage_SetHandle( "icon_infinity.png", 0, 0 )
'Global img_icon_colosseum_large:TImage = LoadImage_SetHandle( "icon_colosseum_large.png", 0, 0 )
AutoMidHandle( True )
Global img_debris_tiny_0:TImage = LoadImage( image_path_prefix + "debris_tiny-1.png" )
Global img_debris_tiny_1:TImage = LoadImage( image_path_prefix + "debris_tiny-2.png" )
Global img_debris_tiny_2:TImage = LoadImage( image_path_prefix + "debris_tiny-3.png" )
Global img_debris_tiny_3:TImage = LoadImage( image_path_prefix + "debris_tiny-4.png" )
Global img_debris_tiny_4:TImage = LoadImage( image_path_prefix + "debris_tiny-5.png" )
Global img_trail_0:TImage = LoadImage( image_path_prefix + "trail-1.png" )
Global img_trail_1:TImage = LoadImage( image_path_prefix + "trail-2.png" )
Global img_trail_2:TImage = LoadImage( image_path_prefix + "trail-3.png" )
Global img_trail_3:TImage = LoadImage( image_path_prefix + "trail-4.png" )
Global img_trail_4:TImage = LoadImage( image_path_prefix + "trail-5.png" )
AutoMidHandle( False )

