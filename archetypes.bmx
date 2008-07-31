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
Function instantiate_archetype:Object( library_index%, entity_index% )
	
	Return Null
End Function

'______________________________________________________________________________
'[ PARTICLES ]
Global particle_archetype:PARTICLE[50]; reset_index()

Global PARTICLE_INDEX_CANNON_MUZZLE_FLASH% = postfix_index()
Global PARTICLE_INDEX_CANNON_SHELL_CASING% = postfix_index()
Global PARTICLE_INDEX_CANNON_MUZZLE_SMOKE% = postfix_index()
Global PARTICLE_INDEX_CANNON_EXPLOSION% = postfix_index()
Global PARTICLE_INDEX_MACHINE_GUN_MUZZLE_FLASH% = postfix_index()
Global PARTICLE_INDEX_MACHINE_GUN_SHELL_CASING% = postfix_index()
Global PARTICLE_INDEX_MACHINE_GUN_MUZZLE_SMOKE% = postfix_index()
Global PARTICLE_INDEX_MACHINE_GUN_EXPLOSION% = postfix_index()
Global PARTICLE_INDEX_TANK_TREAD_DEBRIS% = postfix_index()
Global PARTICLE_INDEX_TANK_TREAD_TRAIL% = postfix_index()
Global PARTICLE_INDEX_MR_THE_BOX_TRAIL% = postfix_index()
Global PARTICLE_INDEX_ROCKET_THRUST% = postfix_index()
Global PARTICLE_INDEX_ROCKET_SMOKE_TRAIL% = postfix_index()
Global PARTICLE_INDEX_MR_THE_BOX_GIB% = postfix_index()
Global PARTICLE_INDEX_LASER_MUZZLE_FLARE% = postfix_index()

particle_archetype[PARTICLE_INDEX_CANNON_MUZZLE_FLASH] = PARTICLE( PARTICLE.Create( img_muzzle_flash, 0, LAYER_FOREGROUND ))
particle_archetype[PARTICLE_INDEX_CANNON_SHELL_CASING] = PARTICLE( PARTICLE.Create( img_projectile_shell_casing, 0, LAYER_FOREGROUND, True, 0.0100 ))
particle_archetype[PARTICLE_INDEX_CANNON_MUZZLE_SMOKE] = PARTICLE( PARTICLE.Create( img_muzzle_smoke, 0, LAYER_FOREGROUND ))
particle_archetype[PARTICLE_INDEX_CANNON_EXPLOSION] = PARTICLE( PARTICLE.Create( img_hit, 0, LAYER_FOREGROUND ))
particle_archetype[PARTICLE_INDEX_MACHINE_GUN_MUZZLE_FLASH] = PARTICLE( PARTICLE.Create( img_mgun_muzzle_flash, 0, LAYER_FOREGROUND ))
particle_archetype[PARTICLE_INDEX_MACHINE_GUN_SHELL_CASING] = PARTICLE( PARTICLE.Create( img_mgun_shell_casing, 0, LAYER_FOREGROUND, True, 0.0100 ))
particle_archetype[PARTICLE_INDEX_MACHINE_GUN_MUZZLE_SMOKE] = PARTICLE( PARTICLE.Create( img_mgun_muzzle_smoke, 0, LAYER_FOREGROUND ))
particle_archetype[PARTICLE_INDEX_MACHINE_GUN_EXPLOSION] = PARTICLE( PARTICLE.Create( img_mgun_hit, 0, LAYER_FOREGROUND ))
particle_archetype[PARTICLE_INDEX_TANK_TREAD_DEBRIS] = PARTICLE( PARTICLE.Create( img_debris, 0, LAYER_BACKGROUND, True, 0.05 ))
particle_archetype[PARTICLE_INDEX_TANK_TREAD_TRAIL] = PARTICLE( PARTICLE.Create( img_trail, 0, LAYER_BACKGROUND, True ))
particle_archetype[PARTICLE_INDEX_MR_THE_BOX_TRAIL] = PARTICLE( PARTICLE.Create( img_box, 0, LAYER_BACKGROUND ))
particle_archetype[PARTICLE_INDEX_ROCKET_THRUST] = PARTICLE( PARTICLE.Create( img_rocket_thrust, 0, LAYER_BACKGROUND ))
particle_archetype[PARTICLE_INDEX_ROCKET_SMOKE_TRAIL] = PARTICLE( PARTICLE.Create( img_rocket_explode, 0, LAYER_FOREGROUND ))
particle_archetype[PARTICLE_INDEX_MR_THE_BOX_GIB] = PARTICLE( PARTICLE.Create( img_box_gib, 0, LAYER_FOREGROUND, True ))
particle_archetype[PARTICLE_INDEX_LASER_MUZZLE_FLARE] = PARTICLE( PARTICLE.Create( img_laser_muzzle_flare, 0, LAYER_FOREGROUND, False ))

