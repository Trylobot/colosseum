Rem
	particle.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const PARTICLE_PRUNE_ACTION_ADD_TO_BG_CACHE% = 1
Const PARTICLE_PRUNE_ACTION_FORCED_FADE_OUT% = 2
Global global_particle_prune_action% = PARTICLE_PRUNE_ACTION_FORCED_FADE_OUT

Const LAYER_UNSPECIFIED% = 0
Const LAYER_FOREGROUND% = 1
Const LAYER_BACKGROUND% = 2

Const PARTICLE_TYPE_IMG% = 0
Const PARTICLE_TYPE_ANIM% = 1
Const PARTICLE_TYPE_STR% = 2

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
	
	Method draw()
		SetColor( red*255, green*255, blue*255 )
		SetAlpha( alpha )
		SetScale( scale, scale )
		
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
	
	Method prune()
		If dead()
			'remove from normal managed list
			unmanage()
			If retain
				manage( game.retained_particle_list )
				game.retained_particle_list_count :+ 1
				If global_particle_prune_action = PARTICLE_PRUNE_ACTION_FORCED_FADE_OUT
					alpha_delta :- 0.100
				End If
			End If
		End If
	End Method	
	
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
	
End Type

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

'______________________________________________________________________________
Const AMMO_PICKUP% = 0
Const HEALTH_PICKUP% = 1
Const COOLDOWN_PICKUP% = 2

