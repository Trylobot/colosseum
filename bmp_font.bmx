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

'______________________________________________________________________________
Function draw_layered_string( str$, x#, y#, fg_font:BMP_FONT = Null, bg_font:BMP_FONT = Null, fg_red% = 255, fg_green% = 255, fg_blue% = 255, bg_red% = 127, bg_green% = 127, bg_blue% = 127 )
	If bg_font
		SetColor( bg_red, bg_green, bg_blue )
		bg_font.draw_string( str, x, y )
	End If
	If fg_font
		SetColor( fg_red, fg_green, fg_blue )
		fg_font.draw_string( str, x, y )
	End If
End Function

'______________________________________________________________________________
Rem
the font image is required to contain exactly these characters (including the space character at position 0):
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
EndRem
Type BMP_FONT
	Const test_string$ = " !~q#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~~"
	Const ascii_start% = 32  'ASCII Space
	Const ascii_end%   = 126 'ASCII Tilde (inclusive)
	Const char_count%  = ascii_end + 1 - ascii_start

	Field font_img:IMAGE_ATLAS_REFERENCE
	Field offset_x%
	Field baseline_y%
	Field char_spacing%
	Field char_width%[]
  Field scale%
  Field height%
	
	Method draw_string( str$, x#, y# )
		Local cx% = x
		Local cy% = y
		Local glyph%
    SetScale( scale, scale )
		For Local i% = 0 Until str.Length
			glyph = str[i] - ascii_start
			If glyph < 0 Or glyph >= char_count Then glyph = 0
			DrawImageRef( font_img, cx, cy, glyph )
			cx :+ scale * (char_width[glyph] + char_spacing)
		Next
	End Method
	
	Method width%( str$, offset% = 0, length% = -1 )
		If length = -1 Then length = str.length
		Local w% = 0
		Local glyph%
		For Local i% = offset Until length
			glyph = str[i] - ascii_start
			If glyph < 0 Or glyph >= char_count Then glyph = 0
			w :+ scale * (char_width[glyph] + char_spacing)
		Next
		Return w
	End Method
	
	Function Create_from_json:BMP_FONT( json:TJSON )
		Local path$
    Local offset_x%
		Local baseline_y%
		Local char_spacing%
		Local char_width%[]
		Local img:IMAGE_ATLAS_REFERENCE
		Local f:BMP_FONT
		
    path = json.GetString( "path" )
    offset_x = json.GetNumber( "offset_x" )
		baseline_y = json.GetNumber( "baseline_y" )
		char_spacing = json.GetNumber( "char_spacing" )
		char_width = Create_Int_array_from_TJSONArray( json.GetArray( "char_widths" ))
		If char_width.Length <> char_count
			DebugStop
			Return Null
		End If
		img = IMAGE_ATLAS_REFERENCE( TEXTURE_MANAGER.reference_map.ValueForKey( path ))
		If Not img
			DebugStop
		End If
		img.LoadVariableWidthBMPFont( char_count, char_width, offset_x, baseline_y )
		f = New BMP_FONT
		f.font_img = img
		f.offset_x = offset_x
		f.baseline_y = baseline_y
		f.char_spacing = char_spacing
		f.char_width = char_width
    f.scale = 1
    f.height = img.height()
		Return f
	End Function
  
  Method clone:BMP_FONT()
    Local f:BMP_FONT = New BMP_FONT
    f.font_img = font_img
		f.offset_x = offset_x
		f.baseline_y = baseline_y
		f.char_spacing = char_spacing
    f.char_width = char_width[..]
    f.scale = scale
    f.height = height
    Return f
  End Method
  
  Function Create_copy_from_json:BMP_FONT( json:TJSON )
    Local key$
    Local b:BMP_FONT
    Local scale%
    Local f:BMP_FONT
    
    key = json.GetString( "base_font" )
    b = get_bmp_font( key )
		If Not b Then Return Null
    scale = json.GetNumber( "scale" )
		f = b.clone()
		'recalculate members which rely on scale
		f.offset_x = scale*b.offset_x
		f.baseline_y = scale*b.baseline_y
		f.char_spacing = scale*b.char_spacing
    f.scale = scale
    f.height = scale*b.height
		Return f
  End Function
	
End Type

