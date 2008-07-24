Rem
	archetypes.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'[ PARTICLE EMITTERS ]
Global particle_emitter_archetype:EMITTER[20]

'particle emitter 0 - tank cannon muzzle flash emitter
particle_emitter_archetype[ 0] = Archetype_EMITTER( EMITS_PARTICLES,  0,  0, MODE_DISABLED, False, False, False, False, False, 0, 0, 1, 1, 50, 50 )
'particle emitter 1 - tank cannon projectile shell casing emitter
particle_emitter_archetype[ 1] = Archetype_EMITTER( EMITS_PARTICLES,  1,  1, MODE_DISABLED, True, False, False, False, True, 0, 0, 1, 1, 2200, 2200 )
'particle emitter 2 - tank cannon muzzle smoke emitter
particle_emitter_archetype[ 2] = Archetype_EMITTER( EMITS_PARTICLES,  2,  2, MODE_DISABLED, False, False, False, False, False, 0, 0, 10, 12, 500, 1000, 0.08, 0.16, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 )

'particle emitter 3 - tank cannon explosion emitter
particle_emitter_archetype[ 3] = Archetype_EMITTER( EMITS_PARTICLES,  3,  3, MODE_DISABLED, False, False, False, False, False, 0, 0, 1, 1, 300, 350 )

'particle emitter 4 - machine gun muzzle flash emitter
particle_emitter_archetype[ 4] = Archetype_EMITTER( EMITS_PARTICLES,  4,  4, MODE_DISABLED, False, False, False, False, False, 0, 0, 1, 1, 25, 25 )
'particle emitter 5 - machine gun projectile shell casing emitter
particle_emitter_archetype[ 5] = Archetype_EMITTER( EMITS_PARTICLES,  5,  5, MODE_DISABLED, True, False, False, False, True, 0, 0, 1, 1, 1400, 1800 )
'particle emitter 6 - machine gun muzzle smoke emitter
particle_emitter_archetype[ 6] = Archetype_EMITTER( EMITS_PARTICLES,  6,  6, MODE_DISABLED, False, False, False, False, False, 0, 0, 6, 8, 300, 600, 0.06, 0.12, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 )

'particle emitter 7 - machine gun explosion emitter
particle_emitter_archetype[ 7] = Archetype_EMITTER( EMITS_PARTICLES,  7,  7, MODE_DISABLED, False, False, False, False, False, 0, 0, 1, 1, 200, 300 )

'particle emitter 8 - tank tread debris emitter
particle_emitter_archetype[ 8] = Archetype_EMITTER( EMITS_PARTICLES,  8, 12, MODE_DISABLED, False, False, False, False, False, 100, 150, 0, 0, 30, 70, 0.75, 1.00, -0.0025, -0.0050 )
'particle emitter 9 - tank tread trail emitter
particle_emitter_archetype[ 9] = Archetype_EMITTER( EMITS_PARTICLES, 13, 17, MODE_DISABLED, False, False, False, False, False, 50, 50, 1, 1, 100, 100, 0.2, 0.4, 0, 0 )

'particle emitter 10 - "the box" emitter
particle_emitter_archetype[10] = Archetype_EMITTER( EMITS_PARTICLES, 20, 20, MODE_ENABLED_FOREVER, False, False, False, False, False, 500, 500, 0, 0, 3000, 3000, 0.5, 0.5, -0.004, -0.004 )

'particle emitter 11 - rocket thrust emitter
particle_emitter_archetype[11] = Archetype_EMITTER( EMITS_PARTICLES, 18, 18, MODE_ENABLED_FOREVER, False, False, False, False, False, 10, 15, 1, 1, 10, 15, 0.50, 0.75, 0, 0, 0.25, 1.00, 0, 0 )

'______________________________________________________________________________
'[ PARTICLES ]
Global particle_archetype:PARTICLE[50]

'particle 0 - tank cannon muzzle flash
particle_archetype[ 0] = Archetype_PARTICLE( img_muzzle_flash, LAYER_FOREGROUND )
'particle 1 - tank cannon projectile shell casing
particle_archetype[ 1] = Archetype_PARTICLE( img_projectile_shell_casing, LAYER_FOREGROUND, True )
'particle 2 - tank cannon muzzle smoke
particle_archetype[ 2] = Archetype_PARTICLE( img_muzzle_smoke, LAYER_FOREGROUND )
'particle 3 - tank cannon explosion
particle_archetype[ 3] = Archetype_PARTICLE( img_hit, LAYER_FOREGROUND )

