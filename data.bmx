Rem
	data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global settings_file_ext$ = "colosseum_settings"
Global data_file_ext$ = "colosseum_data"
Global level_file_ext$ = "colosseum_level"
Global saved_game_file_ext$ = "colosseum_saved_game"

Global data_path$ = "data/"
Global user_path$ = "user/"
Global default_settings_file_name$ = "settings."+settings_file_ext
Global default_assets_file_name$ = "assets."+data_file_ext

Global asset_identifiers$[] = ..
[	"fonts", ..
	"sounds", ..
	"images", ..
	"props", ..
	"particles", ..
	"particle_emitters", ..
	"projectiles", ..
	"projectile_launchers", ..
	"widgets", ..
	"pickups", ..
	"turret_barrels", ..
	"turrets", ..
	"ai_types", ..
	"complex_agents", ..
	"levels" ]
	
Global asset_data_heading$ = "data"

Global font_map:TMap = CreateMap()
Global sound_map:TMap = CreateMap()
Global image_map:TMap = CreateMap()
Global prop_map:TMap = CreateMap()
Global particle_map:TMap = CreateMap()
Global particle_emitter_map:TMap = CreateMap()
Global projectile_map:TMap = CreateMap()
Global projectile_launcher_map:TMap = CreateMap()
Global widget_map:TMap = CreateMap()
Global pickup_map:TMap = CreateMap()
Global turret_map:TMap = CreateMap()
Global ai_type_map:TMap = CreateMap()
Global complex_agent_map:TMap = CreateMap()
Global level_map:TMap = CreateMap()
'______________________________________________________________________________
Function get_font:TImageFont( key$ )
	Return TImageFont( font_map.ValueForKey( key ))
End Function
Function get_sound:TSound( key$ )
	Return TSound( sound_map.ValueForKey( key ))
End Function
Function get_image:TImage( key$ )
	Return TImage( image_map.ValueForKey( key ))
End Function
'Function get_prop:AGENT( key$ )
'	Return AGENT( prop_map.ValueForKey( key ))
'End Function
'...
Function get_ai_type:AI_TYPE( key$ )
	Return AI_TYPE( ai_type_map.ValueForKey( key ))
End Function
'...
Function get_level:LEVEL( key$ )
	Return LEVEL( level_map.ValueForKey( key ))
End Function

'_____________________________________________________________________________
Function load_assets%()
	Local file:TStream = ReadFile( data_path + default_assets_file_name )
	If Not file Then Return False
	Local json:TJSON = TJSON.Create( file )
	file.Close()
	'test successful creation of json object (somehow)
	Local asset_path$, asset_file:TStream, asset_json:TJSON
	For Local asset_id$ = EachIn asset_identifiers
		asset_path = json.GetString( asset_id )
		asset_file = ReadFile( asset_path )
		If Not file Then Continue
		asset_json = TJSON.Create( asset_file )
		'test successful creation of asset_json object (somehow)
		Select asset_id
			Case "fonts"
				load_fonts( asset_json )
			Case "sounds"
				load_sounds( asset_json )
			Case "images"
				load_images( asset_json )
			Case "props"
				load_props( asset_json )
			'Default
				'unrecognized asset
		End Select
	Next
	Return True
End Function
'_____________________________________________________________________________
Function load_fonts%( json:TJSON )
	Local data:TJSONArray = json.GetArray( asset_data_heading )
	'test successful creation of data object (somehow)
	Local asset_json_path$
	Local path$, size%
	Local font:TImageFont
	For Local index% = 0 To data.Size()-1
		asset_json_path = asset_data_heading + "." + index + "."
		path = json.GetString( asset_json_path + "path" )
		size = json.GetNumber( asset_json_path + "size" )
		font = LoadImageFont( path, size, SMOOTHFONT )
		If font <> Null
  		font_map.Insert( StripAll( path )+"_"+size, font )
		End If
	Next
End Function
'_____________________________________________________________________________
Function load_sounds%( json:TJSON )
	Local data:TJSONArray = json.GetArray( asset_data_heading )
	'test successful creation of data object (somehow)
	Local asset_json_path$
	Local path$, looping%
	Local sound:TSound
	For Local index% = 0 To data.Size()-1
		asset_json_path = asset_data_heading + "." + index + "."
		path = json.GetString( asset_json_path + "path" )
		looping = json.GetBoolean( asset_json_path + "looping" )
		sound = LoadSound( path, (looping&SOUND_LOOP) )
		If sound <> Null
			sound_map.Insert( StripAll( path ), sound )
		End If
	Next
End Function
'_____________________________________________________________________________
Function load_images%( json:TJSON )
	Local data:TJSONArray = json.GetArray( asset_data_heading )
	'test successful creation of data object (somehow)
	Local asset_json_path$
	Local path$, handle_x#, handle_y#, frames%, frame_width%, frame_height%
	Local img:TImage
	AutoImageFlags( FILTEREDIMAGE|MIPMAPPEDIMAGE )
	For Local index% = 0 To data.Size()-1
		asset_json_path = asset_data_heading + "." + index + "."
		path = json.GetString( asset_json_path + "path" )
		handle_x = json.GetNumber( asset_json_path + "handle_x" )
		handle_y = json.GetNumber( asset_json_path + "handle_y" )
		frames = json.GetNumber( asset_json_path + "frames" )
		If frames >= 1
			If frames = 1
				img = LoadImage( path )
			Else 'frames > 1
				frame_width = json.GetNumber( asset_json_path + "frame_width" )
				frame_height = json.GetNumber( asset_json_path + "frame_height" )
				img = LoadAnimImage( path, frame_width, frame_height, 0, frames )
			End If
			If img <> Null
				SetImageHandle( img, handle_x, handle_y )
				image_map.Insert( StripAll( path ), img )
			End If
		End If
	Next
