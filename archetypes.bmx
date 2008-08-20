Rem
	archetypes.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global array_index%
Function reset_index()
	array_index = 0
End Function
Function postfix_index%( amount% = 1 )
	array_index :+ amount
	Return (array_index - amount)
End Function
'______________________________________________________________________________
Function load_all_archetypes()
	set_particle_archetypes()
	set_particle_emitter_archetypes()
	set_projectile_archetypes()
	set_projectile_launcher_archetypes()
	set_widget_archetypes()
	set_pickup_archetypes()
	set_turret_archetypes()
	set_complex_agent_archetypes()
End Function

'______________________________________________________________________________
'[ PARTICLES ]
Global particle_archetype:PARTICLE[50]; reset_index()

Global PARTICLE_INDEX_TANK_TREAD_DEBRIS% = postfix_index()
Global PARTICLE_INDEX_TANK_TREAD_TRAIL% = postfix_index()
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
Global PARTICLE_INDEX_ROCKET_SMOKE_TRAIL% = postfix_index()

Function set_particle_archetypes()
	particle_archetype[PARTICLE_INDEX_TANK_TREAD_DEBRIS] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_debris,,,,, LAYER_BACKGROUND, True, 0.05 ))
	particle_archetype[PARTICLE_INDEX_TANK_TREAD_TRAIL] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_trail,,,,, LAYER_BACKGROUND, True ))
	particle_archetype[PARTICLE_INDEX_LIGHT_TANK_TRACK] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_ANIM, img_light_tank_track,,,,,,,,,,,,,, INFINITY ))
	particle_archetype[PARTICLE_INDEX_MED_TANK_TRACK] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_ANIM, img_player_med_tank_track,,,,,,,,,,,,,, INFINITY ))
	particle_archetype[PARTICLE_INDEX_CANNON_MUZZLE_FLASH] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_muzzle_flash,,,,, LAYER_FOREGROUND ))
	particle_archetype[PARTICLE_INDEX_CANNON_SHELL_CASING] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_projectile_shell_casing,,,,, LAYER_FOREGROUND, True, 0.0100 ))
	particle_archetype[PARTICLE_INDEX_CANNON_MUZZLE_SMOKE] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_muzzle_smoke,,,,, LAYER_FOREGROUND ))
	particle_archetype[PARTICLE_INDEX_EXPLOSION] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_circle,,,,, LAYER_FOREGROUND, False, 0.0850 ))
	particle_archetype[PARTICLE_INDEX_RICOCHET_SPARK] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_spark,,,,, LAYER_FOREGROUND, False, 0.0100 ))
	particle_archetype[PARTICLE_INDEX_IMPACT_HALO] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_halo,,,,, LAYER_BACKGROUND, False, 0 ))
	particle_archetype[PARTICLE_INDEX_MACHINE_GUN_MUZZLE_FLASH] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_mgun_muzzle_flash,,,,, LAYER_FOREGROUND ))
	particle_archetype[PARTICLE_INDEX_MACHINE_GUN_SHELL_CASING] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_mgun_shell_casing,,,,, LAYER_FOREGROUND, True, 0.0100 ))
	particle_archetype[PARTICLE_INDEX_MACHINE_GUN_MUZZLE_SMOKE] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_mgun_muzzle_smoke,,,,, LAYER_FOREGROUND ))
	particle_archetype[PARTICLE_INDEX_LASER_MUZZLE_FLARE] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_laser_muzzle_flare,,,,, LAYER_FOREGROUND, False ))
	particle_archetype[PARTICLE_INDEX_ROCKET_THRUST] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_rocket_thrust,,,,, LAYER_BACKGROUND ))
	particle_archetype[PARTICLE_INDEX_ROCKET_SMOKE_TRAIL] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_muzzle_smoke,,,,, LAYER_FOREGROUND ))
End Function

'______________________________________________________________________________
'[ PARTICLE EMITTERS ]
Global particle_emitter_archetype:EMITTER[25]; reset_index();

Global PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS% = postfix_index()
Global PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL% = postfix_index()
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
Global PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS% = postfix_index()
Global PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL% = postfix_index()