'______________________________________________________________________________
'[ PARTICLE EMITTERS ]
Global particle_emitter_archetype:EMITTER[20]; reset_index();

Global PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH% = postfix_index()
Global PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING% = postfix_index()
Global PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE% = postfix_index()
Global PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH% = postfix_index()
Global PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING% = postfix_index()
Global PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE% = postfix_index()
Global PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS% = postfix_index()
Global PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_MR_THE_BOX_TRAIL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_ROCKET_THRUST% = postfix_index()
Global PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL% = postfix_index()
Global PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE% = postfix_index()

particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_MUZZLE_FLASH, MODE_DISABLED, False, False, False, False, False, 0, 0, 1, 1, 50, 50 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_SHELL_CASING, MODE_DISABLED, True, True, False, False, True, 0, 0, 1, 1, 2200, 2200 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_CANNON_MUZZLE_SMOKE, MODE_DISABLED, False, False, False, False, False, 0, 0, 10, 12, 500, 1000, 0.08, 0.16, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_MUZZLE_FLASH, MODE_DISABLED, False, False, False, False, False, 0, 0, 1, 1, 25, 25 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_SHELL_CASING, MODE_DISABLED, True, True, False, False, True, 0, 0, 1, 1, 1400, 1800 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MACHINE_GUN_MUZZLE_SMOKE, MODE_DISABLED, False, False, False, False, False, 0, 0, 6, 8, 300, 600, 0.06, 0.12, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_DEBRIS, MODE_DISABLED, False, True, False, False, False, 100, 150, 0, 0, 200, 350, 0.75, 1.00, -0.0012, -0.0025 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_TANK_TREAD_TRAIL, MODE_DISABLED, False, False, False, False, False, 100, 100, 1, 1, 50, 50 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MR_THE_BOX_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_MR_THE_BOX_TRAIL, MODE_ENABLED_FOREVER, False, False, False, False, False, 500, 500, 0, 0, 3000, 3000, 0.5, 0.5, -0.004, -0.004 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_ROCKET_THRUST, MODE_ENABLED_FOREVER, False, False, False, False, False, 10, 15, 1, 1, 10, 15, 0.50, 0.75, 0, 0, 0.25, 1.00, 0, 0 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_ROCKET_SMOKE_TRAIL, MODE_ENABLED_FOREVER, False, False, False, False, False, 0, 30, 0, 0, 250, 500, 0.06, 0.12, -0.002, -0.020, 0.10, 0.70, 0.0008, 0.0300 ))
particle_emitter_archetype[PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PARTICLE, PARTICLE_INDEX_LASER_MUZZLE_FLARE, MODE_DISABLED, False, False, False, False, False, 0, 0, 1, 1, 50, 50 ))

'______________________________________________________________________________
'[ PROJECTILES ]
Global projectile_archetype:PROJECTILE[10]; reset_index()