'particle 4 - machine gun muzzle flash
particle_archetype[ 4] = Archetype_PARTICLE( img_mgun_muzzle_flash, LAYER_FOREGROUND )
'particle 5 - machine gun shell casing
particle_archetype[ 5] = Archetype_PARTICLE( img_mgun_shell_casing, LAYER_FOREGROUND, True )
'particle 6 - machine gun muzzle smoke
particle_archetype[ 6] = Archetype_PARTICLE( img_mgun_muzzle_smoke, LAYER_FOREGROUND )
'particle 7 - machine gun explosion
particle_archetype[ 7] = Archetype_PARTICLE( img_mgun_hit, LAYER_FOREGROUND )

'particles 8 through 12 - tank tread debris tiny
'ToDo: replace this with a complex particle; 1 frame with 5 variants.
particle_archetype[ 8] = Archetype_PARTICLE( img_debris_tiny_0, LAYER_BACKGROUND )
particle_archetype[ 9] = Archetype_PARTICLE( img_debris_tiny_1, LAYER_BACKGROUND )
particle_archetype[10] = Archetype_PARTICLE( img_debris_tiny_2, LAYER_BACKGROUND )
particle_archetype[11] = Archetype_PARTICLE( img_debris_tiny_3, LAYER_BACKGROUND )
particle_archetype[12] = Archetype_PARTICLE( img_debris_tiny_4, LAYER_BACKGROUND )
'particles 13 through 17 - tank tread trail
'ToDo: replace this with a complex particle; 1 frame with 5 variants.
particle_archetype[13] = Archetype_PARTICLE( img_trail_0, LAYER_BACKGROUND, True )
particle_archetype[14] = Archetype_PARTICLE( img_trail_1, LAYER_BACKGROUND, True )
particle_archetype[15] = Archetype_PARTICLE( img_trail_2, LAYER_BACKGROUND, True )
particle_archetype[16] = Archetype_PARTICLE( img_trail_3, LAYER_BACKGROUND, True )
particle_archetype[17] = Archetype_PARTICLE( img_trail_4, LAYER_BACKGROUND, True )

'particle 18 - rocket thrust
particle_archetype[18] = Archetype_PARTICLE( img_rocket_thrust, LAYER_BACKGROUND )
'particle 19 - rocket explosion
particle_archetype[19] = Archetype_PARTICLE( img_rocket_explode, LAYER_FOREGROUND )

'particle 20 - "the box" trail particle
particle_archetype[20] = Archetype_PARTICLE( img_box, LAYER_BACKGROUND )

'______________________________________________________________________________
'[ PROJECTILE EMITTERS ]
Global projectile_emitter_archetype:EMITTER[10]

'projectile emitter 0 - tank cannon projectile emitter
projectile_emitter_archetype[ 0] = Archetype_EMITTER( EMITS_PROJECTILES,  0,  0, MODE_DISABLED, True, False, False, True, True, 0, 0, 1, 1, 0, 0 )
'projectile emitter 1 - machine gun projectile emitter
projectile_emitter_archetype[ 1] = Archetype_EMITTER( EMITS_PROJECTILES,  1,  1, MODE_DISABLED, True, False, False, True, True, 0, 0, 1, 1, 0, 0 )
'projectile emitter 2 - rocket emitter
projectile_emitter_archetype[ 2] = Archetype_EMITTER( EMITS_PROJECTILES,  2,  2, MODE_DISABLED, False, False, True, True, True, 0, 0, 1, 1, 0, 0 )

'______________________________________________________________________________
'[ PROJECTILES ]
Global projectile_archetype:PROJECTILE[10]

