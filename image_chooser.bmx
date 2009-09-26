Rem
	image_chooser.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "draw_misc.bmx"
Import "mouse.bmx"
Import "base_data.bmx"

'______________________________________________________________________________
Function Create_IMAGE_CHOOSER:IMAGE_CHOOSER( ..
image:TImage[][], image_label$[][], group_label$[], ..
lock%[][], callback( selected% ))
	Local ic:IMAGE_CHOOSER = New IMAGE_CHOOSER
	ic.image = image
	ic.image_label = image_label
	ic.group_label = group_label
	ic.lock = lock
	ic.callback = callback
	Return ic
End Function

Type IMAGE_CHOOSER
	Field image:TImage[][]
	Field image_label$[][]
	Field group_label$[]
	Field lock%[][]
	Field callback( selected% )
	
	Field width%
	Field height%
	Field scale#
	
	Field focused_group%
	
	Method upate()
		update_focus_from_mouse()
		If KeyHit( KEY_ENTER ) Or MouseHit( 1 )
			callback( focused_group )
		End If
		If KeyHit( KEY_RIGHT )
			focused_group :+ 1; If focused_group > image.Length - 1 Then focused_group = 0
		Else If KeyHit( KEY_LEFT )
			focused_group :- 1; If focused_group < 0 Then focused_group = image.Length - 1
		End If
	End Method
	
	Method draw( x%, y% )
		reset_draw_state()
		Local cx%, cy%
		For Local c% = 0 Until image.Length
			cx = x + c*(1.5*image_size + margin)
			cy = y
			If focused_group = c
				SetColor( 0, 0, 0 )
				SetAlpha( 0.50 )
				DrawRect( cx - margin + 1, 0, image_size + 2*margin - 2, window_h )
				SetColor( 160, 160, 160 )
				SetAlpha( 0.80 )
				SetLineWidth( 1 )
				DrawLine( cx - margin,              0, cx - margin,              window_h )
				DrawLine( cx + image_size + margin, 0, cx + image_size + margin, window_h )
				SetAlpha( 1.00 )
				SetColor( 255, 255, 255 )
			Else
				SetAlpha( 0.50 )
			End If
			SetImageFont( get_font( "consolas_bold_14" ))
			DrawText_with_outline( group_label[c], cx, cy )
			cy :+ 22
			For Local L% = 0 Until image[c].Length
				draw_preview_img( image[c][L], cx, cy, lock[c][L], (focused_group = c) )
				cy :+ scale*image[c][L].height + 2
				SetImageFont( get_font( "consolas_10" ))
				DrawText_with_outline( image_label[c][L], cx, cy )
				cy :+ margin + 9
			Next
		Next
	End Method
	
	Method draw_preview_img( img:TImage, x%, y%, locked%, focused% )
		scale = Float(image_size) / Float(Max( img.width, img.height ))
		SetScale( scale, scale )
		DrawImage( img, x, y )
		SetScale( 1, 1 )
	End Method
	
	Method update_focus_from_mouse()
		'if mouse is hovering over an image, update the focus
	End Method
	
	Const image_size% = 50
	Const margin% = 10
	
End Type

