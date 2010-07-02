Rem
	box.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
Function Create_BOX:BOX( x#, y#, w#, h# )
	Local b:BOX = New BOX
	b.x = x; b.y = y
	b.w = w; b.h = h
	Return b
End Function

Type BOX
	Field x#, y# 'position components
	Field w#, h# 'dimension components
	
	Method Set( x#, y#, w#, h# )
		Self.x = x; Self.y = y
		Self.w = w; Self.h = h
	End Method
	
	Method clone:BOX()
		Return Create_BOX( x, y, w, h )
	End Method
	
	Method contains%( b:BOX )
		Return (b.x >= x And b.y >= y And b.x + b.w < x + w And b.y + b.h < y + h)
	End Method
	
	Method intersects%( b:BOX )
		Return Not( x > (b.x+b.w) Or b.x > (x+w) Or y > (b.y+b.h) Or b.y > (y+h) )
	End Method
	
	Method auto_margin:cVEC( hn# )
		Local yn# = y + ((h - hn) / 2.0)
		Local xn# = x + (yn - y)
		Return Create_cVEC( xn, yn )
	End Method
	
End Type
