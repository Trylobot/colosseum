Rem
	update.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Physics and Timing Update
Function update_all()
	If Not FLAG_in_menu And Not FLAG_draw_help
		
		'level
		If hostile_agent_list.IsEmpty()
			load_next_level()
		End If
		
		'control brains (human + ai)
		For Local cb:CONTROL_BRAIN = EachIn control_brain_list
			cb.update()
			cb.prune()
		Next
		
		'pickups
		For Local pkp:PICKUP = EachIn pickup_list
			pkp.update()
		Next
		'projectiles
		For Local proj:PROJECTILE = EachIn projectile_list
			proj.update()
		Next	
		'particles
		For Local list:TList = EachIn particle_lists
			For Local part:PARTICLE = EachIn list
				part.update()
				part.prune()
			Next
		Next

		'friendlies
		For Local friendly:COMPLEX_AGENT = EachIn friendly_agent_list
			friendly.update()
		Next

		'hostiles
		For Local hostile:COMPLEX_AGENT = EachIn hostile_agent_list
			hostile.update()
		Next
		
	End If
End Function


