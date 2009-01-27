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
	Field state_index_cur% 'index of state representing the state of the widget at the beginning of the transformation
	Field state_index_next% 'index of state representing the desired state of the widget
	Field actual_state:TRANSFORM_STATE 'current transform state, used when in-between states
	
	Field transforming% '{true|false}
	Field transform_begin_ts% 'timestamp of beginning of current transformation, used with interpolation
	Field transformations_remaining% '{INFINITE|integer}
	Field prune_idle%
	
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
		w.transforming = initially_transforming
		
		w.traversal_direction = TRAVERSAL_DIRECTION_INCREASING
		w.transform_begin_ts = now()
		w.transformations_remaining = INFINITY
		Return w
	End Function
	
	Method add_state( st:TRANSFORM_STATE )
		If states = Null Or states.Length <= 0
			states = New TRANSFORM_STATE[1]
			states[0] = st.clone()
			state_index_cur = 0
			actual_state = states[state_index_cur].clone()
		Else 'states <> Null And states.Length > 0
			states = states[..states.Length+1]
			states[states.Length-1] = st.clone()
			state_index_next = state_successor( state_index_cur )
		End If
	End Method
	
	Method clone:WIDGET()
		Local w:WIDGET = WIDGET( WIDGET.Create( ..
			name, ..
			img, ..
			layer, ..
			visible, ..
			repeat_mode, ..
			transforming ))
		'copy states
		For Local st:TRANSFORM_STATE = EachIn states
			w.add_state( st )
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
			calculate_actual_state()
			If (now() - transform_begin_ts) >= states[state_index_cur].transition_time
				advance_state()
			End If
		End If
	End Method
	
	Method draw( alpha_override# = 1.0 )
		If visible
			SetColor( actual_state.red, actual_state.green, actual_state.blue )
			SetAlpha( actual_state.alpha*alpha_override )
			SetScale( actual_state.scale_x, actual_state.scale_y )
			SetRotation( get_ang() )
			DrawImage( img, get_x(), get_y() )
		End If
	End Method
	
	Method calculate_actual_state()
		Local cs:TRANSFORM_STATE = states[state_index_cur]
		Local ns:TRANSFORM_STATE = states[state_index_next]
		Local pct# = (Float(now() - transform_begin_ts) / Float(cs.transition_time))
		If pct > 1.0 Then pct = 1.0
		actual_state.pos_x = cs.pos_x + pct * (ns.pos_x - cs.pos_x)
		actual_state.pos_y = cs.pos_y + pct * (ns.pos_y - cs.pos_y)
		actual_state.calc_polar()
		actual_state.ang = cs.ang + pct * (ns.ang - cs.ang)
		actual_state.red = cs.red + pct * (ns.red - cs.red)
		actual_state.green = cs.green + pct * (ns.green - cs.green)
		actual_state.blue = cs.blue + pct * (ns.blue - cs.blue)
		actual_state.alpha = cs.alpha + pct * (ns.alpha - cs.alpha)
		actual_state.scale_x = cs.scale_x + pct * (ns.scale_x - cs.scale_x)
		actual_state.scale_y = cs.scale_y + pct * (ns.scale_y - cs.scale_y)
	End Method
	
	Method advance_state()
		state_index_cur = state_index_next
		state_index_next = state_successor( state_index_next )
		transform_begin_ts = now()
		'post-transformation checks
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
	End Method
	
	Method get_x#()
		Return parent.pos_x + offset*Cos( parent.ang + offset_ang ) + actual_state.pos_length*Cos( parent.ang + offset_ang + actual_state.pos_ang + ang_offset )
	End Method
	Method get_y#()
		Return parent.pos_y + offset*Sin( parent.ang + offset_ang ) + actual_state.pos_length*Sin( parent.ang + offset_ang + actual_state.pos_ang + ang_offset )
	End Method
	Method get_ang#()
		Return parent.ang + offset_ang + actual_state.ang + ang_offset
	End Method
	
	Method queue_transformation( count% = INFINITY, prune_when_finished% = False )
		prune_idle = prune_when_finished
		If transforming
			If count <> INFINITY
				transformations_remaining :+ count
			End If
		Else 'Not transforming
			transformations_remaining = count
			transforming = True
			transform_begin_ts = now()
		End If
	End Method
	
	Method pause()
		transforming = False
	End Method
	
	Method unpause()
		transforming = True
		transform_begin_ts = now()
	End Method

	Method reset()
		transforming = False
		state_index_cur = 0
		actual_state = states[0].clone()
	End Method
	
	Method state_successor%( i% )
		Local final_state% = states.Length - 1
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
	
	Method auto_manage()
		manage( game.environmental_widget_list )
	End Method
	
End Type
