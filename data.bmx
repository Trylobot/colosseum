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
Function load_texture_atlases%()
  Local path$
	Local file:TStream
	Local json:TJSON
  DebugLog( "  " + "texture_atlases" )
	TEXTURE_MANAGER.init( texture_atlas_files.Length )
  For Local a% = 0 Until texture_atlas_files.Length
    path = data_path + texture_atlas_files[a] + "." + data_file_ext
		DebugLog( "    " + path )
    file = ReadFile( path )
    If file
      json = TJSON.Create( file )
      file.Close()
      If Not json.isNull() 'read successful
        TEXTURE_MANAGER.load_texture_from_json( json )
      Else
        Return False
      End If
    Else
      Return False
    End If
		loading_progress :+ 1
	Next
	Return True
End Function

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
				Case "font"
					Local f:TImageFont = Create_TImageFont_from_json( object_json )
					If f Then font_map.Insert( key, f ) Else load_error( object_json )
				Case "bmp_font"
					Local f:BMP_FONT = BMP_FONT.Create_from_json( object_json )
					If f Then bmp_font_map.Insert( key, f ) Else load_error( object_json )
        Case "bmp_font_copy"
          Local f:BMP_FONT = BMP_FONT.Create_copy_from_json( object_json )
          If f Then bmp_font_map.Insert( key, f ) Else load_error( object_json )
				Case "sound"
					Local s:TSound = Create_TSound_from_json( object_json )
					If s Then sound_map.Insert( key, s ) Else load_error( object_json )
				Case "image"
					TEXTURE_MANAGER.load_image_data( object_json, key )
					'Local i:TImage = Create_TImage_from_json( object_json )
					'If i Then image_map.Insert( key, i ) Else load_error( object_json )
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
				Case "unit"
					Local u:COMPLEX_AGENT = Create_COMPLEX_AGENT_from_json( object_json )
					If u Then unit_map.Insert( key, u ) Else load_error( object_json )
				Case "campaign"
					Local c:CAMPAIGN_DATA = Create_CAMPAIGN_DATA_from_json( object_json )
					If c
						campaign_data_map.Insert( key, c )
						'append to global ordered array of all campaigns
						If Not campaign_ordering
							campaign_ordering = [ key ]
						Else 'campaign_ordering <> Null
							campaign_ordering = campaign_ordering[..campaign_ordering.Length+1]
							campaign_ordering[campaign_ordering.Length-1] = key
						End If
					Else
						load_error( object_json )
					End If
			End Select
		End If
	Next
End Function

'_____________________________________________________________________________
Function Create_TImageFont_from_json:TImageFont( json:TJSON )
	Local path$, size%
	path = json.GetString( "path" )
	size = json.GetNumber( "size" )
	Return LoadImageFont( path, size )
End Function

'______________________________________________________________________________
Function Create_TSound_from_json:TSound( json:TJSON )
	Local path$, looping%
	path = json.GetString( "path" )
	looping = json.GetBoolean( "looping" )
	Return LoadSound( path, (looping&SOUND_LOOP) )
End Function

'______________________________________________________________________________
'Deprecated
Rem
Function Create_TImage_from_json:TImage( json:TJSON )
	Local img:TImage
	Local path$, handle_x#, handle_y#, frames%, frame_width%, frame_height%, flip_horizontal%, flip_vertical%
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
ENDREM

'______________________________________________________________________________
Function load_level:LEVEL( path$ )
	Local file:TStream, json:TJSON, lev:LEVEL
	file = ReadFile( path )
	If file
		json = TJSON.Create( file )
		file.Close()
		lev = Create_LEVEL_from_json( json )
		lev.src_path = path
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
		window_w = json.GetNumber( "window_w" )
		window_h = json.GetNumber( "window_h" )
		fullscreen = json.GetBoolean( "fullscreen" )
		bit_depth = json.GetNumber( "bit_depth" )
		refresh_rate = json.GetNumber( "refresh_rate" )
		If AudioDriverExists( json.GetString( "audio_driver" ))
			audio_driver = json.GetString( "audio_driver" )
			SetAudioDriver( audio_driver )
		End If
		bg_music_enabled = json.GetBoolean( "bg_music_enabled" )
		show_ai_menu_game = json.GetBoolean( "show_ai_menu_game" )
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
	If audio_driver
		this_json.SetByName( "audio_driver", TJSONString.Create( audio_driver ))
	Else
		this_json.SetByName( "audio_driver", TJSON.NIL )
	End If
	this_json.SetByName( "bg_music_enabled", TJSONBoolean.Create( bg_music_enabled ))
	this_json.SetByName( "show_ai_menu_game", TJSONBoolean.Create( show_ai_menu_game ))
	this_json.SetByName( "active_particle_limit", TJSONNumber.Create( active_particle_limit ))
	this_json.SetByName( "network_ip_address", TJSONString.Create( network_ip_address ))
	this_json.SetByName( "network_port", TJSONNumber.Create( network_port ))
	'output json data
	Local json:TJSON = TJSON.Create( this_json )
	Local file:TStream = WriteFile( settings_path )
	If Not file Return False
	json.Write( file )
	file.Close()
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
	CreateDir( font_path )
	CreateDir( level_path )
	CreateDir( sound_path )
	CreateDir( user_path )
End Function

'______________________________________________________________________________
Function load_error( json:TJSON )
	DebugLog( " *** ERROR loading~n" + json.ToSource() )
	DebugStop
End Function