Function set_particle_emitter_archetypes()
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] = EMITTER( EMITTER.Archetype( "tank tread debris", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_DEBRIS,,, True,,,, 100, 150, 0, 0, 200, 350, 0.75, 0.75, -0.0012, -0.0025 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] = EMITTER( EMITTER.Archetype( "tank tread trail", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_TRAIL,,,,,,, 100, 100,,, 50, 50 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] = EMITTER( EMITTER.Archetype( "explosion", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_EXPLOSION,,,,,,,,,,, 250,300, 1.0,1.0, -0.100,-0.100, 1.0,1.0, -0.050,-0.050, 1.0,1.0, 1.0,1.0, 0.8,0.8, -0.002,-0.002, -0.035,-0.035, -0.030,-0.030 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( "cannon muzzle flash", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_MUZZLE_FLASH,,,,,,,,,,, 50, 50 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING] = EMITTER( EMITTER.Archetype( "cannon shell casing", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_SHELL_CASING,, True, True,,, True,,,,, 2200, 2200 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( "cannon muzzle smoke", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_MUZZLE_SMOKE,,, True,,,,,, 10, 12, 500, 1000, 0.08, 0.16, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION] = EMITTER( EMITTER.Archetype( "cannon explosion", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_EXPLOSION,,,,,,,,,,, 300,350, 1.0,1.0, -0.100,-0.100, 0.350, 0.400, -0.0075, -0.0075, 1.0,1.0, 1.0,1.0, 0.8,0.8, -0.002,-0.002, -0.035,-0.035, -0.030,-0.030 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_RICOCHET_SPARK] = EMITTER( EMITTER.Archetype( "cannon ricochet spark", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_RICOCHET_SPARK,,, True, True,,,,,,, 50, 50, 1, 1,,, 0.75, 0.75 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO] = EMITTER( EMITTER.Archetype( "cannon impact halo", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_IMPACT_HALO,,,,,,,,,,, 100, 100, 0.5, 0.5, 0, 0, 0.35, 0.35, -0.0100, -0.0100 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( "machine gun muzzle flash", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_MUZZLE_FLASH,,,,,,,,,,, 25, 25 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING] = EMITTER( EMITTER.Archetype( "machine gun shell casing", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_SHELL_CASING,, True, True,,, True,,,,, 1400, 1800 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( "machine gun muzzle smoke", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_MUZZLE_SMOKE,,, True,,,,,, 6, 8, 300, 600, 0.06, 0.12, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_RICOCHET_SPARK] = EMITTER( EMITTER.Archetype( "machine gun ricochet spark", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_RICOCHET_SPARK,,, True, True,,,,,,, 50, 50, 1, 1, 0.0, 0.0, 0.50, 0.50, 0, 0 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE] = EMITTER( EMITTER.Archetype( "laser muzzle flare", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_LASER_MUZZLE_FLARE,,,,,,,,,,, 50, 50 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_EXPLOSION] = EMITTER( EMITTER.Archetype( "laser explosion", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_EXPLOSION,,,,,,,,,,, 250,300, 1.0,1.0, -0.100,-0.100, 0.275,0.300, -0.0065,-0.0065, 1.0,1.0, 0.65,0.65, 0.65,0.65 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_SECONDARY_EXPLOSION] = EMITTER( EMITTER.Archetype( "laser secondary explosion", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_EXPLOSION,,,, True, True,,,, 5,8, 300,300, 1.0,1.0, -0.100,-0.100, 0.100,0.120, -0.0050,-0.0050, 1.0,1.0, 0.65,0.65, 0.65,0.65 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_IMPACT_HALO] = EMITTER( EMITTER.Archetype( "laser impact halo", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_IMPACT_HALO,,,,,,,,,,, 100,100, 0.5,0.5, 0,0, 0.20,0.20, -0.0080,-0.0080, 1.0,1.0, 0.75,0.75, 0.75,0.75 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST] = EMITTER( EMITTER.Archetype( "rocket thrust", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_ROCKET_THRUST, MODE_ENABLED_FOREVER,,,,,, 10, 15,,, 10, 15, 0.50, 0.75, 0, 0, 0.25, 1.00, 0, 0 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL] = EMITTER( EMITTER.Archetype( "rocket smoke trail", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_ROCKET_SMOKE_TRAIL, MODE_ENABLED_FOREVER,,,,,, 0, 30, 0, 0, 250, 500, 0.06, 0.12, -0.002, -0.020, 0.10, 0.70, 0.0008, 0.0300 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS] = EMITTER( EMITTER.Archetype( "quad wheel debris", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_DEBRIS,,, True,,,, 100, 150, 0, 0, 200, 350, 0.75, 0.75, -0.0012, -0.0025 ))
	particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL] = EMITTER( EMITTER.Archetype( "quad wheel trail", EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_TRAIL,,,,,,, 100, 100,,, 50, 50,,,,, 0.60, 0.60, 0.0, 0.0 ))
End Function

'______________________________________________________________________________
'[ PROJECTILES ]
Global projectile_archetype:PROJECTILE[10]; reset_index()

Global PROJECTILE_INDEX_TANK_CANNON% = postfix_index()
Global PROJECTILE_INDEX_MACHINE_GUN% = postfix_index()
Global PROJECTILE_INDEX_LASER% = postfix_index()
Global PROJECTILE_INDEX_ROCKET% = postfix_index()

Function set_projectile_archetypes()
	projectile_archetype[PROJECTILE_INDEX_TANK_CANNON] = PROJECTILE( PROJECTILE.Create( "tank cannon", img_projectile, get_sound( "cannon_hit" ), 50.00, 1000.0, 25.0, -1, 0.0300 ))
		projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_RICOCHET_SPARK], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0, 1, 1, 135, 225, 0.2, 0.8 )
		projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
	projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN] = PROJECTILE( PROJECTILE.Create( "machine gun", img_mgun, get_sound( "mgun_hit" ), 5.00,,, -1, 0.0050 ))
		projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_RICOCHET_SPARK], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0, 1, 1, 135, 225 )
	projectile_archetype[PROJECTILE_INDEX_LASER] = PROJECTILE( PROJECTILE.Create( "laser", img_laser, get_sound( "laser_hit" ), 15.00,,, INFINITY, 0.0001,, True ))
		projectile_archetype[PROJECTILE_INDEX_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
		projectile_archetype[PROJECTILE_INDEX_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_SECONDARY_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0, 5,8, 0,359.999, 1.3,2.5 )
		projectile_archetype[PROJECTILE_INDEX_LASER].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
	projectile_archetype[PROJECTILE_INDEX_ROCKET] = PROJECTILE( PROJECTILE.Create( "rocket", img_rocket, get_sound( "cannon_hit" ), 100.00, 2000.0, 50.0, 4.00, 0.0400, 0.00025 ))
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST], PROJECTILE_MEMBER_EMITTER_CONSTANT ).attach_at( -11, 0 )
		projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL], PROJECTILE_MEMBER_EMITTER_CONSTANT ).attach_at( -11, 0, 0, 10, 150, 210 )
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
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_TANK_CANNON] = EMITTER( EMITTER.Archetype( "tank cannon", EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_TANK_CANNON,, True, False, False, True, True ))
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN] = EMITTER( EMITTER.Archetype( "machine gun", EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_MACHINE_GUN,, True, False, False, True, True ))
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_LASER] = EMITTER( EMITTER.Archetype( "laser", EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_LASER,, False, False, False, True, True ))
	projectile_launcher_archetype[PROJECTILE_LAUNCHER_INDEX_ROCKET] = EMITTER( EMITTER.Archetype( "rocket", EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_ROCKET,, True, False, False, True, True ))
End Function
	
'______________________________________________________________________________
'[ WIDGETS ]
Global widget_archetype:WIDGET[10]; reset_index()

Global WIDGET_INDEX_AI_SEEK_LIGHT% = postfix_index()
Global WIDGET_INDEX_AI_WANDER_LIGHT% = postfix_index()
Global WIDGET_INDEX_ARENA_DOOR% = postfix_index()

Function set_widget_archetypes()
	widget_archetype[WIDGET_INDEX_AI_SEEK_LIGHT] = WIDGET( WIDGET.Create( "AI seek light", img_glow, LAYER_IN_FRONT_OF_PARENT,, REPEAT_MODE_CYCLIC_WRAP, 2, True ))
		widget_archetype[WIDGET_INDEX_AI_SEEK_LIGHT].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 127, 127, 0.000, 1, 1, 200 )))
		widget_archetype[WIDGET_INDEX_AI_SEEK_LIGHT].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 127, 127, 0.750, 1, 1, 200 )))
	widget_archetype[WIDGET_INDEX_AI_WANDER_LIGHT] = WIDGET( WIDGET.Create( "AI wander light", img_glow, LAYER_IN_FRONT_OF_PARENT,, REPEAT_MODE_CYCLIC_WRAP, 2, True ))
		widget_archetype[WIDGET_INDEX_AI_WANDER_LIGHT].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 96, 96, 255, 0.000, 1, 1, 400 )))
		widget_archetype[WIDGET_INDEX_AI_WANDER_LIGHT].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 96, 96, 255, 0.750, 1, 1, 400 )))
	widget_archetype[WIDGET_INDEX_ARENA_DOOR] = WIDGET( WIDGET.Create( "door", img_door, LAYER_IN_FRONT_OF_PARENT,, REPEAT_MODE_CYCLIC_WRAP, 2, False ))
		widget_archetype[WIDGET_INDEX_ARENA_DOOR].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 255, 255, 1, 1, 1, 1750 )))
		widget_archetype[WIDGET_INDEX_ARENA_DOOR].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 25, 0, 0, 255, 255, 255, 1, 1, 1, 925 )))
