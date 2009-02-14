SetTitleMatchMode 2

F12::
{
	Clipboard = 
	Send {home}+{end}^c
	ClipWait, 2
	
	; class
	class=particle
	
	; key
	line = %Clipboard%
	FoundPos := RegExMatch( line, "particle_archetype\[PARTICLE_INDEX_([A-Z0-9_]+)\]", key )
	StringLower, key, key1
	
	; object
	object = 
	
	; argument names
	PARTICLE_arg_names = particle_type,img,frame,frame_delay,str,font,layer,retain,frictional_coefficient,red,green,blue,red_delta,green_delta,blue_delta,life_time,pos_x,pos_y,vel_x,vel_y,ang,ang_vel,alpha,alpha_delta,scale,scale_delta
	StringSplit, args, PARTICLE_arg_names, `,
	
	; argument processing
	FoundPos := RegExMatch( line, "PARTICLE\( PARTICLE.Create\((.*) \)\)", arg_values )
	Loop, PARSE, arg_values1, `,
	{
		if( StrLen( A_LoopField ) == 0 )
			continue ; skip the current iteration
		object := object . args%A_Index% . ":" . A_LoopField . ",{enter}"
	}
	
	; final output
	output = {tab}{{}{enter}{tab}class: "%class%",{enter}key: "%key%",{enter}object: {{}{enter}{tab}%object%{backspace 5}{enter}{backspace}{}}{enter}{backspace}{}},{enter}{backspace}
	ControlSend,, %output%, .colosseum_data
}

