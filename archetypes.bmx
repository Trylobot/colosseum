Rem
	archetypes.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function load_all_archetypes()
	'set_prop_archetypes()
	'set_particle_archetypes()
	set_particle_emitter_archetypes()
	set_projectile_archetypes()
	set_projectile_launcher_archetypes()
	set_widget_archetypes()
	set_pickup_archetypes()
	set_turret_barrel_archetypes()
	set_turret_archetypes()
	set_ai_type_archetypes()
	'set_complex_agent_archetypes()
	set_player_chassis_archetypes()
	set_unit_archetypes()
End Function

Global array_index%
Function reset_index()
	array_index = 0
End Function
Function postfix_index%( amount% = 1 )
	array_index :+ amount
	Return (array_index - amount)
End Function

Rem
'______________________________________________________________________________
'[ PROPS ]
Global prop_archetype:AGENT[2]; reset_index()

Global PROP_INDEX_CRATE_MEDIUM% = postfix_index()
Global PROP_INDEX_CRATE_SMALL% = postfix_index()

Function set_prop_archetypes()
	prop_archetype[PROP_INDEX_CRATE_MEDIUM] = Archetype_AGENT( get_image( "crate" ), get_image( "crate_gibs" ), 0, 200, 400, 160,, True )
	prop_archetype[PROP_INDEX_CRATE_SMALL] = Archetype_AGENT( get_image( "crate_small" ), get_image( "crate_small_gibs" ), 0, 75, 300, 160,, True )
End Function

Function get_prop:AGENT( archetype_index% )
	Local prop:AGENT = Copy_AGENT( prop_archetype[archetype_index] )
	prop.cur_health = prop.max_health
	Return prop
End Function
End Rem

Rem
'______________________________________________________________________________
'[ PARTICLES ]
Global particle_archetype:PARTICLE[50]; reset_index()

Global PARTICLE_INDEX_TANK_TREAD_DEBRIS% = postfix_index()
Global PARTICLE_INDEX_TANK_TREAD_TRAIL_SMALL% = postfix_index()
Global PARTICLE_INDEX_TANK_TREAD_TRAIL_MEDIUM% = postfix_index()
Global PARTICLE_INDEX_LIGHT_TANK_TRACK% = postfix_index()
Global PARTICLE_INDEX_MED_TANK_TRACK% = postfix_index()
Global PARTICLE_INDEX_CANNON_MUZZLE_FLASH% = postfix_index()
Global PARTICLE_INDEX_CANNON_SHELL_CASING% = postfix_index()
Global PARTICLE_INDEX_CANNON_MUZZLE_SMOKE% = postfix_index()
Global PARTICLE_INDEX_EXPLOSION% = postfix_index()
Global PARTICLE_INDEX_RICOCHET_SPARK% = postfix_index()
Global PARTICLE_INDEX_IMPACT_HALO% = postfix_index()
Global PARTICLE_INDEX_MACHINE_GUN_MUZZLE_FLASH% = postfix_index()
Global PARTICLE_INDEX_MACHINE_GUN_SHELL_CASING% = postfix_index()
Global PARTICLE_INDEX_MACHINE_GUN_MUZZLE_SMOKE% = postfix_index()
Global PARTICLE_INDEX_LASER_MUZZLE_FLARE% = postfix_index()
Global PARTICLE_INDEX_ROCKET_THRUST% = postfix_index()
Global PARTICLE_INDEX_ROCKET_CASING% = postfix_index()
Global PARTICLE_INDEX_ROCKET_SMOKE_TRAIL% = postfix_index()

Function set_particle_archetypes()
	particle_archetype[PARTICLE_INDEX_TANK_TREAD_DEBRIS] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "debris" ),,,,, LAYER_BACKGROUND, True, 0.05 ))
	particle_archetype[PARTICLE_INDEX_TANK_TREAD_TRAIL_SMALL] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "trail_3" ),,,,, LAYER_BACKGROUND, True ))
	particle_archetype[PARTICLE_INDEX_TANK_TREAD_TRAIL_MEDIUM] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "trail_5" ),,,,, LAYER_BACKGROUND, True ))
	particle_archetype[PARTICLE_INDEX_LIGHT_TANK_TRACK] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_ANIM, get_image( "light_tank_track" ),,,,,,,,,,,,,, INFINITY ))
	particle_archetype[PARTICLE_INDEX_MED_TANK_TRACK] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_ANIM, get_image( "med_tank_track" ),,,,,,,,,,,,,, INFINITY ))
	particle_archetype[PARTICLE_INDEX_CANNON_MUZZLE_FLASH] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "muzzle_flash" ),,,,, LAYER_FOREGROUND ))
	particle_archetype[PARTICLE_INDEX_CANNON_SHELL_CASING] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "projectile_shell_casing" ),,,,, LAYER_FOREGROUND, True, 0.0100 ))
	particle_archetype[PARTICLE_INDEX_CANNON_MUZZLE_SMOKE] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "muzzle_smoke" ),,,,, LAYER_FOREGROUND ))
	particle_archetype[PARTICLE_INDEX_EXPLOSION] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "white_circle" ),,,,, LAYER_FOREGROUND, False, 0.0850 ))
	particle_archetype[PARTICLE_INDEX_RICOCHET_SPARK] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "spark" ),,,,, LAYER_FOREGROUND, False, 0.0150 ))
	particle_archetype[PARTICLE_INDEX_IMPACT_HALO] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "halo" ),,,,, LAYER_BACKGROUND, False, 0 ))
	particle_archetype[PARTICLE_INDEX_MACHINE_GUN_MUZZLE_FLASH] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "mgun_muzzle_flash" ),,,,, LAYER_FOREGROUND ))
	particle_archetype[PARTICLE_INDEX_MACHINE_GUN_SHELL_CASING] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "mgun_shell_casing" ),,,,, LAYER_FOREGROUND, True, 0.0100 ))
	particle_archetype[PARTICLE_INDEX_MACHINE_GUN_MUZZLE_SMOKE] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "mgun_muzzle_smoke" ),,,,, LAYER_FOREGROUND ))
	particle_archetype[PARTICLE_INDEX_LASER_MUZZLE_FLARE] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "laser_muzzle_flare" ),,,,, LAYER_FOREGROUND, False ))
	particle_archetype[PARTICLE_INDEX_ROCKET_THRUST] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "rocket_thrust" ),,,,, LAYER_BACKGROUND ))
	particle_archetype[PARTICLE_INDEX_ROCKET_CASING] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "rocket_casing" ),,,,, LAYER_FOREGROUND, True, 0.0100 ))
	particle_archetype[PARTICLE_INDEX_ROCKET_SMOKE_TRAIL] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, get_image( "muzzle_smoke" ),,,,, LAYER_FOREGROUND ))
