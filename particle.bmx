Rem
	particle.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const LAYER_UNSPECIFIED% = 0
Const LAYER_FOREGROUND% = 1
Const LAYER_BACKGROUND% = 2

Const PARTICLE_TYPE_IMG% = 0
Const PARTICLE_TYPE_ANIM% = 1
Const PARTICLE_TYPE_STR% = 2

Const PARTICLE_FRAME_RANDOM% = -1

Const ANIMATION_DIRECTION_FORWARDS% = 0
Const ANIMATION_DIRECTION_BACKWARDS% = 1

Type PARTICLE Extends POINT

	Field particle_type% '{single_image|animated|string}
	Field img:TImage, frame% 'image to be drawn, and the current frame index for animation and randomly varied particle sets
	Field frame_delay% 'actual delay until next frame, can be INFINITE
	Field str$, font:TImageFont 'text string and font for STR particles
	Field layer% 'layer {foreground|background}
	Field retain% 'copy particle to background on death?
	Field frictional_coefficient# 'fake friction for slowing particles down
	Field red#, green#, blue# 'color
	Field red_delta#, green_delta#, blue_delta# 'change in color over time
	Field life_time% 'time until object is deleted
	Field created_ts% 'timestamp of object creation

	Field alpha# 'alpha value
	Field alpha_delta# 'alpha rate of change with respect to time
	Field scale# 'scale coefficient
	Field scale_delta# 'scale coefficient rate of change with respect to time
	Field animation_direction% '{forwards|backwards}
	Field last_frame_advance_ts% 'timestamp of last frame advance
	Field text_width#, text_height# 'dimensions of text (STR particles only)
	
	Field parent:POINT
	Field off_x#, off_y#
	Field offset#, offset_ang#
	
	Method New()
	End Method
	
	Function Create:Object( ..
	particle_type%, ..
	img:TImage = Null, frame% = 0, ..
	frame_delay% = INFINITY, ..
	str$ = Null, font:TImageFont = Null, ..
	layer% = LAYER_UNSPECIFIED, ..
	retain% = False, ..
	frictional_coefficient# = 0.0, ..
	red# = 1.0, green# = 1.0, blue# = 1.0, ..
	red_delta# = 0.0, green_delta# = 0.0, blue_delta# = 0.0, ..
	life_time% = INFINITY, ..
	pos_x# = 0.0, pos_y# = 0.0, ..
	vel_x# = 0.0, vel_y# = 0.0, ..
	ang# = 0.0, ..
	ang_vel# = 0.0, ..
	alpha# = 1.0, ..
	alpha_delta# = 0.0, ..
	scale# = 1.0, ..
	scale_delta# = 0.0 )
		Local p:PARTICLE = New PARTICLE

		'static fields
		p.particle_type = particle_type
		p.img = img; p.frame = frame
		p.str = str; p.font = font
		p.str_update()
		p.layer = layer
		p.retain = retain
		p.frictional_coefficient = frictional_coefficient 
		p.red = red; p.green = green; p.blue = blue
		p.red_delta = red_delta; p.green_delta = green_delta; p.blue_delta = blue_delta
		p.life_time = life_time
		p.created_ts = now()
		
		'dynamic fields
		p.pos_x = pos_x; p.pos_y = pos_y
		p.vel_x = vel_x; p.vel_y = vel_y
		p.ang = ang
		p.ang_vel = ang_vel
		p.alpha = alpha
		p.alpha_delta = alpha_delta
		p.scale = scale
		p.scale_delta = scale_delta

		Return p
	End Function
	
	Method clone:PARTICLE( new_frame% = 0 )
		If new_frame = PARTICLE_FRAME_RANDOM
			new_frame = Rand( 0, img.frames.Length - 1 )
		End If
		Return PARTICLE( PARTICLE.Create( ..
			particle_type, img, new_frame, frame_delay, str, font, layer, retain, frictional_coefficient, red, green, blue, red_delta, green_delta, blue_delta, life_time, pos_x, pos_y, vel_x, vel_y, ang, ang_vel, alpha, alpha_delta, scale, scale_delta ))
	End Method
	
	Method update()
		'friction
		vel_x :- vel_x*frictional_coefficient
		vel_y :- vel_y*frictional_coefficient
		ang_vel :- ang_vel*frictional_coefficient
		'update velocity, position, angular velocity and orientation
		Super.update()
		'update alpha
		alpha :+ alpha_delta
		'update scale
		scale :+ scale_delta
		'color
		red :+ red_delta; green :+ green_delta; blue :+ blue_delta
		'animation
		If particle_type = PARTICLE_TYPE_ANIM And frame_delay <> INFINITY And (now() - last_frame_advance_ts) >= frame_delay
			advance_frame()
		End If
	End Method
	
	Method draw( alpha_override# = 1.0, scale_override# = 1.0, hide_widgets% = False )
		SetColor( red*255, green*255, blue*255 )
		SetAlpha( alpha*alpha_override )
		SetScale( scale*scale_override, scale*scale_override )
		
		Select particle_type
			Case PARTICLE_TYPE_IMG, PARTICLE_TYPE_ANIM
				If img <> Null
					If parent <> Null
						SetRotation( ang + parent.ang )
						DrawImage( img, parent.pos_x + scale*offset*Cos( offset_ang + parent.ang ), parent.pos_y + scale*offset*Sin( offset_ang + parent.ang ), frame )
					Else
						SetRotation( ang )
						DrawImage( img, pos_x, pos_y, frame )
					End If
				End If
			Case PARTICLE_TYPE_STR
				If font <> Null And str <> Null
					SetImageFont( font )
					If parent <> Null
						SetRotation( ang + parent.ang )
						DrawText_with_outline( str, parent.pos_x + offset*Cos( offset_ang + parent.ang ) - text_width/2, parent.pos_y + offset*Sin( offset_ang + parent.ang ) - text_height/2 )
					Else
						SetRotation( ang )
						DrawText_with_outline( str, pos_x - scale*text_width/2, pos_y - scale*text_height/2 )
					End If
				End If
		End Select
	End Method
	
	Method str_update()
		If str <> Null And font <> Null
			SetImageFont( font )
			text_width = TextWidth( str )/2.0
			text_height = TextHeight( str )/2.0
		End If
	End Method
	
	Method advance_frame()
		last_frame_advance_ts = now()
		If animation_direction = ANIMATION_DIRECTION_FORWARDS
			frame :+ 1
			If frame >= img.frames.Length - 1 Then frame = 0
		Else If animation_direction = ANIMATION_DIRECTION_BACKWARDS
			frame :- 1
			If frame < 0 Then frame = img.frames.Length - 1
		End If
	End Method
	
	Method dead%()
		Return ..
			(Not (life_time = INFINITY)) And ..
			(now() - created_ts) >= life_time
	End Method
	
	'indicates whether the particle was successfully "pruned" (removed from its managed list)
	Method prune%()
		If dead()
			unmanage()
			Return True
		End If
		Return False
	End Method
	
	'OOP broken
	Method auto_manage()
		If layer = LAYER_BACKGROUND
			manage( game.particle_list_background )
		Else If layer = LAYER_FOREGROUND
			manage( game.particle_list_foreground )
		End If
	End Method
	
	Method attach_at( new_off_x#, new_off_y# )
		off_x = new_off_x; off_y = new_off_y
		cartesian_to_polar( off_x,off_y, offset,offset_ang )
	End Method
	
	Method get_bounding_box:BOX()
		Local size# = Max( img.width, img.height )
		Return Create_BOX( pos_x - size/2.0, pos_y - size/2.0, size, size )
	End Method
	
End Type

Function Create_PARTICLE_from_json:PARTICLE( json:TJSON )
	Local p:PARTICLE
	'required fields
	Local particle_type%
	If json.TypeOf( "particle_type" ) <> JSON_UNDEFINED
		particle_type = enum( json.GetString( "particle_type" ))
	Else
		Return Null 'required field
	End If
	'initialization using default values for optional fields
	p = PARTICLE( PARTICLE.Create( particle_type ))
	'optional fields
	If json.TypeOf( "img" ) <> JSON_UNDEFINED
		p.img = TImage( get_asset( json.GetString( "img" )))
	End If
	If json.TypeOf( "frame" ) <> JSON_UNDEFINED
		p.frame = json.GetNumber( "frame" )
	End If
	If json.TypeOf( "frame_delay" ) <> JSON_UNDEFINED
		p.frame_delay = json.GetNumber( "frame_delay" )
	End If
	If json.TypeOf( "str" ) <> JSON_UNDEFINED
		p.str = json.GetString( "str" )
	End If
	If json.TypeOf( "font" ) <> JSON_UNDEFINED
		p.font = TImageFont( get_asset( json.GetString( "font" )))
	End If
	If json.TypeOf( "layer" ) <> JSON_UNDEFINED
		p.layer = enum( json.GetString( "layer" ))
	End If
	If json.TypeOf( "retain" ) <> JSON_UNDEFINED
		p.retain = json.GetBoolean( "retain" )
	End If
	If json.TypeOf( "frictional_coefficient" ) <> JSON_UNDEFINED
		p.frictional_coefficient = json.GetNumber( "frictional_coefficient" )
	End If
	If json.TypeOf( "red" ) <> JSON_UNDEFINED
		p.red = json.GetNumber( "red" )
	End If
	If json.TypeOf( "green" ) <> JSON_UNDEFINED
		p.green = json.GetNumber( "green" )
	End If
	If json.TypeOf( "blue" ) <> JSON_UNDEFINED
		p.blue = json.GetNumber( "blue" )
	End If
	If json.TypeOf( "red_delta" ) <> JSON_UNDEFINED
		p.red_delta = json.GetNumber( "red_delta" )
	End If
	If json.TypeOf( "green_delta" ) <> JSON_UNDEFINED
		p.green_delta = json.GetNumber( "green_delta" )
	End If
	If json.TypeOf( "blue_delta" ) <> JSON_UNDEFINED
		p.blue_delta = json.GetNumber( "blue_delta" )
	End If
	If json.TypeOf( "life_time" ) <> JSON_UNDEFINED
		p.life_time = json.GetNumber( "life_time" )
	End If
	If json.TypeOf( "pos_x" ) <> JSON_UNDEFINED
		p.pos_x = json.GetNumber( "pos_x" )
	End If
	If json.TypeOf( "pos_y" ) <> JSON_UNDEFINED
		p.pos_y = json.GetNumber( "pos_y" )
	End If
	If json.TypeOf( "vel_x" ) <> JSON_UNDEFINED
		p.vel_x = json.GetNumber( "vel_x" )
	End If
	If json.TypeOf( "vel_y" ) <> JSON_UNDEFINED
		p.vel_y = json.GetNumber( "vel_y" )
	End If
	If json.TypeOf( "ang" ) <> JSON_UNDEFINED
		p.ang = json.GetNumber( "ang" )
	End If
	If json.TypeOf( "ang_vel" ) <> JSON_UNDEFINED
		p.ang_vel = json.GetNumber( "ang_vel" )
	End If
	If json.TypeOf( "alpha" ) <> JSON_UNDEFINED
		p.alpha = json.GetNumber( "alpha" )
	End If
	If json.TypeOf( "alpha_delta" ) <> JSON_UNDEFINED
		p.alpha_delta = json.GetNumber( "alpha_delta" )
	End If
	If json.TypeOf( "scale" ) <> JSON_UNDEFINED
		p.scale = json.GetNumber( "scale" )
	End If
	If json.TypeOf( "scale_delta" ) <> JSON_UNDEFINED
		p.scale_delta = json.GetNumber( "scale_delta" )
	End If

	Return p
End Function

