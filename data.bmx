Rem
	data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "base_data.bmx"
Import "agent.bmx"
Import "particle.bmx"
Import "projectile.bmx"
Import "emitter.bmx"
Import "widget.bmx"
Import "pickup.bmx"
Import "turret_barrel.bmx"
Import "turret.bmx"
Import "ai_type.bmx"
Import "compatibility_data.bmx"
Import "level.bmx"
Import "image_manip.bmx"

'______________________________________________________________________________
Global settings_file_ext$ = "colosseum_settings"
Global data_file_ext$ = "colosseum_data"
Global level_file_ext$ = "colosseum_level"
Global saved_game_file_ext$ = "colosseum_profile"
Global autosave_path$ = "user/autosave.colosseum_data"

Global art_path$ = "art/"
Global data_path$ = "data/"
Global font_path$ = "fonts/"
Global level_path$ = "levels/"
Global sound_path$ = "sound/"
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
	"player_chassis", ..
	"units", ..
	"compatibility", ..
	"levels" ]
	
'_____________________________________________________________________________
Function load_assets%( display_progress% = False )
	Local file:TStream = ReadFile( data_path + default_assets_file_name )
	If Not file Then Return False
	Local json:TJSON = TJSON.Create( file )
	file.Close()
	If Not json.isNull() 'read successful
		Local asset_path$, asset_file:TStream, asset_json:TJSON
		For Local asset_id$ = EachIn asset_identifiers
			asset_path = json.GetString( asset_id )
			Local source_file$ = StripAll( asset_path )
			DebugLog( "  load_assets() --> "+asset_path )
			asset_file = ReadFile( asset_path )
			If file
				global_error_message = source_file + "~n"
				asset_json = TJSON.Create( asset_file )
				If Not asset_json.isNull() And TJSONArray(asset_json.Root) 'read successful
					load_objects( asset_json, source_file, display_progress )
				End If
			Else
				global_error_message :+ "file could not be opened for read."
				load_error()
			End If
		Next
		DebugLog( "~n~n" )
		If display_progress Then fade_out()
		Return True
	End If
	Return False
End Function
'______________________________________________________________________________
Function load_objects%( json:TJSON, source_file$ = Null, display_progress% = False )
	If display_progress Then draw_loaded_asset( , True )
	For Local i% = 0 To TJSONArray( json.Root ).Size() - 1
		Local item:TJSON = TJSON.Create( json.GetObject( String.FromInt( i )))
		Local key$ = item.GetString( "key" )
		Select key 'special implicit keys for certain objects
			Case "{path}"
				key = StripAll( item.GetString( "object.path" ))
			Case "{image_key}"
				key = item.GetString( "object.image_key" )
			Case "{chassis_key}"
				key = item.GetString( "object.chassis_key" )
		End Select
		If key And key <> ""
			key = key.toLower()
			DebugLog( "    load_objects() --> " + key )
			If display_progress Then draw_loaded_asset( key )
			global_error_message = source_file + "/" + key + "~n"
			Local object_json:TJSON = TJSON.Create( item.GetObject( "object" ))
			Select item.GetString( "class" )
				Case "font"
					Local f:TImageFont = Create_TImageFont_from_json( object_json )
					If f Then font_map.Insert( key, f ) Else load_error()
				Case "sound"
					Local s:TSound = Create_TSound_from_json( object_json )
					If s Then sound_map.Insert( key, s ) Else load_error()
				Case "image"
					Local i:TImage = Create_TImage_from_json( object_json )
					If i Then image_map.Insert( key, i ) Else load_error()
				Case "prop"
					Local p:AGENT = Create_AGENT_from_json( object_json )
					If p Then prop_map.Insert( key, p ) Else load_error()
				Case "particle"
					Local p:PARTICLE = Create_PARTICLE_from_json( object_json )
					If p Then particle_map.Insert( key, p ) Else load_error()
				Case "particle_emitter"
					Local em:EMITTER = Create_EMITTER_from_json( object_json )
					If em Then particle_emitter_map.Insert( key, em ) Else load_error()
				Case "projectile"
					Local proj:PROJECTILE = Create_PROJECTILE_from_json( object_json )
					If proj Then projectile_map.Insert( key, proj ) Else load_error()
				Case "projectile_launcher"
					Local lchr:EMITTER = Create_EMITTER_from_json( object_json )
					If lchr Then projectile_launcher_map.Insert( key, lchr ) Else load_error()
				Case "widget"
					Local w:WIDGET = Create_WIDGET_from_json( object_json )
					If w Then widget_map.Insert( key, w ) Else load_error()
				Case "pickup"
					Local pkp:PICKUP = Create_PICKUP_from_json( object_json )
					If pkp Then pickup_map.Insert( key, pkp ) Else load_error()
				Case "turret_barrel"
					Local tb:TURRET_BARREL = Create_TURRET_BARREL_from_json( object_json )
					If tb Then turret_barrel_map.Insert( key, tb ) Else load_error()
				Case "turret"
					Local t:TURRET = Create_TURRET_from_json( object_json )
					If t Then turret_map.Insert( key, t ) Else load_error()
				Case "ai_type"
					Local ai:AI_TYPE = Create_AI_TYPE_from_json( object_json )
					If ai Then ai_type_map.Insert( key, ai ) Else load_error()
				Case "player_chassis"
					Local p_cha:COMPLEX_AGENT = Create_COMPLEX_AGENT_from_json( object_json )
					If p_cha Then player_chassis_map.Insert( key, p_cha ) Else load_error()
				Case "unit"
					Local u:COMPLEX_AGENT = Create_COMPLEX_AGENT_from_json( object_json )
					If u Then unit_map.Insert( key, u ) Else load_error()
				Case "compatibility"
					Local cd:COMPATIBILITY_DATA = Create_COMPATIBILITY_DATA_from_json( object_json )
					If cd Then compatibility_map.Insert( key, cd ) Else load_error()
				'Case "level"
			End Select
		End If
	Next