End Function

'______________________________________________________________________________
'[ PICKUPS ]
Global pickup_archetype:PICKUP[10]; reset_index()

Global PICKUP_INDEX_HEALTH% = postfix_index()
Global PICKUP_INDEX_CANNON_AMMO% = postfix_index()
Global PICKUP_INDEX_COOLDOWN% = postfix_index()

Function set_pickup_archetypes()
	pickup_archetype[PICKUP_INDEX_HEALTH] = PICKUP( PICKUP.Create( img_pickup_health, HEALTH_PICKUP, 100, 20000 ))
	pickup_archetype[PICKUP_INDEX_CANNON_AMMO] = PICKUP( PICKUP.Create( img_pickup_ammo_main_5, AMMO_PICKUP, 5, 20000 ))
	pickup_archetype[PICKUP_INDEX_COOLDOWN] = PICKUP( PICKUP.Create( img_pickup_cooldown, COOLDOWN_PICKUP, 4000, 20000 ))
End Function

'______________________________________________________________________________
'[ TURRETS ]
Global turret_barrel_archetype:TURRET_BARREL[20]; reset_index()

Global TURRET_BARREL_INDEX_LIGHT_CANNON% = postfix_index()
LIGHT_CO_AXIAL_MACHINE_GUN
LIGHT_LASER
DUAL_LIGHT_CANNON_LEFT
DUAL_LIGHT_CANNON_RIGHT
LIGHT_CO_AXIAL_MACHINE_GUN_2
EMPLACEMENT_LIGHT_MACHINE_GUN
EMPLACEMENT_LIGHT_CANNON
EMPLACEMENT_ROCKET_LAUNCHER
LIGHT_MACHINE_GUN

