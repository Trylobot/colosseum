Rem
	image_atlas.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import brl.Max2D
Import brl.D3D7Max2D
'Import brl.GLMax2D
Import "box.bmx"
Import "vec.bmx"

'______________________________________________________________________________
Type TImageAtlas
	
	Global DXFrame:TD3D7ImageFrame
	'Global GLFrame:TGLImageFrame
	
	Field image:TImage
	Field rects:BOX[]
	Field handles:cVEC[]
	Field uv:BOX[]
	
	Const FLIP_NONE%       = 0
	Const FLIP_HORIZONTAL% = 1
	Const FLIP_VERTICAL%   = 2
	Const FLIP_ALL%        = 3
	
	Field vertex_flip%[]
	
	Method UseFrame( f% )
		DXFrame.setUV( uv[f].x, uv[f].y, uv[f].w, uv[f].h )
		'GLFrame.u0 = uv[f].x; GLFrame.v0 = uv[f].w; GLFrame.u1 = uv[f].y; GLFrame.v1 = uv[f].h
		image.handle_x = handles[f].x
		image.handle_y = handles[f].y
	End Method
	
	Method Draw( x#, y#, f%, anim_frame% = 0 )
		UseFrame( f )
		DrawImageRect( image, x, y, rects[f].w, rects[f].h )
	End Method

	Function Load:TImageAtlas( url:Object, rects:BOX[], handles:cVEC[], flags% = -1 )
		Local t:TImageAtlas = New TImageAtlas
		t.image = LoadImage( url, flags )
		t.DXFrame = TD3D7ImageFrame( t.image.frame(0) )
		't.GLFrame = TGLImageFrame( t.image.frame(0) )
		Local frames% = rects.Length
		t.rects = rects
		t.handles = handles
		t.uv = New BOX[frames]
		t.vertex_flip = New Int[frames]
		For Local f% = 0 Until frames
			t.uv[f] = Create_BOX( ..
				rects[f].x / t.image.width, ..
				rects[f].y / t.image.height, ..
				(rects[f].x + rects[f].w) / t.image.width, ..
				(rects[f].y + rects[f].h) / t.image.height )
		Next
		Return t
	End Function
	
End Type

