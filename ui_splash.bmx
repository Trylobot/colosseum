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
	Field logo_tween_scale:TWEEN
	Field logo_tween_ang:TWEEN
	Field intro:TSound
	'menu system
	Field item:Object
	Field handler:TUIEventHandler
  
	Method New()
	End Method
	
  Method Construct( ..
	logo:TImage, ..
	intro:TSound, ..
	handler(item:Object) = Null, item:Object = Null )
		Self.logo = PARTICLE(PARTICLE.Create( PARTICLE_TYPE_IMG, logo,,,,,,,,,,,,,,,, (SETTINGS_REGISTER.WINDOW_WIDTH.get() / 2), 0 ))
		Self.logo_tween_pos_y = TWEEN.Create( 300.0, -300.0, 500.0, TWEEN.quadratic_ease_out )
		Self.logo_tween_scale = TWEEN.Create(   4.0,   -3.0, 500.0, TWEEN.quadratic_ease_out )
		Self.logo_tween_ang   = TWEEN.Create(  25.0,  -25.0, 500.0, TWEEN.quadratic_ease_out )
		Self.intro = intro
		Self.item = item
		Self.handler = TUIEventHandler.Create( handler )
  End Method
	
	Method on_show()
		play_sound( intro )
		logo_tween_pos_y.rewind()
		logo_tween_scale.rewind()
		logo_tween_ang.rewind()
	End Method

  Method draw()
		Local base_scale# = Float(SETTINGS_REGISTER.WINDOW_WIDTH.get()) / Float(logo.img.width)
		logo.scale = base_scale * logo_tween_scale.get()
		logo.pos_y = logo_tween_pos_y.get()
		logo.ang = logo_tween_ang.get()
		logo.draw()
  End Method
	
	Method service( time_elapsed! )
		logo_tween_pos_y.service( time_elapsed )
		logo_tween_scale.service( time_elapsed )
		logo_tween_ang.service( time_elapsed )
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



