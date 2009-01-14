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
	set_complex_agent_archetypes()
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
EndRem

'______________________________________________________________________________
'[ PARTICLE EMITTERS ]
Global particle_emitter_archetype:EMITTER[25]; reset_index();

Global PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS% = postfix_index()
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

Function set_particle_emitter_archetypes()
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_DEBRIS,,, True,,,, 100, 150, 0, 0, 200, 350, 0.75, 0.75, -0.0012, -0.0025 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_TRAIL_SMALL,,,,,,, 100, 100,,, 50, 50 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_MEDIUM] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_TRAIL_MEDIUM,,,,,,, 100, 100,,, 50, 50 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_EXPLOSION,,,,,,,,,,, 250,300, 1.0,1.0, -0.100,-0.100, 1.0,1.0, -0.050,-0.050, 1.0,1.0, 1.0,1.0, 0.8,0.8, -0.002,-0.002, -0.035,-0.035, -0.030,-0.030 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_MUZZLE_FLASH,,,,,,,,,,, 50, 50 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_SHELL_CASING,, True, True,,, True,,,,, 2200, 2200 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_MUZZLE_SMOKE,,, True,,,,,, 10, 12, 500, 1000, 0.08, 0.16, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_EXPLOSION,,,,,,,,,,, 300,350, 1.0,1.0, -0.100,-0.100, 0.350, 0.400, -0.0075, -0.0075, 1.0,1.0, 1.0,1.0, 0.8,0.8, -0.002,-0.002, -0.035,-0.035, -0.030,-0.030 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_RICOCHET_SPARK] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_RICOCHET_SPARK,,,, True, True,,,, 1,5, 150,150, 1,1, -0.120,-0.120, 0.25, 0.68 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_IMPACT_HALO,,,,,,,,,,, 100, 100, 0.5, 0.5, 0, 0, 0.35, 0.45, -0.0100, -0.0100 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_MUZZLE_FLASH,,,,,,,,,,, 25, 25 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_SHELL_CASING,, True, True,,, True,,,,, 1400, 1800 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_MUZZLE_SMOKE,,, True,,,,,, 6, 8, 300, 600, 0.06, 0.12, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_RICOCHET_SPARK] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_RICOCHET_SPARK,,,, True, True,,,,,, 150,150, 1, 1, -0.120,-0.120, 0.38, 0.42, 0, 0 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_LASER_MUZZLE_FLARE,,,,,,,,,,, 50, 50 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_EXPLOSION] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_EXPLOSION,,,,,,,,,,, 250,300, 1.0,1.0, -0.100,-0.100, 0.275,0.300, -0.0065,-0.0065, 1.0,1.0, 0.65,0.65, 0.65,0.65 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_SECONDARY_EXPLOSION] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_EXPLOSION,,,, True, True,,,, 5,8, 300,300, 1.0,1.0, -0.100,-0.100, 0.100,0.120, -0.0050,-0.0050, 1.0,1.0, 0.65,0.65, 0.65,0.65 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_IMPACT_HALO] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_IMPACT_HALO,,,,,,,,,,, 100,100, 0.5,0.5, 0,0, 0.20,0.20, -0.0080,-0.0080, 1.0,1.0, 0.75,0.75, 0.75,0.75 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_ROCKET_THRUST, MODE_ENABLED_FOREVER,,,,,, 10, 15,,, 10, 15, 0.50, 0.75, 0, 0, 0.25, 1.00, 0, 0 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_ROCKET_CASING,, True, True,,, True,,,,, 2200, 2200 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_ROCKET_SMOKE_TRAIL, MODE_ENABLED_FOREVER,,,,,, 25, 50, 0, 0, 250, 500, 0.06, 0.12, -0.002, -0.020, 0.10, 0.70, 0.0008, 0.0300 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_DEBRIS,,, True,,,, 100, 150, 0, 0, 200, 350, 0.75, 0.75, -0.0012, -0.0025 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_TRAIL_SMALL,,,,,,, 100, 100,,, 50, 50,,,,, 0.60, 0.60, 0.0, 0.0 ))
End Function

'______________________________________________________________________________
'[ PROJECTILES ]
Global projectile_archetype:PROJECTILE[10]; reset_index()

