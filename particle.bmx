Rem
	particle.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global retained_particle_list:TList = CreateList()
Global retained_particle_list_count% = 0
Global particle_lists:TList = CreateList()
Global particle_list_background:TList = CreateList(); particle_lists.AddLast( particle_list_background )
Global particle_list_foreground:TList = CreateList(); particle_lists.AddLast( particle_list_foreground )

Const LAYER_FOREGROUND% = 0
Const LAYER_BACKGROUND% = 1

Const PARTICLE_TYPE_IMG% = 0
Const PARTICLE_TYPE_ANIM% = 1
Const PARTICLE_TYPE_STR% = 2

Type PARTICLE Extends POINT

	Field particle_type% '{single_image|animated|string}
	Field img:TImage, frame% 'image to be drawn, and the current frame index for animation and randomly varied particle sets
	Field max_frame_delay% 'maximum delay between frames (animated only)
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
	Field frame_delay_pct# 'percentage from 0.0 to 1.0 of the frame delay to be using (animated_only, default 1.0)
	Field last_frame_advance_ts% 'timestamp of last frame advance
	Field text_width#, text_height# 'dimensions of text (STR particles only)
	
	Field parent:POINT
	Field offset#, offset_ang#
	
	Method New()
	End Method
	
	Function Create:Object( ..
	particle_type%, ..
	img:TImage = Null, frame% = 0, ..
	max_frame_delay% = 250, ..
	str$ = Null, font:TImageFont = Null, ..
	layer%, ..
	retain% = False, ..
	frictional_coefficient# = 0.0, ..
	red# = 255, green# = 255, blue# = 255, ..
	red_delta# = 0.0, green_delta# = 0.0, blue_delta# = 0.0, ..
	life_time% = 0, ..
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
		p.max_frame_delay = max_frame_delay
		p.str = str; p.font = font
		If str <> Null And font <> Null
			SetImageFont( font )
			p.text_width = TextWidth( str )/2.0
			p.text_height = TextHeight( str )/2.0
		End If
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
	
	Method clone:PARTICLE( new_frame% = -1 )
		If new_frame < 0 Then new_frame = frame
		Return PARTICLE( PARTICLE.Create( ..
			particle_type, img, new_frame, max_frame_delay, str, font, layer, retain, frictional_coefficient, red, green, blue, red_delta, green_delta, blue_delta, life_time, pos_x, pos_y, vel_x, vel_y, ang, ang_vel, alpha, alpha_delta, scale, scale_delta ))
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
		If particle_type = PARTICLE_TYPE_ANIM And frame_delay_pct <> 0 And (now() - last_frame_advance_ts >= (Abs(frame_delay_pct)*max_frame_delay))
			advance_frame()
		End If
	End Method
	
	Method draw()
		SetColor( red*255, green*255, blue*255 )
		SetAlpha( alpha )
		SetScale( scale, scale )
		
		Select particle_type
			Case PARTICLE_TYPE_IMG, PARTICLE_TYPE_ANIM
				If img <> Null
					If parent <> Null
						SetRotation( ang + parent.ang )
						DrawImage( img, parent.pos_x + offset*Cos( offset_ang + parent.ang ), parent.pos_y + offset*Sin( offset_ang + parent.ang ), frame )
					Else
						SetRotation( ang )
						DrawImage( img, pos_x, pos_y, frame )
					End If
				End If
			Case PARTICLE_TYPE_STR
				If font <> Null And str <> Null
					If parent <> Null
						SetRotation( ang + parent.ang )
						DrawText( str, parent.pos_x + offset*Cos( offset_ang + parent.ang ) - text_width, parent.pos_y + offset*Sin( offset_ang + parent.ang ) - text_height )
					Else
						SetRotation( ang )
						DrawText( str, pos_x - text_width, pos_y - text_height )
					End If
				End If
		End Select
	End Method
	
	Method advance_frame()
		last_frame_advance_ts = now()
		If frame_delay_pct > 0 'animate forwards
			frame :+ 1
			If frame >= img.frames.Length - 1 Then frame = 0
		Else If frame_delay_pct < 0 'animate backwards
			frame :- 1
			If frame < 0 Then frame = img.frames.Length - 1
		End If
	End Method
	
	Method control_animation( control# )
		frame_delay_pct = 1.0 - control
	End Method
	
	Method dead%()
		Return ..
			(Not (life_time = INFINITY)) And ..
			(now() - created_ts) >= life_time
	End Method
	
	Method prune()
		If dead()
			'remove from normal managed list
			remove_me()
			If retain
				'particle will be added to the background permanently
				add_me( retained_particle_list )
				retained_particle_list_count :+ 1
			End If
		End If
	End Method	
	
	Method auto_manage()
		If layer = LAYER_BACKGROUND
			add_me( particle_list_background )
		Else If layer = LAYER_FOREGROUND
			add_me( particle_list_foreground )
		End If
	End Method
	
	Method attach_at( off_x#, off_y# )
		cartesian_to_polar( off_x, off_y, offset, offset_ang )
	End Method
	
End Type




