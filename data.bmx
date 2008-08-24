Rem
	data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
global data_file_suffix$ = ".ini"
Global data_path_prefix$ = "data/"
Global user_path_prefix$ = "user/"
Global loaded_pct# = 0.00

Global font_map:TMap = CreateMap()
Global sound_map:TMap = CreateMap()
Global image_map:TMap = CreateMap()
Global level_map:TMap = CreateMap()
Global particle_prototype_map:TMap = CreateMap()
Global particle_emitter_prototype_map:TMap = CreateMap()
Global projectile_prototype_map:TMap = CreateMap()
Global projectile_launcher_prototype_map:TMap = CreateMap()
Global widget_prototype_map:TMap = CreateMap()
Global pickup_prototype_map:TMap = CreateMap()
Global turret_prototype_map:TMap = CreateMap()
Global complex_agent_prototype_map:TMap = CreateMap()

Const DIRECTIVE_LOAD_FILE$ = "[load_data]"
Const DIRECTIVE_LOAD_CONFIG$ = "[load_config]"

Const DIRECTIVE_ADD_FONT$ = "[add_font]"
Const DIRECTIVE_ADD_SOUND$ = "[add_sound]"
Const DIRECTIVE_ADD_IMAGE$ = "[add_image]"
Const DIRECTIVE_ADD_LEVEL$ = "[add_level]"
Const DIRECTIVE_ADD_MULTI_FRAME_IMAGE$ = "[add_multi_frame_image]"
Const DIRECTIVE_ADD_PARTICLE_PROTOTYPE$ = "[add_particle]"
Const DIRECTIVE_ADD_PARTICLE_EMITTER_PROTOTYPE$ = "[add_particle_emitter]"
Const DIRECTIVE_ADD_PROJECTILE_PROTOTYPE$ = "[add_projectile]"
Const DIRECTIVE_ADD_PROJECTILE_LAUNCHER_PROTOTYPE$ = "[add_projectile_emitter]"
Const DIRECTIVE_ADD_WIDGET_PROTOTYPE$ = "[add_widget]"
Const DIRECTIVE_ADD_PICKUP_PROTOTYPE$ = "[add_pickup]"
Const DIRECTIVE_ADD_TURRET_PROTOTYPE$ = "[add_turret]"
Const DIRECTIVE_ADD_COMPLEX_AGENT_PROTOTYPE$ = "[add_complex_agent]"

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

Function get_level:LEVEL( key$ )
	Return LEVEL( level_map.ValueForKey( key ))
End Function
'______________________________________________________________________________
Function is_directive%( str$ )
  Return str.StartsWith( "[" ) And str.EndsWith( "]" )
End Function

Function is_comment%( str$ )
  Return str.StartsWith( ";" )
End Function

'______________________________________________________________________________
Function load_data_files()
  Local line$, directive$, token$[], variable$, value$
  Local path$
  Local file_paths:TList = CreateList()

  Local base:TStream = ReadFile( data_path_prefix + "base.ini" )
  If Not base Then append_load_data_error( " error: base.ini not found." )
  While Not Eof( base )
    line = ((ReadLine( base )).Trim()).ToLower()
    If (Not is_comment( line )) And is_directive( line )
      directive = line
      Select directive
        Case DIRECTIVE_LOAD_FILE
          line = ((ReadLine( base )).Trim()).ToLower()
          If is_directive( line ) Then append_load_data_error( " base.ini "+directive+" -> error: 0 variables found of 1 variables required." )
          token = line.Split( "=" )
          variable = token[0].Trim()
          value = token[1].Trim()
          Select variable
            
						Case "path$"
              path = value
              file_paths.AddLast( path )
			      
						Default
			        append_load_data_error( " base.ini -> error: "+variable+" is not a recognized variable for this directive." )
          End Select
        Default
          append_load_data_error( " base.ini -> error: "+directive+" is not a recognized directive." )
      End Select
    End If
  End While
  CloseStream( base )
	
	Local result$
	For Local file$ = EachIn file_paths
		result = load_file( file )
		If result <> "success" Then append_load_data_error( " "+StripDir( file )+" -> "+result )
	Next
	
	output_load_data_errors()