'projectile 0 - tank cannon projectile
projectile_archetype[ 0] = PROJECTILE( PROJECTILE.Create( img_projectile, PARTICLE_INDEX_CANNON_EXPLOSION, 50.00, 0.0, 0.0300, 0.0 ))
'projectile 1 - machine gun projectile
projectile_archetype[ 1] = PROJECTILE( PROJECTILE.Create( img_mgun, PARTICLE_INDEX_MACHINE_GUN_EXPLOSION, 5.00, 0.0, 0.0050, 0.0 ))
'projectile 2 - rocket
projectile_archetype[ 2] = PROJECTILE( PROJECTILE.Create( img_rocket, PARTICLE_INDEX_CANNON_EXPLOSION, 100.00, 5.0, 0.0400, 0.00025 ))
	projectile_archetype[ 2].thrust_emitter = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_THRUST] ))
	projectile_archetype[ 2].thrust_emitter.attach_to( projectile_archetype[ 2], -11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	projectile_archetype[ 2].trail_emitter = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_ROCKET_SMOKE_TRAIL] ))
	projectile_archetype[ 2].trail_emitter.attach_to( projectile_archetype[ 2], -11, 0, 0, 10, 150, 210, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
'projectile 3 - laser
projectile_archetype[ 3] = PROJECTILE( PROJECTILE.Create( img_laser, PARTICLE_INDEX_CANNON_EXPLOSION, 20, 0.0, 0.0001, 0.0 ))
	
'______________________________________________________________________________
'[ PROJECTILE EMITTERS ]
Global projectile_emitter_archetype:EMITTER[10]; reset_index()

'projectile emitter 0 - tank cannon projectile emitter
projectile_emitter_archetype[ 0] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE,  0, MODE_DISABLED, True, False, False, True, True, 0, 0, 1, 1 ))
'projectile emitter 1 - machine gun projectile emitter
projectile_emitter_archetype[ 1] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE,  1, MODE_DISABLED, True, False, False, True, True, 0, 0, 1, 1 ))
'projectile emitter 2 - rocket emitter
projectile_emitter_archetype[ 2] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE,  2, MODE_DISABLED, True, False, False, True, True, 0, 0, 1, 1 ))
'projectile emitter 3 - laser emitter
projectile_emitter_archetype[ 3] = EMITTER( EMITTER.Archetype( EMITTER_TYPE_PROJECTILE,  3, MODE_DISABLED, False, False, False, True, True, 0, 0, 1, 1 ))

'______________________________________________________________________________
'[ WIDGETS ]
Global widget_archetype:WIDGET[1]; reset_index()

Global WIDGET_INDEX_GLOW% = postfix_index()

'widget 0 - glow
widget_archetype[WIDGET_INDEX_GLOW] = WIDGET( WIDGET.Create( img_glow, LAYER_IN_FRONT_OF_PARENT, REPEAT_MODE_LOOP_BACK, 2, True ))
	widget_archetype[WIDGET_INDEX_GLOW].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 127, 127, 0.000, 1, 1, 333 )))
	widget_archetype[WIDGET_INDEX_GLOW].add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0, 0, 0, 255, 127, 127, 0.750, 1, 1, 333 )))
	
'______________________________________________________________________________
'[ PICKUPS ]
Global pickup_archetype:PICKUP[ 2]; reset_index()

'pickup 0 - main cannon ammo
pickup_archetype[ 0] = PICKUP( PICKUP.Archetype( img_pickup_ammo_main_5, AMMO_PICKUP, 5, 20000 ))
'pickup 1 - health
pickup_archetype[ 1] = PICKUP( PICKUP.Archetype( img_pickup_health, HEALTH_PICKUP, 50, 20000 ))

'______________________________________________________________________________
'[ TURRETS ]
Global turret_archetype:TURRET[ 5]; reset_index()

'turret 0 - tank main cannon
turret_archetype[ 0] = TURRET( TURRET.Archetype( TURRET_CLASS_AMMUNITION, img_player_tank_turret_base, img_player_tank_turret_barrel, 2.25, 650, 40, -7, 0, INFINITY, 0, 0, 0, 0 ))
	turret_archetype[ 0].add_emitter( EMITTER_TYPE_PROJECTILE,  0 ).attach_to( turret_archetype[ 0], 20, 0, 0, 0, 0, 0, 4.00, 4.40, 0, 0, 0, 0, 0, 0, -1.0, 1.0, 0, 0, 0, 0 )
	turret_archetype[ 0].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_FLASH ).attach_to( turret_archetype[ 0], 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 0].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_MUZZLE_SMOKE ).attach_to( turret_archetype[ 0], 20, 0, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 0].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_CANNON_SHELL_CASING ).attach_to( turret_archetype[ 0], -3, 3, 0, 0, 0, 0, 0.4, 0.6, 80, 100, 0, 0, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )

'turret 1 - tank co-axial machine gun
turret_archetype[ 1] = TURRET( TURRET.Archetype( TURRET_CLASS_AMMUNITION, Null, img_player_mgun_turret, 2.25, 62.50, INFINITY, 0, 0, 25.0, 1.50, 2.50, 0.0210, 1500 ))
	turret_archetype[ 1].add_emitter( EMITTER_TYPE_PROJECTILE,  1 ).attach_to( turret_archetype[ 1], 14, 2, 0, 0, 0, 0, 4.30, 4.70, 0, 0, 0, 0, 0, 0, -2.2, 2.2, 0, 0, 0, 0 )
	turret_archetype[ 1].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_to( turret_archetype[ 1], 14, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 1].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_to( turret_archetype[ 1], 14, 2, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 1].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_to( turret_archetype[ 1], 8, 2, 0, 0, 0, 0, 0.3, 0.4, 85, 95, 0, 0, 0, 0, -5, 5, -5, 5, 0, 0 )

'turret 2 - rocket turret
turret_archetype[ 2] = TURRET( TURRET.Archetype( TURRET_CLASS_AMMUNITION, img_enemy_stationary_emplacement_1_turret_base, img_enemy_stationary_emplacement_1_turret_barrel, 0.55, 4000, INFINITY, 0, 0, INFINITY, 0, 0, 0, 0 ))
	turret_archetype[ 2].add_emitter( EMITTER_TYPE_PROJECTILE,  2 ).attach_to( turret_archetype[ 2], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0020, 0.0020, 0, 0, 0, 0, 0, 0, 0, 0 )

'turret 3 - machine-gun turret
turret_archetype[ 3] = TURRET( TURRET.Archetype( TURRET_CLASS_AMMUNITION, img_enemy_stationary_emplacement_1_turret_base, img_enemy_stationary_emplacement_2_turret_barrel, 0.80, 50, INFINITY, 0, 0, 25.0, 2.0, 3.0, 0.0175, 2000 ))
	turret_archetype[ 3].add_emitter( EMITTER_TYPE_PROJECTILE,  1 ).attach_to( turret_archetype[ 3], 16, 0, 0, 0, 0, 0, 2.50, 3.00, 0, 0, 0, 0, 0, 0, -4.0, 4.0, 0, 0, 0, 0 )
	turret_archetype[ 3].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_FLASH ).attach_to( turret_archetype[ 3], 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 3].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_MUZZLE_SMOKE ).attach_to( turret_archetype[ 3], 16, 0, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 3].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_MACHINE_GUN_SHELL_CASING ).attach_to( turret_archetype[ 3], 3, 3, 0, 0, 0, 0, 0.4, 0.6, 70, 110, -0.004, -0.004, 0, 0, -5, 5, -5, 5, 0, 0 )

'turret 4 - laser turret
turret_archetype[ 4] = TURRET( TURRET.Archetype( TURRET_CLASS_AMMUNITION, img_laser_turret, Null, 2.25, 250, INFINITY, 0, 0 ))
	turret_archetype[ 4].add_emitter( EMITTER_TYPE_PROJECTILE,  3 ).attach_to( turret_archetype[ 4], 25, 6, 0, 0, 0, 0, 6.00, 6.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 4].add_emitter( EMITTER_TYPE_PARTICLE, PARTICLE_EMITTER_INDEX_LASER_MUZZLE_FLARE ).attach_to( turret_archetype[ 4], 25, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	
'______________________________________________________________________________
'[ ENEMIES ]
Global enemy_archetype:COMPLEX_AGENT[10]; reset_index()

Global ENEMY_INDEX_MR_THE_BOX% = postfix_index()
Global ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT% = postfix_index()
Global ENEMY_INDEX_MOBILE_MINI_BOMB% = postfix_index()
Global ENEMY_INDEX_LIGHT_TANK% = postfix_index()

enemy_archetype[ENEMY_INDEX_MR_THE_BOX] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( img_box, 50, 35, 200.0, 10.0, 0, 1, 6.0, 12.0 ))
	enemy_archetype[ENEMY_INDEX_MR_THE_BOX].rear_trail_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_MR_THE_BOX_TRAIL] ))
	enemy_archetype[ENEMY_INDEX_MR_THE_BOX].rear_trail_emitters[ 0].attach_to( enemy_archetype[ 0], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	enemy_archetype[ENEMY_INDEX_MR_THE_BOX].gib_list.AddLast( PARTICLE( PARTICLE.Create( img_box_gib, 0, LAYER_FOREGROUND, True, 0.0100, 255, 255, 255, 750, 0, 0, -1, 1, 0, 0 )))
	enemy_archetype[ENEMY_INDEX_MR_THE_BOX].gib_list.AddLast( PARTICLE( PARTICLE.Create( img_box_gib, 0, LAYER_FOREGROUND, True, 0.0100, 255, 255, 255, 750, 0, 0, 1, -1, 180, 0 )))
enemy_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( img_enemy_stationary_emplacement_1_chassis, 150, 100, 1000.0, 0, 1, 0, 0, 0, True ))
	enemy_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT].turrets[ 0] = TURRET( TURRET.Copy( turret_archetype[ 2] ))
	enemy_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT].turrets[ 0].attach_to( enemy_archetype[ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT], 0, 0 )