Function set_turret_barrel_archetypes()
	turret_barrel_archetype[TURRET_BARREL_INDEX_LIGHT_CANNON] = Create_TURRET_BARREL( )
End Function


'______________________________________________________________________________
'[ TURRETS ]
Global turret_archetype:TURRET[20]; reset_index()

Global TURRET_INDEX_TANK_SINGLE_CANNON% = postfix_index()
Global TURRET_INDEX_TANK_MACHINE_GUN% = postfix_index()
Global TURRET_INDEX_TANK_LASER% = postfix_index()
Global TURRET_INDEX_TANK_DUAL_CANNON_LEFT% = postfix_index()
Global TURRET_INDEX_TANK_DUAL_CANNON_RIGHT% = postfix_index()
Global TURRET_INDEX_MED_TANK_MACHINE_GUN% = postfix_index()
Global TURRET_INDEX_MACHINE_GUN_TURRET% = postfix_index()
Global TURRET_INDEX_CANNON_TURRET% = postfix_index()
Global TURRET_INDEX_ROCKET_TURRET% = postfix_index()
Global TURRET_INDEX_LIGHT_MACHINE_GUN% = postfix_index()
	
Function set_turret_archetypes()
	turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON] = TURRET( TURRET.Create( "105mm cannon", TURRET_CLASS_AMMUNITION, img_player_tank_turret_base, img_player_tank_turret_barrel, get_sound( "cannon" ), 650, 40, -7, 0 ))
		turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_TANK_CANNON ).attach_at( 20, 0, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH ).attach_at( 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE ).attach_at( 20, 0, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING ).attach_at( -3, 3, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN] = TURRET( TURRET.Create( "0.50 machine gun", TURRET_CLASS_AMMUNITION, Null, img_player_mgun_turret, get_sound( "mgun" ), 62, INFINITY, 0, 0, 25.0, 1.50, 2.75, 0.0210, 1500 ))
		turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN ).attach_at( 14, 2, 0, 0, 0, 0, 4.30, 4.70, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_at( 14, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_at( 14, 2, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_at( 8, 2, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_LASER] = TURRET( TURRET.Create( "10 mw laser", TURRET_CLASS_ENERGY, img_laser_turret, Null, get_sound( "laser" ), 250, INFINITY, 0, 0, 50.0, 5.50, 5.75, 0.0090, 3000 ))
		turret_archetype[TURRET_INDEX_TANK_LASER].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_LASER ).attach_at( 14, 0, 0, 0, 0, 0, 8.00, 8.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_LASER].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE ).attach_at( 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT] = TURRET( TURRET.Create( "105mm paired cannons", TURRET_CLASS_AMMUNITION, img_player_tank_turret_med_base_left, img_player_tank_turret_med_barrel_left, get_sound( "cannon" ), 485, 20, -9, 0, INFINITY ))
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_TANK_CANNON ).attach_at( 24, -2, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH ).attach_at( 24, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE ).attach_at( 24, -2, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING ).attach_at( 11, -3, 0, 0, 0, 0, 0.4, 0.6, 260, 280, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_player_tank_turret_med_base_right, img_player_tank_turret_med_barrel_right, get_sound( "cannon" ), 485, 20, -9, 0, INFINITY ))
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_TANK_CANNON ).attach_at( 24, 2, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH ).attach_at( 24, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE ).attach_at( 24, 2, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING ).attach_at( 11, 3, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
	turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN] = TURRET( TURRET.Create( "0.50 machine gun", TURRET_CLASS_AMMUNITION, Null, img_player_tank_turret_med_mgun_barrel, get_sound( "mgun" ), 62.50, INFINITY, 0, 0, 25.0, 1.50, 2.50, 0.0210, 1500 ))
		turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN ).attach_at( 5, 4, 0, 0, 0, 0, 4.30, 4.70, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_at( 5, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_at( 5, 4, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_at( 0, 5, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )
	turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_enemy_stationary_emplacement_1_turret_base, img_enemy_stationary_emplacement_2_turret_barrel, get_sound( "mgun" ), 50, INFINITY, 0, 0, 25.0, 2.0, 3.0, 0.0175, 2000 ))
		turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN ).attach_at( 16, 0, 0, 0, 0, 0, 2.50, 3.00, 0, 0, 0, 0, 0, 0, -4.0, 4.0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_at( 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_at( 16, 0, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_at( 3, 3, 0, 0, 0, 0, 0.4, 0.6, 70, 110, -0.004, -0.004, 0, 0, -5, 5, -5, 5, 0, 0 )
	turret_archetype[TURRET_INDEX_CANNON_TURRET] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_enemy_stationary_emplacement_1_turret_base, img_player_tank_turret_barrel, get_sound( "cannon" ), 2800, INFINITY, -7, 0 ))
		turret_archetype[TURRET_INDEX_CANNON_TURRET].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_TANK_CANNON ).attach_at( 20, 0, 0, 0, 0, 0, 2.80, 3.00, 0, 0, 0, 0, 0, 0, -1.5, 1.5, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_CANNON_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH ).attach_at( 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_CANNON_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE ).attach_at( 20, 0, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_CANNON_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING ).attach_at( 5, 1, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
	turret_archetype[TURRET_INDEX_ROCKET_TURRET] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_enemy_stationary_emplacement_1_turret_base, img_enemy_stationary_emplacement_1_turret_barrel, Null, 4000, INFINITY, 0, 0 ))
		turret_archetype[TURRET_INDEX_ROCKET_TURRET].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_ROCKET ).attach_at( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0020, 0.0020, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_enemy_light_mgun_turret_base, img_enemy_light_mgun_turret_barrel, get_sound( "mgun" ), 100, INFINITY, 0, 0, 25.0, 5.0, 5.5, 0.0175, 2000 ))
		turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_LAUNCHER_INDEX_MACHINE_GUN ).attach_at( 8, 0, 0, 0, 0, 0, 3.0, 3.4, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_at( 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_at( 8, 0, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_at( 1, 1, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )
End Function

'______________________________________________________________________________
''[ TURRET_GROUPS ]
'Global turret_group_archetype:TURRET_GROUP[15]; reset_index()
'
'Global TURRET_GROUP_INDEX_TANK_SINGLE_CANNON% = postfix_index()
'Global TURRET_GROUP_INDEX_TANK_MACHINE_GUN% = postfix_index()
'Global TURRET_GROUP_INDEX_TANK_LASER% = postfix_index()
'Global TURRET_GROUP_INDEX_TANK_DUAL_CANNON% = postfix_index()
'Global TURRET_GROUP_INDEX_MED_TANK_MACHINE_GUN% = postfix_index()
'Global TURRET_GROUP_INDEX_MACHINE_GUN_TURRET% = postfix_index()
'Global TURRET_GROUP_INDEX_CANNON_TURRET% = postfix_index()
'Global TURRET_GROUP_INDEX_ROCKET_TURRET% = postfix_index()
'Global TURRET_GROUP_INDEX_LIGHT_MACHINE_GUN% = postfix_index()
'
'Function set_turret_group_archetypes()
'	turret_group_archetype[TURRET_GROUP_INDEX_TANK_SINGLE_CANNON] = Create_TURRET_GROUP( 1, [[0]], 2.25 )
'		turret_group_archetype[TURRET_GROUP_INDEX_TANK_SINGLE_CANNON].add_turret( turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON], 0 )
'	turret_group_archetype[TURRET_GROUP_INDEX_TANK_MACHINE_GUN] = Create_TURRET_GROUP( 1, [[0]], 2.25 )
'		turret_group_archetype[TURRET_GROUP_INDEX_TANK_MACHINE_GUN].add_turret( turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN], 0 )
'	turret_group_archetype[TURRET_GROUP_INDEX_TANK_LASER] = Create_TURRET_GROUP( 1, [[0]], 2.25 )
'		turret_group_archetype[TURRET_GROUP_INDEX_TANK_LASER].add_turret( turret_archetype[TURRET_INDEX_TANK_LASER], 0 )
'	turret_group_archetype[TURRET_GROUP_INDEX_TANK_DUAL_CANNON] = Create_TURRET_GROUP( 2, [[0],[1]], 2.00 )
'		turret_group_archetype[TURRET_GROUP_INDEX_TANK_DUAL_CANNON].add_turret( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT], 0 )
'		turret_group_archetype[TURRET_GROUP_INDEX_TANK_DUAL_CANNON].add_turret( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT], 1 )
'	turret_group_archetype[TURRET_GROUP_INDEX_MED_TANK_MACHINE_GUN] = Create_TURRET_GROUP( 1, [[0]], 2.00 )
'		turret_group_archetype[TURRET_GROUP_INDEX_MED_TANK_MACHINE_GUN].add_turret( turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN], 0 )
'	turret_group_archetype[TURRET_GROUP_INDEX_MACHINE_GUN_TURRET] = Create_TURRET_GROUP( 1, [[0]], 0.80 )
'		turret_group_archetype[TURRET_GROUP_INDEX_MACHINE_GUN_TURRET].add_turret( turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET], 0 )
'	turret_group_archetype[TURRET_GROUP_INDEX_CANNON_TURRET] = Create_TURRET_GROUP( 1, [[0]], 0.50 )
'		turret_group_archetype[TURRET_GROUP_INDEX_CANNON_TURRET].add_turret( turret_archetype[TURRET_INDEX_CANNON_TURRET], 0 )
'	turret_group_archetype[TURRET_GROUP_INDEX_ROCKET_TURRET] = Create_TURRET_GROUP( 1, [[0]], 0.50 )
'		turret_group_archetype[TURRET_GROUP_INDEX_ROCKET_TURRET].add_turret( turret_archetype[TURRET_INDEX_ROCKET_TURRET], 0 )
'	turret_group_archetype[TURRET_GROUP_INDEX_LIGHT_MACHINE_GUN] = Create_TURRET_GROUP( 1, [[0]], 2.00 )
'		turret_group_archetype[TURRET_GROUP_INDEX_LIGHT_MACHINE_GUN].add_turret( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 0 )
'End Function

'______________________________________________________________________________
'[ COMPLEX_AGENTS ]
Global complex_agent_archetype:COMPLEX_AGENT[20]; reset_index()

'[ PLAYERS ]
Global PLAYER_INDEX_START% = array_index
Global PLAYER_INDEX_LIGHT_TANK% = postfix_index()
Global PLAYER_INDEX_LASER_TANK% = postfix_index()
Global PLAYER_INDEX_MED_TANK% = postfix_index()
'[ ENEMIES ]
Global ENEMY_INDEX_START% = array_index
Global ENEMY_INDEX_MR_THE_BOX% = postfix_index()
Global ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_MOBILE_MINI_BOMB% = postfix_index()
Global ENEMY_INDEX_LIGHT_QUAD% = postfix_index()
Global ENEMY_INDEX_LIGHT_TANK% = postfix_index()

Function set_complex_agent_archetypes()
	
	' max speed = 1.0
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "light tank", img_player_tank_chassis, Null, AI_BRAIN_TANK, 0, 500, 800.0, 75.0, 75.0, 100.0 ))
'		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_turret_group( turret_group_archetype[TURRET_GROUP_INDEX_TANK_SINGLE_CANNON] ).attach_at( -5, 0 )
'		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_turret_group( turret_group_archetype[TURRET_GROUP_INDEX_TANK_MACHINE_GUN] ).attach_at( -5, 0 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 12, -7, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 12, 7, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -12, -7, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -12, 7, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_FORWARD ).attach_at( 12, -7, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_FORWARD ).attach_at( 12, 7, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_BACKWARD ).attach_at( -12, -7, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_BACKWARD ).attach_at( -12, 7, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].left_track = particle_archetype[PARTICLE_INDEX_LIGHT_TANK_TRACK].clone()
			complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].left_track.parent = complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK]
			complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].left_track.attach_at( 0, -7.5 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].right_track = particle_archetype[PARTICLE_INDEX_LIGHT_TANK_TRACK].clone()
			complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].right_track.parent = complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK]
			complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].left_track.attach_at( 0, 7.5 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
	
	' max speed = 1.0
	complex_agent_archetype[PLAYER_INDEX_LASER_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK] ))
		complex_agent_archetype[PLAYER_INDEX_LASER_TANK].name = "light tank/laser"
		complex_agent_archetype[PLAYER_INDEX_LASER_TANK].turret_groups = CreateList()
		complex_agent_archetype[PLAYER_INDEX_LASER_TANK].add_turret_group( turret_group_archetype[TURRET_GROUP_INDEX_TANK_LASER], 0 ).attach_at( -5, 0 )
	
	' max speed = 0.8
	complex_agent_archetype[PLAYER_INDEX_MED_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "medium tank", img_player_tank_chassis_med, Null, AI_BRAIN_TANK, 0, 750, 1200, 125.0, 100.0, 125.0 ))