'projectile 0 - tank cannon projectile
projectile_archetype[ 0] = Archetype_PROJECTILE( img_projectile,  3, 0.020, 50, 3 )
'projectile 1 - machine gun projectile
projectile_archetype[ 1] = Archetype_PROJECTILE( img_mgun,  7, 0.005, 5, 0 )
'projectile 2 - rocket
projectile_archetype[ 2] = Archetype_PROJECTILE( img_rocket, 19, 0.050, 100, 5 )
	projectile_archetype[ 2].thrust_emitter = Copy_EMITTER( particle_emitter_archetype[11] )
	projectile_archetype[ 2].thrust_emitter.attach_to( projectile_archetype[ 2], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )

'______________________________________________________________________________
'[ PICKUPS ]
Global pickup_archetype:PICKUP[ 1]

'pickup 0 - main cannon ammo
pickup_archetype[ 0] = Archetype_PICKUP( img_pickup_ammo_main_5, AMMO_PICKUP, 5, INFINITY )

'______________________________________________________________________________
'[ TURRETS ]
Global turret_archetype:TURRET[ 5]

'turret 0 - tank cannon
turret_archetype[ 0] = Archetype_TURRET( img_player_tank_turret_base, img_player_tank_turret_barrel, 450, 40, -7, 0 )
	turret_archetype[ 0].projectile_emitter = Copy_EMITTER( projectile_emitter_archetype[ 0] )
	turret_archetype[ 0].projectile_emitter.attach_to( turret_archetype[ 0], 20, 0, 0, 0, 0, 0, 4.3, 4.7, 0, 0, 0, 0, 0, 0, -1, 1, 0, 0, 0, 0 )
	turret_archetype[ 0].muzzle_flash_emitter = Copy_EMITTER( particle_emitter_archetype[ 0] )
	turret_archetype[ 0].muzzle_flash_emitter.attach_to( turret_archetype[ 0], 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 0].muzzle_smoke_emitter = Copy_EMITTER( particle_emitter_archetype[ 2] )
	turret_archetype[ 0].muzzle_smoke_emitter.attach_to( turret_archetype[ 0], 20, 0, 3, 6, -45, 45, 0.05, 0.40, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 0].ejector_port_emitter = Copy_EMITTER( particle_emitter_archetype[ 1] )
	turret_archetype[ 0].ejector_port_emitter.attach_to( turret_archetype[ 0], -3, 3, 0, 0, 0, 0, 0.4, 0.6, 80, 100, -0.005, -0.005, 0, 0, -10, 10, -3.5, 3.5, 0, 0 )

'turret 1 - machine gun
turret_archetype[ 1] = Archetype_TURRET( Null, img_player_mgun_turret, 75, INFINITY, 0, 0 )
	turret_archetype[ 1].projectile_emitter = Copy_EMITTER( projectile_emitter_archetype[ 1] )
	turret_archetype[ 1].projectile_emitter.attach_to( turret_archetype[ 1], 14, 2, 0, 0, 0, 0, 5.300, 5.700, 0, 0, 0, 0, 0, 0, -3, 3, 0, 0, 0, 0 )
	turret_archetype[ 1].muzzle_flash_emitter = Copy_EMITTER( particle_emitter_archetype[ 4] )
	turret_archetype[ 1].muzzle_flash_emitter.attach_to( turret_archetype[ 1], 14, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 1].muzzle_smoke_emitter = Copy_EMITTER( particle_emitter_archetype[ 6] )
	turret_archetype[ 1].muzzle_smoke_emitter.attach_to( turret_archetype[ 1], 14, 2, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 1].ejector_port_emitter = Copy_EMITTER( particle_emitter_archetype[ 5] )
	turret_archetype[ 1].ejector_port_emitter.attach_to( turret_archetype[ 1], 8, 2, 0, 0, 0, 0, 0.3, 0.4, 85, 95, -0.004, -0.004, 0, 0, -5, 5, -5, 5, 0, 0 )

'turret 2 - rocket turret
turret_archetype[ 2] = Archetype_TURRET( Null, img_enemy_stationary_emplacement_1_turret, 5000, INFINITY, 0, 0 )
	turret_archetype[ 2].projectile_emitter = Copy_EMITTER( projectile_emitter_archetype[ 2] )
	turret_archetype[ 2].projectile_emitter.attach_to( turret_archetype[ 2], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.05, 0.05, 0, 0, 0, 0, 0, 0, 0, 0 )
