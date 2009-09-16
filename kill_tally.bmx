Rem
	kill_tally.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "audio.bmx"
Import "draw_misc.bmx"

'______________________________________________________________________________
Function kill_tally( title$, bg:TImage, kills_this_level% )
	SetOrigin( 0, 0 )
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	
	Local continue_msg$ = "press enter to continue"
	Local kills_msg$
	
	Local kills_counted% = 0
	Local begin_ts% = now(), transition_ts% = begin_ts
	Local transition_time# = 400
	Local animating% = True
	Local kill_signal% = False

	FlushKeys()
	FlushMouse()

	play_sound( get_sound( "mgun_hit" ), 1.0 )
	
	Repeat
		Cls()
		draw_fuzzy( bg )
		
		If animating
			If (now() - transition_ts) > transition_time
				If kills_counted < kills_this_level - 1
					kills_counted :+ 1
					If transition_time > 0 Then transition_time = 2016000.0/(5.0*Float(now() - begin_ts) + 4600.0) - 30.0
					play_sound( get_sound( "mgun_hit" ), 0.1 + transition_time/400.0, 0.3333 )
					transition_ts = now()
				Else 'kills_counted >= kills_this_level
					kills_counted = kills_this_level
					animating = False
				End If
			End If
			If (KeyHit( KEY_ENTER ) Or KeyHit( KEY_SPACE ) Or KeyHit( KEY_ESCAPE ) Or MouseHit( 1 ))
				kills_counted = kills_this_level
				animating = False
			End If
		End If
		
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetImageFont( get_font( "consolas_bold_50" ))
		DrawText_with_glow( title, window_w/2 - TextWidth( title )/2, 20 )
		
		SetColor( 212, 64, 64 )
		SetImageFont( get_font( "consolas_bold_24" ))
		If animating
			kills_msg = format_number( kills_counted - 1 )+" kills"
			SetAlpha( time_alpha_pct( begin_ts, transition_time, False ))
			DrawText_with_glow( kills_msg, window_w/2 - TextWidth( kills_msg )/2, 95 )
			SetAlpha( time_alpha_pct( begin_ts - transition_time/2, transition_time, True ))
		Else
			SetAlpha( 1 )
		End If
		kills_msg = format_number( kills_counted )+" kills"
		DrawText_with_glow( kills_msg, window_w/2 - TextWidth( kills_msg )/2, 95 )
		
		If animating
			SetAlpha( time_alpha_pct( begin_ts, transition_time, False ))
			draw_skulls( 20, 140, window_w - 40, kills_counted - 1 )
			SetAlpha( time_alpha_pct( begin_ts - transition_time/2, transition_time, True ))
		Else
			SetAlpha( 1 )
		End If
		draw_skulls( 20, 140, window_w - 40, kills_counted )
		
		SetColor( 212, 64, 64 )
		SetAlpha( 1 )
		SetImageFont( get_font( "consolas_bold_14" ))
		DrawText_with_glow( continue_msg, window_w/2 - TextWidth( continue_msg )/2, window_h - 60 )
		
		Flip()
		
		kill_signal = AppTerminate()
	Until (Not animating And (KeyHit( KEY_ENTER ) Or KeyHit( KEY_SPACE ) Or KeyHit( KEY_ESCAPE ) Or MouseHit( 1 ))) Or kill_signal
	If kill_signal Then End
	
	FlushKeys()
	FlushMouse()
End Function

Function draw_skulls( x%, y%, max_width%, count% )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	Local denominations%[] = [ 1, 5, 25, 250 ]
	Local images:TImage[] = [ ..
		get_image( "skull" ), ..
		get_image( "skull5" ), ..
		get_image( "skull25" ), ..
		get_image( "skull250" )]
	Local skull_count%[4]
	
	Local w% = images[0].width + 2
	'count instances of each denomination
	For Local i% = denominations.Length - 1 To 0 Step -1
		While count >= denominations[i]
			skull_count[i] :+ 1
			count :- denominations[i]
		End While
	Next
	'x = window_w/2 - (skull5_count + skull_count)*w/2
	Local orig_x% = x
	For Local i% = denominations.Length - 1 To 0 Step -1
		If skull_count[i] > 0
			DrawText( pad( String.FromInt(denominations[i]), 3,, True ), x-12, y+10 )
			For Local k% = 0 To skull_count[i] - 1
				If (x + (k + 1)*images[i].width + 2) > window_w - 20
					y :+ images[i].height + 2
				End If
				DrawImage( images[i], 40 + x + k*images[i].width + 2, y )
			Next
			x = orig_x
			y :+ images[i].height + 2
		End If
	Next
End Function