End Function
End Rem

'______________________________________________________________________________
'[ PARTICLE EMITTERS ]
Global particle_emitter_archetype:EMITTER[25]; reset_index();

Global PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS% = postfix_index()
Global PARTICLE_EMITTER_INDEX_TANK_TREAD_DUST_CLOUD% = postfix_index()
Global PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_MEDIUM% = postfix_index()
Global PARTICLE_EMITTER_INDEX_EXPLOSION% = postfix_index()
Global PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH% = postfix_index()
Global PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING% = postfix_index()
Global PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE% = postfix_index()
Global PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION% = postfix_index()
Global PARTICLE_EMITTER_INDEX_CANNON_RICOCHET_SPARK% = postfix_index()
Global PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO% = postfix_index()
Global PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH% = postfix_index()
Global PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING% = postfix_index()
Global PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE% = postfix_index()
Global PARTICLE_EMITTER_INDEX_MACHINE_GUN_RICOCHET_SPARK% = postfix_index()
Global PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE% = postfix_index()
Global PARTICLE_EMITTER_INDEX_LASER_EXPLOSION% = postfix_index()
Global PARTICLE_EMITTER_INDEX_LASER_SECONDARY_EXPLOSION% = postfix_index()
Global PARTICLE_EMITTER_INDEX_LASER_IMPACT_HALO% = postfix_index()
Global PARTICLE_EMITTER_INDEX_ROCKET_THRUST% = postfix_index()
Global PARTICLE_EMITTER_INDEX_ROCKET_CASING% = postfix_index()
Global PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS% = postfix_index()
Global PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_SPAWNER% = postfix_index()

Function set_particle_emitter_archetypes()
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "tank_tread_debris",,, True,,,, 100, 150, 0, 0, 200, 350, 0.75, 0.75, -0.0012, -0.0025 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DUST_CLOUD] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "dust",,, True,,,, 50, 100,,, 3000, 4000, 0.10, 0.20, -0.0010, -0.0020, 0.10, 0.12, 0.0010, 0.0015, 125, 255, 125, 255, 125, 255 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "tank_tread_trail_small",,,,,,, 100, 100,,, 0, 0 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_MEDIUM] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "tank_tread_trail_medium",,,,,,, 100, 100,,, 0, 0 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "explosion",,,,,,,,,,, 250,300, 1.0,1.0, -0.100,-0.100, 1.0,1.0, -0.050,-0.050, 1.0,1.0, 1.0,1.0, 0.8,0.8, -0.002,-0.002, -0.035,-0.035, -0.030,-0.030 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "cannon_muzzle_flash",,,,,,,,,,, 50, 50 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "cannon_shell_casing",, True, True,,, True,,,,, 2200, 2200 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "cannon_muzzle_smoke",,, True,,,,,, 10, 12, 500, 1000, 0.08, 0.16, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "explosion",,,,,,,,,,, 300,350, 1.0,1.0, -0.100,-0.100, 0.350, 0.400, -0.0075, -0.0075, 1.0,1.0, 1.0,1.0, 0.8,0.8, -0.002,-0.002, -0.035,-0.035, -0.030,-0.030 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_RICOCHET_SPARK] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "ricochet_spark",,,, True, True,,,, 1,5, 150,150, 1,1, -0.120,-0.120, 0.25, 0.68 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "impact_halo",,,,,,,,,,, 100, 100, 0.5, 0.5, 0, 0, 0.35, 0.45, -0.0100, -0.0100 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "machine_gun_muzzle_flash",,,,,,,,,,, 25, 25 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "machine_gun_shell_casing",, True, True,,, True,,,,, 1400, 1800 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "machine_gun_muzzle_smoke",,, True,,,,,, 6, 8, 300, 600, 0.06, 0.12, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_RICOCHET_SPARK] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "ricochet_spark",,,, True, True,,,,,, 150,150, 1, 1, -0.120,-0.120, 0.38, 0.42, 0, 0 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "laser_muzzle_flare",,,,,,,,,,, 50, 50 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_EXPLOSION] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "explosion",,,,,,,,,,, 250,300, 1.0,1.0, -0.100,-0.100, 0.275,0.300, -0.0065,-0.0065, 1.0,1.0, 0.65,0.65, 0.65,0.65 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_SECONDARY_EXPLOSION] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "explosion",,,, True, True,,,, 5,8, 300,300, 1.0,1.0, -0.100,-0.100, 0.100,0.120, -0.0050,-0.0050, 1.0,1.0, 0.65,0.65, 0.65,0.65 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_IMPACT_HALO] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "impact_halo",,,,,,,,,,, 100,100, 0.5,0.5, 0,0, 0.20,0.20, -0.0080,-0.0080, 1.0,1.0, 0.75,0.75, 0.75,0.75 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "rocket_thrust", MODE_ENABLED_FOREVER,,,,,, 10, 15,,, 10, 15, 0.50, 0.75, 0, 0, 0.25, 1.00, 0, 0 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "rocket_casing",, True, True,,, True,,,,, 2200, 2200 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "rocket_smoke_trail", MODE_ENABLED_FOREVER,,,,,, 25, 50, 0, 0, 250, 500, 0.06, 0.12, -0.002, -0.020, 0.10, 0.70, 0.0008, 0.0300 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "tank_tread_debris",,, True,,,, 100, 150, 0, 0, 200, 350, 0.75, 0.75, -0.0012, -0.0025 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "tank_tread_trail_small",,,,,,, 100, 100,,, 50, 50,,,,, 0.60, 0.60, 0.0, 0.0 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_SPAWNER] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, "laser", MODE_ENABLED_WITH_TIMER,,, True, True, True, 10,25,,, 500,500, 1.0,1.0, -0.008,-0.008, 0.2,0.2, 0.015,0.015 ))
End Function

