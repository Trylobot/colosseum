Rem
	image_chooser.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "draw_misc.bmx"
Import "mouse.bmx"

'______________________________________________________________________________
Function Create_IMAGE_CHOOSER:IMAGE_CHOOSER( ..
image:TImage[][], image_label$[][], group_label$[], ..
image_size%, callback( selected% ))
	Local ic:IMAGE_CHOOSER = New IMAGE_CHOOSER
	ic.image = image
	ic.image_label = image_label
	ic.group_label = group_label
	ic.image_size = image_size
	ic.callback = callback
	Return ic
End Function

Type IMAGE_CHOOSER
	Field image:TImage[][]
	Field image_label$[][]
	Field group_label$[]
	Field lock%[][]
	Field image_size%
	Field callback( selected% )
	
	Field focus%
	Field width%
	Field height%
	
	Method upate()
		update_focus_from_mouse()
		If KeyHit( KEY_ENTER ) Or MouseHit( 1 )
			callback( owning_group( focus ))
		End If
	End Method
	
	Method draw( x%, y% )
		reset_draw_state()
		SetScale( 0.1, 0.1 )
		For Local c% = 0 Until image.Length
			If focus <> c
				SetAlpha( 0.25 )
			Else 'focus == i
				SetAlpha( 1.00 )
			End If
			For Local L% = 0 Until image[c].Length
				DrawImage( image[c][L], x + 50*c, y + 50*L )
			Next
		Next
	End Method
	
	Method update_focus_from_mouse()
		'if mouse is hovering over an image, update the focus
	End Method
	
	Method owning_group%( index% )
		Return 0
	End Method
End Type

