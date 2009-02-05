Rem
	point.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function Create_POINT:POINT( ..
pos_x# = 0.0, pos_y# = 0.0, ..
ang# = 0.0, ..
vel_x# = 0.0, vel_y# = 0.0, ..
ang_vel# = 0.0, ..
acc_x# = 0.0, acc_y# = 0.0, ..
ang_acc# = 0.0 )
	Local p:POINT = New POINT
	p.pos_x = pos_x; p.pos_y = pos_y
	p.ang = ang
	p.vel_x = vel_x; p.vel_y = vel_y
	p.ang_vel = ang_vel
	p.acc_x = acc_x; p.acc_y = acc_y
	p.ang_acc = ang_acc
	Return p
End Function

Function Copy_POINT:POINT( other:POINT )
	Return Create_POINT( ..
		other.pos_x, other.pos_y, ..
		other.ang, ..
		other.vel_x, other.vel_y, ..
		other.ang_vel, ..
		other.acc_x, other.acc_y, ..
		other.ang_acc )
End Function
'__________________________________
Type POINT Extends MANAGED_OBJECT
	
	Field pos_x# 'position (x-axis), pixels
	Field pos_y# 'position (y-axis), pixels
	Field ang# 'orientation angle, degrees
	Field vel_x# 'velocity (x-component), pixels per second
	Field vel_y# 'velocity (y-component), pixels per second
	Field ang_vel# 'angular velocity, degrees per second
	Field acc_x# 'acceleration (x-component), pixels per second per second
	Field acc_y# 'acceleration (y-component), pixels per second per second
	Field ang_acc# 'angular acceleration, degrees per second per second
	
	Method New()
	End Method
	
'	Method clone:POINT()
'		Return Create_POINT( pos_x, pos_y, ang, vel_x, vel_y, ang_vel, acc_x, acc_y, ang_acc )
'	End Method
	
	Method update()
		'velocity
		vel_x :+ acc_x
		vel_y :+ acc_y
		'position
		pos_x :+ vel_x
		pos_y :+ vel_y
		'angular velocity
		ang_vel :+ ang_acc
		'orientation
		ang = ang_wrap( ang + ang_vel )
	End Method
	
	Method draw( alpha_override#, scale_override# ) 'dummy method (for virtual's sake!)
	End Method
	
	Method dist_to#( other:Object )
		If Not other Then Return 0
		If cVEC( other ) Then Return Sqr( Pow(cVEC( other ).x-pos_x,2) + Pow(cVEC( other ).y-pos_y,2) )
		Return Sqr( Pow(POINT(other).pos_x-pos_x,2) + Pow(POINT(other).pos_y-pos_y,2) )
	End Method

	Method ang_to#( other:Object )
		If Not other Then Return 0
		If cVEC( other ) Then Return ATan2( cVEC( other ).y-pos_y, cVEC( other ).x-pos_x )
		Return ATan2( POINT(other).pos_y-pos_y, POINT(other).pos_x-pos_x )
	End Method
	
	Method add_pos:POINT( delta_pos_x#, delta_pos_y# )
		Local p:POINT = Copy_POINT( Self )
		p.pos_x :+ delta_pos_x; p.pos_y :+ delta_pos_y
		Return p
	End Method
	
	Method move_to( argument:Object, dummy1% = False, dummy2% = False )
		If POINT( argument )
			Local pos:POINT = POINT( argument )
			pos_x = pos.pos_x
			pos_y = pos.pos_y
			ang = pos.ang
			vel_x = pos.vel_x
			vel_y = pos.vel_y
			ang_vel = pos.ang_vel
			acc_x = pos.acc_x
			acc_y = pos.acc_y
			ang_acc = pos.ang_acc
		Else If cVEC( argument )
			Local pos:cVEC = cVEC( argument )
			pos_x = pos.x
			pos_y = pos.y
			ang = 0
		End If
	End Method
	
	Method to_json:TJSONObject()
		Local p:POINT = Create_POINT()
		Local this_json:TJSONObject = New TJSONObject
		If pos_x <> p.pos_x     Then this_json.SetByName( "pos_x", TJSONNumber.Create( pos_x ))
		If pos_y <> p.pos_y     Then this_json.SetByName( "pos_y", TJSONNumber.Create( pos_y ))
		If ang <> p.ang         Then this_json.SetByName( "ang", TJSONNumber.Create( ang ))
		If vel_x <> p.vel_x     Then this_json.SetByName( "vel_x", TJSONNumber.Create( vel_x ))
		If vel_y <> p.vel_y     Then this_json.SetByName( "vel_y", TJSONNumber.Create( vel_y ))
		If ang_vel <> p.ang_vel Then this_json.SetByName( "ang_vel", TJSONNumber.Create( ang_vel ))
		If acc_x <> p.acc_x     Then this_json.SetByName( "acc_x", TJSONNumber.Create( acc_x ))
		If acc_y <> p.acc_y     Then this_json.SetByName( "acc_y", TJSONNumber.Create( acc_y ))
		If ang_acc <> p.ang_acc Then this_json.SetByName( "ang_acc", TJSONNumber.Create( ang_acc ))
		Return this_json
	End Method
	
	Method to_cvec:cVEC()
		Return Create_cVEC( pos_x, pos_y )
	End Method
	
End Type

Function Create_POINT_from_json:POINT( json:TJSON )
	Local p:POINT
	'no required fields
	p = Create_POINT()
	'read and assign optional fields as available
	If json.TypeOf( "pos_x" ) <> JSON_UNDEFINED   Then p.pos_x = json.GetNumber( "pos_x" )
	If json.TypeOf( "pos_y" ) <> JSON_UNDEFINED   Then p.pos_y = json.GetNumber( "pos_y" )
	If json.TypeOf( "ang" ) <> JSON_UNDEFINED     Then p.ang = json.GetNumber( "ang" )
	If json.TypeOf( "vel_x" ) <> JSON_UNDEFINED   Then p.vel_x = json.GetNumber( "vel_x" )
	If json.TypeOf( "vel_y" ) <> JSON_UNDEFINED   Then p.vel_y = json.GetNumber( "vel_y" )
	If json.TypeOf( "ang_vel" ) <> JSON_UNDEFINED Then p.ang_vel = json.GetNumber( "ang_vel" )
	If json.TypeOf( "acc_x" ) <> JSON_UNDEFINED   Then p.acc_x = json.GetNumber( "acc_x" )
	If json.TypeOf( "acc_y" ) <> JSON_UNDEFINED   Then p.acc_y = json.GetNumber( "acc_y" )
	If json.TypeOf( "ang_acc" ) <> JSON_UNDEFINED Then p.ang_acc = json.GetNumber( "ang_acc" )
	Return p
End Function