'______________________________________________________________________________
'[ PROJECTILES ]
Global projectile_archetype:PROJECTILE[10]; reset_index()

Global PROJECTILE_INDEX_TANK_CANNON% = postfix_index()
Global PROJECTILE_INDEX_MACHINE_GUN% = postfix_index()
Global PROJECTILE_INDEX_LASER% = postfix_index()
Global PROJECTILE_INDEX_ROCKET% = postfix_index()
	
Function set_projectile_archetypes()
	projectile_archetype[PROJECTILE_INDEX_TANK_CANNON] = PROJECTILE( PROJECTILE.Create( get_image( "projectile" ), get_sound( "cannon_hit" ), 50.00, 1000.0, 25.0,, 0.0300 ))
		projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_RICOCHET_SPARK], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0,0, 0,0, 135,225, 0.50,2.50 )
		projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_map.Insert( "tank_cannon", projectile_archetype[PROJECTILE_INDEX_TANK_CANNON] )
	projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN] = PROJECTILE( PROJECTILE.Create( get_image( "mgun" ), get_sound( "mgun_hit" ), 5.00,,,, 0.0050 ))
		projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_RICOCHET_SPARK], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0,0, 0,0, 135,225, 0.50,1.00 )
		projectile_map.Insert( "machine_gun", projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN] )
	projectile_archetype[PROJECTILE_INDEX_LASER] = PROJECTILE( PROJECTILE.Create( get_image( "laser_red" ), get_sound( "laser_hit" ), 15.00,,,, 0.0001,, True ))
		projectile_archetype[PROJECTILE_INDEX_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_archetype[PROJECTILE_INDEX_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_SECONDARY_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0, 5,8, 0,359.999, 1.3,2.5 )
		projectile_archetype[PROJECTILE_INDEX_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_map.Insert( "laser", projectile_archetype[PROJECTILE_INDEX_LASER] )
	projectile_archetype[PROJECTILE_INDEX_ROCKET] = PROJECTILE( PROJECTILE.Create( get_image( "rocket" ), get_sound( "cannon_hit" ), 100.00, 2000.0, 50.0, 4.00, 0.0400, 0.00025 ))
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST], PROJECTILE_MEMBER_EMITTER_CONSTANT ).attach_at( -11, 0 )
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL], PROJECTILE_MEMBER_EMITTER_CONSTANT ).attach_at( -11, 0, 0, 10, -30, 30 )
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_map.Insert( "rocket", projectile_archetype[PROJECTILE_INDEX_ROCKET] )
End Function

'______________________________________________________________________________
'[ PROJECTILE LAUNCHERS ] (emitters)
Global projectile_launcher_archetype:EMITTER[10]; reset_index()

Global PROJECTILE_LAUNCHER_INDEX_TANK_CANNON% = postfix_index()
Global PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN% = postfix_index()
Global PROJECTILE_LAUNCHER_INDEX_LASER% = postfix_index()
Global PROJECTILE_LAUNCHER_INDEX_ROCKET% = postfix_index()

Function set_projectile_launcher_archetypes()
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_TANK_CANNON] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, "tank_cannon",, True, False, False, True, True ))
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, "machine_gun",, True, False, False, True, True ))
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_LASER] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, "laser",, False, False, False, True, True ))
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_ROCKET] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, "rocket",, True, False, False, True, True ))
End Function
	
'______________________________________________________________________________
'[ WIDGETS ]
Global widget_archetype:WIDGET[10]; reset_index()

Global WIDGET_INDEX_AI_LIGHTBULB% = postfix_index()
Global WIDGET_INDEX_ARENA_DOOR% = postfix_index()
Global WIDGET_INDEX_BAY_DOOR_CLOCKWISE% = postfix_index()
Global WIDGET_INDEX_BAY_DOOR_COUNTER_CLOCKWISE% = postfix_index()
Global WIDGET_INDEX_RAMP_EXTENDER% = postfix_index()
Global WIDGET_INDEX_SPINNER% = postfix_index()

