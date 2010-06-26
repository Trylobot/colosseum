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
Const art_path$ = "art/"
Const data_path$ = "data/"
Const font_path$ = "fonts/"
Const level_path$ = "levels/"
Const sound_path$ = "sound/"
Const user_path$ = "user/"

Const settings_file_ext$ = "config.json"
Const data_file_ext$ = "media.json"
Const level_file_ext$ = "level.json"
Const saved_game_file_ext$ = "profile.json"
Const level_preview_ext$ = "preview.png"

Const autosave_path$ = user_path + "autosave" + "." + settings_file_ext
Const settings_path$ = user_path + "settings" + "." + settings_file_ext

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
  "gibs"..
]

'______________________________________________________________________________
Global font_map:TMap = CreateMap() 'deprecated; use BMP_FONT instead
Global sound_map:TMap = CreateMap()
'Global image_map:TMap = CreateMap() 'use TEXTURE_MANAGER instead of image map
Global level_grid$[][]

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

'______________________________________________________________________________
Function level_preview_path_from_level_path$( lev_path$ )
  Return lev_path[..(lev_path.Length-level_file_ext.Length)] + level_preview_ext
End Function

