Rem
	ui_splash.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type TUISplash Extends TUIObject
	'assets
	Field logo:PARTICLE
	Field intro:TSound
	'menu system
	Field item:Object
	Field handler:TUIEventHandler
  
	Method New()
	End Method
	
  Method Construct( ..
	logo:TImage, lx%, ly%, ..
	intro:TSound, ..
	handler(item:Object) = Null, item:Object = Null )
		Self.logo = PARTICLE(PARTICLE.Create( PARTICLE_TYPE_IMG, logo,,,,,,,,,,,,,,,, lx, ly ))
		Self.intro = intro
		Self.item = item
		Self.handler = TUIEventHandler.Create( handler )
  End Method
	
	Method on_show()
		play_sound( intro )
	End Method

  Method draw()
		logo.draw()
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



