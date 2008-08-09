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
'[ PARTICLES ]
Global particle_archetype:PARTICLE[50]; reset_index()

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
Global PARTICLE_INDEX_TANK_TREAD_DEBRIS% = postfix_index()
Global PARTICLE_INDEX_TANK_TREAD_TRAIL% = postfix_index()
Global PARTICLE_INDEX_MR_THE_BOX_TRAIL% = postfix_index()

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
particle_archetype[PARTICLE_INDEX_TANK_TREAD_DEBRIS] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_debris,,,,, LAYER_BACKGROUND, True, 0.05 ))
particle_archetype[PARTICLE_INDEX_TANK_TREAD_TRAIL] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_trail,,,,, LAYER_BACKGROUND, True ))
particle_archetype[PARTICLE_INDEX_MR_THE_BOX_TRAIL] = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_box,,,,, LAYER_BACKGROUND ))

'______________________________________________________________________________
'[ PARTICLE EMITTERS ]
Global particle_emitter_archetype:EMITTER[20]; reset_index();

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
Global PARTICLE_EMITTER_INDEX_MACHINE_GUN_IMPACT_HALO% = postfix_index()
Global PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS% = postfix_index()
Global PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_MR_THE_BOX_TRAIL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_ROCKET_THRUST% = postfix_index()
Global PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE% = postfix_index()
Global PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS% = postfix_index()
Global PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL% = postfix_index()

particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_MUZZLE_FLASH,, False, False, False, False, False,,,,, 50, 50 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_SHELL_CASING,, True, True, False, False, True,,,,, 2200, 2200 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_MUZZLE_SMOKE,, False, True, False, False, False,,, 10, 12, 500, 1000, 0.08, 0.16, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_EXPLOSION,, False, False, False, False, False,,,,, 300, 350,,,,, 0.24, 0.28, -0.0006, -0.0009, 255,255, 255,255, 225,225, -0.010,-0.010, -0.010,-0.010, -0.008,-0.008 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_RICOCHET_SPARK] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_RICOCHET_SPARK,, False, True, True, False, False,,,,, 50, 50, 1, 1,,, 0.75, 0.75 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_IMPACT_HALO,, False, False, False, False, False,,,,, 100, 100, 0.5, 0.5, 0, 0, 0.35, 0.35, -0.0100, -0.0100 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_MUZZLE_FLASH,, False, False, False, False, False,,,,, 25, 25 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_SHELL_CASING,, True, True, False, False, True,,,,, 1400, 1800 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_MUZZLE_SMOKE,, False, True, False, False, False,,, 6, 8, 300, 600, 0.06, 0.12, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_RICOCHET_SPARK] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_RICOCHET_SPARK,, False, True, True, False, False,,,,, 50, 50, 1, 1, 0.0, 0.0, 0.50, 0.50, 0, 0 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_IMPACT_HALO] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_IMPACT_HALO,, False, False, False, False, False,,,,, 50, 50, 0.25, 0.25, 0, 0, 0.150, 0.150, -0.0005, -0.0005 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_DEBRIS,, False, True, False, False, False, 100, 150, 0, 0, 200, 350, 0.75, 0.75, -0.0012, -0.0025 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_TRAIL,, False, False, False, False, False, 100, 100,,, 50, 50 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MR_THE_BOX_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MR_THE_BOX_TRAIL, MODE_ENABLED_FOREVER, False, False, False, False, False, 500, 500, 0, 0, 3000, 3000, 0.5, 0.5, -0.004, -0.004 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_ROCKET_THRUST, MODE_ENABLED_FOREVER, False, False, False, False, False, 10, 15,,, 10, 15, 0.50, 0.75, 0, 0, 0.25, 1.00, 0, 0 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_ROCKET_SMOKE_TRAIL, MODE_ENABLED_FOREVER, False, False, False, False, False, 0, 30, 0, 0, 250, 500, 0.06, 0.12, -0.002, -0.020, 0.10, 0.70, 0.0008, 0.0300 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_LASER_MUZZLE_FLARE,, False, False, False, False, False,,,,, 50, 50 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_DEBRIS,, False, True, False, False, False, 100, 150, 0, 0, 200, 350, 0.75, 0.75, -0.0012, -0.0025 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_TRAIL,, False, False, False, False, False, 100, 100,,, 50, 50,,,,, 0.60, 0.60, 0.0, 0.0 ))

