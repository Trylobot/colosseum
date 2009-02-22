SetTitleMatchMode 2

F12::
{
	Clipboard = 
	Send {home}+{end}^c{home}
	ClipWait, 2
	
	; class
	class=turret
	
	; key
	line = %Clipboard%
	FoundPos := RegExMatch( line, "turret_archetype\[TURRET_INDEX_([A-Z0-9_]+)\]", key )
	StringLower, key, key1
	
	; object
	object = 
	
	; object argument names
	arg_names = name,class,priority,image_key,cash_value,firing_sound_key,turret_barrel_count,firing_sequence,max_ang_vel,max_ammo,heat_based,heat_per_shot_min,heat_per_shot_max,cooling_rate,overheat_delay,effective_range
	StringSplit, args, arg_names, `,
	
	; object argument processing
	FoundPos := RegExMatch( line, "TURRET\( TURRET.Create\( (.*) \)", arg_values )
	Loop, PARSE, arg_values1, `,
	{
		if( StrLen( A_LoopField ) == 0 )
			continue ; skip the current iteration
		value = %A_LoopField%
		object := object . "`t`t`t" . args%A_Index% . ": " . value . ",`n"
	}
	; object static arguments
	object := object . "`t`t`tturret_barrels: [`n`t`t`t],`n"
	
	; erase object's final comma
	StringTrimRight, object, object, 2
	object := object . "`n"
	
	; output
	output := "`t{`n`t`tclass: """ . class . """,`n`t`tkey: """ . key . """,`n`t`tobject: {`n" . object . "`t`t}`n`t},`n"
	Clipboard := output
	ClipWait, 2
	ControlSend,, ^v, .colosseum_data
}