Global PROJECTILE_INDEX_TANK_CANNON% = postfix_index()
Global PROJECTILE_INDEX_MACHINE_GUN% = postfix_index()
Global PROJECTILE_INDEX_LASER% = postfix_index()
Global PROJECTILE_INDEX_ROCKET% = postfix_index()

Function set_projectile_archetypes()
	projectile_archetype[PROJECTILE_INDEX_TANK_CANNON] = PROJECTILE( PROJECTILE.Create( get_image( "projectile" ), get_sound( "cannon_hit" ), 50.00, 1000.0, 25.0, -1, 0.0300 ))
		projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_RICOCHET_SPARK], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0,0, 0,0, 135,225, 0.50,2.50 )
		projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
	projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN] = PROJECTILE( PROJECTILE.Create( get_image( "mgun" ), get_sound( "mgun_hit" ), 5.00,,, -1, 0.0050 ))
		projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_RICOCHET_SPARK], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0,0, 0,0, 135,225, 0.50,1.00 )
	projectile_archetype[PROJECTILE_INDEX_LASER] = PROJECTILE( PROJECTILE.Create( get_image( "laser" ), get_sound( "laser_hit" ), 15.00,,, INFINITY, 0.0001,, True ))
		projectile_archetype[PROJECTILE_INDEX_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_archetype[PROJECTILE_INDEX_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_SECONDARY_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0, 5,8, 0,359.999, 1.3,2.5 )
		projectile_archetype[PROJECTILE_INDEX_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
	projectile_archetype[PROJECTILE_INDEX_ROCKET] = PROJECTILE( PROJECTILE.Create( get_image( "rocket" ), get_sound( "cannon_hit" ), 100.00, 2000.0, 50.0, 4.00, 0.0400, 0.00025 ))
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST], PROJECTILE_MEMBER_EMITTER_CONSTANT ).attach_at( -11, 0 )
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL], PROJECTILE_MEMBER_EMITTER_CONSTANT ).attach_at( -11, 0, 0, 10, -30, 30 )
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
End Function
	
'______________________________________________________________________________
'[ PROJECTILE LAUNCHERS ] (emitters)
Global projectile_launcher_archetype:EMITTER[10]; reset_index()

Global PROJECTILE_LAUNCHER_INDEX_TANK_CANNON% = postfix_index()
Global PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN% = postfix_index()
Global PROJECTILE_LAUNCHER_INDEX_LASER% = postfix_index()
Global PROJECTILE_LAUNCHER_INDEX_ROCKET% = postfix_index()

Function set_projectile_launcher_archetypes()
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_TANK_CANNON] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_TANK_CANNON,, True, False, False, True, True ))
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_MACHINE_GUN,, True, False, False, True, True ))
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_LASER] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_LASER,, False, False, False, True, True ))
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_ROCKET] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_ROCKET,, True, False, False, True, True ))
End Function
	
'______________________________________________________________________________
'[ WIDGETS ]
Global widget_archetype:WIDGET[10]; reset_index()

Global WIDGET_INDEX_AI_SEEK_LIGHT% = postfix_index()
Global WIDGET_INDEX_AI_WANDER_LIGHT% = postfix_index()
Global WIDGET_INDEX_ARENA_DOOR% = postfix_index()

Function set_widget_archetypes()
	widget_archetype[WIDGET_INDEX_AI_SEEK_LIGHT] = WIDGET( WIDGET.Create( "AI seek light", get_image( "glow" ), LAYER_IN_FRONT_OF_PARENT,, REPEAT_MODE_CYCLIC_WRAP, 2, True ))
		widget_archetype[WIDGET_INDEX_AI_SEEK_LIGHT].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 127, 127, 0.000, 1, 1, 200 )))
		widget_archetype[WIDGET_INDEX_AI_SEEK_LIGHT].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 127, 127, 0.750, 1, 1, 200 )))
	widget_archetype[WIDGET_INDEX_AI_WANDER_LIGHT] = WIDGET( WIDGET.Create( "AI wander light", get_image( "glow" ), LAYER_IN_FRONT_OF_PARENT,, REPEAT_MODE_CYCLIC_WRAP, 2, True ))
		widget_archetype[WIDGET_INDEX_AI_WANDER_LIGHT].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 96, 96, 255, 0.000, 1, 1, 400 )))
		widget_archetype[WIDGET_INDEX_AI_WANDER_LIGHT].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 96, 96, 255, 0.750, 1, 1, 400 )))
	widget_archetype[WIDGET_INDEX_ARENA_DOOR] = WIDGET( WIDGET.Create( , get_image( "door" ), LAYER_IN_FRONT_OF_PARENT,, REPEAT_MODE_CYCLIC_WRAP, 2, False ))
		widget_archetype[WIDGET_INDEX_ARENA_DOOR].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 255, 255, 1, 1, 1, 1750 )))
		widget_archetype[WIDGET_INDEX_ARENA_DOOR].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 35, 0, 0, 255, 255, 255, 1, 1, 1, 925 )))
