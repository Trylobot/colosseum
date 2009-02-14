SetTitleMatchMode 2

F12::
{
	Clipboard = 
	Send {home}+{end}^c{home}
	ClipWait, 2
	
	; class
	class=particle_emitter
	
	; key
	line = %Clipboard%
	FoundPos := RegExMatch( line, "particle_emitter_archetype\[PARTICLE_EMITTER_INDEX_([A-Z0-9_]+)\]", key )
	StringLower, key, key1
	
	; object
	object = 
	
	; argument names
	arg_names = emitter_type,particle_archetype,mode,combine_vel_with_parent_vel,combine_vel_ang_with_parent_ang,inherit_ang_from_dist_ang,inherit_vel_ang_from_ang,inherit_acc_ang_from_vel_ang,interval_min,interval_max,count_min,count_max,life_time_min,life_time_max,alpha_min,alpha_max,alpha_delta_min,alpha_delta_max,scale_min,scale_max,scale_delta_min,scale_delta_max,red_min,red_max,green_min,green_max,blue_min,blue_max,red_delta_min,red_delta_max,green_delta_min,green_delta_max,blue_delta_min,blue_delta_max
	StringSplit, args, arg_names, `,
	
	; argument processing
	FoundPos := RegExMatch( line, "EMITTER\( EMITTER.Archetype\((.*) \)\)", arg_values )
	Loop, PARSE, arg_values1, `,
	{
		if( StrLen( A_LoopField ) == 0 )
			continue ; skip the current iteration
		value = %A_LoopField%
		object := object . "`t`t`t" . args%A_Index% . ": " . value . ",`n"
	}
	StringTrimRight, object, object, 2
	object := object . "`n"
	
	output := "`t{`n`t`tclass: """ . class . """,`n`t`tkey: """ . key . """,`n`t`tobject: {`n" . object . "`t`t}`n`t},`n"
	
	; final output
	Clipboard := output
	ClipWait, 2
	ControlSend,, ^v, .colosseum_data
}

