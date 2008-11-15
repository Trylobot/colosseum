Rem
	cvec.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function Create_cVEC:cVEC( x#, y# )
	Local v:cVEC = New cVEC
	v.x = x; v.y = y
	Return v
End Function

Type cVEC 'cartesian coordinate system 2D vector
	Field x# 'x axis vector component
	Field y# 'y axis vector component
	
	Method New()
	End Method
	
	Function Create:cVEC( x#, y# )
		Local v:cVEC = New cVEC
		v.x = x; v.y = y
		Return v
	End Function
	Method clone:cVEC()
		Return cVEC( cVEC.Create( x, y ))
	End Method
	
	Method r#()
		Return Sqr( Pow( x, 2 ) + Pow( y, 2 ))
	End Method
	Method a#()
		Return ATan2( y, x )
	End Method
End Type
