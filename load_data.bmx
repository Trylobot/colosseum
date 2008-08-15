Rem
	load_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global data_path_prefix$ = "data/"
Global font_path_prefix$ = "fonts/"
Global audio_path_prefix$ = "sound/"
Global image_path_prefix$ = "art/"

Global file_paths:TList = CreateList()
Global font_map:TMap = CreateMap()
Global img_map:TMap = CreateMap()

Const DIRECTIVE_LOAD_FILE$ = "[load_data]"
Const DIRECTIVE_ADD_FONT$ = "[add_font]"
Const DIRECTIVE_ADD_IMAGE$ = "[add_image]"

'______________________________________________________________________________
Function load_all()
	load_base()
	For Local path$ = EachIn file_paths
		load_file( path )
	Next
End Function
'______________________________________________________________________________
Function get_font:TImageFont( key$ )
	Return TImageFont( font_map.ValueForKey( key ))
End Function
'______________________________________________________________________________
Function is_directive%( str$ )
  Return str.StartsWith( "[" ) And str.EndsWith( "]" )
End Function

Function is_comment%( str$ )
  Return str.StartsWith( ";" )
End Function
'______________________________________________________________________________
Function load_base()
  Local line$, directive$, token$[], variable$, value$ 
  Local path$
  
  Local base:TStream = ReadFile( data_path_prefix + "base.ini" )
  If Not base Then DebugLog( " error: base.ini not found." )
  While Not Eof( base )
    line = ((ReadLine( base )).Trim()).ToLower()
    If (Not is_comment( line )) And is_directive( line )
      directive = line
      Select directive
        Case DIRECTIVE_LOAD_FILE
          line = ((ReadLine( base )).Trim()).ToLower()
          If is_directive( line ) Then DebugLog( " base.ini "+directive+" -> error: 0 variables found of 1 variables required." )
          token = line.Split( "=" )
          variable = token[0].Trim()
          value = token[1].Trim()
          Select variable
            Case "path$"
              path = value
              file_paths.AddLast( path )
			      Default
			        DebugLog( " base.ini -> error: "+variable+" is not a recognized variable for this directive." )
          End Select
        Default
          DebugLog( " base.ini -> error: "+directive+" is not a recognized directive." )
      End Select
    End If
  End While
  CloseStream( base )
End Function
'______________________________________________________________________________
Function load_file( file_path$ )
  Local line$, directive$, result$
  
  Local file:TStream = ReadFile( file_path )
  While Not Eof( file )
    line = ((ReadLine( file )).Trim()).ToLower()
    If (Not is_comment( line )) And is_directive( line )
      directive = line
      Select directive
				Case DIRECTIVE_ADD_FONT
					result = add_font( file, font_map )
					If result <> "success" Then DebugLog( " "+StripDir( file_path )+" "+directive+" -> "+result )
        Case DIRECTIVE_ADD_IMAGE
          result = add_image( file, img_map )
          If result <> "success" Then DebugLog( " "+StripDir( file_path )+" "+directive+" -> "+result )
        Default
          DebugLog( " "+StripDir( file_path )+" -> error: "+directive+" is not a recognized directive." )
      End Select
    End If
  End While
  CloseStream( file )
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
  map.Insert( StripAll( path )+"_"+size, font )
  
  Return "success"
End Function
'______________________________________________________________________________
Function add_image$( file:TStream, map:TMap )
  Local line$, token$[], variable$, value$
  Local img:TImage, path$, handle_x#, handle_y#, filtered%, mipmapped%, dynamic%
  Local variable_count% = 6

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
			Case "filtered%"
				filtered = value.ToInt()
			Case "mipmapped%"
				mipmapped = value.ToInt()
			Case "dynamic%"
				dynamic = value.ToInt()
      Default
        Return "error: "+variable+" is not a recognized variable for this directive."
    End Select
  Next
  img = LoadImage( path, (filtered & FILTEREDIMAGE) | (mipmapped & MIPMAPPEDIMAGE) | (dynamic & DYNAMICIMAGE) )
  SetImageHandle( img, handle_x, handle_y )
  map.Insert( StripAll( path ), img )
  
  Return "success"
