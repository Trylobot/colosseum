Rem
	storage.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import brl.Map
Import brl.FreeTypeFont
Import brl.FreeAudioAudio
Import brl.OGGLoader
Import brl.PNGLoader
Import "texture_manager.bmx"

'______________________________________________________________________________
Global font_map:TMap = CreateMap()
Global sound_map:TMap = CreateMap()
'Global image_map:TMap = CreateMap()
'use TEXTURE_MANAGER instead

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

