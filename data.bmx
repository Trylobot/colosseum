Rem
	data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "constants.bmx"
'Import "base_data.bmx"
'Import "agent.bmx"
'Import "particle.bmx"
'Import "projectile.bmx"
'Import "emitter.bmx"
'Import "widget.bmx"
'Import "pickup.bmx"
'Import "turret_barrel.bmx"
'Import "turret.bmx"
'Import "ai_type.bmx"
'Import "complex_agent.bmx"
'Import "player_profile.bmx"
'Import "level.bmx"
'Import "campaign_data.bmx"
'Import "image_manip.bmx"
'Import "settings.bmx"
'Import "texture_manager.bmx"

Global loading_progress%

'_____________________________________________________________________________
Function load_assets%()
	Local path$
	Local file:TStream
	Local json:TJSON
	For Local a% = 0 Until asset_files.Length
		path = data_path + asset_files[a] + "." + data_file_ext
		DebugLog( "  " + path )
		file = ReadFile( path )
		If file
			json = TJSON.Create( file )
      file.Close()
			If Not json.isNull() And TJSONArray( json.Root ) 'read successful
				load_objects( json, asset_files[a] )
			End If
		Else
			Return False
		End If
		loading_progress :+ 1
	Next
	DebugLog( "~n~n" )
	Return True
End Function

'_____________________________________________________________________________
Function load_level_grid%()
	Local path$
	Local file:TStream
	Local json:TJSON, value:TJSON
	Local r%, c%
	Local root:TJSONArray, arr:TJSONArray
	Local this_level_path$
	
	path = data_path + "level_select" + "." + data_file_ext
	file = ReadFile( path )
	If file
		json = TJSON.Create( file )
    file.Close()
		If Not json.isNull() And TJSONArray( json.Root ) 'read successful
			root = TJSONArray( json.root )
			level_grid = level_grid[.. root.Size()]
			For r = 0 Until root.Size()
				arr = TJSONArray( root.GetByIndex( r ))
				level_grid[r] = level_grid[r][.. arr.Size()]
				For c = 0 Until arr.Size()
					value = TJSON.Create( arr.GetByIndex( c ))
					this_level_path = value.GetString("")
					'////
					level_grid[r][c] = this_level_path
				Next
			Next
		End If
	Else
		Return False
	End If
	loading_progress :+ 1
	Return True
End Function