enemy_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( img_enemy_stationary_emplacement_1_chassis, 100, 100, 1000.0, 0, 1, 0, 0, 0, True ))
	enemy_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].turrets[ 0] = TURRET( TURRET.Copy( turret_archetype[ 3] ))
	enemy_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT].turrets[ 0].attach_to( enemy_archetype[ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT], 0, 0 )
enemy_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( img_enemy_stationary_emplacement_1_chassis, 100, 100, 1000.0, 0, 1, 0, 0, 0, True ))
	enemy_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT].turrets[ 0] = TURRET( TURRET.Copy( turret_archetype[ 0] )) 'main cannon
	enemy_archetype[ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT].turrets[ 0].attach_to( player_archetype[ 0], -5, 0 )
enemy_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( img_nme_mobile_bomb, 75, 50, 200, 10.0, 0, 1, 7.50, 25.0 ))
	enemy_archetype[ENEMY_INDEX_MOBILE_MINI_BOMB].add_widget( widget_archetype[WIDGET_INDEX_GLOW] ).attach_at( -6, 0 )
'enemy_archetype[ENEMY_INDEX_LIGHT_TANK] = ?

'______________________________________________________________________________
'[ PLAYERS ]
Global player_archetype:COMPLEX_AGENT[ 4]; reset_index()

'player 0 - temporary testing player - tank cannon, machine gun, two tank tread motivators (substituted for with eight individual emitters for now)
player_archetype[ 0] = COMPLEX_AGENT( COMPLEX_AGENT.Archetype( img_player_tank_chassis, 0, 500, 800.0, 75.0, 2, 2, 75.0, 100.0 ))
	player_archetype[ 0].turrets[ 0] = TURRET( TURRET.Copy( turret_archetype[ 0] )) 'main cannon
	player_archetype[ 0].turrets[ 0].attach_to( player_archetype[ 0], -5, 0 )
	player_archetype[ 0].turrets[ 1] = TURRET( TURRET.Copy( turret_archetype[ 1] )) 'machine gun
	player_archetype[ 0].turrets[ 1].attach_to( player_archetype[ 0], -5, 0 )
	player_archetype[ 0].forward_debris_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	player_archetype[ 0].forward_debris_emitters[ 0].attach_to( player_archetype[ 0], 12, -7, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].forward_debris_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	player_archetype[ 0].forward_debris_emitters[ 1].attach_to( player_archetype[ 0], 12, 7, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_debris_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	player_archetype[ 0].rear_debris_emitters[ 0].attach_to( player_archetype[ 0], -12, -7, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_debris_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DEBRIS] ))
	player_archetype[ 0].rear_debris_emitters[ 1].attach_to( player_archetype[ 0], -12, 7, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].forward_trail_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	player_archetype[ 0].forward_trail_emitters[ 0].attach_to( player_archetype[ 0], 12, -7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].forward_trail_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	player_archetype[ 0].forward_trail_emitters[ 1].attach_to( player_archetype[ 0], 12, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_trail_emitters[ 0] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	player_archetype[ 0].rear_trail_emitters[ 0].attach_to( player_archetype[ 0], -12, -7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_trail_emitters[ 1] = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_TRAIL] ))
	player_archetype[ 0].rear_trail_emitters[ 1].attach_to( player_archetype[ 0], -12, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )

'player 1
'...?
'player 2
'...?
'player 3 - "King Bam" - dual cannons
'...?
	