'	turret_archetype[ 2].muzzle_flash_emitter = Copy_EMITTER( particle_emitter_archetype[11] )
'	turret_archetype[ 2].muzzle_flash_emitter.attach_to( turret_archetype[ 2], -10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )

'______________________________________________________________________________
'[ ENEMIES ]
Global enemy_archetype:COMPLEX_AGENT[10]

'enemy 0 - "the box"
enemy_archetype[ 0] = Archetype_COMPLEX_AGENT( img_box, 50, 100, 200.0, 1.0, 0, 1, 1, 1.2 )
	enemy_archetype[ 0].rear_trail_emitters[ 0] = Copy_EMITTER( particle_emitter_archetype[10] )
	enemy_archetype[ 0].rear_trail_emitters[ 0].attach_to( enemy_archetype[ 0], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )

'enemy 1 - stationary emplacement 1 (rocket launcher emplacement)
enemy_archetype[ 1] = Archetype_COMPLEX_AGENT( img_enemy_stationary_emplacement_1_base, 100, 150, 0, 0, 1, 0, 0, 0 )
	enemy_archetype[ 1].turrets[ 0] = Copy_TURRET( turret_archetype[ 2] )
	enemy_archetype[ 1].turrets[ 0].attach_to( enemy_archetype[ 1], 0, 0 )

'______________________________________________________________________________
'[ PLAYERS ]
Global player_archetype:COMPLEX_AGENT[ 4]

'player 0 - temporary testing player - tank cannon, machine gun, two tank tread motivators (substituted for with eight individual emitters for now)
player_archetype[ 0] = Archetype_COMPLEX_AGENT( img_player_tank_chassis, 0, 500, 800.0, 20.0, 2, 2, 8.0, 16.0 )
	player_archetype[ 0].turrets[ 0] = Copy_TURRET( turret_archetype[ 0] ) 'main cannon
	player_archetype[ 0].turrets[ 0].attach_to( player_archetype[ 0], -5, 0 )
	player_archetype[ 0].turrets[ 1] = Copy_TURRET( turret_archetype[ 1] ) 'machine gun
	player_archetype[ 0].turrets[ 1].attach_to( player_archetype[ 0], -5, 0 )
	'to do: replace the following eight emitters with motivator archetype copies
	player_archetype[ 0].forward_debris_emitters[ 0] = Copy_EMITTER( particle_emitter_archetype[ 8] )
	player_archetype[ 0].forward_debris_emitters[ 0].attach_to( player_archetype[ 0], 12, -7, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].forward_debris_emitters[ 1] = Copy_EMITTER( particle_emitter_archetype[ 8] )
	player_archetype[ 0].forward_debris_emitters[ 1].attach_to( player_archetype[ 0], 12, 7, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_debris_emitters[ 0] = Copy_EMITTER( particle_emitter_archetype[ 8] )
	player_archetype[ 0].rear_debris_emitters[ 0].attach_to( player_archetype[ 0], -12, -7, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_debris_emitters[ 1] = Copy_EMITTER( particle_emitter_archetype[ 8] )
	player_archetype[ 0].rear_debris_emitters[ 1].attach_to( player_archetype[ 0], -12, 7, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].forward_trail_emitters[ 0] = Copy_EMITTER( particle_emitter_archetype[ 9] )
	player_archetype[ 0].forward_trail_emitters[ 0].attach_to( player_archetype[ 0], 12, -7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].forward_trail_emitters[ 1] = Copy_EMITTER( particle_emitter_archetype[ 9] )
	player_archetype[ 0].forward_trail_emitters[ 1].attach_to( player_archetype[ 0], 12, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_trail_emitters[ 0] = Copy_EMITTER( particle_emitter_archetype[ 9] )
	player_archetype[ 0].rear_trail_emitters[ 0].attach_to( player_archetype[ 0], -12, -7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_trail_emitters[ 1] = Copy_EMITTER( particle_emitter_archetype[ 9] )
	player_archetype[ 0].rear_trail_emitters[ 1].attach_to( player_archetype[ 0], -12, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )

'player 1
'...?
'player 2
'...?
'player 3 - "King Bam" - dual mega cannons, machine gun, four tank tread motivators
'...?
	