End Function
'______________________________________________________________________________
Function load_props%( json:TJSON )
	Local data:TJSONArray = json.GetArray( asset_data_heading )
	'test successful creation of data object (somehow)
	Local asset_json_path$
	Local img:TImage, gibs:TImage, cash_value%, max_health#, mass#, frictional_coefficient#, physics_disabled%, destruct_on_contact%
	Local prop:AGENT
	For Local index% = 0 To data.Size()-1
		'asset_json_path
	Next
End Function

'______________________________________________________________________________
Function load_level:LEVEL( path$ )
	Local file:TStream, json:TJSON
	file = ReadFile( path )
	If file
		json = TJSON.Create( file )
		file.Close()
		Return Create_LEVEL_from_json( json )
	Else
		Return Null
	End If
End Function
'______________________________________________________________________________
Function save_level%( path$, lev:LEVEL )
	If lev <> Null
		Local file:TStream, json:TJSON
		json = TJSON.Create( lev.to_json() )
		file = WriteFile( path )
		If file
			json.Write( file )
			file.Close()
			Return True
		Else
			Return False
		End If
	Else
		Return False
	End If
End Function

'______________________________________________________________________________
Function create_dirs()
	CreateDir( data_path )
	CreateDir( user_path )
End Function
'______________________________________________________________________________
Function enforce_suffix$( str$, suffix$ )
	Return str + suffix
End Function

'______________________________________________________________________________
Function load_settings%()
	Local file:TStream = ReadFile( data_path + default_settings_file_name )
	If Not file Return False
	Local json:TJSON = TJSON.Create( file )
	file.Close()
	'check for existence of specified graphics mode
	If GraphicsModeExists( ..
	json.GetNumber( "window_w" ), ..
	json.GetNumber( "window_h" ), ..
	json.GetNumber( "bit_depth" ), ..
	json.GetNumber( "refresh_rate" ) )
		'success
		window_w = json.GetNumber( "window_w" )
		window_h = json.GetNumber( "window_h" )
		fullscreen = json.GetBoolean( "fullscreen" )
		bit_depth = json.GetNumber( "bit_depth" )
		refresh_rate = json.GetNumber( "refresh_rate" )
		ip_address = json.getString( "ip_address" )
		ip_port = json.GetNumber( "port" )
		Return True
	End If
	'bad graphics mode
	Return False
End Function
'______________________________________________________________________________
Function save_settings%()
	Local this_json:TJSONObject = New TJSONObject
	this_json.SetByName( "window_w", TJSONNumber.Create( window_w ))
	this_json.SetByName( "window_h", TJSONNumber.Create( window_h ))
	this_json.SetByName( "fullscreen", TJSONBoolean.Create( fullscreen ))
	this_json.SetByName( "bit_depth", TJSONNumber.Create( bit_depth ))
	this_json.SetByName( "refresh_rate", TJSONNumber.Create( refresh_rate ))
	this_json.SetByName( "ip_address", TJSONString.Create( ip_address ))
	this_json.SetByName( "port", TJSONNumber.Create( ip_port ))
	'output json data
	Local json:TJSON = TJSON.Create( this_json )
	Local file:TStream = WriteFile( data_path + default_settings_file_name )
	If Not file Return False
	json.Write( file )
	file.Close()
End Function

'______________________________________________________________________________
Function load_game:PLAYER_PROFILE( path$ )
	Local file:TStream, json:TJSON, prof:PLAYER_PROFILE
	file = ReadFile( path )
	If file
		json = TJSON.Create( file )
		file.Close()
		prof = Create_PLAYER_PROFILE_from_json( json )
		prof.src_path = path
		Return prof
	Else
		Return Null
	End If
End Function
'______________________________________________________________________________
Function save_game%( path$, game:PLAYER_PROFILE )
	If game <> Null
		Local file:TStream, json:TJSON
		json = TJSON.Create( game.to_json() )
		file = WriteFile( path )
		If file
			json.Write( file )
			file.Close()
			Return True
		Else
			Return False
		End If
	Else
		Return False
	End If
End Function
'______________________________________________________________________________
Function find_files:TList( path$, ext$ = "" )
	Local list:TList = CreateList()
	Local dir% = ReadDir( path ) 'if directory exists, assign integer handle
	If dir = 0 '(directory does not exist)
		Return list 'empty at this point
	Else 'dir <> 0 (directory exists)
		Local file$
		Repeat
			file = NextFile( dir )
			If file <> ""
				If ext = "" '(no filter)
					list.AddLast( path + file )
				Else 'suffix <> "" (filter)
					If ExtractExt( file ) = ext
						list.AddLast( path + file )
					End If
				End If
			End If
		Until file = ""
		Return list
	End If
End Function
'______________________________________________________________________________
Function save_pixmap_to_file( px:TPixmap )
	Local file_prefix$ = "screenshot_"
	Local dir$[] = LoadDir( user_path )
	'find the highest unused screenshot number
	Local high% = 1
	For Local file$ = EachIn dir
		If file.Find( file_prefix ) >= 0
			Local current% = StripAll(file)[(file_prefix.length)..].ToInt()
			If high <= current Then high = current + 1
		EndIf
	Next
	'build path
	Local path$ = user_path + file_prefix + pad( high, 3, "0" ) + ".png"
	'save png
	SavePixmapPNG( px, path )
End Function


