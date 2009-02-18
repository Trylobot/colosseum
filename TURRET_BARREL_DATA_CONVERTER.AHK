SetTitleMatchMode 2

F11::
{
	Clipboard = 
	Send {home}+{end}^c{home}
	ClipWait, 2
	
	; class
	class=turret_barrel
	
	; key
	line = %Clipboard%
	FoundPos := RegExMatch( line, "turret_barrel_archetype\[TURRET_BARREL_INDEX_([A-Z0-9_]+)\]", key )
	StringLower, key, key1
	
	; object
	object = 
	
	; argument names
	arg_names = image_key,reload_time,recoil_max
	StringSplit, args, arg_names, `,
	
	; argument processing
	FoundPos := RegExMatch( line, "Create_TURRET_BARREL\( (.*) \)", arg_values )
	Loop, PARSE, arg_values1, `,
	{
		if( StrLen( A_LoopField ) == 0 )
			continue ; skip the current iteration
		value = %A_LoopField%
		object := object . "`t`t`t" . args%A_Index% . ": " . value . ",`n"
	}
	object := object . "`t`t`tlauncher: `n`t`t`tlaunch_emitters: [`n`t`t`t],`n"
	StringTrimRight, object, object, 2
	object := object . "`n"
	
	output := "`t{`n`t`tclass: """ . class . """,`n`t`tkey: """ . key . """,`n`t`tobject: {`n" . object . "`t`t}`n`t},`n"
	
	; final output
	Clipboard := output
	ClipWait, 2
	ControlSend,, ^v, .colosseum_data
}

