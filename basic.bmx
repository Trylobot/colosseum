Rem
	point.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Conversion
Function cartesian_to_polar( c_x#, c_y#, p_dist# Var, p_ang# Var )
	p_dist = Sqr( c_x*c_x + c_y*c_y )
	If c_x <> 0
		p_ang = ATan( c_y/c_x )
		If c_x < 0 Then p_ang :- 180
	Else 'c_x = 0
		If c_y > 0 Then p_ang = 90 Else If c_y < 0 Then p_ang = 90 Else p_ang = 0
	End If
End Function
Function polar_to_cartesian( p_dist#, p_ang#, c_x# Var, c_y# Var )
	'...?
End Function
'______________________________________________________________________________
'Inquiry
Function point_at( x1#, y1#, x2#, y2#, r# Var, a# Var ) 'returns a polar vector drawn from p1 to p2
	Local dx#, dy#
	dx = x2 - x1
	dy = y2 - y1
	r = Sqr( dx*dx + dy*dy )
	If dx <> 0
		a = ATan( dy/dx )
		If dx < 0 Then a :- 180
	Else 'dx = 0
		If dy > 0 Then a = 90 Else If dy < 0 Then a = 90 Else a = 0
	End If
End Function
'______________________________________________________________________________
Const RESULT_EQUAL% = 0
Const RESULT_LESS_THAN% = -1
Const RESULT_GREATER_THAN% = 1

Function compare_angles%( a1#, a2#, threshold# )
	Local diff# = Abs((a1 Mod 360) - (a2 Mod 360))
	If diff < threshold Then Return RESULT_EQUAL ..
	Else If diff <= 180 Then Return RESULT_LESS_THAN ..
	Else Return RESULT_GREATER_THAN 'diff > 180
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
		link.Remove()
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