End Function
'______________________________________________________________________________
Global load_data_errors$ = ""

Function append_load_data_error( error_str$ )
	load_data_errors :+ error_str + "~n"
End Function

Function output_load_data_errors()
	If load_data_errors.Length > 0
		DebugLog load_data_errors
		Notify load_data_errors
	End If
End Function
'______________________________________________________________________________
'[ LOAD ] functions
Function load_file$( file_path$ )
  Local line$, directive$, result$
  
  Local file:TStream = ReadFile( file_path )
  While Not Eof( file )
		result = "success"
    line = ((ReadLine( file )).Trim()).ToLower()
    If (Not is_comment( line )) And is_directive( line )
      directive = line
      Select directive
				
				Case DIRECTIVE_ADD_FONT
					result = add_font( file, font_map )
				Case DIRECTIVE_ADD_SOUND
					result = add_sound( file, sound_map )
        Case DIRECTIVE_ADD_IMAGE
          result = add_image( file, image_map, False )
				Case DIRECTIVE_ADD_MULTI_FRAME_IMAGE
					result = add_image( file, image_map, True )
        
				Default
          result = "error: "+directive+" is not a recognized directive."
      End Select
			If result <> "success" Then Return result
    End If
  End While
  CloseStream( file )
	
	Return "success"
End Function
'______________________________________________________________________________
Function add_font$( file:TStream, map:TMap )
  Local line$, token$[], variable$, value$
  Local font:TImageFont, path$, size%
  Local variable_count% = 2

  For Local i% = 0 To variable_count - 1
		If Eof( file ) Then Return "error: "+i+" variables found of "+variable_count+" variables required."
    line = ((ReadLine( file )).Trim()).ToLower()
    If is_directive( line ) Then Return "error: "+i+" variables found of "+variable_count+" variables required."
    token = line.Split( "=" )
    variable = token[0].Trim()
    value = token[1].Trim()
    Select variable
      
			Case "path$"
        path = value
      Case "size%"
        size = value.ToInt()
      
			Default
        Return "error: "+variable+" is not a recognized variable for this directive."
    End Select
  Next
  
	font = LoadImageFont( path, size, SMOOTHFONT )
	If font = Null Then Return "error: "+StripDir( path )+" could not be loaded."
  map.Insert( StripAll( path )+"_"+size, font )
  
  Return "success"
End Function
'______________________________________________________________________________
Function add_sound$( file:TStream, map:TMap )
  Local line$, token$[], variable$, value$
  Local sound:TSound, path$, looped%
  Local variable_count% = 2

  For Local i% = 0 To variable_count - 1
		If Eof( file ) Then Return "error: "+i+" variables found of "+variable_count+" variables required."
    line = ((ReadLine( file )).Trim()).ToLower()
    If is_directive( line ) Then Return "error: "+i+" variables found of "+variable_count+" variables required."
    token = line.Split( "=" )
    variable = token[0].Trim()
    value = token[1].Trim()
		Select variable
      
			Case "path$"
        path = value
      Case "looped@"
        looped = string_to_boolean( value )
      
			Default
        Return "error: "+variable+" is not a recognized variable for this directive."
    End Select
  Next
  
	sound = LoadSound( path, (looped & SOUND_LOOP) )
	If sound = Null Then Return "error: "+StripDir( path )+" could not be loaded."
  map.Insert( StripAll( path ), sound )
  
  Return "success"