'______________________________________________________________________________
'[ PROJECTILES ]
Global projectile_archetype:PROJECTILE[10]; reset_index()

Global PROJECTILE_INDEX_TANK_CANNON% = postfix_index()
Global PROJECTILE_INDEX_MACHINE_GUN% = postfix_index()
Global PROJECTILE_INDEX_LASER% = postfix_index()
Global PROJECTILE_INDEX_ROCKET% = postfix_index()

projectile_archetype[PROJECTILE_INDEX_TANK_CANNON] = PROJECTILE( PROJECTILE.Create( img_projectile, snd_bullet_hit, 50.00,, -1, 0.0300 ))
	projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_RICOCHET_SPARK], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0, 1, 1, 135, 225, 0.2, 0.8 )
	projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
	projectile_archetype[PROJECTILE_INDEX_TANK_CANNON].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_EXPLOSION], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN] = PROJECTILE( PROJECTILE.Create( img_mgun, snd_bullet_hit, 5.00,, -1, 0.0050 ))
	projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_RICOCHET_SPARK], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0, 1, 1, 135, 225 )
	projectile_archetype[PROJECTILE_INDEX_MACHINE_GUN].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_IMPACT_HALO], PROJECTILE_MEMBER_EMITTER_PAYLOAD ).attach_at( 0, 0 )
projectile_archetype[PROJECTILE_INDEX_LASER] = PROJECTILE( PROJECTILE.Create( img_laser, Null, 15.00,, INFINITY, 0.0001,, True ))
projectile_archetype[PROJECTILE_INDEX_ROCKET] = PROJECTILE( PROJECTILE.Create( img_rocket, Null, 100.00, 5.0, 4.00, 0.0400, 0.00025 ))
	projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST], PROJECTILE_MEMBER_EMITTER_CONSTANT ).attach_at( -11, 0 )
	projectile_archetype[PROJECTILE_INDEX_ROCKET].add_emitter( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL], PROJECTILE_MEMBER_EMITTER_CONSTANT ).attach_at( -11, 0, 0, 10, 150, 210 )

'______________________________________________________________________________
'[ PROJECTILE EMITTERS ]
Global projectile_emitter_archetype:EMITTER[10]; reset_index()

Global PROJECTILE_EMITTER_INDEX_TANK_CANNON% = postfix_index()
Global PROJECTILE_EMITTER_INDEX_MACHINE_GUN% = postfix_index()
Global PROJECTILE_EMITTER_INDEX_LASER% = postfix_index()
Global PROJECTILE_EMITTER_INDEX_ROCKET% = postfix_index()

projectile_emitter_archetype[PROJECTILE_EMITTER_INDEX_TANK_CANNON] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_TANK_CANNON,, True, False, False, True, True ))
projectile_emitter_archetype[PROJECTILE_EMITTER_INDEX_MACHINE_GUN] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_MACHINE_GUN,, True, False, False, True, True ))
projectile_emitter_archetype[PROJECTILE_EMITTER_INDEX_LASER] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_LASER,, False, False, False, True, True ))
projectile_emitter_archetype[PROJECTILE_EMITTER_INDEX_ROCKET] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE, PROJECTILE_INDEX_ROCKET,, True, False, False, True, True ))

'______________________________________________________________________________
'[ WIDGETS ]
Global widget_archetype:WIDGET[5]; reset_index()

Global WIDGET_INDEX_GLOW% = postfix_index()
Global WIDGET_ARENA_DOOR% = postfix_index()

widget_archetype[WIDGET_INDEX_GLOW] = WIDGET( WIDGET.Create( img_glow, LAYER_IN_FRONT_OF_PARENT, REPEAT_MODE_CYCLIC_WRAP, 2, True ))
	widget_archetype[WIDGET_INDEX_GLOW].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 127, 127, 0.000, 1, 1, 333 )))
	widget_archetype[WIDGET_INDEX_GLOW].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 127, 127, 0.750, 1, 1, 333 )))