End Function

'______________________________________________________________________________
'[ PICKUPS ]
Global pickup_archetype:PICKUP[10]; reset_index()

Global PICKUP_INDEX_HEALTH% = postfix_index()
Global PICKUP_INDEX_CANNON_AMMO% = postfix_index()
Global PICKUP_INDEX_COOLDOWN% = postfix_index()

Function set_pickup_archetypes()
	pickup_archetype[PICKUP_INDEX_HEALTH] = PICKUP( PICKUP.Create( get_image( "pickup_health" ), HEALTH_PICKUP, 200, 20000 ))
	pickup_archetype[PICKUP_INDEX_CANNON_AMMO] = PICKUP( PICKUP.Create( get_image( "pickup_ammo_main_5" ), AMMO_PICKUP, 5, 20000 ))
	pickup_archetype[PICKUP_INDEX_COOLDOWN] = PICKUP( PICKUP.Create( get_image( "pickup_cooldown" ), COOLDOWN_PICKUP, 4000, 20000 ))
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
	turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON] = TURRET( TURRET.Create( "105mm cannon", TURRET_CLASS_AMMUNITION, get_image( "player_tank_turret_base" ), get_sound( "cannon" ), 1, [[0]], 2.25, 40,,,,,, 500.0 ))
		turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CANNON], 0 ).attach_at( 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN] = TURRET( TURRET.Create( "0.50 machine-gun", TURRET_CLASS_AMMUNITION, Null, get_sound( "mgun" ), 1, [[0]], 2.25, INFINITY, 25.0, 1.50, 2.75, 0.0210, 1500, 250.0 ))
		turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN], 0 ).attach_at( 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_LASER] = TURRET( TURRET.Create( "10 MW laser", TURRET_CLASS_ENERGY, get_image( "laser_turret_base-barrel" ), get_sound( "laser" ), 1, [[0]], 2.25, INFINITY, 50.0, 5.50, 5.75, 0.0090, 3000, 400.0 ))
		turret_archetype[TURRET_INDEX_TANK_LASER].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_LASER], 0 ).attach_at( 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON] = TURRET( TURRET.Create( "105mm cannon (2x)", TURRET_CLASS_AMMUNITION, get_image( "player_tank_turret_med_base" ), get_sound( "cannon" ), 2, [[0],[1]], 2.00, 40,,,,,, 500.0 ))
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_LEFT], 0 ).attach_at( 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_DUAL_LIGHT_CANNON_RIGHT], 1 ).attach_at( 0, 0 )
	turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN] = TURRET( TURRET.Create( "0.50 machine-gun", TURRET_CLASS_AMMUNITION, Null, get_sound( "mgun" ), 1, [[0]], 2.00, INFINITY, 25.0, 1.50, 2.50, 0.0210, 1500, 200.0 ))
		turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CO_AXIAL_MACHINE_GUN_2], 0 ).attach_at( 0, 0 )
	turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET] = TURRET( TURRET.Create( "0.50 machine-gun", TURRET_CLASS_AMMUNITION, get_image( "enemy_stationary-emplacement-1_turret-base" ), get_sound( "mgun" ), 1, [[0]], 0.80, INFINITY, 25.0, 2.0, 3.0, 0.0175, 2000, 300.0 ))
		turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_MACHINE_GUN], 0 ).attach_at( 0, 0 )
	turret_archetype[TURRET_INDEX_CANNON_TURRET] = TURRET( TURRET.Create( "105mm cannon", TURRET_CLASS_AMMUNITION, get_image( "enemy_stationary-emplacement-1_turret-base" ), get_sound( "cannon" ), 1, [[0]], 0.50, INFINITY,,,,,, 600.0 ))
		turret_archetype[TURRET_INDEX_CANNON_TURRET].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_LIGHT_CANNON], 0 ).attach_at( 0, 0 )
	turret_archetype[TURRET_INDEX_ROCKET_TURRET] = TURRET( TURRET.Create( "rocket launcher", TURRET_CLASS_AMMUNITION, get_image( "enemy_stationary-emplacement-1_turret-base" ), get_sound( "rocket_launch" ), 1, [[0]], 0.50, INFINITY,,,,,, 600.0 ))
		turret_archetype[TURRET_INDEX_ROCKET_TURRET].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_EMPLACEMENT_ROCKET_LAUNCHER], 0 ).attach_at( 0, 0 )
	turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN] = TURRET( TURRET.Create( "0.50 machine-gun", TURRET_CLASS_AMMUNITION, get_image( "enemy_light_mgun_turret_base" ), get_sound( "mgun" ), 1, [[0]], 2.00, INFINITY, 25.0, 5.0, 5.5, 0.0175, 2000, 250.0 ))
		turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_turret_barrel( turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_MACHINE_GUN], 0 ).attach_at( 0, 0 )