'______________________________________________________________________________
Function load_objects%( json:TJSON, source_file$ = Null )
	For Local i% = 0 To TJSONArray( json.Root ).Size() - 1
		Local item:TJSON = TJSON.Create( json.GetObject( String.FromInt( i )))
		Local key$ = item.GetString( "key" ).Trim()
		Select key 'special implicit keys for certain objects
			Case "{path}"
				key = StripAll( item.GetString( "object.path" ).Trim() )
			Case "{image_key}"
				key = item.GetString( "object.image_key" ).Trim()
			Case "{chassis_key}"
				key = item.GetString( "object.chassis_key" ).Trim()
		End Select
		If key And key <> ""
			key = key.toLower()
			DebugLog( "    " + key )
			Local object_json:TJSON = TJSON.Create( item.GetObject( "object" ))
			Select item.GetString( "class" ).Trim()
				Case "bmp_font"
					Local f:BMP_FONT = BMP_FONT.Create_from_json( object_json )
					If f Then bmp_font_map.Insert( key, f ) Else load_error( object_json )
        Case "bmp_font_copy"
          Local f:BMP_FONT = BMP_FONT.Create_copy_from_json( object_json )
          If f Then bmp_font_map.Insert( key, f ) Else load_error( object_json )
        Case "font_style"
          Local s:FONT_STYLE = FONT_STYLE.Create_from_json( object_json )
          If s Then font_style_map.Insert( key, s ) Else load_error( object_json )
				Case "sound"
					Local s:TSound = Create_TSound_from_json( object_json )
					If s Then sound_map.Insert( key, s ) Else load_error( object_json )
				Case "image"
					Local i:TImage = Create_TImage_from_json( object_json )
					If i Then image_map.Insert( key, i ) Else load_error( object_json )
				Case "prop"
					Local p:AGENT = Create_AGENT_from_json( object_json )
					If p Then prop_map.Insert( key, p ) Else load_error( object_json )
				Case "particle"
					Local p:PARTICLE = Create_PARTICLE_from_json( object_json )
					If p Then particle_map.Insert( key, p ) Else load_error( object_json )
				Case "particle_emitter"
					Local em:PARTICLE_EMITTER = Create_PARTICLE_EMITTER_from_json( object_json )
					If em Then particle_emitter_map.Insert( key, em ) Else load_error( object_json )
				Case "projectile"
					Local proj:PROJECTILE = Create_PROJECTILE_from_json( object_json )
					If proj Then projectile_map.Insert( key, proj ) Else load_error( object_json )
				Case "projectile_launcher"
					Local lchr:PROJECTILE_LAUNCHER = Create_PROJECTILE_LAUNCHER_from_json( object_json )
					If lchr Then projectile_launcher_map.Insert( key, lchr ) Else load_error( object_json )
				Case "widget"
					Local w:WIDGET = Create_WIDGET_from_json( object_json )
					If w Then widget_map.Insert( key, w ) Else load_error( object_json )
				Case "pickup"
					Local pkp:PICKUP = Create_PICKUP_from_json( object_json )
					If pkp Then pickup_map.Insert( key, pkp ) Else load_error( object_json )
				Case "turret_barrel"
					Local tb:TURRET_BARREL = Create_TURRET_BARREL_from_json( object_json )
					If tb Then turret_barrel_map.Insert( key, tb ) Else load_error( object_json )
				Case "turret"
					Local t:TURRET = Create_TURRET_from_json( object_json )
					If t Then turret_map.Insert( key, t ) Else load_error( object_json )
				Case "ai_type"
					Local ai:AI_TYPE = Create_AI_TYPE_from_json( object_json )
					If ai Then ai_type_map.Insert( key, ai ) Else load_error( object_json )
				Case "player_vehicle"
					Local p_veh:COMPLEX_AGENT = Create_COMPLEX_AGENT_from_json( object_json )
					If p_veh Then player_vehicle_map.Insert( key, p_veh ) Else load_error( object_json )
				Case "gibs"
					Local g:GIB_SYSTEM = Create_GIB_SYSTEM_from_json( object_json )
					If g Then gibs_map.Insert( key, g ) Else load_error( object_json )
				Case "unit"
					Local u:COMPLEX_AGENT = Create_COMPLEX_AGENT_from_json( object_json )
					If u Then unit_map.Insert( key, u ) Else load_error( object_json )
			End Select
		End If
	Next
End Function

'______________________________________________________________________________
Function Create_TSound_from_json:TSound( json:TJSON )
	Local path$, looping%
	path = json.GetString( "path" )
	looping = json.GetBoolean( "looping" )
	Return LoadSound( path, (looping&SOUND_LOOP)|SOUND_HARDWARE )
End Function

'______________________________________________________________________________
Function Create_TImage_from_json:TImage( json:TJSON )
	Local flags% = 0
	AutoMidHandle( True )
	Local img:TImage
	Local path$, handle_x#, handle_y#, frames%, frame_width%, frame_height%, flip_horizontal%, flip_vertical%
	path = json.GetString( "path" )
	frames = 1
	If JSON.TypeOf( "frames" ) = JSON_NUMBER Then frames = JSON.GetNumber( "frames" )
	If JSON.TypeOf( "filtered" ) = JSON_UNDEFINED Or JSON.GetBoolean( "filtered" ) Then flags = flags|FILTEREDIMAGE
	If json.GetBoolean( "mipmapped" ) Then flags = flags|MIPMAPPEDIMAGE
	If frames >= 1
		'load either regular image or primitive animated image
		If frames = 1
			img = LoadImage( path, flags )
		Else 'frames > 1
			frame_width = json.GetNumber( "frame_width" )
			frame_height = json.GetNumber( "frame_height" )
			img = LoadAnimImage( path, frame_width, frame_height, 0, frames, flags )
		End If
		'mod the basic image properties
		If img
			flip_horizontal = json.GetBoolean( "flip_horizontal" )
			flip_vertical = json.GetBoolean( "flip_vertical" )
			img = pixel_transform( img, flip_horizontal, flip_vertical ) 'does nothing if both are false
			'default handle is set by "AutoMidHandle"
			If json.TypeOf( "handle_x" ) <> JSON_UNDEFINED Or json.TypeOf( "handle_y" ) <> JSON_UNDEFINED
				'override
				handle_x = json.GetNumber( "handle_x" )
				handle_y = json.GetNumber( "handle_y" )
				SetImageHandle( img, handle_x, handle_y )
			End If
			Return img
		End If
	End If
	Return Null
