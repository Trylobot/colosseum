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
	Rem
	character ordering
	 !"#$%'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
	EndRem
	Const ascii_start% = 32  'ASCII Space
	Const ascii_end%   = 126 'ASCII Tilde
	Const char_count%  = ascii_end - ascii_start

	Field font_img:IMAGE_ATLAS_REFERENCE
	Field char_width%[]
  Field scale%
	
	Method draw_string( str$, x#, y# )
		Local cx% = x
		Local cy% = y
		Local glyph%
    SetScale( scale, scale )
		For Local i% = 0 Until str.Length
			glyph = str[i] - ascii_start
			If glyph < char_count
				DrawImageRef( font_img, cx, cy, glyph )
				cx :+ scale * char_width[glyph]
			End If
		Next
	End Method
	
	Function Create_from_json:BMP_FONT( json:TJSON )
		Local src_path$
    Local offset_x%
		Local baseline_y%
		Local char_width%[]
		Local img:IMAGE_ATLAS_REFERENCE
		Local f:BMP_FONT
		
    src_path = json.GetString( "path" )
    offset_x = json.GetNumber( "offset_x" )
		baseline_y = json.GetNumber( "baseline_y" )
		char_width = Create_Int_array_from_TJSONArray( json.GetArray( "char_widths" ))
		If char_width.Length <> char_count
			DebugStop
			Return Null
		End If
		img = IMAGE_ATLAS_REFERENCE( TEXTURE_MANAGER.reference_map.ValueForKey( src_path ))
		img.LoadVariableWidthBMPFont( char_count, char_width, offset_x, baseline_y )
		f = New BMP_FONT
		f.font_img = img
		f.char_width = char_width
    f.scale = 1
		Return f
	End Function
  
  Method clone:BMP_FONT()
    Local f:BMP_FONT = New BMP_FONT
    f.font_img = font_img
    f.char_width = char_width[..]
    f.scale = scale
    Return f
  End Method
  
  Function Create_copy_from_json:BMP_FONT( json:TJSON )
    Local base_font_key$
    Local base_font:BMP_FONT
    Local scale%
    Local f:BMP_FONT
    
    base_font_key = json.GetString( "base_font" )
    base_font = get_bmp_font( base_font_key )
    scale = json.GetNumber( "scale" )
		f = base_font.clone()
    f.scale = scale
		Return f
  End Function
	
End Type

