Rem
	instaquit.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "base_data.bmx"
'Import "misc.bmx"
'Import "flags.bmx"
'Import "settings.bmx"
'Import "draw_misc.bmx"

'______________________________________________________________________________
'Instaquit: quit instantly from anywhere, just hold ESC for a few seconds
Global esc_held% = False
Global esc_press_ts% = now()
Global esc_held_progress_bar_show_time_required% = 200
Global instaquit_time_required% = 1000

Function escape_key_release%()
	Return (Not KeyDown( KEY_ESCAPE ) And esc_held)
End Function

Function escape_key_update()
	If FLAG.instaquit_plz Then Return 'no questions asked
	'instaquit
	If esc_held And (now() - esc_press_ts) >= instaquit_time_required
		FLAG.instaquit_plz = True
	End If
	'escape key state
	If KeyDown( KEY_ESCAPE )
		If Not esc_held
			esc_press_ts = now()
		End If
		esc_held = True
	Else
		esc_held = False
	End If
End Function

'______________________________________________________________________________
Function draw_instaquit_progress()
	SetOrigin( 0, 0 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	Local alpha_multiplier# = time_alpha_pct( esc_press_ts + esc_held_progress_bar_show_time_required, esc_held_progress_bar_show_time_required )
	SetAlpha( 0.5 * alpha_multiplier )
	SetColor( 0, 0, 0 )
	DrawRect( 0,0, window_w,window_h )
	SetAlpha( 1.0 * alpha_multiplier )
	SetColor( 255, 255, 255 )
	draw_percentage_bar( 100,window_h/2-25, window_w-200,50, Float( now() - esc_press_ts ) / Float( instaquit_time_required - 50 ),,,,,,, 2 )
	Local str$ = "continue holding ESC to quit"
	'SetImageFont( get_font( "consolas_bold_24" ))
	Local fg:BMP_FONT = get_bmp_font( "arcade_14" )
	Local bg:BMP_FONT = get_bmp_font( "arcade_14_outline" )
	'DrawText_with_outline( str, window_w/2-TextWidth( str )/2, window_h/2+30 )
	Local x% = window_w/2 - fg.width( str )/2
	Local y% = window_h/2 + 35
	draw_layered_string( str, x, y, fg, bg, 0,0,0, 255,255,255 )
End Function

