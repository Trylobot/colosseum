Rem
	widget.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const REPEAT_MODE_NONE% = 0
Const REPEAT_MODE_CYCLIC_WRAP% = 1
Const REPEAT_MODE_LOOP_BACK% = 2

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
	Field prune_idle%
	
	Method New()
	End Method
	
	Function Create:Object( ..
	name$ = Null, ..
	img:TImage, ..
	layer% = LAYER_IN_FRONT_OF_PARENT, ..
	visible% = True, ..
	repeat_mode% = REPEAT_MODE_CYCLIC_WRAP, ..
	initially_transforming% = False )
		Local w:WIDGET = New WIDGET
		w.name = name
		w.img = img
		w.layer = layer
		w.visible = visible
		w.repeat_mode = repeat_mode
		w.cur_state = -1
		w.final_state = -1
		w.traversal_direction = TRAVERSAL_DIRECTION_INCREASING
		w.transforming = initially_transforming
		w.transform_begin_ts = now()
		w.transformations_remaining = INFINITY
		Return w
	End Function
	
	Method clone:WIDGET()
		Local w:WIDGET = WIDGET( WIDGET.Create( name, img, layer, visible, repeat_mode, transforming ))
		'copy list of states
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
						If prune_idle
							unmanage()
						End If
					End If
				End If
			End If
			If transforming
				'currently transforming
				Local ns:TRANSFORM_STATE = states[ state_successor( cur_state )]
				Local pct# = (Float(now() - transform_begin_ts) / Float(cs.transition_time))
				state.pos_x = cs.pos_x + pct * (ns.pos_x - cs.pos_x)
				state.pos_y = cs.pos_y + pct * (ns.pos_y - cs.pos_y)
				state.calc_polar()
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
		End If
	End Method
	
	Method draw()
		If visible
			SetColor( state.red, state.green, state.blue )
			SetAlpha( state.alpha )
			SetScale( state.scale_x, state.scale_y )
			SetRotation( get_ang() )
			DrawImage( img, get_x(), get_y() )
		End If
	End Method
	
	Method get_x#()
		Return parent.pos_x + offset*Cos( parent.ang + offset_ang ) + state.pos_length*Cos( parent.ang + offset_ang + state.pos_ang + ang_offset )
	End Method
	Method get_y#()
		Return parent.pos_y + offset*Sin( parent.ang + offset_ang ) + state.pos_length*Sin( parent.ang + offset_ang + state.pos_ang + ang_offset )
	End Method
	Method get_ang#()
		Return parent.ang + offset_ang + state.ang + ang_offset
	End Method
	
	Method queue_transformation( count% = INFINITY, prune_when_finished% = False )
		prune_idle = prune_when_finished
		If transforming
			transformations_remaining :+ count
		Else
			transformations_remaining = count
			transforming = True
			transform_begin_ts = now()
		End If
	End Method
	
	Method add_state( st:TRANSFORM_STATE )
		If states = Null
			cur_state = 0
			final_state = 0
			states = New TRANSFORM_STATE[1]
			states[0] = st.clone()
			state = st.clone()
		Else 'states <> Null
			states = states[..states.Length+1]
			final_state = states.Length - 1
			states[final_state] = st.clone()
		End If
	End Method
	
	Method state_successor%( i% )
		Select repeat_mode
			Case REPEAT_MODE_NONE
				If i >= final_state
					Return final_state
				End If
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
