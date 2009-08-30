Rem
	storage.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict

'______________________________________________________________________________
Global font_map:TMap = CreateMap()
Global sound_map:TMap = CreateMap()
Global image_map:TMap = CreateMap()

Function get_font:TImageFont( key$ ) 'returns read-only reference
	Return TImageFont( font_map.ValueForKey( Key.toLower() ))
End Function

Function get_sound:TSound( Key$ ) 'returns read-only reference
	Return TSound( sound_map.ValueForKey( key.toLower() ))
End Function

Function get_image:TImage( Key$ ) 'returns read-only reference
	Return TImage( image_map.ValueForKey( Key.toLower() ))
End Function