End Function
'______________________________________________________________________________
Function add_image$( file:TStream, map:TMap, multi_frame% = False )
  Local line$, token$[], variable$, value$
  Local img:TImage, path$, handle_x#, handle_y#, cell_width%, cell_height%, cell_count%, filtered%, mipmapped%, dynamic%
  Local variable_count% = 6
	If multi_frame
		variable_count :+ 3
	End If

  For Local i% = 0 To variable_count - 1
		If Eof( file ) Then Return "error: "+i+" variables found of "+variable_count+" variables required."
    line = ((ReadLine( file )).Trim()).ToLower()
    If is_directive( line ) Then Return "error: "+i+" variables found of "+variable_count+" variables required."
    token = line.Split( "=" )
    variable = token[0].Trim()
    value = token[1].Trim()
    Select variable
      
			Case "path$"
        path = value
      Case "handle_x#"
        handle_x = value.ToFloat()
      Case "handle_y#"
        handle_y = value.ToFloat()
      Case "cell_width%"
        cell_width = value.ToInt()
      Case "cell_height%"
        cell_height = value.ToInt()
      Case "cell_count%"
        cell_count = value.ToInt()
			Case "filtered@"
				filtered = string_to_boolean( value )
			Case "mipmapped@"
				mipmapped = string_to_boolean( value )
			Case "dynamic@"
				dynamic = string_to_boolean( value )
      
			Default
        Return "error: "+variable+" is not a recognized variable for this directive."
    End Select
  Next
  
	If multi_frame
		img = LoadAnimImage( path, cell_width, cell_height, 0, cell_count, (filtered & FILTEREDIMAGE) | (mipmapped & MIPMAPPEDIMAGE) | (dynamic & DYNAMICIMAGE) )
	else
		img = LoadImage( path, (filtered & FILTEREDIMAGE) | (mipmapped & MIPMAPPEDIMAGE) | (dynamic & DYNAMICIMAGE) )
	End If
	If img = Null Then Return "error: "+StripDir( path )+" could not be loaded."
  SetImageHandle( img, handle_x, handle_y )
  map.Insert( StripAll( path ), img )
  
  Return "success"
End Function

'______________________________________________________________________________
'[ SAVE ] functions
Function make_filename$( str$ ) 'this needs to replace invalid characters with valid ones
	Return str
End Function

Function save_level_to_file%( lev:LEVEL, filename$ = "" )
	If filename = "" Then filename = make_filename( lev.name ) + data_file_suffix
	CreateDir( user_path_prefix ) 'guarantees the existence of the required path
	Local file:TStream = WriteFile( user_path_prefix + filename )
	
	
	
'	file.WriteLine( DIRECTIVE_ADD_LEVEL )
'	file.WriteLine( "name$ = "+lev.name )
'	file.WriteLine( "width% = "+lev.width )
'	file.WriteLine( "height% = "+lev.height )
'	file.WriteLine( "row_count% = "+lev.row_count )
'	file.WriteLine( "col_count% = "+lev.col_count )
'	file.WriteLine( "horizontal_divs%[] = "+serialize_Int_array( lev.horizontal_divs ))
'	file.WriteLine( "vertical_divs%[] = "+serialize_Int_array( lev.vertical_divs ))
'	file.WriteLine( "pathing@[,] = "+serialize_Int_array( lev.pathing ))
'	file.WriteLine( "spawns:List = "+lev.serialize_spawns() )
'	file.WriteLine( "squads:List = "+lev.serialize_squads() )
'	file.WriteLine( "" )
	
	CloseStream( file )
End Function

Function save_screenshot_to_file( screen:TImage, filename$ = "" )
	
End Function

'______________________________________________________________________________
Function load_all_archetypes()
	set_particle_archetypes()
	set_particle_emitter_archetypes()
	set_projectile_archetypes()
	set_projectile_launcher_archetypes()
	set_widget_archetypes()
	set_pickup_archetypes()
	set_turret_barrel_archetypes()
	set_turret_archetypes()
	set_complex_agent_archetypes()
End Function
'______________________________________________________________________________
Function load_environment()
	'attach door widgets To every spawn point
	For Local spawn:POINT = EachIn friendly_spawn_points
		attach_door( spawn, friendly_door_list )
	Next
	friendly_doors_status = DOOR_STATUS_CLOSED
	For Local spawn:POINT = EachIn enemy_spawn_points
		attach_door( spawn, hostile_door_list )
	Next
	hostile_doors_status = DOOR_STATUS_CLOSED
End Function

'##############################################################################
'Images
AutoImageFlags( FILTEREDIMAGE | MIPMAPPEDIMAGE )

