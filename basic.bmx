Rem
	basic.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Conversion
Function cartesian_to_polar( x#, y#, r# Var, a# Var )
	r = Sqr( x*x + y*y )
	If x <> 0
		a = ATan( y/x )
		If x < 0 Then a :- 180
	Else 'x = 0
		If y > 0 Then a = 90 Else If y < 0 Then a = 90 Else a = 0
	End If
End Function
Function polar_to_cartesian( p_dist#, p_ang#, c_x# Var, c_y# Var )
	'...?
End Function
'______________________________________________________________________________
Function angle_between#( ax#, ay#, bx#, by# ) 'returns angle of vector from point 1 to point 2
	Local dot# = (( ax*bx ) + ( ay*by ))
	Local ang# = ACos( dot / ( Sqr( ax*ax + ay*ay )*Sqr( bx*bx + by*by )))
	If dot < 0
		If ang > 0 Then ang :+ 180 ..
		Else ang :- 180
	End If
	Return ang
End Function
'______________________________________________________________________________
Type MANAGED_OBJECT
	
	Field link:TLink 'back-reference to the list which contains this object
	
	Method New()
	End Method
	
	Method add_me( list:TList )
		link = ( list.AddLast( Self ))
	End Method
	Method remove_me()
		If link <> Null Then link.Remove()
	End Method
	
End Type
'______________________________________________________________________________
Type cVEC 'cartesian 2D vector
	
	Field x# 'x axis vector component
	Field y# 'y axis vector component
	
	Method New()
	End Method
	
End Type
'______________________________________________________________________________
Type pVEC 'polar 2D vector
	
	Field r# 'radius vector component
	Field a# 'angle vector component (theta)
	
	Method New()
	End Method
	
End Type
