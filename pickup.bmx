Rem
	pickup.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "managed_object.bmx"
'Import "audio.bmx"
'Import "json.bmx"
'Import "texture_manager.bmx"

'______________________________________________________________________________
Const PICKUP_PROBABILITY# = 0.25 'chance of an enemy dropping a pickup (randomly selected from all pickups)

Global pickup_map:TMap = CreateMap() 

Function get_pickup:PICKUP( key$, copy% = True )
	Local pkp:PICKUP = PICKUP( pickup_map.ValueForKey( Key.toLower() ))
	If copy And pkp Then Return pkp.clone()
	Return pkp
End Function

Type PICKUP Extends MANAGED_OBJECT
	Const AMMO% = 1
	Const HEALTH% = 2
	Const COOLDOWN% = 3

	Field img:TImage 'image to be drawn
	Field snd:TSound
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
	img:TImage = Null, ..
	snd:TSound = Null, ..
	pickup_type% = 0, ..
	pickup_amount% = 0, ..
	life_time% = 0, ..
	pos_x# = 0.0, pos_y# = 0.0, ..
	alpha# = 1.0 )
		Local p:PICKUP = New PICKUP
		'static fields
		p.img = img
		p.snd = snd
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
			img, snd, pickup_type, pickup_amount, life_time, pos_x, pos_y, alpha ))
	End Method

	Method update()
		prune()
		If managed()
			Local age_pct# = Float(now() - created_ts) / Float(life_time)
			If      age_pct < 0.20 Then alpha = 6 * (age_pct / 0.20) ..
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
	
	Method play()
		If snd Then play_sound( snd )
	End Method
	
	Method dead%()
		Return ..
			(Not (life_time = INFINITY)) And ..
			(now() - created_ts) > life_time
	End Method
	
	Method prune()
		If dead()
			unmanage()
		End If
	End Method
	
	Rem
	Method auto_manage()
		manage( game.pickup_list )
	End Method
	EndRem
	
End Type

Function Create_PICKUP_from_json:PICKUP( json:TJSON )
	Local p:PICKUP
	'no required fields
	p = PICKUP( PICKUP.Create() )
	'optional fields
	If json.TypeOf( "image_key" ) <> JSON_UNDEFINED     Then p.img = get_image( json.GetString( "image_key" ))
	If json.TypeOf( "sound_key" ) <> JSON_UNDEFINED     Then p.snd = get_sound( json.GetString( "sound_key" ))
	If json.TypeOf( "pickup_type" ) <> JSON_UNDEFINED   Then p.pickup_type = json.GetNumber( "pickup_type" )
	If json.TypeOf( "pickup_amount" ) <> JSON_UNDEFINED Then p.pickup_amount = json.GetNumber( "pickup_amount" )
	If json.TypeOf( "life_time" ) <> JSON_UNDEFINED     Then p.life_time = json.GetNumber( "life_time" )
	Return p
End Function


