Rem
	ui_splash.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type TUISplash Extends TUIObject
	'assets
	Field logo:PARTICLE
	Field logo_tween_pos_y:TWEEN
	Field logo_tween_alpha:TWEEN
	Field reveal_tween_alpha:TWEEN
	Field intro:TSound
	'menu system
	Field item:Object
	Field handler:TUIEventHandler
  
	Method New()
	End Method
	
  Method Construct( ..
	logo_img:TImage, ..
	intro:TSound, ..
	handler(item:Object) = Null, item:Object = Null )
		logo = PARTICLE(PARTICLE.Create( PARTICLE_TYPE_IMG, logo_img,,,,,,,,,,,,,,, (SETTINGS_REGISTER.WINDOW_WIDTH.get() / 2), 0 ))
		logo_tween_pos_y = TWEEN.Create( -logo_img.height/2, +logo_img.height/2, 500.0, TWEEN.quadratic_ease_out )
		logo_tween_alpha = TWEEN.Create( 0.0, +1.0, 500.0, TWEEN.quadratic_ease_out )
		reveal_tween_alpha = TWEEN.Create( 1.0, -1.0, 750.0, TWEEN.quadratic_ease_in_out )
		Self.intro = intro
		Self.item = item
		Self.handler = TUIEventHandler.Create( handler )
  End Method
	
	Method on_show()
		play_sound( intro )
		logo_tween_pos_y.rewind()
		logo_tween_alpha.rewind()
		reveal_tween_alpha.rewind()
	End Method

  Method draw()
		'reveal cover
		If Not logo_tween_pos_y.is_finished()
			SetAlpha( 1 )
		Else
			SetAlpha( reveal_tween_alpha.get() )
		End If
		SetColor( 255, 255, 255 )
		DrawRect( 0, 0, SETTINGS_REGISTER.WINDOW_WIDTH.get(), SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
		'logo
		SetAlpha( 1 )
		logo.pos_y = logo_tween_pos_y.get()
		logo.alpha = logo_tween_alpha.get()
		logo.scale = Float(SETTINGS_REGISTER.WINDOW_WIDTH.get()) / Float(logo.img.width)
		logo.draw()
  End Method
	
	Method service( time_elapsed! )
		If logo_tween_pos_y.is_finished()
			reveal_tween_alpha.service( time_elapsed )
		End If
		logo_tween_pos_y.service( time_elapsed )
		logo_tween_alpha.service( time_elapsed )
	End Method
  
  Method on_mouse_click%( mx%, my% )
		activate()
  End Method
	
	Method on_keyboard_enter%()
		activate()
	End Method
	
	Method activate()
		If handler Then handler.invoke( item )
	End Method
	
End Type



