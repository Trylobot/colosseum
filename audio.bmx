Rem
	audio.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "flags.bmx"
Import "settings.bmx"
Import "misc.bmx"
Import "base_data.bmx"

'______________________________________________________________________________
'Audio
Global audio_channels:TList = CreateList()
Global bg_music:TChannel
Global engine_start:TChannel
Global engine_idle:TChannel
Global engine_start_ts%
Global last_known_player_speed#

Function play_sound( sound:TSound, volume# = 1.0, pitch_variance# = 0.0 )
	If sound <> Null
		Local channel:TChannel = AllocChannel()
		sound.Cue( channel )
		channel.SetVolume( volume )
		channel.SetRate( Rnd( 1.0 - pitch_variance, 1.0 + pitch_variance ))
		ResumeChannel( channel )
		audio_channels.AddLast( channel )
	End If
End Function

Function play_all_audio()
	'background music
	If bg_music = Null
		bg_music = AllocChannel()
		CueSound( get_sound( "bgm" ), bg_music )
		bg_music.SetVolume( 0.5 )
	End If
	If bg_music_enabled
		ResumeChannel( bg_music )
	Else 'Not FLAG_bg_music_on
		PauseChannel( bg_music )
	End If
	'player engine sounds
	If Not FLAG.in_menu
		If FLAG.engine_ignition
			start_player_engine()
		End If
		tweak_engine_idle( last_known_player_speed )
	Else If engine_idle 'FLAG.in_menu
		SetChannelVolume( engine_idle, 0 )
	End If
	'maintenance
	For Local channel:TChannel = EachIn audio_channels
		If Not channel.Playing()
			channel.Stop()
			audio_channels.Remove( channel )
		End If
	Next
End Function

Function start_player_engine()
	If engine_start <> Null
		StopChannel( engine_start )
		engine_start = Null
	End If
	engine_start = AllocChannel()
	CueSound( get_sound( "engine_start" ), engine_start )
	SetChannelVolume( engine_start, 0.5 )
	ResumeChannel( engine_start )
	FLAG.engine_ignition = False 'game.player_engine_ignition = False
End Function

Function tweak_engine_idle( entity_speed# )
	If Not FLAG.engine_running 'game.player_engine_running	
		If engine_start <> Null
			If Not ChannelPlaying( engine_start )
				FLAG.engine_running = True 'game.player_engine_running = True
			End If
		End If
		If engine_idle <> Null
			StopChannel( engine_idle )
			engine_idle = Null
		End If
	End If
	If FLAG.engine_running 'game.player_engine_running
		If engine_start <> Null
			If Not ChannelPlaying( engine_start )
				'stop engine_start
				StopChannel( engine_start )
				engine_start = Null
				'start engine_idle
				engine_idle = AllocChannel()
				CueSound( get_sound( "engine_idle_loop" ), engine_idle )
				SetChannelVolume( engine_idle, 0.5 )
				ResumeChannel( engine_idle )
				engine_start_ts = now()
			End If
		End If
		If engine_start = Null
			If engine_idle = Null
				'start engine_idle
				engine_idle = AllocChannel()
				CueSound( get_sound( "engine_idle_loop" ), engine_idle )
				ResumeChannel( engine_idle )
				engine_start_ts = now()
			End If
			Local factor# = 10000.0/(Float(now() - engine_start_ts) + 10000.0)
			SetChannelVolume( engine_idle, factor * (0.5 + ( 0.5 * (entity_speed / 2.0))) )
			SetChannelRate( engine_idle, 1.0 + (entity_speed / 2.0) )
		End If
	End If
End Function