Function set_widget_archetypes()
	widget_archetype[WIDGET_INDEX_AI_LIGHTBULB] = WIDGET( WIDGET.Create( "lightbulb", get_image( "lightbulb" )))
		widget_archetype[WIDGET_INDEX_AI_LIGHTBULB].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( ,,,,,, 0.0, 0.75, 0.75, 100 )))
		widget_archetype[WIDGET_INDEX_AI_LIGHTBULB].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( ,,,,,, 0.75, 1.25, 1.25, 100 )))
	widget_archetype[WIDGET_INDEX_ARENA_DOOR] = WIDGET( WIDGET.Create( "door", get_image( "door" ), LAYER_IN_FRONT_OF_PARENT,, REPEAT_MODE_CYCLIC_WRAP, False ))
		widget_archetype[WIDGET_INDEX_ARENA_DOOR].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 255, 255, 1, 1, 1, 1750 )))
		widget_archetype[WIDGET_INDEX_ARENA_DOOR].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 32, 0, 0, 255, 255, 255, 1, 1, 1, 925 )))
	widget_archetype[WIDGET_INDEX_BAY_DOOR_CLOCKWISE] = WIDGET( WIDGET.Create( "bay door clockwise", get_image( "bay_door" )))
		widget_archetype[WIDGET_INDEX_BAY_DOOR_CLOCKWISE].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0,,,,,,, 1000 )))
		widget_archetype[WIDGET_INDEX_BAY_DOOR_CLOCKWISE].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 90,,,,,,, 1000 )))
	widget_archetype[WIDGET_INDEX_BAY_DOOR_COUNTER_CLOCKWISE] = WIDGET( WIDGET.Create( "bay door counter-clockwise", pixel_transform( get_image( "bay_door" ),, True )))
		widget_archetype[WIDGET_INDEX_BAY_DOOR_COUNTER_CLOCKWISE].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0,,,,,,, 1000 )))
		widget_archetype[WIDGET_INDEX_BAY_DOOR_COUNTER_CLOCKWISE].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, -90,,,,,,, 1000 )))
	widget_archetype[WIDGET_INDEX_RAMP_EXTENDER] = WIDGET( WIDGET.Create( "ramp", get_image( "ramp" ), LAYER_BEHIND_PARENT))
		widget_archetype[WIDGET_INDEX_RAMP_EXTENDER].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0,,,,,,, 1000 )))
		widget_archetype[WIDGET_INDEX_RAMP_EXTENDER].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( -11, 0, 0,,,,,,, 1000 )))
	widget_archetype[WIDGET_INDEX_SPINNER] = WIDGET( WIDGET.Create( "spinner", get_image( "spinner" )))
		widget_archetype[WIDGET_INDEX_SPINNER].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, -180,,,,,,, 1000 )))
		widget_archetype[WIDGET_INDEX_SPINNER].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 180,,,,,,, 1000 )))
End Function

'______________________________________________________________________________
'[ PICKUPS ]
Global pickup_archetype:PICKUP[10]; reset_index()

Global PICKUP_INDEX_HEALTH% = postfix_index()
Global PICKUP_INDEX_CANNON_AMMO_5% = postfix_index()
Global PICKUP_INDEX_CANNON_AMMO_10% = postfix_index()
Global PICKUP_INDEX_CANNON_AMMO_15% = postfix_index()
Global PICKUP_INDEX_CANNON_AMMO_20% = postfix_index()
Global PICKUP_INDEX_COOLDOWN% = postfix_index()

Function set_pickup_archetypes()
	pickup_archetype[PICKUP_INDEX_HEALTH] = PICKUP( PICKUP.Create( get_image( "pickup_health" ), HEALTH_PICKUP, 200, 60000 ))
	pickup_archetype[PICKUP_INDEX_CANNON_AMMO_5] = PICKUP( PICKUP.Create( get_image( "pickup_ammo_main_5" ), AMMO_PICKUP, 5, 60000 ))
	pickup_archetype[PICKUP_INDEX_CANNON_AMMO_10] = PICKUP( PICKUP.Create( get_image( "pickup_ammo_main_10" ), AMMO_PICKUP, 10, 60000 ))
	pickup_archetype[PICKUP_INDEX_CANNON_AMMO_15] = PICKUP( PICKUP.Create( get_image( "pickup_ammo_main_15" ), AMMO_PICKUP, 15, 60000 ))
	pickup_archetype[PICKUP_INDEX_CANNON_AMMO_20] = PICKUP( PICKUP.Create( get_image( "pickup_ammo_main_20" ), AMMO_PICKUP, 20, 60000 ))
	pickup_archetype[PICKUP_INDEX_COOLDOWN] = PICKUP( PICKUP.Create( get_image( "pickup_cooldown" ), COOLDOWN_PICKUP, 4000, 60000 ))
End Function

'______________________________________________________________________________
'[ TURRET BARRELS ]
Global turret_barrel_archetype:TURRET_BARREL[20]; reset_index()

Global TURRET_BARREL_INDEX_LIGHT_CANNON% = postfix_index()
Global TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN% = postfix_index()
Global TURRET_BARREL_INDEX_LIGHT_LASER% = postfix_index()
Global TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_LEFT% = postfix_index()
Global TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_RIGHT% = postfix_index()
Global TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN_2% = postfix_index()
Global TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_MACHINE_GUN% = postfix_index()
Global TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_CANNON% = postfix_index()
Global TURRET_BARREL_INDEX_EMPLACEMENT_ROCKET_LAUNCHER% = postfix_index()
Global TURRET_BARREL_INDEX_LIGHT_MACHINE_GUN% = postfix_index()

