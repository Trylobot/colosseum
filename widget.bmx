Rem
	pickup.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type TRANSFORM_STATE
	
	Field pos_x#, pos_y#
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
Const REPEAT_MODE_CYCLIC_WRAP% = 0
Const REPEAT_MODE_LOOP_BACK% = 1

Type WIDGET Extends MANAGED_OBJECT
	
	Field parent:POINT 'parent object, provides local origin
	Field off_x#, off_y# 'static positional offset from parent position
	Field img:TImage 'image to be drawn
	
	Field repeat_mode% '{cyclic_wrap|loop_back}
	Field state_list:TList 'sequence of states to be traversed over time
	Field state_link:TLink 'reference to list link containing current state
	Field state:TRANSFORM_STATE 'current transform state, used only when in-between states
	Field transforming% '{true|false}
	Field transform_begin_ts% 'timestamp of beginning of current transformation, used with interpolation
	Field transformations_remaining% '{INFINITE|integer}
	
	Method New()
		state_list = CreateList()
	End Method
	
	Function Create:Object( ..
	img:TImage, ..
	repeat_mode% = REPEAT_MODE_CYCLIC_WRAP )
		Local w:WIDGET = New WIDGET
		w.img = img
		w.repeat_mode = repeat_mode
		Return w
	End Function
	
	Method clone:WIDGET()	
		Local w:WIDGET = WIDGET( WIDGET.Create( img, repeat_mode ))
		'list of states
		For Local cur_state:TRANSFORM_STATE = EachIn state_list
			w.add_state( cur_state )
		Next
		Return w
	End Method

	Method attach_to( ..
	new_parent:POINT, ..
	new_off_x#, new_off_y# )
		parent = new_parent
		off_x = new_off_x; off_y = new_off_y
	End Method
	
	Method update()
		If transforming
			Local cs:TRANSFORM_STATE = TRANSFORM_STATE( state_link.Value() )
			If (now() - transform_begin_ts) >= cs.transition_time
				'finished current transformation
				state_link = next_state_link()
				cs = TRANSFORM_STATE( state_link.Value() )
				transform_begin_ts = now()
				If transformations_remaining > 0
					'are there any transformations left to do?
					transformations_remaining :- 1
					If transformations_remaining = 0 Then transforming = False
				End If
			End If
			If transforming
				'currently transforming
				Local ns:TRANSFORM_STATE = TRANSFORM_STATE( next_state_link().Value() )
				Local pct# = ((now() - transform_begin_ts) / cs.transition_time)
				state.pos_x = cs.pos_x + pct * (ns.pos_x - cs.pos_x)
				state.pos_y = cs.pos_y + pct * (ns.pos_y - cs.pos_y)
				state.ang = cs.ang + pct * (ns.ang - cs.ang)
				state.red = cs.red + pct * (ns.red - cs.red)
				state.green = cs.red + pct * (ns.green - cs.green)
				state.blue = cs.blue + pct * (ns.blue - cs.blue)
				state.alpha = cs.alpha + pct * (ns.alpha - cs.alpha)
				state.scale_x = cs.scale_x + pct * (ns.scale_x - cs.scale_x)
				state.scale_y = cs.scale_y + pct * (ns.scale_y - cs.scale_y)
			Else
				'was transforming, until just a moment ago
				state = TRANSFORM_STATE( state_link.Value() ).clone()
			End If
		End If
	End Method
	
	Method draw()
		SetColor( state.red, state.green, state.blue )
		SetAlpha( state.alpha )
		SetRotation( parent.ang + state.ang )
		SetScale( state.scale_x, state.scale_y )
		DrawImage( img, parent.pos_x + off_x + state.pos_x, parent.pos_y + off_y + state.pos_y )
	End Method
	
	Method next_state_link:TLink()
		If state_link = Null Then Return Null
		Return state_link.NextLink()
	End Method
	
	Method begin_transformation( count% = INFINITY )
		transformations_remaining = count
		transform_begin_ts = now()
		transforming = True
	End Method
	
	Method add_state( s:TRANSFORM_STATE )
		state_list.AddLast( s.clone() )
	End Method
	
End Type


