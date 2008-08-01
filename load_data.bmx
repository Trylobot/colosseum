Rem
	load_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Fonts
Global font_path_prefix$ = "fonts/"

Global consolas_normal_8:TImageFont = LoadImageFont( font_path_prefix + "consolas.ttf", 8 )
Global consolas_normal_10:TImageFont = LoadImageFont( font_path_prefix + "consolas.ttf", 10 )
Global consolas_normal_12:TImageFont = LoadImageFont( font_path_prefix + "consolas.ttf", 12 )
Global consolas_normal_24:TImageFont = LoadImageFont( font_path_prefix + "consolas.ttf", 24 )
Global consolas_bold_24:TImageFont = LoadImageFont( font_path_prefix + "consolas_bold.ttf", 24 )
Global consolas_bold_50:TImageFont = LoadImageFont( font_path_prefix + "consolas_bold.ttf", 50 )
Global consolas_bold_100:TimageFont = LoadImageFont( font_path_prefix + "consolas_bold.ttf", 100 )
Global consolas_bold_150:TImageFont = LoadImageFont( font_path_prefix + "consolas_bold.ttf", 150 )

'______________________________________________________________________________
'Sound
Global audio_path_prefix$ = "sound/"

Global bg_music_victory_8_bit:TSound = LoadSound( audio_path_prefix + "victory_8-bit.ogg", SOUND_LOOP )
Global bg_music:TChannel = AllocChannel()
CueSound( bg_music_victory_8_bit, bg_music )
SetChannelVolume( bg_music, 0.5000 )

'______________________________________________________________________________
'Images
AutoImageFlags( FILTEREDIMAGE | MIPMAPPEDIMAGE )
Global image_path_prefix$ = "art/"

