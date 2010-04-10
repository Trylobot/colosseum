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
Function draw_layered_string#( str$, x#, y#, fg_font:BMP_FONT = Null, bg_font:BMP_FONT = Null, fg_red% = 255, fg_green% = 255, fg_blue% = 255, bg_red% = 127, bg_green% = 127, bg_blue% = 127 )
	Local y_delta# = 0
	If bg_font
		SetColor( bg_red, bg_green, bg_blue )
		y_delta = bg_font.draw_string( str, x, y )
	End If
	If fg_font
		SetColor( fg_red, fg_green, fg_blue )
		fg_font.draw_string( str, x, y )
	End If
	Return y_delta
End Function

Function draw_outline_procedurally#( font:BMP_FONT, str$, x#, y#, d# = 1 )
	If Not font Then Return 0
	Local y_delta# = 0
	For Local r% = 0 Until 3
		For Local c% = 0 Until 3
			y_delta = font.draw_string( str, x + (r-1)*d, y + (c-1)*d )
		Next
	Next
	Return y_delta
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
	Const ASCII_NEWLINE% = Asc("~n")

	Field font_img:IMAGE_ATLAS_REFERENCE
	Field offset_x%
	Field baseline_y%
	Field char_spacing%
	Field line_spacing%
	Field char_width%[]
  Field scale%
  Field height%
	
	Method draw_string#( str$, x#, y# )
		Local cx% = x - offset_x
		Local cy% = y - baseline_y
		Local ascii%, glyph%
    SetScale( scale, scale )
		For Local i% = 0 Until str.Length
			ascii = str[i]
			If ascii = ASCII_NEWLINE
				cx = x - offset_x
				cy :+ height + line_spacing
				Continue
			End If
			glyph = ascii - ascii_start
			If glyph < 0 Or glyph >= char_count Then glyph = 0
			DrawImageRef( font_img, cx, cy, glyph )
			cx :+ char_width[glyph] + char_spacing
		Next
		Return (cy - y)
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
		Local line_spacing%
		Local char_width%[]
		Local img:IMAGE_ATLAS_REFERENCE
		Local f:BMP_FONT
		
    path = json.GetString( "path" )
    offset_x = json.GetNumber( "offset_x" )
		baseline_y = json.GetNumber( "baseline_y" )
		char_spacing = json.GetNumber( "char_spacing" )
		line_spacing = json.GetNumber( "line_spacing" )
		char_width = Create_Int_array_from_TJSONArray( json.GetArray( "char_widths" ))
		If char_width.Length <> char_count
			DebugStop
			Return Null
		End If
		img = IMAGE_ATLAS_REFERENCE( TEXTURE_MANAGER.reference_map.ValueForKey( path ))
		If Not img
			DebugStop
		End If
		img.LoadVariableWidthBMPFont( char_count, char_width, 0, 0 )
		f = New BMP_FONT
		f.font_img = img
		f.offset_x = offset_x
		f.baseline_y = baseline_y
		f.char_spacing = char_spacing
		f.line_spacing = line_spacing
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
		f.line_spacing = line_spacing
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
    scale = json.GetNumber( "scale" )
    b = get_bmp_font( key )
		If Not b Then Return Null
		f = b.clone()
    f.scale = scale
		'apply scale
		f.offset_x :* scale
		f.baseline_y :* scale
		f.char_spacing :* scale
		f.line_spacing :* scale
		For Local i% = 0 Until b.char_width.Length
			f.char_width[i] :* scale
		Next
    f.height :* scale
		Return f
  End Function
	
End Type

