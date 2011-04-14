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
	Field img_buf:TImageBuffer
	
	Function Create:GRAFFITI_MANAGER( bg_clean:TImage )', backbuffer_width%, backbuffer_height% )
		Local g:GRAFFITI_MANAGER = New GRAFFITI_MANAGER
		g.img_buf = TImageBuffer.CreateFromImage( bg_clean )
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

End Type

