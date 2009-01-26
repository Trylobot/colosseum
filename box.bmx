Rem
	box.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

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
	
	Method clone:BOX()
		Return Create_BOX( x, y, w, h )
	End Method
	
	Method contains%( other:BOX )
		Return (other.x >= x And other.y >= y And other.x + other.w < x + w And other.y + other.h < y + h)
	End Method

End Type