Function LoadImage_SetHandle:TImage( path$, x# = 0, y# = 0 )
	Local img:TImage = LoadImage( "art/" + path )
	SetImageHandle( img, x, y )
	Return img
End Function
Function LoadAnimImage_SetHandle:TImage( path$, x# = 0, y# = 0, w# = 1, h# = 1, frames% = 1 )
	Local img:TImage = LoadAnimImage( "art/" + path, w, h, 0, frames )
	SetImageHandle( img, x, y )
	Return img
End Function

Global img_player_tank_chassis:TImage = LoadImage_SetHandle( "player_tank_chassis.png", 11.5, 6.5 )
Global img_light_tank_track:TImage = LoadAnimImage_SetHandle( "light_tank_track.png", 12.5, 3, 25, 6, 8 )
Global img_player_tank_turret_base:TImage = LoadImage_SetHandle( "player_tank_turret_base.png", 6.5, 6.5 )
Global img_player_tank_turret_barrel:TImage = LoadImage_SetHandle( "player_tank_turret_barrel.png", 3.5, 3.5 )
Global img_player_mgun_turret:TImage = LoadImage_SetHandle( "player_tank_mgun_turret.png", 3.5, 3.5 )
Global img_player_tank_chassis_med:TImage = LoadImage_SetHandle( "player_tank_chassis_med.png", 16.5, 11.5 )
Global img_player_med_tank_track:TImage = LoadAnimImage_SetHandle( "med_tank_track.png", 16.5, 4, 33, 8, 8 )
Global img_player_tank_turret_med_base:TImage = LoadImage_SetHandle( "player_tank_turret_med_base.png", 7.5, 11.5 )
Global img_player_tank_turret_med_barrel_right:TImage = LoadImage_SetHandle( "player_tank_turret_med_barrel_right.png", 7.5, 11.5 )
Global img_player_tank_turret_med_barrel_left:TImage = LoadImage_SetHandle( "player_tank_turret_med_barrel_left.png", 7.5, 11.5 )
Global img_player_tank_turret_med_mgun_barrel:TImage = LoadImage_SetHandle( "player_tank_med_mgun_turret_barrel.png", 7.5, 11.5 )
Global img_laser_turret:TImage = LoadImage_SetHandle( "laser_turret_base-barrel.png", 6.5, 6.5 )

Global img_box:TImage = LoadImage_SetHandle( "box.png", 8.5, 8.5 )
Global img_enemy_stationary_emplacement_1_chassis:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-1_chassis.png", 13.5, 13.5 )
Global img_enemy_stationary_emplacement_1_turret_base:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-1_turret-base.png", 11.5, 11.5 )
Global img_enemy_stationary_emplacement_1_turret_barrel:TImage = LoadImage_SetHandle( "enemy_stationary-emplacement-1_turret-barrel.png", 11.5, 11.5 )
Global img_enemy_stationary_emplacement_2_turret_barrel:TImage = LoadImage_SetHandle( "enemy_machine-gun_emplacement_turret-barrel.png", 2.5, 2.5 )
Global img_nme_mobile_bomb:TImage = LoadImage_SetHandle( "nme_mobile_bomb.png", 7.5, 7.5 )
Global img_limb:TImage = LoadImage_SetHandle( "limb.png", 2.5, 3.5 )
Global img_enemy_quad_chassis:TImage = LoadImage_SetHandle( "enemy_quad_chassis.png", 9.5, 7.5 )
Global img_enemy_light_mgun_turret_base:TImage = LoadImage_SetHandle( "enemy_light_mgun_turret_base.png", 3.5, 2.5 )
Global img_enemy_light_mgun_turret_barrel:TImage = LoadImage_SetHandle( "enemy_light_mgun_turret_barrel.png", 3.5, 2.5 )

Global img_muzzle_flash:TImage = LoadImage_SetHandle( "muzzle_flash.png", 0.5, 12.5 )
Global img_mgun_muzzle_flash:TImage = LoadImage_SetHandle( "mgun_muzzle_flash.png", 0.5, 7.5 )
Global img_muzzle_smoke:TImage = LoadImage_SetHandle( "muzzle_smoke.png", 15.5, 15.5 )
Global img_mgun_muzzle_smoke:TImage = LoadImage_SetHandle( "mgun_muzzle_smoke.png", 8.5, 8.5 )
Global img_mgun_shell_casing:TImage = LoadImage_SetHandle( "mgun_shell_casing.png", 3.5, 2.5 )
Global img_projectile_shell_casing:TImage = LoadImage_SetHandle( "projectile_shell_casing.png", 5.5, 3.5 )
Global img_rocket_thrust:TImage = LoadImage_SetHandle( "rocket_thrust.png", 16.5, 6.5 )
Global img_halo:TImage = LoadImage_SetHandle( "halo.png", 100, 100 )
Global img_spark:TImage = LoadImage_SetHandle( "spark.png", 0.5, 2.5 )
Global img_laser_muzzle_flare:TImage = LoadImage_SetHandle( "laser_muzzle_flare.png", 1.5, 7.5 )
Global img_circle:TImage = LoadImage_SetHandle( "white_circle.png", 25, 25 )

Global img_projectile:TImage = LoadImage_SetHandle( "projectile.png", 6.5, 3.5 )
Global img_mgun:TImage = LoadImage_SetHandle( "mgun.png", 4.5, 1.5 )
Global img_laser:TImage = LoadImage_SetHandle( "laser.png", 13.5, 2.5 )
Global img_rocket:TImage = LoadImage_SetHandle( "rocket.png", 10.5, 3.5 )

Global img_debris:TImage = LoadAnimImage_SetHandle( "debris.png", 2.5, 2.5, 5, 5, 5 )
Global img_trail:TImage = LoadAnimImage_SetHandle( "trail.png", 2.5, 3.5, 4, 7, 5 )
Global img_box_gib:TImage = LoadAnimImage_SetHandle( "box_gib.png", 8.5, 8.5, 17, 17, 6 )
Global img_tower_gibs:TImage = LoadAnimImage_SetHandle( "tower_gibs.png", 11.5, 11.5, 23, 23, 11 )
Global img_bomb_gibs:TImage = LoadAnimImage_SetHandle( "bomb_gibs.png", 7.5, 7.5, 15, 15, 7 )
Global img_quad_gibs:TImage = LoadAnimImage_SetHandle( "quad_gibs.png", 9.5, 7.5, 19, 15, 9 )
Global img_stickies:TImage = LoadAnimImage_SetHandle( "stickies.png", 7.5, 7.5, 16, 16, 5 )
Global img_glow:TImage = LoadImage_SetHandle( "glow.png", 7.5, 7.5 )

Global img_pickup_ammo_main_5:TImage = LoadImage_SetHandle( "pickup_ammo_main_5.png", 16, 9 )
Global img_pickup_health:TImage = LoadImage_SetHandle( "pickup_health.png", 16, 9 )
Global img_pickup_cooldown:TImage = LoadImage_SetHandle( "pickup_cooldown.png", 16, 9 )

Global img_help_kb:TImage = LoadImage_SetHandle( "help_kb.png", 0, 0 )
Global img_help_kb_mouse:TImage = LoadImage_SetHandle( "help_kb_and_mouse.png", 0, 0 )
Global img_arena_bg:TImage = LoadImage_SetHandle( "bg.png", 0, 0 )
Global img_arena_fg:TImage = LoadImage_SetHandle( "fg.png", 0, 0 )
Global img_walls_border:TImage = LoadImage_SetHandle( "walls_border.png", 0, 0 )
Global img_walls_inner:TImage = LoadImage_SetHandle( "walls_inner.png", 0, 0 )
Global img_icon_music_note:TImage = LoadImage_SetHandle( "icon_music_note.png", 0, 0 )
Global img_icon_speaker_on:TImage = LoadImage_SetHandle( "icon_speaker_on.png", 0, 0 )
Global img_icon_speaker_off:TImage = LoadImage_SetHandle( "icon_speaker_off.png", 0, 0 )
Global img_icon_player_cannon_ammo:TImage = LoadImage_SetHandle( "icon_player_cannon_ammo.png", 0, 0 )
Global img_shine:TImage = LoadImage_SetHandle( "bar_shine.png", 15, 0 )

Global img_door:TImage = LoadImage_SetHandle( "door.png", 1, 7 )
Global img_reticle:TImage = LoadImage_SetHandle( "reticle.png", 22.5, 2.5 )