End Function

'______________________________________________________________________________
Function load_level:LEVEL( path$ )
	Local file:TStream, json:TJSON, lev:LEVEL
	Local load_start% = now()
	file = ReadFile( path )
	If file
		json = TJSON.Create( file )
		file.Close()
		lev = Create_LEVEL_from_json( json )
		lev.src_path = path
		DebugLog "  Loaded level " + path + " in " + elapsed_str(load_start) + " sec."
		Return lev
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
			lev.src_path = path
			Return True
		Else
			Return False
		End If
	Else
		Return False
	End If
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
		SETTINGS_REGISTER.PLAYER_PROFILE_NAME.set( prof.name )
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
Function load_settings%()
	Local file:TStream = ReadFile( settings_path )
	If Not file Return False
	Local json:TJSON = TJSON.Create( file )
	file.Close()
	If Not json Return False
	'check for existence of specified graphics mode
	If GraphicsModeExists( ..
	json.GetNumber( "window_w" ), ..
	json.GetNumber( "window_h" ), ..
	json.GetNumber( "bit_depth" ), ..
	json.GetNumber( "refresh_rate" )) ..
	Or Not json.GetBoolean( "fullscreen" )
		'success
		SETTINGS_REGISTER.FULL_SCREEN.set( json.GetBoolean( "fullscreen" ))
		SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH.set( json.GetNumber( "window_w" ))
		SETTINGS_REGISTER.ACTUAL_WINDOW_HEIGHT.set( json.GetNumber( "window_h" ))
		SETTINGS_REGISTER.BIT_DEPTH.set( json.GetNumber( "bit_depth" ))
		SETTINGS_REGISTER.REFRESH_RATE.set( json.GetNumber( "refresh_rate" ))
		If AudioDriverExists( json.GetString( "audio_driver" ))
			audio_driver = json.GetString( "audio_driver" )
			SetAudioDriver( audio_driver )
		End If
		bg_music_enabled = json.GetBoolean( "bg_music_enabled" )
		SETTINGS_REGISTER.SHOW_AI_MENU_GAME.set( json.GetBoolean( "show_ai_menu_game" ))
		SETTINGS_REGISTER.ACTIVE_PARTICLE_LIMIT.set( json.GetNumber( "active_particle_limit" ))
		Return True
	End If
	'bad graphics mode
	Return False
End Function

'______________________________________________________________________________
Function save_settings%()
	Local this_json:TJSONObject = New TJSONObject
	this_json.SetByName( "fullscreen", TJSONBoolean.Create( SETTINGS_REGISTER.FULL_SCREEN.get() ))
	this_json.SetByName( "window_w", TJSONNumber.Create( SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH.get() ))
	this_json.SetByName( "window_h", TJSONNumber.Create( SETTINGS_REGISTER.ACTUAL_WINDOW_HEIGHT.get() ))
	this_json.SetByName( "bit_depth", TJSONNumber.Create( SETTINGS_REGISTER.BIT_DEPTH.get() ))
	this_json.SetByName( "refresh_rate", TJSONNumber.Create( SETTINGS_REGISTER.REFRESH_RATE.get() ))
	If audio_driver
		this_json.SetByName( "audio_driver", TJSONString.Create( audio_driver ))
	Else
		this_json.SetByName( "audio_driver", TJSON.NIL )
	End If
	this_json.SetByName( "bg_music_enabled", TJSONBoolean.Create( bg_music_enabled ))
	this_json.SetByName( "show_ai_menu_game", TJSONBoolean.Create( SETTINGS_REGISTER.SHOW_AI_MENU_GAME.get() ))
	this_json.SetByName( "active_particle_limit", TJSONNumber.Create( SETTINGS_REGISTER.ACTIVE_PARTICLE_LIMIT.get() ))
	'output json data
	Local json:TJSON = TJSON.Create( this_json )
	Local file:TStream = WriteFile( settings_path )
	If Not file Return False
	json.Write( file )
	file.Close()
End Function

'______________________________________________________________________________
Function load_autosave_profile_path$()
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

'_____________________________________________________________________________
Function create_dirs()
	CreateDir( art_path )
	CreateDir( data_path )
	CreateDir( level_path )
	CreateDir( sound_path )
	CreateDir( user_path )
End Function

'______________________________________________________________________________
Function load_error( json:TJSON )
	DebugLog( " *** ERROR loading~n" + json.ToSource() )
	DebugStop
End Function

