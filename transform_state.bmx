Rem
	transform_state.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type TRANSFORM_STATE
	
	Field pos_x#, pos_y#
	Field pos_length#, pos_ang#
	Field ang#
	Field red%, green%, blue%
	Field alpha#
	Field scale_x#, scale_y#
	Field transition_time%
	
	Method New()
	End Method
	
	Function Create:Object( ..
	pos_x#, pos_y#, ..
	ang#, ..
	red%, green%, blue%, ..
	alpha#, ..
	scale_x#, scale_y#, ..
	transition_time% )
		Local s:TRANSFORM_STATE = New TRANSFORM_STATE
		s.pos_x = pos_x; s.pos_y = pos_y
		cartesian_to_polar( pos_x, pos_y, s.pos_length, s.pos_ang )
		s.ang = ang
		s.red = red; s.green = green; s.blue = blue
		s.alpha = alpha
		s.scale_x = scale_x; s.scale_y = scale_y
		s.transition_time = transition_time
		Return s
	End Function

	Method clone:TRANSFORM_STATE()
		Return TRANSFORM_STATE( TRANSFORM_STATE.Create( ..
			pos_x, pos_y, ang, red, green, blue, alpha, scale_x, scale_y, transition_time ))
	End Method
	
End Type