Function set_turret_barrel_archetypes()
	turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CANNON] = Create_TURRET_BARREL( get_image( "player_tank_turret_barrel" ), 650, -7 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CANNON].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_TANK_CANNON] ).attach_at( 20, 0, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH] ).attach_at( 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE] ).attach_at( 20, 0, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING] ).attach_at( -3, 3, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
	turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN] = Create_TURRET_BARREL( get_image( "player_tank_mgun_turret" ), 62, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN] ).attach_at( 14, 2, 0, 0, 0, 0, 4.30, 4.70, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH] ).attach_at( 14, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE] ).attach_at( 14, 2, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING] ).attach_at( 8, 2, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )
	turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_LASER] = Create_TURRET_BARREL( Null, 250 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_LASER].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_LASER] ).attach_at( 20, 0, 0, 0, 0, 0, 8.00, 8.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE] ).attach_at( 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_LEFT] = Create_TURRET_BARREL( get_image( "player_tank_turret_med_barrel_left" ), 485, -9 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_LEFT].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_TANK_CANNON] ).attach_at( 24, -2, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_LEFT].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH] ).attach_at( 24, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_LEFT].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE] ).attach_at( 24, -2, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_LEFT].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING] ).attach_at( 11, -3, 0, 0, 0, 0, 0.4, 0.6, 260, 280, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
	turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_RIGHT] = Create_TURRET_BARREL( get_image( "player_tank_turret_med_barrel_right" ), 485, -9 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_RIGHT].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_TANK_CANNON] ).attach_at( 24, 2, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_RIGHT].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH] ).attach_at( 24, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_RIGHT].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE] ).attach_at( 24, 2, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_RIGHT].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING] ).attach_at( 11, 3, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
	turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN_2] = Create_TURRET_BARREL( get_image( "player_tank_med_mgun_turret_barrel" ), 62 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN_2].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN] ).attach_at( 5, 4, 0, 0, 0, 0, 4.30, 4.70, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN_2].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH] ).attach_at( 5, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN_2].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE] ).attach_at( 5, 4, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN_2].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING] ).attach_at( 0, 5, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )
	turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_MACHINE_GUN] = Create_TURRET_BARREL( get_image( "enemy_machine-gun_emplacement_turret-barrel" ), 50, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_MACHINE_GUN].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN] ).attach_at( 16, 0, 0, 0, 0, 0, 2.50, 3.00, 0, 0, 0, 0, 0, 0, -4.0, 4.0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH] ).attach_at( 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE] ).attach_at( 16, 0, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING] ).attach_at( 3, 3, 0, 0, 0, 0, 0.4, 0.6, 70, 110, -0.004, -0.004, 0, 0, -5, 5, -5, 5, 0, 0 )
	turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_CANNON] = Create_TURRET_BARREL( get_image( "player_tank_turret_barrel" ), 2800, -7 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_CANNON].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_TANK_CANNON] ).attach_at( 20, 0, 0, 0, 0, 0, 2.80, 3.00, 0, 0, 0, 0, 0, 0, -1.5, 1.5, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH] ).attach_at( 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE] ).attach_at( 20, 0, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING] ).attach_at( 5, 1, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
	turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_ROCKET_LAUNCHER] = Create_TURRET_BARREL( get_image( "enemy_stationary-emplacement-1_turret-barrel" ), 4000, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_ROCKET_LAUNCHER].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_ROCKET] ).attach_at( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0020, 0.0020, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_ROCKET_LAUNCHER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_CASING] ).attach_at( -12, 0, 0, 0, 0, 0, 0.2, 0.5, 175, 185, 0, 0, 0, 0, 0, 0, -5, 5, 0, 0 )
	turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_MACHINE_GUN] = Create_TURRET_BARREL( get_image( "enemy_light_mgun_turret_barrel" ), 100, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_MACHINE_GUN].add_launcher( projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN] ).attach_at( 8, 0, 0, 0, 0, 0, 3.0, 3.4, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH] ).attach_at( 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE] ).attach_at( 8, 0, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING] ).attach_at( 1, 1, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )
End Function

'______________________________________________________________________________
'[ TURRETS ]
Global turret_archetype:TURRET[20]; reset_index()

Global TURRET_INDEX_TANK_SINGLE_CANNON% = postfix_index()
Global TURRET_INDEX_TANK_MACHINE_GUN% = postfix_index()
Global TURRET_INDEX_TANK_LASER% = postfix_index()
Global TURRET_INDEX_TANK_DUAL_CANNON% = postfix_index()
Global TURRET_INDEX_MED_TANK_MACHINE_GUN% = postfix_index()
Global TURRET_INDEX_MACHINE_GUN_TURRET% = postfix_index()
Global TURRET_INDEX_CANNON_TURRET% = postfix_index()
Global TURRET_INDEX_ROCKET_TURRET% = postfix_index()
Global TURRET_INDEX_LIGHT_MACHINE_GUN% = postfix_index()

