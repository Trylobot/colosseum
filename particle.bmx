Rem
	particle.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "point.bmx"
'Import "draw_misc.bmx"
'Import "texture_manager.bmx"
'Import "box.bmx"
'Import "base_data.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Global particle_map:TMap = CreateMap()

Function get_particle:PARTICLE( Key$, new_frame% = 0, Copy% = True )
	Local part:PARTICLE = PARTICLE( particle_map.ValueForKey( key.toLower() ))
	If copy And part Then Return part.clone( new_frame )
	Return part
End Function

Const LAYER_UNSPECIFIED% = 0
Const LAYER_FOREGROUND% = 1
Const LAYER_BACKGROUND% = 2

Const PARTICLE_TYPE_IMG% = 0
Const PARTICLE_TYPE_ANIM% = 1
Const PARTICLE_TYPE_STR% = 2

Const LIFETIME_WHILE_MOVING% = -2

Const PARTICLE_FRAME_RANDOM% = -1

Const ANIMATION_DIRECTION_FORWARDS% = 0
Const ANIMATION_DIRECTION_BACKWARDS% = 1

Type PARTICLE Extends POINT

	Field particle_type% '{single_image|animated|string}
	Field img:TImage, frame% 'image to be drawn, and the current frame index for animation and randomly varied particle sets
	Field handle:pVEC 'handle (polar)
	Field frame_delay% 'actual delay until next frame, can be INFINITE
	Field str$, font:FONT_STYLE 'text string and font for STR particles
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
	str$ = Null, font:FONT_STYLE = Null, ..
	layer% = LAYER_UNSPECIFIED, ..
	retain% = False, ..
	frictional_coefficient# = 0.0, ..
	red# = 255.0, green# = 255.0, blue# = 255.0, ..
	red_delta# = 0.0, green_delta# = 0.0, blue_delta# = 0.0, ..
	life_time% = INFINITY, ..
	pos_x# = 0.0, pos_y# = 0.0, ..
	vel_x# = 0.0, vel_y# = 0.0, ..
	ang# = 0.0, ..
	ang_vel# = 0.0, ..
	alpha# = 1.0, ..
	alpha_delta# = 0.0, ..
	scale# = 1.0, ..
	scale_delta# = 0.0, ..
	offset# = 0.0, ..
	offset_ang# = 0.0 )
		Local p:PARTICLE = New PARTICLE

		'static fields
		p.particle_type = particle_type
		p.img = img; p.frame = frame
		If img
			Local handle:cVEC = Create_cVEC( img.handle_x, img.handle_y )
			p.handle = Create_pVEC( handle.r(), handle.a() )
		Else
			p.handle = Create_pVEC( 0, 0 )
		End If
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
		p.offset = offset
		p.offset_ang = offset_ang

		Return p
	End Function
	
	Method clone:PARTICLE( new_frame% = 0 )
		'frame (for multi-frame particles)
		If new_frame = PARTICLE_FRAME_RANDOM And img
			new_frame = Rand( 0, img.frames.Length - 1 )
		Else
			new_frame = 0
		End If
		'main fields
		Return PARTICLE( PARTICLE.Create( ..
			particle_type, img, new_frame, frame_delay, str, font, layer, retain, frictional_coefficient, red, green, blue, red_delta, green_delta, blue_delta, life_time, pos_x, pos_y, vel_x, vel_y, ang, ang_vel, alpha, alpha_delta, scale, scale_delta, offset, offset_ang ))
		
	End Method
	
	Method update()
		'friction
		vel_x :- timescale * vel_x * frictional_coefficient
		vel_y :- timescale * vel_y * frictional_coefficient
		ang_vel :- timescale * ang_vel * frictional_coefficient
		'update velocity, position, angular velocity and orientation
		Super.update()
		'update alpha
		alpha :+ timescale * alpha_delta
		'update scale
		scale :+ timescale * scale_delta
		'color
		red :+ timescale * red_delta; green :+ timescale * green_delta; blue :+ timescale * blue_delta
		'animation
		If particle_type = PARTICLE_TYPE_ANIM And frame_delay <> INFINITY And (now() - last_frame_advance_ts) >= frame_delay
			advance_frame()
		End If
	End Method
	
	Method draw( alpha_override# = 1.0, scale_override# = 1.0 )
		SetAlpha( alpha*alpha_override )
		Local final_scale# = scale*scale_override
		SetScale( final_scale, final_scale )
		
		Select particle_type
			Case PARTICLE_TYPE_IMG, PARTICLE_TYPE_ANIM
				SetColor( red, green, blue )
				If img <> Null
					If parent
						SetRotation( ang + parent.ang )
						DrawImage( img, parent.pos_x + final_scale*offset*Cos( offset_ang + parent.ang ), parent.pos_y + final_scale*offset*Sin( offset_ang + parent.ang ), frame )
					Else
						SetRotation( ang )
						DrawImage( img, pos_x, pos_y, frame )
					End If
				End If
			Case PARTICLE_TYPE_STR
				If font <> Null And str <> Null
					SetRotation( 0 )
					If parent
						font.draw_string( str, parent.pos_x + final_scale*offset*Cos( offset_ang + parent.ang ) - text_width/2, parent.pos_y + final_scale*offset*Sin( offset_ang + parent.ang ) - text_height/2 )
					Else
						font.draw_string( str, pos_x - scale*text_width/2, pos_y - scale*text_height/2 )
					End If
				End If
		End Select
	End Method
	
	Method str_update()
		If str <> Null And font <> Null
			text_width = font.width( str )/2.0
			text_height = font.height/2.0
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
      (Not (life_time = LIFETIME_WHILE_MOVING And in_motion())) And ..
			(now() - created_ts) >= life_time
	End Method
  
  Method in_motion%()
    Return (vel_x < COMPONENT_MOTION_THRESHOLD And vel_y < COMPONENT_MOTION_THRESHOLD)
  End Method
  Const COMPONENT_MOTION_THRESHOLD# = 0.0005
	
	'indicates whether the particle was successfully "pruned" (removed from its managed list)
	Method prune%()
		If dead()
			unmanage()
			Return True
		End If
		Return False
	End Method
	
	Method attach_at( new_off_x#, new_off_y# )
		off_x = new_off_x; off_y = new_off_y
		cartesian_to_polar( off_x,off_y, offset,offset_ang )
	End Method
	
End Type

Function Create_PARTICLE_from_json:PARTICLE( json:TJSON )
	Local p:PARTICLE
	'reserve space for required fields
	Local particle_type%
	'read required fields
	If json.TypeOf( "particle_type" ) <> JSON_UNDEFINED Then particle_type = json.GetNumber( "particle_type" ) Else Return Null
	'create object with required fields only
	p = PARTICLE( PARTICLE.Create( particle_type ))
	'read and assign optional fields as available
	If json.TypeOf( "image_key" ) <> JSON_UNDEFINED              Then p.img = get_image( json.GetString( "image_key" ))
	If p.img
		Local handle:cVEC = Create_cVEC( p.img.handle_x, p.img.handle_y )
		p.handle = Create_pVEC( handle.r(), handle.a() )
	End If
	If json.TypeOf( "frame" ) <> JSON_UNDEFINED                  Then p.frame = json.GetNumber( "frame" )
	If json.TypeOf( "frame_delay" ) <> JSON_UNDEFINED            Then p.frame_delay = json.GetNumber( "frame_delay" )
	If json.TypeOf( "str" ) <> JSON_UNDEFINED                    Then p.str = json.GetString( "str" )
	If json.TypeOf( "font_style" ) <> JSON_UNDEFINED             Then p.font = get_font_style( json.GetString( "font_style" ))
	If json.TypeOf( "layer" ) <> JSON_UNDEFINED                  Then p.layer = json.GetNumber( "layer" )
	If json.TypeOf( "retain" ) <> JSON_UNDEFINED                 Then p.retain = json.GetBoolean( "retain" )
	If json.TypeOf( "frictional_coefficient" ) <> JSON_UNDEFINED Then p.frictional_coefficient = json.GetNumber( "frictional_coefficient" )
	If json.TypeOf( "red" ) <> JSON_UNDEFINED                    Then p.red = json.GetNumber( "red" )
	If json.TypeOf( "green" ) <> JSON_UNDEFINED                  Then p.green = json.GetNumber( "green" )
	If json.TypeOf( "blue" ) <> JSON_UNDEFINED                   Then p.blue = json.GetNumber( "blue" )
	If json.TypeOf( "red_delta" ) <> JSON_UNDEFINED              Then p.red_delta = json.GetNumber( "red_delta" )
	If json.TypeOf( "green_delta" ) <> JSON_UNDEFINED            Then p.green_delta = json.GetNumber( "green_delta" )
	If json.TypeOf( "blue_delta" ) <> JSON_UNDEFINED             Then p.blue_delta = json.GetNumber( "blue_delta" )
	If json.TypeOf( "life_time" ) <> JSON_UNDEFINED              Then p.life_time = json.GetNumber( "life_time" )
	If json.TypeOf( "pos_x" ) <> JSON_UNDEFINED                  Then p.pos_x = json.GetNumber( "pos_x" )
	If json.TypeOf( "pos_y" ) <> JSON_UNDEFINED                  Then p.pos_y = json.GetNumber( "pos_y" )
	If json.TypeOf( "vel_x" ) <> JSON_UNDEFINED                  Then p.vel_x = json.GetNumber( "vel_x" )
	If json.TypeOf( "vel_y" ) <> JSON_UNDEFINED                  Then p.vel_y = json.GetNumber( "vel_y" )
	If json.TypeOf( "ang" ) <> JSON_UNDEFINED                    Then p.ang = json.GetNumber( "ang" )
	If json.TypeOf( "ang_vel" ) <> JSON_UNDEFINED                Then p.ang_vel = json.GetNumber( "ang_vel" )
	If json.TypeOf( "alpha" ) <> JSON_UNDEFINED                  Then p.alpha = json.GetNumber( "alpha" )
	If json.TypeOf( "alpha_delta" ) <> JSON_UNDEFINED            Then p.alpha_delta = json.GetNumber( "alpha_delta" )
	If json.TypeOf( "scale" ) <> JSON_UNDEFINED                  Then p.scale = json.GetNumber( "scale" )
	If json.TypeOf( "scale_delta" ) <> JSON_UNDEFINED            Then p.scale_delta = json.GetNumber( "scale_delta" )
	Return p
End Function