Function LoadImage_SetHandle:TImage( path$, x# = 0, y# = 0 )
	Local img:TImage = LoadImage( image_path_prefix + path )
	SetImageHandle( img, x, y )
	Return img
End Function
Function LoadAnimImage_SetHandle:TImage( path$, x# = 0, y# = 0, w# = 1, h# = 1, frames% = 1 )
	Local img:TImage = LoadAnimImage( image_path_prefix + path, w, h, 0, frames )
	SetImageHandle( img, x, y )
	Return img 
End Function

Global img_player_tank_chassis:TImage = LoadImage_SetHandle( "player_tank_chassis.png", 16, 12 )
Global img_player_tank_turret_base:TImage = LoadImage_SetHandle( "player_tank_turret_base.png", 6, 6 )
Global img_player_tank_turret_barrel:TImage = LoadImage_SetHandle( "player_tank_turret_barrel.png", 3, 3 )
Global img_player_mgun_turret:TImage = LoadImage_SetHandle( "player_tank_mgun_turret.png", 3, 3 )
Global img_muzzle_flash:TImage = LoadImage_SetHandle( "muzzle_flash.png", 0, 12 )
Global img_mgun_muzzle_flash:TImage = LoadImage_SetHandle( "mgun_muzzle_flash.png", 0, 7 )
Global img_projectile:TImage = LoadImage_SetHandle( "projectile.png", 6, 3 )
Global img_projectile_shell_casing:TImage = LoadImage_SetHandle( "projectile_shell_casing.png", 5, 3 )
Global img_mgun:TImage = LoadImage_SetHandle( "mgun.png", 4, 1 )
Global img_mgun_shell_casing:TImage = LoadImage_SetHandle( "mgun_shell_casing.png", 3, 2 )
Global img_hit:TImage = LoadImage_SetHandle( "hit.png", 14, 14 )
Global img_mgun_hit:TImage = LoadImage_SetHandle( "mgun_hit.png", 9, 9 )
Global img_muzzle_smoke:TImage = LoadImage_SetHandle( "muzzle_smoke.png", 15, 15 )
Global img_mgun_muzzle_smoke:TImage = LoadImage_SetHandle( "mgun_muzzle_smoke.png", 8, 8 )
Global img_enemy_stationary_emplacement_1_chassis:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-1_chassis.png", 11, 11 )
Global img_enemy_stationary_emplacement_1_turret_base:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-1_turret-base.png", 11, 11 )
Global img_enemy_stationary_emplacement_1_turret_barrel:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-1_turret-barrel.png", 11, 11 )
Global img_enemy_stationary_emplacement_2_chassis:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-2_chassis.png", 17, 17 )
Global img_enemy_stationary_emplacement_2_turret_base:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-2_turret-base.png", 12, 6 )
Global img_enemy_stationary_emplacement_2_turret_barrel:TImage = LoadImage_SetHandle( "enemy_machine-gun_emplacement_turret-barrel.png", 2, 2 )
Global img_chain_gun:TImage = LoadImage_SetHandle( "chain_gun.png", 3, 1 )
Global img_chain_gun_shell_casing:TImage = LoadImage_SetHandle( "chain_gun_shell_casing.png", 1, 1 )
Global img_rocket:TImage = LoadImage_SetHandle( "rocket.png", 13, 5 )
Global img_rocket_thrust:TImage = LoadImage_SetHandle( "rocket_thrust.png", 16, 6 )
Global img_rocket_explode:TImage = LoadImage_SetHandle( "rocket_explode.png", 14, 14 )
Global img_box:TImage = LoadImage_SetHandle( "box.png", 8, 8 )
Global img_box_gib:TImage = LoadAnimImage_SetHandle( "box_gib.png", 8, 8, 17, 17, 2 )
Global img_pickup_ammo_main_5:TImage = LoadImage_SetHandle( "pickup_ammo_main_5.png", 16, 9 )
Global img_pickup_health:TImage = loadimage_Sethandle( "pickup_health.png", 16, 9 )
Global img_help:TImage = LoadImage_SetHandle( "help.png", 0, 0 )
Global img_arena_bg:TImage = LoadImage_SetHandle( "bg.png", 0, 0 )
Global img_arena_wall:TImage = LoadImage_SetHandle( "bg_wall.png", 0, 0 )
Global img_icon_player_cannon_ammo:TImage = LoadImage_SetHandle( "icon_player_cannon_ammo.png", 0, 0 )
Global img_debris:TImage = LoadAnimImage_SetHandle( "debris.png", 2, 2, 5, 5, 5 )
Global img_trail:TImage = LoadAnimImage_SetHandle( "trail.png", 2, 3, 4, 7, 5 )
Global img_reticle:TImage = LoadImage_SetHandle( "reticle.png", -8, 7 )
Global img_icon_music_note:TImage = LoadImage_SetHandle( "icon_music_note.png", 0, 0 )
Global img_icon_speaker_on:TImage = LoadImage_SetHandle( "icon_speaker_on.png", 0, 0 )
Global img_icon_speaker_off:TImage = LoadImage_SetHandle( "icon_speaker_off.png", 0, 0 )
Global img_nme_mobile_bomb:TImage = LoadImage_SetHandle( "nme_mobile_bomb.png", 7, 7 )
Global img_glow:TImage = LoadImage_SetHandle( "glow.png", 7, 7 )
Global img_laser:TImage = LoadImage_SetHandle( "laser.png", 13, 2 )
Global img_laser_turret:TImage = LoadImage_SetHandle( "laser_turret_base-barrel.png", 6, 6 )
Global img_laser_muzzle_flare:TImage = LoadImage_SetHandle( "laser_muzzle_flare.png", 1, 7 )
Global img_tower_gibs:TImage = LoadAnimImage_SetHandle( "tower_gibs.png", 11, 11, 23, 23, 11 )
Global img_bomb_gibs:TImage = LoadAnimImage_SetHandle( "bomb_gibs.png", 7, 7, 15, 15, 7 )
