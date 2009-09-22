Rem
	tank_track.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "misc.bmx"
Import "particle.bmx"

'______________________________________________________________________________
Const velocity_threshold# = 0.00001
Const angular_speed_threshold# = 0.00001
Const frame_delay_max% = 100
Const parallel_frame_delay_factor_default# = 17.5
Const perpendicular_frame_delay_factor_default# = 40.0

Function Create_TANK_TRACK:TANK_TRACK( ..
track:PARTICLE, ..
parent:POINT = Null, ..
offset_x% = 0, offset_y% = 0, ..
orientation%, ..
parallel_frame_delay_factor%, ..
perpendicular_frame_delay_factor% )
	If Not track Then Return Null 'cannot be Null
	Local tt:TANK_TRACK = New TANK_TRACK
	tt.track = track
	tt.track.parent = parent
	tt.track.attach_at( offset_x, offset_y )
	tt.orientation = orientation
	tt.parallel_frame_delay_factor = parallel_frame_delay_factor
	tt.perpendicular_frame_delay_factor = perpendicular_frame_delay_factor
	Return tt
End Function

Function Copy_TANK_TRACK:TANK_TRACK( other:TANK_TRACK, parent:POINT = Null )
	Return Create_TANK_TRACK( ..
		other.track, parent, other.track.off_x, other.track.off_y, ..
		other.orientation, other.parallel_frame_delay_factor, other.perpendicular_frame_delay_factor )
End Function

Type TANK_TRACK
	Field track:PARTICLE
	Field orientation%
	Field parallel_frame_delay_factor%
	Field perpendicular_frame_delay_factor%
	
	Method update( vel# )
		Local frame_delay# = INFINITY
		Local vel_ang# = vector_angle( track.parent.vel_x, track.parent.vel_y )
		If vel > velocity_threshold
			If Abs( ang_wrap( vel_ang - track.parent.ang )) <= 90
				track.animation_direction = ANIMATION_DIRECTION_FORWARDS
			Else
				track.animation_direction = ANIMATION_DIRECTION_BACKWARDS
			End If
			frame_delay = parallel_frame_delay_factor / vel
		End If
		If frame_delay = INFINITY Or frame_delay >= frame_delay_max
			If track.parent.ang_vel > angular_speed_threshold
				Select orientation
					Case ORIENTATION_RIGHT
						track.animation_direction = ANIMATION_DIRECTION_BACKWARDS
					Case ORIENTATION_LEFT
						track.animation_direction = ANIMATION_DIRECTION_FORWARDS
				End Select
			Else If track.parent.ang_vel < -angular_speed_threshold
				Select orientation
					Case ORIENTATION_RIGHT
						track.animation_direction = ANIMATION_DIRECTION_FORWARDS
					Case ORIENTATION_LEFT
						track.animation_direction = ANIMATION_DIRECTION_BACKWARDS
				End Select
			End If
			frame_delay = perpendicular_frame_delay_factor / Abs( track.parent.ang_vel )
		End If
		track.frame_delay = frame_delay
		track.update()
	End Method
	
	Method draw( alpha_override# = 1.0 )
		track.draw( alpha_override )
	End Method
	
	Const ORIENTATION_RIGHT% = 1
	Const ORIENTATION_LEFT% = 2
End Type

Function Create_TANK_TRACK_from_json:TANK_TRACK( json:TJSON )
	Local tt:TANK_TRACK
	Local particle_key$, particle_obj:PARTICLE, offset_x%, offset_y%, orientation%
	If json.TypeOf( "particle_key" ) <> JSON_UNDEFINED Then particle_key = json.GetString( "particle_key" ) Else Return Null
	particle_obj = get_particle( particle_key,, False )
	If Not particle_obj Then Return Null
	If json.TypeOf( "offset_x" )     <> JSON_UNDEFINED Then offset_x =     json.GetNumber( "offset_x" )     Else Return Null
	If json.TypeOf( "offset_y" )     <> JSON_UNDEFINED Then offset_y =     json.GetNumber( "offset_y" )     Else Return Null
	If json.TypeOf( "orientation" )  <> JSON_UNDEFINED Then orientation =  json.GetNumber( "orientation" )  Else Return Null
	tt = Create_TANK_TRACK( ..
		particle_obj,, offset_x, offset_y, orientation, ..
		parallel_frame_delay_factor_default, perpendicular_frame_delay_factor_default )
	If Not tt Then Return Null
	If json.TypeOf( "parallel_frame_delay_factor" )      <> JSON_UNDEFINED Then tt.parallel_frame_delay_factor =      json.GetNumber( "parallel_frame_delay_factor" )
	If json.TypeOf( "perpendicular_frame_delay_factor" ) <> JSON_UNDEFINED Then tt.perpendicular_frame_delay_factor = json.GetNumber( "perpendicular_frame_delay_factor" )
	Return tt
End Function

