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
	profile.input_method = INPUT_KEYBOARD_MOUSE_HYBRID
Global level_editor_cache:LEVEL = Null
	
'screen state flags
Global FLAG_in_menu% = True
Global FLAG_in_shop% = False
Global FLAG_bg_music_on% = False
Global FLAG_no_sound% = False
Global FLAG_draw_help% = False
Global FLAG_console% = False

'______________________________________________________________________________
Type PLAYER_PROFILE
	Field archetype%
	Field input_method%
	Field current_level$
	Field cash%
	Field kills%
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "archetype", TJSONNumber.Create( archetype ))
		this_json.SetByName( "input_method", TJSONNumber.Create( input_method ))
		this_json.SetByName( "current_level", TJSONString.Create( current_level ))
		this_json.SetByName( "cash", TJSONNumber.Create( cash ))
		this_json.SetByName( "kills", TJSONNumber.Create( kills ))
		Return this_json
	End Method
End Type

Function Create_PLAYER_PROFILE_from_json:PLAYER_PROFILE( json:TJSON )
	Local prof:PLAYER_PROFILE = New PLAYER_PROFILE
	prof.archetype = json.GetNumber( "archetype" )
	prof.input_method = json.GetNumber( "input_method" )
	prof.current_level = json.GetString( "current_level" )
	prof.cash = json.GetNumber( "cash" )
	prof.kills = json.GetNumber( "kills" )
	Return prof
End Function

Function get_player_id%()
	If game <> Null And game.player <> Null
		Return game.player.id
	Else
		Return -1
	End If
End Function
'______________________________________________________________________________
'Global current_level_index% = 0
'Global all_levels:Object[]
Global next_level$

'______________________________________________________________________________
Function core_begin_new_game()
	main_game = Create_ENVIRONMENT( True )
	FLAG_in_menu = False
	game = main_game
	game.clear()
	'current_level_index = -1
	game.load_next_level()
	game.game_in_progress = True
	game.spawn_player( profile.archetype )
End Function

'______________________________________________________________________________
'Quit instantly from anywhere; hold ESC for a few seconds
Global esc_held% = False, esc_press_ts% = now()
Global esc_held_progress_bar_show_time_required% = 200, instaquit_time_required% = 1000

Function check_esc_held()
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