'		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_turret_group( turret_group_archetype[TURRET_GROUP_INDEX_TANK_DUAL_CANNON], 0 ).attach_at( -9, 0 )
'		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_turret_group( turret_group_archetype[TURRET_GROUP_INDEX_MED_TANK_MACHINE_GUN], 1 ).attach_at( -9, 0 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 15, -8, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 15, 8, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -15, -8, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -15, 8, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_FORWARD ).attach_at( 15, -8, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_FORWARD ).attach_at( 15, 8, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_BACKWARD ).attach_at( -15, -8, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_BACKWARD ).attach_at( -15, 8, 1, 1 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].left_track = particle_archetype[PARTICLE_INDEX_MED_TANK_TRACK].clone()
			complex_agent_archetype[PLAYER_INDEX_MED_TANK].left_track.parent = complex_agent_archetype[PLAYER_INDEX_MED_TANK]
			complex_agent_archetype[PLAYER_INDEX_MED_TANK].left_track.attach_at( 0, -10.5 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].right_track = particle_archetype[PARTICLE_INDEX_MED_TANK_TRACK].clone()
			complex_agent_archetype[PLAYER_INDEX_MED_TANK].right_track.parent = complex_agent_archetype[PLAYER_INDEX_MED_TANK]
			complex_agent_archetype[PLAYER_INDEX_MED_TANK].right_track.attach_at( 0, -10.5 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		
	complex_agent_archetype[ENEMY_INDEX_MR_THE_BOX] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "mr. the box", img_box, img_box_gib, AI_BRAIN_MR_THE_BOX, 50, 35, 200.0, 10.0, 6.0, 12.0 ))
		complex_agent_archetype[ENEMY_INDEX_MR_THE_BOX].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
	
	complex_agent_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "machine-gun emplacement", img_enemy_stationary_emplacement_1_chassis, img_tower_gibs, AI_BRAIN_TURRET, 100, 100, 1000.0, 0, 0, 0, True ))
