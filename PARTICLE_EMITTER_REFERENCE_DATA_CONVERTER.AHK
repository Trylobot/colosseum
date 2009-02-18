SetTitleMatchMode 2

F12::
{
	Clipboard = 
	Send {home}+{end}^c{home}
	ClipWait, 2
	
	; class
	class=particle_emitter
	
	; key
	FoundPos := RegExMatch( Clipboard, "get_(projectile_launcher|particle_emitter)\( ""([A-Za-z0-9_]+)"" \)", result )
	StringLower, key_name, result1
	key_name = %key_name%_key
	StringLower, key_value, result2
		
	indent = 
	if( key_name == "projectile_launcher_key" )
		indent := "`t`t`t"
	else if( key_name == "particle_emitter_key" )
		indent := "`t`t`t`t"
	
	; object
	object = 
	
	; argument names
	arg_names = offset_x,offset_y,dist_min,dist_max,dist_ang_min,dist_ang_max,vel_min,vel_max,vel_ang_min,vel_ang_max,acc_min,acc_max,acc_ang_min,acc_ang_max,ang_min,ang_max,ang_vel_min,ang_vel_max,ang_acc_min,ang_acc_max
	StringSplit, args, arg_names, `,
	
	; argument processing
	FoundPos := RegExMatch( Clipboard, "attach_at\((.*)\)", arg_values )
	Loop, PARSE, arg_values1, `,
	{
		if( StrLen( A_LoopField ) == 0 )
			continue
		value = %A_LoopField%
		if( value == "0" )
			continue
		object := object . indent . "`t`t" . args%A_Index% . ": " . value . ",`n"
	}
	StringTrimRight, object, object, 2
	object := object . "`n"
	
	output := indent . "{`n" . indent . "`t" . key_name . ": """ . key_value . """,`n" . indent . "`tattach_at: {`n" . object . "" . indent . "`t}`n" . indent . "},`n"
	
	; final output
	Clipboard := output
	ClipWait, 2
	ControlSend,, ^v, .colosseum_data
}

