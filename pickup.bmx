Rem
	pickup.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global pickup_list:TList = CreateList()

Const AMMO_PICKUP% = 0
Const HEALTH_PICKUP% = 1

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
			remove_me()
		End If
	End Method
	
	Method auto_manage()
		add_me( pickup_list )
	End Method
	
End Type
'______________________________________________________________________________