Function set_turret_archetypes()
	turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON] = TURRET( TURRET.Create( "105mm cannon", TURRET_CLASS_AMMUNITION, get_image( "player_tank_turret_base" ), 1000, get_sound( "cannon" ), 1, [[0]], 2.25, 40,,,,,, 500.0 ))
		turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CANNON], 0 ).attach_at( 0, 0 )
		turret_map.Insert( "light_cannon", turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON] )
	turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN] = TURRET( TURRET.Create( "0.50 machine-gun", TURRET_CLASS_AMMUNITION, Null, 750, get_sound( "mgun" ), 1, [[0]], 2.25, INFINITY, 25.0, 1.50, 2.75, 0.0210, 1500, 250.0 ))
		turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN], 0 ).attach_at( 0, 0 )
		turret_map.Insert( "light_cannon_coaxial_machine_gun", turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN] )
	turret_archetype[TURRET_INDEX_TANK_LASER] = TURRET( TURRET.Create( "10 MW laser", TURRET_CLASS_ENERGY, get_image( "laser_turret_base-barrel" ), 2125, get_sound( "laser" ), 1, [[0]], 2.25, INFINITY, 50.0, 5.50, 5.75, 0.0090, 3000, 400.0 ))
		turret_archetype[TURRET_INDEX_TANK_LASER].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_LASER], 0 ).attach_at( 0, 0 )
		turret_map.Insert( "light_laser", turret_archetype[TURRET_INDEX_TANK_LASER] )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON] = TURRET( TURRET.Create( "105mm cannon (2x)", TURRET_CLASS_AMMUNITION, get_image( "player_tank_turret_med_base" ), 4000, get_sound( "cannon" ), 2, [[0],[1]], 2.00, 40,,,,,, 500.0 ))
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_LEFT], 0 ).attach_at( 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_RIGHT], 1 ).attach_at( 0, 0 )
		turret_map.Insert( "dual_light_cannon", turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON] )
	turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN] = TURRET( TURRET.Create( "0.50 machine-gun", TURRET_CLASS_AMMUNITION, Null, 1000, get_sound( "mgun" ), 1, [[0]], 2.00, INFINITY, 25.0, 1.50, 2.50, 0.0210, 1500, 200.0 ))
		turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN_2], 0 ).attach_at( 0, 0 )
		turret_map.Insert( "dual_light_cannon_coaxial_machine_gun", turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN] )
	turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET] = TURRET( TURRET.Create( , TURRET_CLASS_AMMUNITION, get_image( "enemy_stationary-emplacement-1_turret-base" ),, get_sound( "mgun" ), 1, [[0]], 0.80, INFINITY, 25.0, 2.0, 3.0, 0.0175, 2000, 300.0 ))
		turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_MACHINE_GUN], 0 ).attach_at( 0, 0 )
		turret_map.Insert( "stationary_emplacement_machine_gun", turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET] )
	turret_archetype[TURRET_INDEX_CANNON_TURRET] = TURRET( TURRET.Create( , TURRET_CLASS_AMMUNITION, get_image( "enemy_stationary-emplacement-1_turret-base" ),, get_sound( "cannon" ), 1, [[0]], 0.50, INFINITY,,,,,, 600.0 ))
		turret_archetype[TURRET_INDEX_CANNON_TURRET].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_CANNON], 0 ).attach_at( 0, 0 )
		turret_map.Insert( "stationary_emplacement_light_cannon",turret_archetype[TURRET_INDEX_CANNON_TURRET]  )
	turret_archetype[TURRET_INDEX_ROCKET_TURRET] = TURRET( TURRET.Create( , TURRET_CLASS_AMMUNITION, get_image( "enemy_stationary-emplacement-1_turret-base" ),, get_sound( "rocket_launch" ), 1, [[0]], 0.50, INFINITY,,,,,, 600.0 ))
		turret_archetype[TURRET_INDEX_ROCKET_TURRET].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_ROCKET_LAUNCHER], 0 ).attach_at( 0, 0 )
		turret_map.Insert( "stationary_emplacement_rocket_launcher", turret_archetype[TURRET_INDEX_ROCKET_TURRET] )
	turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN] = TURRET( TURRET.Create( , TURRET_CLASS_AMMUNITION, get_image( "enemy_light_mgun_turret_base" ),, get_sound( "mgun" ), 1, [[0]], 2.00, INFINITY, 25.0, 5.0, 5.5, 0.0175, 2000, 250.0 ))
		turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_MACHINE_GUN], 0 ).attach_at( 0, 0 )
		turret_map.Insert( "light_machine_gun", turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN] )
End Function

'______________________________________________________________________________
'[ AI_TYPE ]
Function set_ai_type_archetypes()
	ai_type_map.Insert( "wildlife", Create_AI_TYPE( False, True, False, False ))
	ai_type_map.Insert( "turret", Create_AI_TYPE( True, False, False, False ))
	ai_type_map.Insert( "bomb", Create_AI_TYPE( False, True, True, False ))
	ai_type_map.Insert( "vehicle", Create_AI_TYPE( True, True, False, False ))
	ai_type_map.Insert( "carrier", Create_AI_TYPE( False, True, False, True ))
	ai_type_map.Insert( "armed_carrier", Create_AI_TYPE( True, True, False, True ))
End Function

'______________________________________________________________________________
'[ PLAYER_CHASSIS ]
Global player_chassis_archetype:COMPLEX_AGENT[2]; reset_index()

Global PLAYER_CHASSIS_INDEX_LIGHT_TANK% = postfix_index()
Global PLAYER_CHASSIS_INDEX_MEDIUM_TANK% = postfix_index()

