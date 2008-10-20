Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Generic globals
Const INFINITY% = -1
Const UNSPECIFIED% = -1
Const PICKUP_PROBABILITY# = 0.50 'chance of an enemy dropping a pickup (randomly selected from all pickups)
Const arena_lights_fade_time% = 1000
Global level_intro_time% = 2000

'environmental objects
Global mouse:cVEC = New cVEC
Global mouse_delta:cVEC = New cVEC
Global main_game:ENVIRONMENT 'game in which player participates
Global ai_menu_game:ENVIRONMENT 'menu ai demo environment
Global game:ENVIRONMENT 'current game environment
Global profile:PLAYER_PROFILE = New PLAYER_PROFILE
Global level_editor_cache:LEVEL = Null
	
'app state flags
Global FLAG_in_menu% = True
Global FLAG_game_loaded% = False
Global FLAG_in_shop% = False
Global FLAG_bg_music_on% = False
Global FLAG_no_sound% = False
Global FLAG_draw_help% = False
Global FLAG_console% = False

'______________________________________________________________________________
Type PLAYER_PROFILE
	Field profile_name$
	Field inventory%[]
	Field input_method%
	Field current_level$
	Field cash%
	Field kills%
	
	Method New()
		input_method = INPUT_KEYBOARD_MOUSE_HYBRID
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		
		
		this_json.SetByName( "input_method", TJSONNumber.Create( input_method ))
		this_json.SetByName( "current_level", TJSONString.Create( current_level ))
		this_json.SetByName( "cash", TJSONNumber.Create( cash ))
		this_json.SetByName( "kills", TJSONNumber.Create( kills ))
		Return this_json
	End Method
End Type

Function Create_PLAYER_PROFILE_from_json:PLAYER_PROFILE( json:TJSON )
	Local prof:PLAYER_PROFILE = New PLAYER_PROFILE
	
	
	prof.input_method = json.GetNumber( "input_method" )
	prof.current_level = json.GetString( "current_level" )
	prof.cash = json.GetNumber( "cash" )
	prof.kills = json.GetNumber( "kills" )
	Return prof
End Function
'______________________________________________________________________________
Function play_level( level_file_path$, player_archetype% )
	main_game = Create_ENVIRONMENT( True )
	Local success% = main_game.load_level( level_file_path )
	If success
		main_game.game_in_progress = True
		Local player:COMPLEX_AGENT = create_player( player_archetype )
		Local player_brain:CONTROL_BRAIN = create_player_brain( player )
		main_game.insert_player( player, player_brain )
		main_game.respawn_player()
		FLAG_in_menu = False
		FLAG_in_shop = False
	Else
		main_game = Null
	End If
End Function
'______________________________________________________________________________
Function create_player:COMPLEX_AGENT( archetype% )
	Return COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype], ALIGNMENT_FRIENDLY ))
End Function
'______________________________________________________________________________
Function create_player_brain:CONTROL_BRAIN( avatar:COMPLEX_AGENT )
	Return Create_CONTROL_BRAIN( avatar, CONTROL_TYPE_HUMAN, profile.input_method )
End Function
'______________________________________________________________________________
Function get_player_id%()
	If game <> Null And game.player <> Null
		Return game.player.id
	Else
		Return -1
	End If
End Function
'______________________________________________________________________________
'Instaquit: quit instantly from anywhere, just hold ESC for a few seconds
Global esc_held% = False, esc_press_ts% = now()
Global esc_held_progress_bar_show_time_required% = 200, instaquit_time_required% = 1000

Function check_instaquit()
	If KeyDown( KEY_ESCAPE ) And Not esc_held
		esc_press_ts = now()
		esc_held = True
	Else If KeyDown( KEY_ESCAPE ) 'esc_held
		If (now() - esc_press_ts) >= esc_held_progress_bar_show_time_required
			draw_instaquit_progress()
		End If
		If (now() - esc_press_ts) >= instaquit_time_required
			End
		End If
	Else
		esc_held = False
	End If
End Function

Function draw_instaquit_progress()
	Local alpha_multiplier# = time_alpha_pct( esc_press_ts + esc_held_progress_bar_show_time_required, esc_held_progress_bar_show_time_required )
	
	SetAlpha( 0.5 * alpha_multiplier )
	SetColor( 0, 0, 0 )
	DrawRect( 0,0, window_w,window_h )
	
	SetAlpha( 1.0 * alpha_multiplier )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	draw_percentage_bar( 100,window_h/2-25, window_w-200,50, Float( now() - esc_press_ts ) / Float( instaquit_time_required - 50 ))
	Local str$ = "continue holding ESC to quit"
	SetImageFont( get_font( "consolas_bold_24" ))
	DrawText( str, window_w/2-TextWidth( str )/2, window_h/2+30 )
End Function

