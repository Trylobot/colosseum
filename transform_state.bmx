Rem
	transform_state.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "misc.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Type TRANSFORM_STATE
	
	Field pos_x#, pos_y#
	Field pos_length#, pos_ang#
	Field ang#
	Field red%, green%, blue%
	Field alpha#
	Field scale_x#, scale_y#
	Field transition_time%
	
	Function Create:Object( ..
	pos_x# = 0.0, pos_y# = 0.0, ..
	ang# = 0.0, ..
	red% = 255, green% = 255, blue% = 255, ..
	alpha# = 1.0, ..
	scale_x# = 1.0, scale_y# = 1.0, ..
	transition_time% = 1000 )
		Local s:TRANSFORM_STATE = New TRANSFORM_STATE
		s.pos_x = pos_x; s.pos_y = pos_y
		s.calc_polar()
		s.ang = ang
		s.red = red; s.green = green; s.blue = blue
		s.alpha = alpha
		s.scale_x = scale_x; s.scale_y = scale_y
		If transition_time <> 0 Then s.transition_time = transition_time Else s.transition_time = 1000
		Return s
	End Function
	
	Method calc_polar()
		cartesian_to_polar( pos_x, pos_y, pos_length, pos_ang )
	End Method
	
	Method clone:TRANSFORM_STATE()
		Return TRANSFORM_STATE( TRANSFORM_STATE.Create( ..
			pos_x, pos_y, ..
			ang, ..
			red, green, blue, ..
			alpha, ..
			scale_x, scale_y, ..
			transition_time ))
	End Method
	
End Type

Function Create_TRANSFORM_STATE_from_json:TRANSFORM_STATE( json:TJSON )
	Local t:TRANSFORM_STATE
	'no required fields
	t = TRANSFORM_STATE( TRANSFORM_STATE.Create() )
	If json.TypeOf( "pos_x" ) <> JSON_UNDEFINED           Then t.pos_x = json.GetNumber( "pos_x" )
	If json.TypeOf( "pos_y" ) <> JSON_UNDEFINED           Then t.pos_y = json.GetNumber( "pos_y" )
	If json.TypeOf( "ang" ) <> JSON_UNDEFINED             Then t.ang = json.GetNumber( "ang" )
	If json.TypeOf( "red" ) <> JSON_UNDEFINED             Then t.red = json.GetNumber( "red" )
	If json.TypeOf( "green" ) <> JSON_UNDEFINED           Then t.green = json.GetNumber( "green" )
	If json.TypeOf( "blue" ) <> JSON_UNDEFINED            Then t.blue = json.GetNumber( "blue" )
	If json.TypeOf( "alpha" ) <> JSON_UNDEFINED           Then t.alpha = json.GetNumber( "alpha" )
	If json.TypeOf( "scale_x" ) <> JSON_UNDEFINED         Then t.scale_x = json.GetNumber( "scale_x" )
	If json.TypeOf( "scale_y" ) <> JSON_UNDEFINED         Then t.scale_y = json.GetNumber( "scale_y" )
	If json.TypeOf( "transition_time" ) <> JSON_UNDEFINED Then t.transition_time = json.GetNumber( "transition_time" )
	Return t
End Function



