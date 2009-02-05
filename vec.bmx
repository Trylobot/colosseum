Rem
	vec.bmx
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
	
	Method scale:cVEC( scalar# )
		Return Create_cVEC( x * scalar, y * scalar )
	End Method
	
	Method add:cVEC( other:cVEC )
		Return Create_cVEC( x + other.x, y + other.y )
	End Method
	
	Method clone:cVEC()
		Return Create_cVEC( x, y )
	End Method
	
	Method r#()
		Return Sqr( Pow( x, 2 ) + Pow( y, 2 ))
	End Method
	
	Method a#()
		Return ATan2( y, x )
	End Method
	
	Method to_string$()
		Return "( "+x+", "+y+" )"
	End Method
End Type
'______________________________________________________________________________
Function Create_pVEC:pVEC( r#, a# )
	Local v:pVEC = New pVEC
	v.r = r; v.a = a
	Return v
End Function

Type pVEC 'polar coordinate system 2D vector
	Field r# 'radius vector component
	Field a# 'angle vector component (theta)
	
	Method clone:pVEC()
		Return Create_pVEC( r, a )
	End Method
	
	Method x#()
		Return (r * Cos( a ))
	End Method
	
	Method y#()
		Return (r * Sin( a ))
	End Method
End Type

