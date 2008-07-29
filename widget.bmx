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
	
	Method clone:TRANSFORM_STATE()
		Return TRANSFORM_STATE( TRANSFORM_STATE.Create( ..
			pos_x, pos_y, ang, red, green, blue, alpha, scale_x, scale_y, transition_time ))
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
End Type
'______________________________________________________________________________
Const REPEAT_MODE_CYCLIC_WRAP% = 0
Const REPEAT_MODE_LOOP_BACK% = 1

Type WIDGET Extends MANAGED_OBJECT
	
	Field parent:POINT 'parent object, provides local origin
	Field off_x#, off_y# 'static positional offset from parent position
	
	Field repeat_mode% '{cyclic_wrap|loop_back}
	Field state_list:TList 'sequence of states to be traversed over time
	Field cur_state:TLink 'reference to list link containing current state
	Field next_state:TLink 'reference to list link containing next state
	Field state:TRANSFORM_STATE 'current transform state, used only when in-between states
	Field transforming% '{true|false}
	Field transform_begin_ts% 'timestamp of beginning of current transformation, used with interpolation
	Field transformations_remaining% '{INFINITE|integer}
	
	Method New()
	End Method
	
	Method update()
		If transforming
			Local cs:TRANSFORM_STATE = TRANSFORM_STATE( cur_state.Value() )
			Local ns:TRANSFORM_STATE = TRANSFORM_STATE( next_state.Value() )
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
		End If
	End Method
	
	Method draw()
		Local 
		If transforming
			
		Else
			
		End If
	End Method
	
	Method begin_transformation( count% = INFINITY )
		transform_begin_ts = now()
		transforming = True
		transformations_remaining = count
	End Method
	
	Method add_state( s:TRANSFORM_STATE )
		state_list.AddLast( s.clone() )
	End Method
	
	Method attach_to( ..
	new_parent:POINT, ..
	new_off_x#, new_off_y# )
		parent = new_parent
		off_x = new_off_x; off_y = new_off_y
	End Method
	
	Function Archetype:Object( ..
	)
		Local w:WIDGET = New WIDGET
		
		Return w
	End Function
	
	Function Copy:Object( ..
	)	
		Local w:WIDGET = New WIDGET
		
		Return w
	End Function

End Type


