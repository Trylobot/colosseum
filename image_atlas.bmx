Rem
	image_atlas.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import brl.max2d
Import "box.bmx"
Import "vec.bmx"

'______________________________________________________________________________
Type TImageAtlas Extends TImage
		
	Field rects:BOX[]
	Field handles:cVEC[]
	
	Function CreateAtlas:TImageAtlas( frames%, flags%, mr%,mg%,mb% )
		Local t:TImageAtlas=New TImageAtlas
		t.flags=flags
		t.mask_r=mr
		t.mask_g=mg
		t.mask_b=mb
		t.pixmaps=New TPixmap[frames]
		t.frames=New TImageFrame[frames]
		t.seqs=New Int[frames]
		Return t
	End Function
	
	Function LoadAtlas:TImageAtlas( url:Object, rects:BOX[], handles:cVEC[], flags%, mr%,mg%,mb% )
		Local pixmap:TPixmap
		If rects.length = 0 Then Return Null
		pixmap = TPixmap( url )
		If Not pixmap Then pixmap = LoadPixmap( url )
		If Not pixmap Then Return Null
		
		Local count% = rects.length
		Local img:TImageAtlas = CreateAtlas( count, flags, mr,mg,mb )
		img.rects = rects
		img.handles = handles
		For Local i% = 0 Until count
			Local window:TPixmap = pixmap.Window( rects[i].x, rects[i].y, rects[i].w, rects[i].h )
			img.SetPixmap( i, window.Copy() )
		Next
		Return img
	End Function
	
	Method SetDimensionsFromFrame( f% )
		width    = rects[f].w
		height   = rects[f].h
		handle_x = handles[f].x
		handle_y = handles[f].y
	End Method
	
End Type

'______________________________________________________________________________
Function LoadImageAtlas:TImageAtlas( url:Object, rects:BOX[], flags% = -1 )
	If flags = -1 Then flags = TMax2DGraphics.auto_imageflags
	Local atlas:TImageAtlas = TImageAtlas.LoadAtlas( url, rects, flags, TMax2DGraphics.mask_red, TMax2DGraphics.mask_green, TMax2DGraphics.mask_blue )
	If Not atlas Then Return Null
	If TMax2DGraphics.auto_midhandle Then MidHandleImage atlas
	Return atlas
End Function

