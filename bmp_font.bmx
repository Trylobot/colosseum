Rem
	bmp_font.bmx
	This is a COLOSSEUM project BlitzMax source file.

EndRem
'SuperStrict
'Import "image_atlas.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Global bmp_font_map:TMap = CreateMap() 

Function get_bmp_font:BMP_FONT( key$ )
	Return BMP_FONT( bmp_font_map.ValueForKey( key.toLower() ))
End Function

Type BMP_FONT
	Const ascii_start% = 32
	Const ascii_end% = 126
	Const char_count% = ascii_end - ascii_start
	Rem
	character ordering
	 !"#$%'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
	EndRem
	Field font_img:IMAGE_ATLAS_REFERENCE
	Field char_width%[]
	
	Method draw_string( str$, x#, y# )
		Local cx% = x
		Local cy% = y
		Local glyph_index%
		For Local i% = 0 Until str.Length
			glyph_index = Asc( str[i..i+1] ) - ascii_start
			If glyph_index < char_width.Length
				DrawImageRef( font_img, cx, cy, glyph_index )
				cx :+ char_width[glyph_index]
			Else
				Return
			End If
		Next
	End Method
	
	Function Create_from_json:BMP_FONT( json:TJSON )
		Local src_path$
		Local scale%
		Local baseline_y%
		Local char_width%[]
		Local img:IMAGE_ATLAS_REFERENCE
		Local f:BMP_FONT
		src_path = json.GetString( "path" ).Trim()
		scale = json.GetNumber( "scale" )
		baseline_y = json.GetNumber( "baseline_y" )
		char_width = Create_Int_array_from_TJSONArray( json.GetArray( "char_widths" ))
		If char_width.Length <> char_count
			DebugLog "Error in BMP_FONT Create_from_json: expected " + char_count + " characters, found " + char_width.Length 
			Return Null
		End If
		img = IMAGE_ATLAS_REFERENCE( TEXTURE_MANAGER.reference_map.ValueForKey( src_path ))
		img.LoadVariableWidthBMPFont( char_count, char_width, scale, baseline_y )
		f = New BMP_FONT
		f.font_img = img
		f.char_width = char_width
		Return f
	End Function
	
End Type