End Function

'______________________________________________________________________________
Function get_keys$[]( map:TMap )
	Local list:TList = CreateList()
	Local size% = 0
	For Local key$ = EachIn MapKeys( map )
		list.AddLast( Key )
		size :+ 1
	Next
	Local array$[] = New String[ size ]
	Local i% = 0
	For Local key$ = EachIn list
		array[i] = key
		i :+ 1
	Next
	Return array
End Function

'_____________________________________________________________________________
Function Create_TImageFont_from_json:TImageFont( json:TJSON )
	Local path$, size%
	path = json.GetString( "path" )
	size = json.GetNumber( "size" )
	Return LoadImageFont( path, size )
End Function
'_____________________________________________________________________________
Function Create_TSound_from_json:TSound( json:TJSON )
	Local path$, looping%
	path = json.GetString( "path" )
	looping = json.GetBoolean( "looping" )
	Return LoadSound( path, (looping&SOUND_LOOP) )
End Function
'_____________________________________________________________________________
Function Create_TImage_from_json:TImage( json:TJSON )
	Local path$, handle_x#, handle_y#, frames%, frame_width%, frame_height%, flip_horizontal%, flip_vertical%
	Local img:TImage
	'AutoImageFlags( FILTEREDIMAGE|MIPMAPPEDIMAGE )
	AutoImageFlags( FILTEREDIMAGE )
	path = json.GetString( "path" )
	frames = json.GetNumber( "frames" )
	If frames >= 1
		If frames = 1
			img = LoadImage( path )
		Else 'frames > 1
			frame_width = json.GetNumber( "frame_width" )
			frame_height = json.GetNumber( "frame_height" )
			img = LoadAnimImage( path, frame_width, frame_height, 0, frames )
		End If
		If img
			flip_horizontal = json.GetBoolean( "flip_horizontal" )
			flip_vertical = json.GetBoolean( "flip_vertical" )
			img = pixel_transform( img, flip_horizontal, flip_vertical ) 'does nothing if both are false
			handle_x = json.GetNumber( "handle_x" )
			handle_y = json.GetNumber( "handle_y" )
			SetImageHandle( img, handle_x, handle_y )
			Return img
		End If
	End If
	Return Null
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
	CreateDir( art_path )
	CreateDir( data_path )
	CreateDir( font_path )
	CreateDir( level_path )
	CreateDir( sound_path )
	CreateDir( user_path )
End Function
'______________________________________________________________________________
Function enforce_suffix$( str$, suffix$ )
	Return str + suffix
End Function

'______________________________________________________________________________
Function load_settings%()
	Local file:TStream = ReadFile( user_path + default_settings_file_name )
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
			window = Create_BOX( 0, 0, window_w, window_h )
		fullscreen = json.GetBoolean( "fullscreen" )
		bit_depth = json.GetNumber( "bit_depth" )
		refresh_rate = json.GetNumber( "refresh_rate" )
		show_ai_menu_game = json.GetBoolean( "show_ai_menu_game" )
		retain_particles = json.GetBoolean( "retain_particles" )
		active_particle_limit = json.GetNumber( "active_particle_limit" )
		network_ip_address = json.getString( "network_ip_address" )
		network_port = json.GetNumber( "network_port" )
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
	this_json.SetByName( "show_ai_menu_game", TJSONBoolean.Create( show_ai_menu_game ))
	this_json.SetByName( "retain_particles", TJSONBoolean.Create( retain_particles ))
	this_json.SetByName( "active_particle_limit", TJSONNumber.Create( active_particle_limit ))
	this_json.SetByName( "network_ip_address", TJSONString.Create( network_ip_address ))
	this_json.SetByName( "network_port", TJSONNumber.Create( network_port ))
	'output json data
	Local json:TJSON = TJSON.Create( this_json )
	Local file:TStream = WriteFile( user_path + default_settings_file_name )
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
Function save_game%( path$, prof:PLAYER_PROFILE )
	Local file:TStream, json:TJSON
	json = TJSON.Create( prof.to_json() )
	file = WriteFile( path )
	If file
		json.Write( file )
		file.Close()
		Return True
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
Function save_pixmap_to_file( px:TPixmap, file_prefix$ = "screenshot_" )
	Local dir$[] = LoadDir( user_path )
	'find the highest unused screenshot number
	Local high% = 1
	For Local file$ = EachIn dir
		If file.Find( file_prefix ) >= 0
			Local Current% = StripAll(file)[(file_prefix.length)..].ToInt()
			If high <= Current Then high = Current + 1
		EndIf
	Next
	'procedurally build filename
	Local path$ = user_path + file_prefix + pad( high, 3, "0" ) + ".png"
	'save png
	SavePixmapPNG( px, path )
End Function
'______________________________________________________________________________
Function load_autosave$()
	Local file:TStream, json:TJSON
	file = ReadFile( autosave_path )
	If file
		json = TJSON.Create( file )
		file.Close()
		Return json.GetString( "autosave" )
	Else
		Return Null
	End If
End Function
'______________________________________________________________________________
Function save_autosave( profile_path$ )
	Local file:TStream, json:TJSON
	json = TJSON.Create( New TJSONObject )
	json.SetValue( "autosave", TJSONString.Create( profile_path ))
	file = WriteFile( autosave_path )
	If file
		json.Write( file )
		file.Close()
	End If
End Function


