Rem
	steering_wheel.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "point.bmx"
Import "particle.bmx"
Import "json.bmx"

'______________________________________________________________________________
Const speed_threshold# = 0.25
Const centering_factor# = 0.03333

Function Create_STEERING_WHEEL:STEERING_WHEEL( ..
wheel:PARTICLE, ..
parent:POINT = Null, ..
offset_x% = 0, offset_y% = 0 )
	Local sw:STEERING_WHEEL = New STEERING_WHEEL
	sw.wheel = wheel.clone()
	sw.wheel.parent = parent
	sw.wheel.attach_at( offset_x, offset_y )
	Return sw
End Function

Function Copy_STEERING_WHEEL:STEERING_WHEEL( other:STEERING_WHEEL, parent:POINT = Null )
	Return Create_STEERING_WHEEL( ..
		other.wheel, parent, other.wheel.off_x, other.wheel.off_y )
End Function

Type STEERING_WHEEL
	Field wheel:PARTICLE
	
	Method update( turning_control_pct# )
		wheel.ang = 50.0 * turning_control_pct
	End Method
	
	Method draw( alpha_override# = 1.0, scale_override# = 1.0 )
		wheel.draw( alpha_override, scale_override )
	End Method
	
End Type

Function Create_STEERING_WHEEL_from_json:STEERING_WHEEL( json:TJSON )
	Local sw:STEERING_WHEEL
	Local particle_key$, particle_obj:PARTICLE, offset_x%, offset_y%
	If json.TypeOf( "particle_key" ) <> JSON_UNDEFINED Then particle_key = json.GetString( "particle_key" ) Else Return Null
	particle_obj = get_particle( particle_key,, False )
	If Not particle_obj Then Return Null
	If json.TypeOf( "offset_x" )     <> JSON_UNDEFINED Then offset_x =     json.GetNumber( "offset_x" )     Else Return Null
	If json.TypeOf( "offset_y" )     <> JSON_UNDEFINED Then offset_y =     json.GetNumber( "offset_y" )     Else Return Null
	sw = Create_STEERING_WHEEL( particle_obj,, offset_x, offset_y )
	Return sw
End Function

