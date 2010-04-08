Rem
	storage.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import brl.Map
'Import brl.FreeTypeFont
'Import brl.FreeAudioAudio
'Import brl.OGGLoader
'Import brl.PNGLoader
'Import "texture_manager.bmx"

'______________________________________________________________________________
Const settings_file_ext$ = "colosseum_settings"
Const data_file_ext$ = "colosseum_data"
Const level_file_ext$ = "colosseum_level"
Const saved_game_file_ext$ = "colosseum_profile"
Const autosave_path$ = "user/autosave.colosseum_data"

Const art_path$ = "art/"
Const data_path$ = "data/"
Const font_path$ = "fonts/"
Const level_path$ = "levels/"
Const sound_path$ = "sound/"
Const user_path$ = "user/"

Const default_settings_file_name$ = "settings" + "." + settings_file_ext

Global texture_atlas_files$[] = [ ..
  "texture_atlas_filtered", ..
  "texture_atlas_raw" ..
]

Global asset_files$[] = [ ..
	"fonts", ..
	"bmp_fonts", ..
	"sounds", ..
	"images", ..
	"props", ..
	"particles", ..
	"particle_emitters", ..
	"projectiles", ..
	"projectile_launchers", ..
	"widgets", ..
	"pickups", ..
	"turret_barrels", ..
	"turrets", ..
	"ai_types", ..
	"player_vehicles", ..
	"units", ..
	"campaigns" ..
]

'______________________________________________________________________________
Global font_map:TMap = CreateMap() 'deprecated; use BMP_FONT instead
Global sound_map:TMap = CreateMap()
'Global image_map:TMap = CreateMap() 'use TEXTURE_MANAGER instead of image map

Function get_font:TImageFont( key$ ) 'returns read-only reference
	Return TImageFont( font_map.ValueForKey( key.toLower() ))
End Function

Function get_sound:TSound( key$ ) 'returns read-only reference
	Return TSound( sound_map.ValueForKey( key.toLower() ))
End Function

'Function get_image:TImage( key$ ) 'returns read-only reference
'	Return TImage( image_map.ValueForKey( key.toLower() ))
'End Function
Function get_image:IMAGE_ATLAS_REFERENCE( key$ )
	Return TEXTURE_MANAGER.GetImageRef( key )
End Function