widget_archetype[WIDGET_ARENA_DOOR] = WIDGET( WIDGET.Create( img_door, LAYER_IN_FRONT_OF_PARENT, REPEAT_MODE_CYCLIC_WRAP, 2, False ))
	widget_archetype[WIDGET_ARENA_DOOR].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( -50, 0, 0, 255, 255, 255, 1, 1, 1, 1750 )))
	widget_archetype[WIDGET_ARENA_DOOR].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( -25, 0, 0, 255, 255, 255, 1, 1, 1, 1750 )))
	
'______________________________________________________________________________
'[ PICKUPS ]
Global pickup_archetype:PICKUP[3]; reset_index()

Global PICKUP_INDEX_HEALTH% = postfix_index()
Global PICKUP_INDEX_CANNON_AMMO% = postfix_index()
Global PICKUP_INDEX_COOLDOWN% = postfix_index()

pickup_archetype[PICKUP_INDEX_HEALTH] = PICKUP( PICKUP.Create( img_pickup_health, HEALTH_PICKUP, 100, 20000 ))
pickup_archetype[PICKUP_INDEX_CANNON_AMMO] = PICKUP( PICKUP.Create( img_pickup_ammo_main_5, AMMO_PICKUP, 5, 20000 ))
pickup_archetype[PICKUP_INDEX_COOLDOWN] = PICKUP( PICKUP.Create( img_pickup_cooldown, COOLDOWN_PICKUP, INFINITY, 20000 ))

'______________________________________________________________________________
'[ TURRETS ]
Global turret_archetype:TURRET[10]; reset_index()

Global TURRET_INDEX_TANK_SINGLE_CANNON% = postfix_index()
Global TURRET_INDEX_TANK_MACHINE_GUN% = postfix_index()
Global TURRET_INDEX_TANK_LASER% = postfix_index()
Global TURRET_INDEX_TANK_DUAL_CANNON_LEFT% = postfix_index()
Global TURRET_INDEX_TANK_DUAL_CANNON_RIGHT% = postfix_index()
Global TURRET_INDEX_MED_TANK_MACHINE_GUN% = postfix_index()
Global TURRET_INDEX_ROCKET_TURRET% = postfix_index()
Global TURRET_INDEX_MACHINE_GUN_TURRET% = postfix_index()
Global TURRET_INDEX_CANNON_TURRET% = postfix_index()
Global TURRET_INDEX_LIGHT_MACHINE_GUN% = postfix_index()

turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON] = TURRET( TURRET.Create( "105mm cannon", TURRET_CLASS_AMMUNITION, img_player_tank_turret_base, img_player_tank_turret_barrel, snd_tank_cannon_fire, 2.25, 650, 40, -7, 0 ))
	turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_TANK_CANNON ).attach_to( turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON], 20, 0, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH ).attach_to( turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON], 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE ).attach_to( turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON], 20, 0, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING ).attach_to( turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON], -3, 3, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN] = TURRET( TURRET.Create( "0.50 machine gun", TURRET_CLASS_AMMUNITION, Null, img_player_mgun_turret, snd_mgun_turret_fire, 2.25, 62, INFINITY, 0, 0, 25.0, 1.50, 2.75, 0.0210, 1500 ))
	turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_MACHINE_GUN ).attach_to( turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN], 14, 2, 0, 0, 0, 0, 4.30, 4.70, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_to( turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN], 14, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_to( turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN], 14, 2, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_to( turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN], 8, 2, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )
turret_archetype[TURRET_INDEX_TANK_LASER] = TURRET( TURRET.Create( "10 mw laser", TURRET_CLASS_ENERGY, img_laser_turret, Null, snd_laser_fire, 2.25, 250, INFINITY, 0, 0, 50.0, 5.50, 5.75, 0.0090, 3000 ))
	turret_archetype[TURRET_INDEX_TANK_LASER].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_LASER ).attach_to( turret_archetype[TURRET_INDEX_TANK_LASER], 14, 0, 0, 0, 0, 0, 8.00, 8.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_LASER].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE ).attach_to( turret_archetype[TURRET_INDEX_TANK_LASER], 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT] = TURRET( TURRET.Create( "105mm paired cannons", TURRET_CLASS_AMMUNITION, img_player_tank_turret_med_base_left, img_player_tank_turret_med_barrel_left, snd_tank_cannon_fire, 2.00, 485, 20, -9, 0, INFINITY ))
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_TANK_CANNON ).attach_to( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT], 24, -2, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH ).attach_to( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT], 24, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE ).attach_to( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT], 24, -2, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING ).attach_to( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT], 11, -3, 0, 0, 0, 0, 0.4, 0.6, 260, 280, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_player_tank_turret_med_base_right, img_player_tank_turret_med_barrel_right, snd_tank_cannon_fire, 2.00, 485, 20, -9, 0, INFINITY ))
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_TANK_CANNON ).attach_to( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT], 24, 2, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH ).attach_to( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT], 24, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE ).attach_to( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT], 24, 2, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING ).attach_to( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT], 11, 3, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN] = TURRET( TURRET.Create( "0.50 machine gun", TURRET_CLASS_AMMUNITION, Null, img_player_tank_turret_med_mgun_barrel, snd_mgun_turret_fire, 2.00, 62.50, INFINITY, 0, 0, 25.0, 1.50, 2.50, 0.0210, 1500 ))
	turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_MACHINE_GUN ).attach_to( turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN], 5, 4, 0, 0, 0, 0, 4.30, 4.70, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_to( turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN], 5, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_to( turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN], 5, 4, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_to( turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN], 0, 5, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )
turret_archetype[TURRET_INDEX_ROCKET_TURRET] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_enemy_stationary_emplacement_1_turret_base, img_enemy_stationary_emplacement_1_turret_barrel, Null, 0.55, 4000, INFINITY, 0, 0 ))
	turret_archetype[TURRET_INDEX_ROCKET_TURRET].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_ROCKET ).attach_to( turret_archetype[TURRET_INDEX_ROCKET_TURRET], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0020, 0.0020, 0, 0, 0, 0, 0, 0, 0, 0 )
turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_enemy_stationary_emplacement_1_turret_base, img_enemy_stationary_emplacement_2_turret_barrel, snd_mgun_turret_fire, 0.80, 50, INFINITY, 0, 0, 25.0, 2.0, 3.0, 0.0175, 2000 ))
	turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_MACHINE_GUN ).attach_to( turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET], 16, 0, 0, 0, 0, 0, 2.50, 3.00, 0, 0, 0, 0, 0, 0, -4.0, 4.0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_to( turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET], 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_to( turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET], 16, 0, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_to( turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET], 3, 3, 0, 0, 0, 0, 0.4, 0.6, 70, 110, -0.004, -0.004, 0, 0, -5, 5, -5, 5, 0, 0 )
turret_archetype[TURRET_INDEX_CANNON_TURRET] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_enemy_stationary_emplacement_1_turret_base, img_player_tank_turret_barrel, snd_tank_cannon_fire, 0.45, 2800, INFINITY, -7, 0 ))
	turret_archetype[TURRET_INDEX_CANNON_TURRET].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_TANK_CANNON ).attach_to( turret_archetype[TURRET_INDEX_CANNON_TURRET], 20, 0, 0, 0, 0, 0, 2.80, 3.00, 0, 0, 0, 0, 0, 0, -1.5, 1.5, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_CANNON_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH ).attach_to( turret_archetype[TURRET_INDEX_CANNON_TURRET], 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_CANNON_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE ).attach_to( turret_archetype[TURRET_INDEX_CANNON_TURRET], 20, 0, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_CANNON_TURRET].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING ).attach_to( turret_archetype[TURRET_INDEX_CANNON_TURRET], 5, 1, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )
turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN] = TURRET( TURRET.Create( "", TURRET_CLASS_AMMUNITION, img_enemy_light_mgun_turret_base, img_enemy_light_mgun_turret_barrel, snd_mgun_turret_fire, 2.00, 100, INFINITY, 0, 0, 25.0, 5.0, 5.5, 0.0175, 2000 ))
	turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_emitter( EMITTER_TYPE_PROJECTILE, PROJECTILE_EMITTER_INDEX_MACHINE_GUN ).attach_to( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 8, 0, 0, 0, 0, 0, 3.0, 3.4, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_to( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_to( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 8, 0, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_to( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 1, 1, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )
		
'______________________________________________________________________________
'[ COMPLEX_AGENTS ]
Global complex_agent_archetype:COMPLEX_AGENT[20]; reset_index()

'[ PLAYERS ]
Global PLAYER_INDEX_START% = array_index
Global PLAYER_INDEX_LIGHT_TANK% = postfix_index()
Global PLAYER_INDEX_LASER_TANK% = postfix_index()
Global PLAYER_INDEX_MED_TANK% = postfix_index()

complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "light tank", img_player_tank_chassis, Null, AI_BRAIN_TANK, 0, 500, 800.0, 75.0, 2, 2, 75.0, 100.0 ))
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_SINGLE_CANNON], 0 ).attach_at( -5, 0 )
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_MACHINE_GUN], 1 ).attach_at( -5, 0 )
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].firing_sequence = [ [[0]], [[1]] ]
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].firing_state = [ 0, 0 ]
		complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].FLAG_increment_firing_group = [ False, False ]
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].forward_debris_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].forward_debris_emitters[ 0].attach_to( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK], 12, -7, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].forward_debris_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].forward_debris_emitters[ 1].attach_to( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK], 12, 7, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].rear_debris_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].rear_debris_emitters[ 0].attach_to( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK], -12, -7, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].rear_debris_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].rear_debris_emitters[ 1].attach_to( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK], -12, 7, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].forward_trail_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].forward_trail_emitters[ 0].attach_to( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK], 12, -7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].forward_trail_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].forward_trail_emitters[ 1].attach_to( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK], 12, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].rear_trail_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].rear_trail_emitters[ 0].attach_to( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK], -12, -7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].rear_trail_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK].rear_trail_emitters[ 1].attach_to( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK], -12, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )

complex_agent_archetype[PLAYER_INDEX_LASER_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK] ))
	complex_agent_archetype[PLAYER_INDEX_LASER_TANK].name = "light tank/laser"
	complex_agent_archetype[PLAYER_INDEX_LASER_TANK].turret_count = 1
	complex_agent_archetype[PLAYER_INDEX_LASER_TANK].turrets = New TURRET[1]
	complex_agent_archetype[PLAYER_INDEX_LASER_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_LASER], 0 ).attach_at( -5, 0 )
		complex_agent_archetype[PLAYER_INDEX_LASER_TANK].firing_sequence = [ [[0]] ]
		complex_agent_archetype[PLAYER_INDEX_LASER_TANK].firing_state = [ 0 ]
		complex_agent_archetype[PLAYER_INDEX_LASER_TANK].FLAG_increment_firing_group = [ False ]

complex_agent_archetype[PLAYER_INDEX_MED_TANK] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "medium tank", img_player_tank_chassis_med, Null, AI_BRAIN_TANK, 0, 750, 1200, 125.0, 3, 2, 100.0, 125.0 ))
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_LEFT], 0 ).attach_at( -9, 0 )
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_turret( turret_archetype[TURRET_INDEX_TANK_DUAL_CANNON_RIGHT], 1 ).attach_at( -9, 0 )
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].add_turret( turret_archetype[TURRET_INDEX_MED_TANK_MACHINE_GUN], 2 ).attach_at( -9, 0 )
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].firing_sequence = [ [[0],[1]], [[2]] ]
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].firing_state = [ 0, 0 ]
		complex_agent_archetype[PLAYER_INDEX_MED_TANK].FLAG_increment_firing_group = [ False, False ]
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].forward_debris_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].forward_debris_emitters[ 0].attach_to( complex_agent_archetype[PLAYER_INDEX_MED_TANK], 15, -8, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].forward_debris_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].forward_debris_emitters[ 1].attach_to( complex_agent_archetype[PLAYER_INDEX_MED_TANK], 15, 8, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].rear_debris_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].rear_debris_emitters[ 0].attach_to( complex_agent_archetype[PLAYER_INDEX_MED_TANK], -15, -8, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].rear_debris_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].rear_debris_emitters[ 1].attach_to( complex_agent_archetype[PLAYER_INDEX_MED_TANK], -15, 8, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].forward_trail_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].forward_trail_emitters[ 0].attach_to( complex_agent_archetype[PLAYER_INDEX_MED_TANK], 15, -8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].forward_trail_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].forward_trail_emitters[ 1].attach_to( complex_agent_archetype[PLAYER_INDEX_MED_TANK], 15, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].rear_trail_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].rear_trail_emitters[ 0].attach_to( complex_agent_archetype[PLAYER_INDEX_MED_TANK], -15, -8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].rear_trail_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	complex_agent_archetype[PLAYER_INDEX_MED_TANK].rear_trail_emitters[ 1].attach_to( complex_agent_archetype[PLAYER_INDEX_MED_TANK], -15, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )

'[ ENEMIES ]
Global ENEMY_INDEX_START% = array_index
Global ENEMY_INDEX_MR_THE_BOX% = postfix_index()
Global ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_MOBILE_MINI_BOMB% = postfix_index()
Global ENEMY_INDEX_LIGHT_QUAD% = postfix_index()

complex_agent_archetype[ENEMY_INDEX_MR_THE_BOX] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "mr. the box", img_box, img_box_gib, AI_BRAIN_MR_THE_BOX, 50, 35, 200.0, 10.0, 0, 1, 6.0, 12.0 ))

complex_agent_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "machine-gun emplacement", img_enemy_stationary_emplacement_1_chassis, img_tower_gibs, AI_BRAIN_TURRET, 100, 100, 1000.0, 0, 1, 0, 0, 0, True ))
	complex_agent_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].add_turret( turret_archetype[TURRET_INDEX_MACHINE_GUN_TURRET], 0 ).attach_at( 0, 0 )

complex_agent_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "cannon emplacement", img_enemy_stationary_emplacement_1_chassis, img_tower_gibs, AI_BRAIN_TURRET, 100, 100, 1000.0, 0, 1, 0, 0, 0, True ))
	complex_agent_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT].add_turret( turret_archetype[TURRET_INDEX_CANNON_TURRET], 0 ).attach_at( 0, 0 )

complex_agent_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "rocket emplacement", img_enemy_stationary_emplacement_1_chassis, img_tower_gibs, AI_BRAIN_TURRET, 150, 100, 1000.0, 0, 1, 0, 0, 0, True ))
	complex_agent_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT].add_turret( turret_archetype[TURRET_INDEX_ROCKET_TURRET], 0 ).attach_at( 0, 0 )

complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "mini bomb", img_nme_mobile_bomb, img_bomb_gibs, AI_BRAIN_SEEKER, 75, 50, 200, 10.0, 0, 1, 7.50, 30.0 ))
	complex_agent_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB].add_widget( widget_archetype[WIDGET_INDEX_GLOW] ).attach_at( -6, 0 )

complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( "machine-gun quad", img_enemy_quad_chassis, img_quad_gibs, AI_BRAIN_TANK, 150, 100, 400, 25.0, 1, 2, 35.0, 55.0 ))
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].add_turret( turret_archetype[TURRET_INDEX_LIGHT_MACHINE_GUN], 0 ).attach_at( -6, 0 )
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].forward_debris_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS] ))
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].forward_debris_emitters[ 0].attach_to( complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD], -3, -4, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].forward_debris_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS] ))
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].forward_debris_emitters[ 1].attach_to( complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD], -3, 4, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].rear_debris_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS] ))
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].rear_debris_emitters[ 0].attach_to( complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD], -8, -4, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].rear_debris_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_DEBRIS] ))
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].rear_debris_emitters[ 1].attach_to( complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD], -8, 4, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].forward_trail_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL] ))
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].forward_trail_emitters[ 0].attach_to( complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD], -3, -4, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].forward_trail_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL] ))
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].forward_trail_emitters[ 1].attach_to( complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD], -3, 4, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].rear_trail_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL] ))
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].rear_trail_emitters[ 0].attach_to( complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD], -8, -4, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].rear_trail_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_QUAD_WHEEL_TRAIL] ))
	complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD].rear_trail_emitters[ 1].attach_to( complex_agent_archetype[ENEMY_INDEX_LIGHT_QUAD], -8, 4, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )






