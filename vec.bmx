Rem
	vec.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "misc.bmx"

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
	
	Method to_string$( as_int% = False )
		If as_int
			Return "( "+Int(x)+", "+Int(y)+" )"
		Else
			Return "( "+x+", "+y+" )"
		End If
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
	
	Method to_string$( as_int% = False )
		If as_int
			Return "( "+Int(x())+", "+Int(y())+" )"
		Else
			Return "( "+x()+", "+y()+" )"
		End If
	End Method
End Type

Function remove_origin_cVEC:cVEC( v:cVEC )
	Local ox#, oy#
	GetOrigin( ox, oy )
	Return Create_cVEC( v.x - ox, v.y - oy )
End Function

'______________________________________________________________________________
Function line_intersects_line%( v1:cVEC, v2:cVEC, v3:cVEC, v4:cVEC )
	Local denom# = ((v4.y-v3.y)*(v2.x-v1.x))-((v4.x-v3.x)*(v2.y-v1.y))
	Local num# =   ((v4.x-v3.x)*(v1.y-v3.y))-((v4.y-v3.y)*(v1.x-v3.x))
	Local num2# =  ((v2.x-v1.x)*(v1.y-v3.y))-((v2.y-v1.y)*(v1.x-v3.x))
	If denom = 0.0
		Return False 'coincident or parallel (no intersection possible)
	End If
	
	Local ua# = num/denom
	Local ub# = num2/denom
	Return (ua >= 0.0 And ua <= 1.0) And (ub >= 0.0 And ub <= 1.0)
End Function
'______________________________________________________________________________
Function line_intersects_rect%( v1:cVEC, v2:cVEC, r:cVEC, r_dim:cVEC )
	Local lower_left:cVEC = Create_cVEC( r.x, r.y+r_dim.y )
	Local upper_right:cVEC = Create_cVEC( r.x+r_dim.x, r.y )
	Local upper_left:cVEC = Create_cVEC( r.x, r.y )
	Local lower_right:cVEC = Create_cVEC( r.x+r_dim.x, r.y+r_dim.y )
	
	Rem (will never happen in my game)
	'is line completely encased by rect? 
	If  (v1.x > lower_left.x And v1.x < upper_right.x) And (v1.y < lower_left.y And v1.y > upper_right.y) ..
	And (v2.x > lower_left.x And v2.x < upper_right.x) And (v2.y < lower_left.y And v2.y > upper_right.y)
		Return True
	End If
	EndRem
	
	'line intersects one of the lines making up the rectangle's borders
	If line_intersects_line( v1,v2, upper_left,lower_left ) ..
	Or line_intersects_line( v1,v2, lower_left,lower_right ) ..
	Or line_intersects_line( v1,v2, upper_left,upper_right ) ..
	Or line_intersects_line( v1,v2, upper_right,lower_right )
		Return True
	Else
		Return False
	End If
End Function
'______________________________________________________________________________
Rem
	If lag_aimer = Null Then lag_aimer = cVEC.Create( p_tur.pos_x - 20, p_tur.pos_y - 20 )
	Local m_rail# = (lag_aimer.y - game.mouse.y)/(lag_aimer.x - game.mouse.x)
	Local b_rail# = lag_aimer.y - m_rail*lag_aimer.x
	Local ptur_pointer:cVEC = cVEC.Create( Cos( p_tur.ang ), Sin( p_tur.ang ))
	Local m_ptur# = (p_tur.pos_y - ptur_pointer.y)/(p_tur.pos_x - ptur_pointer.x)
	Local b_ptur# = p_tur.pos_y - m_ptur*p_tur.pos_x
	lag_aimer.x = (b_ptur - b_rail)/(m_rail - m_ptur)
	lag_aimer.y = m_rail*lag_aimer.x + b_rail
	SetRotation( p_tur.ang )
	SetAlpha( 0.5 )
	DrawImage( img_reticle, lag_aimer.x, lag_aimer.y )
End rem

Function intersection:cVEC( j1:cVEC, j2:cVEC, k1:cVEC, k2:cVEC ) 'return the point of intersection between two lines, j & k, given by four points
	Local mj#, bj#
	Local mk#, bk#
	mj = (j1.y - j2.y)/(j1.x - j2.x)
	bj = j1.y - (mj * j1.x)
	mk = (k1.y - k2.y)/(k1.x - k2.x)
	bk = k1.y - (mk * k1.x)
	Local i:cVEC = New cVEC
	i.x = (bk - bj)/(mj - mk)
	i.y = (mj * i.x) + bj
	Return i
End Function