Function set_player_chassis_archetypes()
	player_chassis_archetype[PLAYER_CHASSIS_INDEX_LIGHT_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "war horse", get_image( "player_tank_chassis" ), get_image( "light_tank_hitbox" ), get_image( "quad_gibs" ),, 1250, 0, 500, 800.0, 75.0, 75.0, 100.0 ))
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_LIGHT_TANK].add_motivator_package( "light_tank_track", 0, 6.5 )
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_LIGHT_TANK].add_trail_package( PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL,, 12, 6 )
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_LIGHT_TANK].add_dust_cloud_package( , 12, 7, 0, 2, -45, 45, 0.2, 0.8 )
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_LIGHT_TANK].add_turret_anchor( cVEC.Create( -5, 0 ))
		player_chassis_map.Insert( "light_tank", player_chassis_archetype[PLAYER_CHASSIS_INDEX_LIGHT_TANK] )
	player_chassis_archetype[PLAYER_CHASSIS_INDEX_MEDIUM_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "predator", get_image( "player_tank_chassis_med" ), get_image( "medium_tank_hitbox" ), get_image( "quad_gibs" ),, 5000, 0, 750, 1200, 125.0, 100.0, 125.0 ))
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_MEDIUM_TANK].add_motivator_package( "med_tank_track", 0, 7.5 )
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_MEDIUM_TANK].add_trail_package( PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_MEDIUM,, 15, 8 )
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_MEDIUM_TANK].add_dust_cloud_package( , 15, 8, 0, 2, -45, 45, 0.2, 0.8 )
		player_chassis_archetype[PLAYER_CHASSIS_INDEX_MEDIUM_TANK].add_turret_anchor( cVEC.Create( -9, 0 ))
		player_chassis_map.Insert( "medium_tank", player_chassis_archetype[PLAYER_CHASSIS_INDEX_MEDIUM_TANK] )
End Function

'______________________________________________________________________________
'[ UNITS ]
Global unit_archetype:COMPLEX_AGENT[8]; reset_index()

Global UNIT_INDEX_MR_THE_BOX% = postfix_index()
Global UNIT_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT% = postfix_index()
Global UNIT_INDEX_CANNON_TURRET_EMPLACEMENT% = postfix_index()
Global UNIT_INDEX_ROCKET_TURRET_EMPLACEMENT% = postfix_index()
Global UNIT_INDEX_MOBILE_MINI_BOMB% = postfix_index()
Global UNIT_INDEX_LIGHT_QUAD% = postfix_index()
Global UNIT_INDEX_LIGHT_TANK% = postfix_index()
Global UNIT_INDEX_CARRIER% = postfix_index()

