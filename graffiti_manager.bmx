Rem
	graffiti_manager.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "box.bmx"
'Import "texture_manager.bmx"
'Import "particle.bmx"

'______________________________________________________________________________
Type GRAFFITI_MANAGER
	Field img_buf:IMAGE_BUFFER
	
	Function Create:GRAFFITI_MANAGER( bg_clean:TImage )', backbuffer_width%, backbuffer_height% )
		Local g:GRAFFITI_MANAGER = New GRAFFITI_MANAGER
		g.img_buf = IMAGE_BUFFER.CreateFromImage( CreateImage( bg_clean.width, bg_clean.height ))
		g.BindBuffer()
		SetScale( 1, 1 )
		SetRotation( 0 )
		SetColor( 255, 255, 255 )
		DrawImage( bg_clean, 0, 0 )
		g.UnBindBuffer()
		Return g
	End Function
	
	Method draw()
		DrawImage( img_buf.Image, 0, 0 )
	End Method
	
	Method BindBuffer()
		img_buf.BindBuffer()
	End Method
	
	Method UnBindBuffer()
		img_buf.UnBindBuffer()
	End Method
	
	Rem
	Method Reset()
		SetScale( 1, 1 )
		SetRotation( 0 )
		SetColor( 255, 255, 255 )
		Local sand:TImage = generate_sand_image( img_buf.OrigW, img_buf.OrigH )
		BindBuffer()
		DrawImage( sand, 0, 0 )
		UnBindBuffer()
	End Method
	Endrem
	
End Type

