Rem
	point.bmx
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
	
	Method dead%()
		Return ..
			(Not (life_time = INFINITY)) And ..
			(now() - created_ts) >= life_time
	End Method
	
	Method prune()
		If dead()
			remove_me()
		End If
	End Method	
	
	Method draw()
		SetRotation( 0 )
		SetAlpha( alpha )
		SetScale( 1, 1 )
		
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method update()
		'update alpha and prune if necessary
		alpha = (life_time - (now() - created_ts)) / 3000
		prune()
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_PICKUP:PICKUP( ..
img:TImage, ..
pickup_type%, ..
pickup_amount%, ..
life_time% )
	Local p:PICKUP = New PICKUP
	
	'static fields
	p.img = img
	p.pickup_type = pickup_type
	p.pickup_amount = pickup_amount
	p.life_time = life_time
	
	'dynamic fields
	p.pos_x = 0
	p.pos_y = 0
	p.alpha = 1
	p.created_ts = now()
	
	Return p
End Function
'______________________________________________________________________________
Function Copy_PICKUP:PICKUP( other:PICKUP )
	If other = Null Then Return Null
	Local p:PICKUP = New PICKUP
	
	'static fields
	p.img = other.img
	p.pickup_type = other.pickup_type
	p.pickup_amount = other.pickup_amount
	p.life_time = other.life_time
	
	'dynamic fields
	p.pos_x = other.pos_x
	p.pos_y = other.pos_y
	p.alpha = other.alpha
	p.created_ts = now()
	
	p.add_me( pickup_list )
	Return p
End Function