'		complex_agent_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].add_turret_group( turret_group_archetype[TURRET_GROUP_INDEX_MACHINE_GUN_TURRET], 0 ).attach_at( 0, 0 )
		complex_agent_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
	
	complex_agent_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "cannon emplacement", img_enemy_stationary_emplacement_1_chassis, img_tower_gibs, AI_BRAIN_TURRET, 100, 100, 1000.0, 0, 0, 0, True ))
'		complex_agent_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT].add_turret_group( turret_group_archetype[TURRET_GROUP_INDEX_CANNON_TURRET], 0 ).attach_at( 0, 0 )
		complex_agent_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		
	complex_agent_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "rocket emplacement", img_enemy_stationary_emplacement_1_chassis, img_tower_gibs, AI_BRAIN_TURRET, 150, 100, 1000.0, 0, 0, 0, True ))
'		complex_agent_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT].add_turret_group( turret_group_archetype[TURRET_GROUP_INDEX_ROCKET_TURRET], 0 ).attach_at( 0, 0 )
		complex_agent_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		
	complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "mini bomb", img_nme_mobile_bomb, img_bomb_gibs, AI_BRAIN_SEEKER, 75, 50, 200, 10.0, 7.50, 30.0 ))
		complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB].add_widget( widget_archetype[WIDGET_INDEX_AI_SEEK_LIGHT], WIDGET_CONSTANT ).attach_at( -6, 0 )
		complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB].add_widget( widget_archetype[WIDGET_INDEX_AI_WANDER_LIGHT], WIDGET_CONSTANT ).attach_at( -6, 0 )
		complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )
		
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "machine-gun quad", img_enemy_quad_chassis, img_quad_gibs, AI_BRAIN_TANK, 100, 50, 400, 25.0, 35.0, 55.0 ))
'		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_turret_group( turret_group_archetype[TURRET_GROUP_INDEX_LIGHT_MACHINE_GUN], 0 ).attach_at( -6, 0 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 3, -4, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_FORWARD ).attach_at( 3, 4, 0, 2, -45, 45, 0.3, 0.6 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -3, -4, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ), EVENT_DRIVE_BACKWARD ).attach_at( -3, 4, 0, 2, 135, 225, 0.3, 0.6 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_FORWARD ).attach_at( 3, -4, 1, 1 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_FORWARD ).attach_at( 3, 4, 1, 1 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_BACKWARD ).attach_at( -3, -4, 1, 1 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ), EVENT_DRIVE_BACKWARD ).attach_at( -3, 4, 1, 1 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_EXPLOSION] ), EVENT_DEATH ).attach_at( 0, 0 )

	complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK] ))
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].cash_value = 300
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].max_health = 150
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].add_widget( widget_archetype[WIDGET_INDEX_AI_SEEK_LIGHT], WIDGET_CONSTANT ).attach_at( -10.5, 0 )
		complex_agent_archetype[ENEMY_INDEX_LIGHT_TANK].add_widget( widget_archetype[WIDGET_INDEX_AI_WANDER_LIGHT], WIDGET_CONSTANT ).attach_at( -10.5, 0 )
		
End Function