Type PICKUP Extends MANAGED_OBJECT
	
	Field img:TImage 'image to be drawn
	Field pickup_type% 'pickup type indicator
	Field pickup_amount% 'magnitude of pickup
	Field life_time% 'time until object is deleted
	
	Field pos_x# 'position (x-axis), pixels
	Field pos_y# 'position (y-axis), pixels
	Field alpha# '(private) alpha value, based on life_time and created_ts
	Field created_ts% '(private) timestamp of object creation
	
	Method New()
	End Method
	
	Function Create:Object( ..
	img:TImage, ..
	pickup_type%, ..
	pickup_amount%, ..
	life_time%, ..
	pos_x# = 0.0, pos_y# = 0.0, ..
	alpha# = 1.0 )
		Local p:PICKUP = New PICKUP
		
		'static fields
		p.img = img
		p.pickup_type = pickup_type
		p.pickup_amount = pickup_amount
		p.life_time = life_time
		
		'dynamic fields
		p.pos_x = pos_x
		p.pos_y = pos_y
		p.alpha = alpha
		p.created_ts = now()
		
		Return p
	End Function

	Method clone:PICKUP()
		Return PICKUP( PICKUP.Create( ..
			img, pickup_type, pickup_amount, life_time, pos_x, pos_y, alpha ))
	End Method

	Method update()
		prune()
		If managed()
			Local age_pct# = Float(now() - created_ts) / Float(life_time)
			If      age_pct < 0.20 Then alpha = (age_pct / 0.20) ..
			Else If age_pct < 0.80 Then alpha = 1.0 ..
			Else                        alpha = 1.0 - ((age_pct - 0.80) / 0.25)
		End If
	End Method
	
	Method draw()
		SetRotation( 0 )
		SetAlpha( alpha )
		SetScale( 1, 1 )
		
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method dead%()
		Return ..
			(Not (life_time = INFINITY)) And ..
			(now() - created_ts) > life_time
	End Method
	
	Method prune()
		If dead()
			unmanage()
		End If
	End Method
	
	Method auto_manage()
		manage( game.pickup_list )
	End Method
	
End Type

'______________________________________________________________________________
Const REPEAT_MODE_CYCLIC_WRAP% = 0
Const REPEAT_MODE_LOOP_BACK% = 1

Const TRAVERSAL_DIRECTION_INCREASING% = 0
Const TRAVERSAL_DIRECTION_DECREASING% = 1

Const LAYER_BEHIND_PARENT% = 0
Const LAYER_IN_FRONT_OF_PARENT% = 1

Type WIDGET Extends MANAGED_OBJECT
	
	Field parent:POINT 'parent object, provides local origin
	Field img:TImage 'image to be drawn
	Field layer% 'whether to be drawn before the parent or after it
	Field visible% '{true|false}
	
	Field attach_x# 'original attachment position (x component)
	Field attach_y# 'original attachment position (y component)
	Field offset# 'offset from parent
	Field offset_ang# 'angle of offset from parent
	Field ang_offset# 'angle to be combined with all transform state angles
	Field repeat_mode% '{cyclic_wrap|loop_back}
	Field traversal_direction% '{increasing|decreasing}
	Field states:TRANSFORM_STATE[] 'sequence of states to be traversed over time
	Field cur_state% 'index of current transform state
	Field final_state% 'index of last valid state
	Field state:TRANSFORM_STATE 'current transform state, used only when in-between states
	Field transforming% '{true|false}
	Field transform_begin_ts% 'timestamp of beginning of current transformation, used with interpolation
	Field transformations_remaining% '{INFINITE|integer}
	
	Method New()
	End Method
	
	Function Create:Object( ..
	name$ = Null, ..
	img:TImage, ..
	layer%, ..
	visible% = True, ..
	repeat_mode%, ..
	state_count%, ..
	initially_transforming% )
		Local w:WIDGET = New WIDGET
		w.name = name
		w.img = img
		w.layer = layer
		w.visible = visible
		w.repeat_mode = repeat_mode
		w.states = New TRANSFORM_STATE[state_count]
		w.cur_state = -1
		w.final_state = -1
		w.traversal_direction = TRAVERSAL_DIRECTION_INCREASING
		w.transforming = initially_transforming
		w.transformations_remaining = INFINITY
		Return w
	End Function
	
	Method clone:WIDGET()
		Local w:WIDGET = WIDGET( WIDGET.Create( name, img, layer, visible, repeat_mode, states.Length, transforming ))
		'list of states
		For Local cur_state:TRANSFORM_STATE = EachIn states
			w.add_state( cur_state )
		Next
		Return w
	End Method

	Method attach_at( ..
	new_attach_x# = 0.0, new_attach_y# = 0.0, ..
	new_ang_offset# = 0.0, ..
	FLAG_mute_offset_ang% = False )
		attach_x = new_attach_x; attach_y = new_attach_y
		cartesian_to_polar( attach_x, attach_y, offset, offset_ang )
		ang_offset = new_ang_offset
		If FLAG_mute_offset_ang
			ang_offset :- offset_ang
		End If
	End Method
	
	Method update()
		If transforming
			Local cs:TRANSFORM_STATE = states[cur_state]
			If (now() - transform_begin_ts) >= cs.transition_time
				'finished current transformation
				cur_state = state_successor( cur_state )
				cs = states[cur_state]
				transform_begin_ts = now()
				If transformations_remaining > 0
					'are there any transformations left
					transformations_remaining :- 1
					If transformations_remaining <= 0
						'no? fine
						transforming = False
					End If
				End If
			End If
			If transforming
				'currently transforming
				Local ns:TRANSFORM_STATE = states[ state_successor( cur_state )]
				Local pct# = (Float(now() - transform_begin_ts) / Float(cs.transition_time))
				'state.pos_x = cs.pos_x + pct * (ns.pos_x - cs.pos_x)
				'state.pos_y = cs.pos_y + pct * (ns.pos_y - cs.pos_y)
				state.pos_length = cs.pos_length + pct * (ns.pos_length - cs.pos_length)
				state.pos_ang = cs.pos_ang + pct * (ns.pos_ang - cs.pos_ang)
				state.ang = cs.ang + pct * (ns.ang - cs.ang)
				state.red = cs.red + pct * (ns.red - cs.red)
				state.green = cs.green + pct * (ns.green - cs.green)
				state.blue = cs.blue + pct * (ns.blue - cs.blue)
				state.alpha = cs.alpha + pct * (ns.alpha - cs.alpha)
				state.scale_x = cs.scale_x + pct * (ns.scale_x - cs.scale_x)
				state.scale_y = cs.scale_y + pct * (ns.scale_y - cs.scale_y)
			Else
				'widget just stopped transforming during this update() call
				state = cs.clone()
			End If
		Else
			'not transforming, nothing to update.
		End If
	End Method
	
	Method draw()
		If visible
			SetColor( state.red, state.green, state.blue )
			SetAlpha( state.alpha )
			SetScale( state.scale_x, state.scale_y )
			
			SetRotation( parent.ang + offset_ang + state.ang + ang_offset )
			DrawImage( img, ..
				parent.pos_x + offset*Cos( parent.ang + offset_ang ) + state.pos_length*Cos( parent.ang + offset_ang + state.ang + ang_offset ), ..
				parent.pos_y + offset*Sin( parent.ang + offset_ang ) + state.pos_length*Sin( parent.ang + offset_ang + state.ang + ang_offset ) )
		End If
	End Method
	
	Method queue_transformation( count% = INFINITY )
		If transforming
			transformations_remaining :+ count
		Else
			transformations_remaining = count
			transforming = True
			transform_begin_ts = now()
		End If
	End Method
	
	Method add_state( s:TRANSFORM_STATE )
		final_state :+ 1
		states[final_state] = s.clone()
		If cur_state < 0 Then cur_state = 0
		If state = Null Then state = states[cur_state].clone()
	End Method
	
	Method state_successor%( i% )
		Select repeat_mode
			Case REPEAT_MODE_CYCLIC_WRAP
				If i >= final_state
					Return 0
				Else 'i < final_state
					Return i + 1
				End If
			Case REPEAT_MODE_LOOP_BACK
				Select traversal_direction
					Case TRAVERSAL_DIRECTION_INCREASING
						If i >= final_state
							traversal_direction = TRAVERSAL_DIRECTION_DECREASING
							Return i - 1
						Else 'i < final_state
							Return i + 1
						End If
					Case TRAVERSAL_DIRECTION_DECREASING
						If i <= 0
							traversal_direction = TRAVERSAL_DIRECTION_INCREASING
							Return i + 1
						Else 'i > 0
							Return i - 1
						End If
				End Select
		End Select
	End Method
	
	Method reset()
		transforming = False
		cur_state = 0
		state = states[cur_state].clone()
	End Method
	
	Method auto_manage()
		manage( game.environmental_widget_list )
	End Method
	
End Type