End Function

'______________________________________________________________________________
'[ AI_TYPE ]
Function set_ai_type_archetypes()
	ai_type_map.Insert( "wildlife", Create_AI_TYPE( False, True, False, False ))
	ai_type_map.Insert( "turret", Create_AI_TYPE( True, False, False, False ))
	ai_type_map.Insert( "bomb", Create_AI_TYPE( False, True, True, False ))
	ai_type_map.Insert( "vehicle", Create_AI_TYPE( True, True, False, False ))
	ai_type_map.Insert( "carrier", Create_AI_TYPE( False, True, False, True ))
End Function

'______________________________________________________________________________
'[ COMPLEX_AGENTS ]
Global complex_agent_archetype:COMPLEX_AGENT[10]; reset_index()

'[ PLAYERS ]
Global player_index_start% = array_index
Global PLAYER_INDEX_LIGHT_TANK% = postfix_index()
Global PLAYER_INDEX_LASER_TANK% = postfix_index()
Global PLAYER_INDEX_MEDIUM_TANK% = postfix_index()
'[ ENEMIES ]
Global enemy_index_start% = array_index
Global ENEMY_INDEX_MR_THE_BOX% = postfix_index()
Global ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_MOBILE_MINI_BOMB% = postfix_index()
Global ENEMY_INDEX_LIGHT_QUAD% = postfix_index()
Global ENEMY_INDEX_LIGHT_TANK% = postfix_index()

Function set_complex_agent_archetypes()
	
	'max speed = 1.0
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "light tank", get_image( "player_tank_chassis" ), get_image( "quad_gibs" ), "vehicle", 0, 500, 800.0, 75.0, 75.0, 100.0 ))
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_turret_anchor( cVEC.Create( -5, 0 ))
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON], 0 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN], 0 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 12, -7, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 12, 7, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -12, -7, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -12, 7, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] ), EVENT_DRIVE_FORWARD ).attach_at( 12, -6, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] ), EVENT_DRIVE_FORWARD ).attach_at( 12, 6, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] ), EVENT_DRIVE_BACKWARD ).attach_at( -12, -6, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] ), EVENT_DRIVE_BACKWARD ).attach_at( -12, 6, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].left_track = particle_archetype[PARTICLE_INDEX_LIGHT_TANK_TRACK].clone()
			complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].left_track.parent = complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK]
			complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].left_track.attach_at( 0, -6.5 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].right_track = particle_archetype[PARTICLE_INDEX_LIGHT_TANK_TRACK].clone()
			complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].right_track.parent = complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK]
			complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].right_track.attach_at( 0, 6.5 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
	
	complex_agent_archetype[PLAYER_INDEX_LASER_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK] ))
		complex_agent_archetype[PLAYER_INDEX_LASER_TANK].name = "light tank/laser"
		complex_agent_archetype[PLAYER_INDEX_LASER_TANK].remove_all_turrets()
		complex_agent_archetype[PLAYER_INDEX_LASER_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_LASER], 0 )
	
	'max speed = 0.8
	complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "medium tank", get_image( "player_tank_chassis_med" ), get_image( "quad_gibs" ), "vehicle", 0, 750, 1200, 125.0, 100.0, 125.0 ))
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_turret_anchor( cVEC.Create( -9, 0 ))
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON], 0 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_turret( turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN], 0 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 15, -8, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 15, 8, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -15, -8, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -15, 8, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_MEDIUM] ), EVENT_DRIVE_FORWARD ).attach_at( 15, -8, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_MEDIUM] ), EVENT_DRIVE_FORWARD ).attach_at( 15, 8, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_MEDIUM] ), EVENT_DRIVE_BACKWARD ).attach_at( -15, -8, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_MEDIUM] ), EVENT_DRIVE_BACKWARD ).attach_at( -15, 8, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].left_track = particle_archetype[PARTICLE_INDEX_MED_TANK_TRACK].clone()
			complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].left_track.parent = complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK]
			complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].left_track.attach_at( 0, -7.5 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].right_track = particle_archetype[PARTICLE_INDEX_MED_TANK_TRACK].clone()
			complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].right_track.parent = complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK]
			complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].right_track.attach_at( 0, 7.5 )
		complex_agent_archetype[PLAYER_INDEX_MEDIUM_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		
	complex_agent_archetype[ENEMY_INDEX_MR_THE_BOX] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "mr. the box", get_image( "box" ), get_image( "box_gib" ), "wildlife", 50, 35, 350.0, 8.0, 6.0, 12.0 ))
		complex_agent_archetype[ENEMY_INDEX_MR_THE_BOX].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
	
	complex_agent_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "machine-gun emplacement", get_image( "enemy_stationary-emplacement-1_chassis" ), get_image( "tower_gibs" ), "turret", 100, 100, 1000.0, 0, 0, 0, True ))
		complex_agent_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].add_turret_anchor( cVEC.Create( 0, 0 ))
		complex_agent_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].add_turret( turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET], 0 )
		complex_agent_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
	
	complex_agent_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "cannon emplacement", get_image( "enemy_stationary-emplacement-1_chassis" ), get_image( "tower_gibs" ), "turret", 100, 100, 1000.0, 0, 0, 0, True ))
		complex_agent_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT].add_turret_anchor( cVEC.Create( 0, 0 ))
		complex_agent_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT].add_turret( turret_archetype[TURRET_INDEX_CANNON_TURRET], 0 )
		complex_agent_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		
	complex_agent_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "rocket emplacement", get_image( "enemy_stationary-emplacement-1_chassis" ), get_image( "tower_gibs" ), "turret", 150, 100, 1000.0, 0, 0, 0, True ))
		complex_agent_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT].add_turret_anchor( cVEC.Create( 0, 0 ))
		complex_agent_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT].add_turret( turret_archetype[TURRET_INDEX_ROCKET_TURRET], 0 )
		complex_agent_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		
	complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "mini bomb", get_image( "nme_mobile_bomb" ), get_image( "bomb_gibs" ), "bomb", 75, 50, 200, 10.0, 7.50, 30.0 ))
		complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB].add_widget( widget_archetype[WIDGET_INDEX_AI_SEEK_LIGHT], WIDGET_CONSTANT ).attach_at( -6, 0 )
		complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB].add_widget( widget_archetype[WIDGET_INDEX_AI_WANDER_LIGHT], WIDGET_CONSTANT ).attach_at( -6, 0 )
		complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "machine-gun quad", get_image( "enemy_quad_chassis" ), get_image( "quad_gibs" ), "vehicle", 100, 50, 400, 25.0, 35.0, 55.0 ))
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_turret_anchor( cVEC.Create( -6, 0 ))
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_turret( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 0 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 3, -4, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 3, 4, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -3, -4, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -3, 4, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] ), EVENT_DRIVE_FORWARD ).attach_at( 3, -4, 1, 1 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] ), EVENT_DRIVE_FORWARD ).attach_at( 3, 4, 1, 1 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] ), EVENT_DRIVE_BACKWARD ).attach_at( -3, -4, 1, 1 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL_SMALL] ), EVENT_DRIVE_BACKWARD ).attach_at( -3, 4, 1, 1 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )

	complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK] ))
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].cash_value = 300
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].max_health = 175
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].turrets[0].turret_barrel_array[0].reload_time = 1500
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].turrets[0].max_heat = 20.0
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].driving_force.magnitude_max = 66.0
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].turning_force.magnitude_max = 75.0
		
End Function