Function set_unit_archetypes()		
	unit_archetype[UNIT_INDEX_MR_THE_BOX] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "mr_the_box", get_image( "box" ),, get_image( "box_gib" ), "wildlife", 50, 35, 350.0, 8.0, 6.0, 12.0 ))
		unit_archetype[UNIT_INDEX_MR_THE_BOX].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		unit_map.Insert( "mr_the_box", unit_archetype[UNIT_INDEX_MR_THE_BOX] )
	unit_archetype[UNIT_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "machine_gun_emplacement", get_image( "enemy_stationary-emplacement-1_chassis" ),, get_image( "tower_gibs" ), "turret", 100, 100, 1000.0, 0, 0, 0, True ))
		unit_archetype[UNIT_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		unit_archetype[UNIT_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].add_turret_anchor( cVEC.Create( 0, 0 ))
		unit_archetype[UNIT_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].add_turret( turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET], 0 )
		unit_map.Insert( "machine_gun_emplacement", unit_archetype[UNIT_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT] )
	unit_archetype[UNIT_INDEX_CANNON_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "cannon_emplacement", get_image( "enemy_stationary-emplacement-1_chassis" ),, get_image( "tower_gibs" ), "turret", 100, 100, 1000.0, 0, 0, 0, True ))
		unit_archetype[UNIT_INDEX_CANNON_TURRET_EMPLACEMENT].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		unit_archetype[UNIT_INDEX_CANNON_TURRET_EMPLACEMENT].add_turret_anchor( cVEC.Create( 0, 0 ))
		unit_archetype[UNIT_INDEX_CANNON_TURRET_EMPLACEMENT].add_turret( turret_archetype[TURRET_INDEX_CANNON_TURRET], 0 )
		unit_map.Insert( "cannon_emplacement", unit_archetype[UNIT_INDEX_CANNON_TURRET_EMPLACEMENT] )
	unit_archetype[UNIT_INDEX_ROCKET_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "rocket_emplacement", get_image( "enemy_stationary-emplacement-1_chassis" ),, get_image( "tower_gibs" ), "turret", 150, 100, 1000.0, 0, 0, 0, True ))
		unit_archetype[UNIT_INDEX_ROCKET_TURRET_EMPLACEMENT].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		unit_archetype[UNIT_INDEX_ROCKET_TURRET_EMPLACEMENT].add_turret_anchor( cVEC.Create( 0, 0 ))
		unit_archetype[UNIT_INDEX_ROCKET_TURRET_EMPLACEMENT].add_turret( turret_archetype[TURRET_INDEX_ROCKET_TURRET], 0 )
		unit_map.Insert( "rocket_emplacement", unit_archetype[UNIT_INDEX_ROCKET_TURRET_EMPLACEMENT] )
	unit_archetype[UNIT_INDEX_MOBILE_MINI_BOMB] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "mini_bomb", get_image( "nme_mobile_bomb" ),, get_image( "bomb_gibs" ), "bomb", 75, 50, 200, 10.0, 7.50, 30.0 ))
		unit_archetype[UNIT_INDEX_MOBILE_MINI_BOMB].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		unit_archetype[UNIT_INDEX_MOBILE_MINI_BOMB].add_widget( widget_archetype[WIDGET_INDEX_AI_LIGHTBULB], WIDGET_AI_LIGHTBULB ).attach_at( 0, 0 )
		unit_map.Insert( "mini_bomb", unit_archetype[UNIT_INDEX_MOBILE_MINI_BOMB] )
	unit_archetype[UNIT_INDEX_LIGHT_QUAD] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "machine_gun_quad", get_image( "enemy_quad_chassis" ),, get_image( "quad_gibs" ), "vehicle", 100, 50, 400, 25.0, 35.0, 55.0 ))
		unit_archetype[UNIT_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		unit_archetype[UNIT_INDEX_LIGHT_QUAD].add_trail_package( PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL,, 3, 4 )
		unit_archetype[UNIT_INDEX_LIGHT_QUAD].add_dust_cloud_package( , 8, 5, 0, 2, -45, 45, 0.2, 0.8 )
		unit_archetype[UNIT_INDEX_LIGHT_QUAD].add_turret_anchor( cVEC.Create( -6, 0 ))
		unit_archetype[UNIT_INDEX_LIGHT_QUAD].add_turret( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 0 )
		unit_map.Insert( "machine_gun_quad", unit_archetype[UNIT_INDEX_LIGHT_QUAD] )
	unit_archetype[UNIT_INDEX_LIGHT_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "light_tank", get_image( "player_tank_chassis" ), get_image( "light_tank_hitbox" ), get_image( "quad_gibs" ), "vehicle", 300, 175, 800.0, 75.0, 50.0, 65.0 ))
		unit_archetype[UNIT_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		unit_archetype[UNIT_INDEX_LIGHT_TANK].add_motivator_package( "light_tank_track", 0, 6.5 )
		unit_archetype[UNIT_INDEX_LIGHT_TANK].add_trail_package( PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL,, 12, 6 )
		unit_archetype[UNIT_INDEX_LIGHT_TANK].add_dust_cloud_package( , 12, 7, 0, 2, -45, 45, 0.2, 0.8 )
		unit_archetype[UNIT_INDEX_LIGHT_TANK].add_turret_anchor( cVEC.Create( -5, 0 ))
		unit_archetype[UNIT_INDEX_LIGHT_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON], 0 )
		unit_archetype[UNIT_INDEX_LIGHT_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN], 0 )
		unit_archetype[UNIT_INDEX_LIGHT_TANK].turrets[0].turret_barrel_array[0].reload_time = 2000
		unit_archetype[UNIT_INDEX_LIGHT_TANK].turrets[0].turret_barrel_array[0].launcher.vel.scale( 0.60 )
		unit_archetype[UNIT_INDEX_LIGHT_TANK].turrets[1].turret_barrel_array[0].reload_time = 105
		unit_archetype[UNIT_INDEX_LIGHT_TANK].turrets[1].turret_barrel_array[0].launcher.vel.scale( 0.60 )
		unit_archetype[UNIT_INDEX_LIGHT_TANK].turrets[1].max_heat = 15.0
		unit_map.Insert( "light_tank", unit_archetype[UNIT_INDEX_LIGHT_TANK] )
	unit_archetype[UNIT_INDEX_CARRIER] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "armed_carrier", get_image( "carrier_chassis" ), get_image( "carrier_hitbox" ), get_image( "carrier_gibs" ), "armed_carrier", 375, 300, 1200, 125.0, 70.0, 95.0 ))
		unit_archetype[UNIT_INDEX_CARRIER].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		unit_archetype[UNIT_INDEX_CARRIER].add_motivator_package( "med_tank_track", 1, 8.5 )
		unit_archetype[UNIT_INDEX_CARRIER].add_trail_package( PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_MEDIUM,, 16, 8 )
		unit_archetype[UNIT_INDEX_CARRIER].add_dust_cloud_package( , 16, 8, 0, 2, -45, 45, 0.2, 0.8 )
		unit_archetype[UNIT_INDEX_CARRIER].add_widget( widget_archetype[WIDGET_INDEX_BAY_DOOR_CLOCKWISE], WIDGET_DEPLOY ).attach_at( -16, -9,, True )
		unit_archetype[UNIT_INDEX_CARRIER].add_widget( widget_archetype[WIDGET_INDEX_BAY_DOOR_COUNTER_CLOCKWISE], WIDGET_DEPLOY ).attach_at( -16, 9,, True )
		unit_archetype[UNIT_INDEX_CARRIER].add_widget( widget_archetype[WIDGET_INDEX_RAMP_EXTENDER], WIDGET_DEPLOY ).attach_at( -15, 0,, True )
		unit_archetype[UNIT_INDEX_CARRIER].add_widget( widget_archetype[WIDGET_INDEX_SPINNER], WIDGET_DEPLOY ).attach_at( 10, 0,, True )
		unit_archetype[UNIT_INDEX_CARRIER].add_turret_anchor( cVEC.Create( 10, -10 ))
		unit_archetype[UNIT_INDEX_CARRIER].add_turret_anchor( cVEC.Create( 10, 10 ))
		unit_archetype[UNIT_INDEX_CARRIER].add_turret( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 0 )
		unit_archetype[UNIT_INDEX_CARRIER].add_turret( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 1 )
		unit_archetype[UNIT_INDEX_CARRIER].add_factory_unit( UNIT_INDEX_MOBILE_MINI_BOMB, 4 )
		unit_map.Insert( "armed_carrier", unit_archetype[UNIT_INDEX_CARRIER] )
End Function

