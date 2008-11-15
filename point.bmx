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
	
	Method dist_to#( other:POINT )
		Return Sqr( Pow(other.pos_x-pos_x,2) + Pow(other.pos_y-pos_y,2) )
	End Method
	Method dist_to_cVEC#( other:cVEC )
		Return Sqr( Pow(other.x-pos_x,2) + Pow(other.y-pos_y,2) )
	End Method
	
	Method ang_to#( other:POINT )
		Return ATan2( other.pos_y-pos_y, other.pos_x-pos_x )
	End Method
	Method ang_to_cVEC#( other:cVEC )
		Return ATan2( other.y-pos_y, other.x-pos_x )
	End Method
	
	Method add_pos:POINT( delta_pos_x#, delta_pos_y# )
		Local p:POINT = Copy_POINT( Self )
		p.pos_x :+ delta_pos_x; p.pos_y :+ delta_pos_y
		Return p
	End Method
	
	Method move_to( pos:POINT )
		pos_x = pos.pos_x
		pos_y = pos.pos_y
		ang = pos.ang
		vel_x = pos.vel_x
		vel_y = pos.vel_y
		ang_vel = pos.ang_vel
		acc_x = pos.acc_x
		acc_y = pos.acc_y
		ang_acc = pos.ang_acc
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "pos_x", TJSONNumber.Create( pos_x ))
		this_json.SetByName( "pos_y", TJSONNumber.Create( pos_y ))
		this_json.SetByName( "ang", TJSONNumber.Create( ang ))
		this_json.SetByName( "vel_x", TJSONNumber.Create( vel_x ))
		this_json.SetByName( "vel_y", TJSONNumber.Create( vel_y ))
		this_json.SetByName( "ang_vel", TJSONNumber.Create( ang_vel ))
		this_json.SetByName( "acc_x", TJSONNumber.Create( acc_x ))
		this_json.SetByName( "acc_y", TJSONNumber.Create( acc_y ))
		this_json.SetByName( "ang_acc", TJSONNumber.Create( ang_acc ))
		Return this_json
	End Method
	
End Type

Function Create_POINT_from_json:POINT( json:TJSON )
	Local p:POINT = New POINT
	p.pos_x = json.GetNumber( "pos_x" )
	p.pos_y = json.GetNumber( "pos_y" )
	p.ang = json.GetNumber( "ang" )
	p.vel_x = json.GetNumber( "vel_x" )
	p.vel_y = json.GetNumber( "vel_y" )
	p.ang_vel = json.GetNumber( "ang_vel" )
	p.acc_x = json.GetNumber( "acc_x" )
	p.acc_y = json.GetNumber( "acc_y" )
	p.ang_acc = json.GetNumber( "ang_acc" )
	Return p
End Function

