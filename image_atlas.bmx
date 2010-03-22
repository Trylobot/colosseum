Rem
	image_atlas.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import brl.max2d

'______________________________________________________________________________
Type TImageAtlas Extends TImage
		
	Field xywh%[]
	
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
	
	Function LoadAtlas:TImageAtlas( url:Object, xywh%[], flags%, mr%,mg%,mb% )
		Local pixmap:TPixmap
		If xywh.length Mod 4 <> 0 Or xywh.length < 4 Then Return Null
		pixmap = TPixmap( url )
		If Not pixmap Then pixmap = LoadPixmap( url )
		If Not pixmap Then Return Null
		
		Local count% = xywh.length / 4
		Local img:TImageAtlas = CreateAtlas( count, flags, mr,mg,mb )
		img.xywh = xywh
		Local x%, y%, w%, h%
		For Local i% = 0 Until count
			x = xywh[ 4*i + 0 ]
			y = xywh[ 4*i + 1 ]
			w = xywh[ 4*i + 2 ]
			h = xywh[ 4*i + 3 ]
			Local window:TPixmap = pixmap.Window( x, y, w, h )
			img.SetPixmap( i, window.Copy() )
		Next
		Return img
	End Function
	
	Method SetFrame( index% )
		width  = xywh[ 4*index + 2 ]
		height = xywh[ 4*index + 3 ]
	End Method
	
End Type

'______________________________________________________________________________
Function LoadImageAtlas:TImageAtlas( url:Object, xywh%[], flags% = -1 )
	If flags = -1 Then flags = TMax2DGraphics.auto_imageflags
	Local atlas:TImageAtlas = TImageAtlas.LoadAtlas( url, xywh, flags, TMax2DGraphics.mask_red, TMax2DGraphics.mask_green, TMax2DGraphics.mask_blue )
	If Not atlas Then Return Null
	If TMax2DGraphics.auto_midhandle Then MidHandleImage atlas
	Return atlas
End Function

