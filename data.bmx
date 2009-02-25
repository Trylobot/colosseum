Rem
	data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

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
Global turret_barrel_map:TMap = CreateMap()
Global turret_map:TMap = CreateMap()
Global ai_type_map:TMap = CreateMap()
Global player_chassis_map:TMap = CreateMap()
Global unit_map:TMap = CreateMap()
Global compatibility_map:TMap = CreateMap()
Global level_map:TMap = CreateMap()

'______________________________________________________________________________
Function get_font:TImageFont( key$ ) 'returns read-only reference
	Return TImageFont( font_map.ValueForKey( key.toLower() ))
End Function
'________________________________
Function get_sound:TSound( key$ ) 'returns read-only reference
	Return TSound( sound_map.ValueForKey( key.toLower() ))
End Function
'________________________________
Function get_image:TImage( key$ ) 'returns read-only reference
	Return TImage( image_map.ValueForKey( key.toLower() ))
End Function
'________________________________
Function get_prop:AGENT( key$, copy% = True )
	Local ag:AGENT = AGENT( prop_map.ValueForKey( key.toLower() ))
	If copy And ag Then Return Copy_AGENT( ag )
	Return ag
End Function
'________________________________
Function get_particle:PARTICLE( key$, new_frame% = 0, copy% = True )
	Local part:PARTICLE = PARTICLE( particle_map.ValueForKey( key.toLower() ))
	If copy And part Then Return part.clone( new_frame )
	Return part
End Function
'________________________________
Function get_particle_emitter:EMITTER( key$, copy% = True )
	Local em:EMITTER = EMITTER( particle_emitter_map.ValueForKey( key.toLower() ))
	If copy And em Then Return EMITTER( EMITTER.Copy( em ))
	Return em
End Function
'________________________________
Function get_projectile:PROJECTILE( key$, source_id% = NULL_ID, copy% = True )
	Local proj:PROJECTILE = PROJECTILE( projectile_map.ValueForKey( key.toLower() ))
	If copy And proj Then Return proj.clone( source_id )
	Return proj
End Function
'________________________________
Function get_projectile_launcher:EMITTER( key$, copy% = True )
	Local lchr:EMITTER = EMITTER( projectile_launcher_map.ValueForKey( key.toLower() ))
	If copy And lchr Then Return EMITTER( EMITTER.Copy( lchr ))
	Return lchr
End Function
'________________________________
Function get_pickup:PICKUP( key$, copy% = True )
	Local pkp:PICKUP = PICKUP( pickup_map.ValueForKey( key.toLower() ))
	If copy And pkp Then Return pkp.clone()
	Return pkp
End Function
'________________________________
Function get_turret_barrel:TURRET_BARREL( key$, copy% = True )
	Local tb:TURRET_BARREL = TURRET_BARREL( turret_barrel_map.ValueForKey( key.toLower() ))
	If copy And tb Then Return TURRET_BARREL( tb.clone())
	Return tb
End Function
'________________________________
Function get_turret:TURRET( key$, copy% = True )
	Local tur:TURRET = TURRET( turret_map.ValueForKey( key.toLower() ))
	If copy And tur Then Return tur.clone()
	Return tur
End Function
'________________________________
Function get_widget:WIDGET( key$, copy% = True )
	Local w:WIDGET = WIDGET( widget_map.ValueForKey( key.toLower() ))
	If copy And w Then Return w.clone()
	Return w
End Function
'________________________________
Function get_ai_type:AI_TYPE( key$ ) 'returns read-only reference
	Return AI_TYPE( ai_type_map.ValueForKey( key.toLower() ))
End Function
'________________________________
Function get_player_chassis:COMPLEX_AGENT( key$, copy% = True ) 'returns a new instance, which is a copy of the global archetype
	Local comp_ag:COMPLEX_AGENT = COMPLEX_AGENT( player_chassis_map.ValueForKey( key.toLower() ))
	If copy And comp_ag Then Return COMPLEX_AGENT( COMPLEX_AGENT.Copy( comp_ag ))
	Return comp_ag
End Function
'________________________________
Function get_unit:COMPLEX_AGENT( key$, alignment% = ALIGNMENT_NONE, copy% = True ) 'returns a new instance, which is a copy of the global archetype
	Local unit:COMPLEX_AGENT = COMPLEX_AGENT( unit_map.ValueForKey( key.toLower() ))
	If copy And unit Then Return COMPLEX_AGENT( COMPLEX_AGENT.Copy( unit, alignment ))
	Return unit
End Function
'________________________________
Function get_compatibility:COMPATIBILITY_DATA( key$ ) 'returns read-only reference (recursive inheritance expansion)
	Local cd:COMPATIBILITY_DATA = COMPATIBILITY_DATA( compatibility_map.ValueForKey( key.toLower() ))
	If cd
		cd = cd.clone()
		If cd.inherits_from Then cd.inherit( get_compatibility( cd.inherits_from ))
	End If
	Return cd
End Function
'________________________________
Function get_level:LEVEL( key$, copy% = True ) 'returns read-only reference
	Local lev:LEVEL = LEVEL( level_map.ValueForKey( key.toLower() ))
	'If copy Then Return ...
	Return lev
End Function


'________________________________
Function get_inventory_object_cost%( item_type$, item_key$ )
	Select item_type
		Case "chassis"
			Local cmp_ag:COMPLEX_AGENT = get_player_chassis( item_key )
			If cmp_ag Then Return cmp_ag.cash_value ..
			Else Return 0
		Case "turret"
			Local tur:TURRET = get_turret( item_key )
			If tur Then Return tur.cash_value ..
			Else Return 0
		Default
			Return 0
	End Select
End Function

'_____________________________________________________________________________
Function load_assets%()
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
					load_objects( asset_json, source_file )
				End If
			Else
				global_error_message :+ "file could not be opened for read."
				load_error()
			End If
		Next
		DebugLog( "~n~n" )
		Return True
	End If
	Return False
End Function
'______________________________________________________________________________
Function load_objects%( json:TJSON, source_file$ = Null )
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

Global global_error_message$
Function load_error()
	DebugLog "      ERROR: " + global_error_message
	If global_error_message Then Notify( "ERROR: " + global_error_message, True )
	End
End Function

'______________________________________________________________________________
Function get_keys$[]( map:TMap )
	Local list:TList = CreateList()
	Local size% = 0
	For Local key$ = EachIn MapKeys( map )
		list.AddLast( key )
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
	Return LoadImageFont( path, size, SMOOTHFONT )
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
	this_json.SetByName( "show_ai_menu_game", TJSONBoolean.Create( show_ai_menu_game ))
	this_json.SetByName( "retain_particles", TJSONBoolean.Create( retain_particles ))
	this_json.SetByName( "active_particle_limit", TJSONNumber.Create( active_particle_limit ))
	this_json.SetByName( "ip_address", TJSONString.Create( ip_address ))
	this_json.SetByName( "port", TJSONNumber.Create( ip_port ))
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
Function save_autosave( profile_path$ ) 'new bug!
	Local file:TStream, json:TJSON
	json = TJSON.Create( New TJSONObject )
	json.SetValue( "autosave", TJSONString.Create( profile_path ))
	file = WriteFile( autosave_path )
	If file
		json.Write( file )
		file.Close()
	End If
End Function

Function unfilter_image:TImage( img:TImage )
	If Not img Then Return Null
	Local new_img:TImage = LoadImage( img.pixmaps[0], 0 )'img.flags&(~MIPMAPPEDIMAGE) )
	SetImageHandle( new_img, img.handle_x, img.handle_y )
	Return new_img
End Function

