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
	
	Method show( parent:POINT, background_particle_manager:TList )
		For Local gib:PARTICLE = EachIn gibs
			gib.parent = parent
			gib.update()
			gib.created_ts = now()
			gib.manage( background_particle_manager )
		Next
	End Method
	
	Method clone:GIB_SYSTEM()
		Local g:GIB_SYSTEM = New GIB_SYSTEM
		g.gibs = New PARTICLE[gibs.Length]
		For Local i% = 0 Until gibs.Length
			g.gibs[i] = gibs[i].clone()
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
		For Local i% = 0 Until gibs_json.Size()
			Local gib_json:TJSON = TJSON.Create( gibs_json.GetByIndex( i ))
			image_path = gib_json.GetString( "image_path" )
			AutoImageFlags( FILTEREDIMAGE )
			AutoMidHandle( True )
			img = LoadImage( image_path )
			offset_x = gib_json.GetNumber( "offset_x" )
			offset_y = gib_json.GetNumber( "offset_y" )
			Local offset:cVEC = Create_CVEC( offset_x, offset_y )
			speed = gib_json.GetNumber( "speed" )
			g.gibs[i] = PARTICLE(PARTICLE.Create( PARTICLE_TYPE_IMG, img,,,,,, LAYER_BACKGROUND, True, 0.100,,,,,,, 750 ))
		Next
	End If
	Return g
	Rem
	If gibs <> Null
		For Local i% = 0 To gibs.cell_count - 1
			Local gib:PARTICLE = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, gibs, i,,,,, LAYER_BACKGROUND, True, 0.100,,,,,,, 750 ))
			Local gib_offset#, gib_offset_ang#
			cartesian_to_polar( gib.pos_x, gib.pos_y, gib_offset, gib_offset_ang )
			gib.pos_x = pos_x + gib_offset*Cos( gib_offset_ang + ang )
			gib.pos_y = pos_y + gib_offset*Sin( gib_offset_ang + ang )
			Local gib_vel#, gib_vel_ang#
			gib_vel = Rnd( -2.0, 2.0 )
			gib_vel_ang = Rnd( 0.0, 359.9999 )
			gib.vel_x = vel_x + gib_vel*Cos( gib_vel_ang + ang )
			gib.vel_y = vel_y + gib_vel*Sin( gib_vel_ang + ang )
			gib.ang = ang + Rand( -30, 30 )
			gib.ang_vel = Rnd( -3.0, 3.0 )
			gib.update()
			gib.created_ts = now()
			gib.manage( background_particle_manager )
		Next
	End If
	EndRem
End Function