End Function

'______________________________________________________________________________
'Sounds
Global bg_music_victory_8_bit:TSound = LoadSound( audio_path_prefix + "victory_8-bit.ogg", SOUND_LOOP )
Global bg_music:TChannel = AllocChannel()
CueSound( bg_music_victory_8_bit, bg_music )

Global snd_engine_start:TSound = LoadSound( audio_path_prefix + "engine_start.ogg" )
Global snd_engine_idle_loop:TSound = LoadSound( audio_path_prefix + "engine_idle_loop.ogg", SOUND_LOOP )

Global snd_cannon_fire:TSound = LoadSound( audio_path_prefix + "cannon.ogg" )
Global snd_mgun_turret_fire:TSound = LoadSound( audio_path_prefix + "mgun.ogg" )
Global snd_laser_fire:TSound = LoadSound( audio_path_prefix + "laser.ogg" )
Global snd_cannon_hit:TSound = LoadSound( audio_path_prefix + "cannon_hit.ogg" )
Global snd_mgun_hit:TSound = LoadSound( audio_path_prefix + "mgun_hit.ogg" )
Global snd_laser_hit:TSound = LoadSound( audio_path_prefix + "laser_hit.ogg" )

'______________________________________________________________________________
'Images
AutoImageFlags( FILTEREDIMAGE | MIPMAPPEDIMAGE )

Function LoadImage_SetHandle:TImage( path$, x# = 0, y# = 0 )
	Local img:TImage = LoadImage( image_path_prefix + path )
	SetImageHandle( img, x, y )
	Return img
End Function
Function LoadAnimImage_SetHandle:TImage( path$, x# = 0, y# = 0, w# = 1, h# = 1, frames% = 1 )
	Local img:TImage = LoadAnimImage( image_path_prefix + path, w, h, 0, frames )
	SetImageHandle( img, x, y )
	Return img
End Function

Global img_player_tank_chassis:TImage = LoadImage_SetHandle( "player_tank_chassis.png", 12.5, 9.5 )
Global img_light_tank_track:TImage = LoadAnimImage_SetHandle( "light_tank_track.png", 12.5, 9.5, 25, 11, 8 )
Global img_player_tank_turret_base:TImage = LoadImage_SetHandle( "player_tank_turret_base.png", 6.5, 6.5 )
Global img_player_tank_turret_barrel:TImage = LoadImage_SetHandle( "player_tank_turret_barrel.png", 3.5, 3.5 )
Global img_player_mgun_turret:TImage = LoadImage_SetHandle( "player_tank_mgun_turret.png", 3.5, 3.5 )
Global img_player_tank_chassis_med:TImage = LoadImage_SetHandle( "player_tank_chassis_med.png", 16.5, 11.5 )
Global img_player_med_tank_track:TImage = LoadAnimImage_SetHandle( "med_tank_track.png", 16.5, 11.5, 33, 12, 8 )
Global img_player_tank_turret_med_base_right:TImage = LoadImage_SetHandle( "player_tank_turret_med_base_right.png", 7.5, 11.5 )
Global img_player_tank_turret_med_base_left:TImage = LoadImage_SetHandle( "player_tank_turret_med_base_left.png", 7.5, 11.5 )
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
Global img_rocket:TImage = LoadImage_SetHandle( "rocket.png", 13.5, 5.5 )

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
Global img_icon_music_note:TImage = LoadImage_SetHandle( "icon_music_note.png", 0, 0 )
Global img_icon_speaker_on:TImage = LoadImage_SetHandle( "icon_speaker_on.png", 0, 0 )
Global img_icon_speaker_off:TImage = LoadImage_SetHandle( "icon_speaker_off.png", 0, 0 )
Global img_icon_player_cannon_ammo:TImage = LoadImage_SetHandle( "icon_player_cannon_ammo.png", 0, 0 )

Global img_door:TImage = LoadImage_SetHandle( "door.png", 1, 7 )
Global img_reticle:TImage = LoadImage_SetHandle( "reticle.png", 22.5, 2.5 )



