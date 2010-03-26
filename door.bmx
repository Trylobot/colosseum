Rem
	door.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "texture_manager.bmx"
Import "widget.bmx"
Import "managed_object.bmx"
Import "point.bmx"
Import "particle.bmx"

'______________________________________________________________________________
Function Create_DOOR:DOOR( parent:POINT )
	Local d:DOOR = New DOOR
	d.parent = parent
	d.left_slider = get_widget( "door" )
	d.left_slider.parent = parent
	d.left_slider.attach_at( 25 + 50/3 - d.left_slider.img.height/2 + 1, 0, 90, True )
	d.right_slider = get_widget( "door" )
	d.right_slider.parent = parent
	d.right_slider.attach_at( 25 + 50/3 - d.right_slider.img.height/2 + 1, 0, -90, True )
	d.all_sliders = [ d.left_slider, d.right_slider ]
	d.left_servo = get_particle( "door_servo" )
	d.left_servo.parent = parent
	d.left_servo.attach_at( 25 + 50/3 - d.left_slider.img.height/2 + 1, 73 )
	d.left_servo.ang = -90
	d.right_servo = get_particle( "door_servo" )
	d.right_servo.parent = parent
	d.right_servo.attach_at( 25 + 50/3 - d.right_slider.img.height/2 + 1, -73 )
	d.right_servo.ang = 90
	d.bg = get_image( "door_bg" )
	d.fg = get_image( "door_fg" )
	d.status = DOOR.DOOR_CLOSED
	Return d
End Function

Type DOOR Extends MANAGED_OBJECT
	Const DOOR_CLOSED% = 0 'remove the prefix DOOR, it's superfluous
	Const DOOR_OPEN% = 1
	
	Field parent:POINT
	Field bg:IMAGE_ATLAS_REFERENCE
	Field fg:IMAGE_ATLAS_REFERENCE
	Field left_slider:WIDGET
	Field right_slider:WIDGET
	Field all_sliders:WIDGET[]
	Field left_servo:PARTICLE
	Field right_servo:PARTICLE
	Field status%
	
	Method update()
		left_slider.update()
		right_slider.update()
		If left_slider.transforming
			left_servo.frame_delay = left_slider.states[ left_slider.state_index_cur ].transition_time / 35.0
			right_servo.frame_delay = right_slider.states[ right_slider.state_index_cur ].transition_time / 35.0
			If left_slider.state_index_cur = 0
				left_servo.animation_direction = ANIMATION_DIRECTION_FORWARDS
				right_servo.animation_direction = ANIMATION_DIRECTION_FORWARDS
			Else 'left_slider.state_index_cur <> 0
				left_servo.animation_direction = ANIMATION_DIRECTION_BACKWARDS
				right_servo.animation_direction = ANIMATION_DIRECTION_BACKWARDS
			End If
		Else 'Not left_slider.transforming
			left_servo.frame_delay = INFINITY
			right_servo.frame_delay = INFINITY
		End If
		left_servo.update()
		right_servo.update()
	End Method
	
	Method draw_bg()
		SetColor( 255, 255, 255 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		SetRotation( parent.ang )
		DrawImageRef( bg, parent.pos_x, parent.pos_y )
	End Method
	
	Method draw_fg()
		SetColor( 255, 255, 255 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		SetRotation( parent.ang )
		DrawImageRef( fg, parent.pos_x, parent.pos_y )
		left_slider.draw()
		right_slider.draw()
		left_servo.draw()
		right_servo.draw()
	End Method
	
	Method toggle%() 'returns new status
		status = Not status
		left_slider.queue_transformation( 1 )
		right_slider.queue_transformation( 1 )
	End Method
	Method open()
		If status = DOOR_CLOSED Then toggle()
	End Method
	Method close()
		If status = DOOR_OPEN Then toggle()
	End Method
	
End Type

