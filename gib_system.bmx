Rem
	data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'_____________________________________________________________________________
Global gibs_map:TMap = CreateMap()

Function get_gibs:GIB_SYSTEM( key$ ) 'returns read-only reference
	Local g:GIB_SYSTEM = GIB_SYSTEM( gibs_map.ValueForKey( key.toLower() ))
	If g Then Return g.clone() Else Return Null
End Function


Type GIB_SYSTEM
	Field gibs:PARTICLE[]
	Field gib_speed#[]
	
	Method show( spawn:POINT, background_particle_manager:TList )
		For Local i% = 0 Until gibs.Length
			Local gib:PARTICLE = gibs[i]
			gib.pos_x = spawn.pos_x + gib.offset*Cos( gib.offset_ang + spawn.ang )
			gib.pos_y = spawn.pos_y + gib.offset*Sin( gib.offset_ang + spawn.ang )
			gib.ang = spawn.ang
			Local speed# = gib_speed[i]
			gib.vel_x = spawn.vel_x + speed*Cos( gib.offset_ang + spawn.ang )
			gib.vel_y = spawn.vel_y + speed*Sin( gib.offset_ang + spawn.ang )
			gib.ang_vel = spawn.ang_vel
			gib.created_ts = now()
			gib.manage( background_particle_manager )
		Next
	End Method
	
	Method clone:GIB_SYSTEM()
		Local g:GIB_SYSTEM = New GIB_SYSTEM
		g.gibs = New PARTICLE[gibs.Length]
		g.gib_speed = New Float[gib_speed.Length]
		For Local i% = 0 Until gibs.Length
			g.gibs[i] = gibs[i].clone()
			g.gib_speed[i] = gib_speed[i]
		Next
		Return g
	End Method
End Type

Function Create_GIB_SYSTEM_from_json:GIB_SYSTEM( json:TJSON )
	Local g:GIB_SYSTEM
	'reserve space for required fields
	Local image_path$, img:TImage
	Local offset_x#
	Local offset_y#
	Local speed#
	'read required fields
	If json.TypeOf( "gibs" ) = JSON_ARRAY
		Local gibs_json:TJSONArray = TJSONArray( json.GetArray( "gibs" ))
		g = New GIB_SYSTEM
		g.gibs = New PARTICLE[gibs_json.Size()]
		g.gib_speed = New Float[gibs_json.Size()]
		For Local i% = 0 Until gibs_json.Size()
			Local gib_json:TJSON = TJSON.Create( gibs_json.GetByIndex( i ))
			image_path = gib_json.GetString( "image_path" )
			AutoImageFlags( FILTEREDIMAGE )
			AutoMidHandle( True )
			img = LoadImage( image_path )
			offset_x = gib_json.GetNumber( "offset_x" )
			offset_y = gib_json.GetNumber( "offset_y" )
			Local p:PARTICLE = PARTICLE(PARTICLE.Create( PARTICLE_TYPE_IMG, img,,,,, LAYER_BACKGROUND, True, 0.100,,,,,,, 750 ))
			p.attach_at( offset_x, offset_y )
			g.gibs[i] = p
			speed = gib_json.GetNumber( "speed" )
			g.gib_speed[i] = -speed
		Next
	End If
	Return g
End Function

