Rem
	archetypes.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global particle_emitter_archetype:EMITTER[20]

'particle emitter 0 - tank cannon muzzle flash emitter
particle_emitter_archetype[ 0] = Archetype_EMITTER( EMITS_PARTICLES,  0,  0, False, False, False, False, 0, 0, 1, 1, 50, 50 )
'particle emitter 1 - tank cannon projectile shell casing emitter
particle_emitter_archetype[ 1] = Archetype_EMITTER( EMITS_PARTICLES,  1,  1, True, False, False, True, 0, 0, 1, 1, 2200, 2200 )
'particle emitter 2 - tank cannon muzzle smoke emitter
particle_emitter_archetype[ 2] = Archetype_EMITTER( EMITS_PARTICLES,  2,  2, False, False, False, False, 0, 0, 10, 12, 500, 1000, 0.08, 0.16, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 )

'particle emitter 3 - tank cannon explosion emitter
particle_emitter_archetype[ 3] = Archetype_EMITTER( EMITS_PARTICLES,  3,  3, False, False, False, False, 0, 0, 1, 1, 300, 350 )

'particle emitter 4 - machine gun muzzle flash emitter
particle_emitter_archetype[ 4] = Archetype_EMITTER( EMITS_PARTICLES,  4,  4, False, False, False, False, 0, 0, 1, 1, 25, 25 )
'particle emitter 5 - machine gun projectile shell casing emitter
particle_emitter_archetype[ 5] = Archetype_EMITTER( EMITS_PARTICLES,  5,  5, True, False, False, True, 0, 0, 1, 1, 1400, 1800 )
'particle emitter 6 - machine gun muzzle smoke emitter
particle_emitter_archetype[ 6] = Archetype_EMITTER( EMITS_PARTICLES,  6,  6, False, False, False, False, 0, 0, 6, 8, 300, 600, 0.06, 0.12, -0.002, -0.004, 0.15, 0.75, 0.0010, 0.0100 )

'particle emitter 7 - machine gun explosion emitter
particle_emitter_archetype[ 7] = Archetype_EMITTER( EMITS_PARTICLES,  7,  7, False, False, False, False, 0, 0, 1, 1, 200, 300 )

'particle emitter 8 - tank tread debris emitter
particle_emitter_archetype[ 8] = Archetype_EMITTER( EMITS_PARTICLES,  8, 12, False, False, False, False, 100, 150, 0, 0, 30, 70, 0.75, 1.00, -0.0025, -0.0050 )
'particle emitter 9 - tank tread trail emitter
particle_emitter_archetype[ 9] = Archetype_EMITTER( EMITS_PARTICLES, 13, 17, False, False, False, False, 50, 50, 1, 1, 100, 100, 0.2, 0.4, 0, 0 )

'particle emitter 10 - "the box" trail-of-self emitter
particle_emitter_archetype[10] = Archetype_EMITTER( EMITS_PARTICLES, 22, 22, False, False, False, False, 800, 800, 0, 0, 1000, 1000, 1.0, 1.0, 0.001, 0.001 )

'particle emitter 11 - rocket thrust emitter
particle_emitter_archetype[11] = Archetype_EMITTER( EMITS_PARTICLES, 20, 20, False, False, False, False, 10, 15, 1, 1, 10, 15, 0.25, 0.50, 0, 0, 0.25, 1.00, 0, 0 )

'______________________________________________________________________________
Global projectile_emitter_archetype:EMITTER[10]

'projectile emitter 0 - tank cannon projectile emitter
projectile_emitter_archetype[ 0] = Archetype_EMITTER( EMITS_PROJECTILES,  0,  0, True, False, True, True, 0, 0, 1, 1, 0, 0 )
'projectile emitter 1 - machine gun projectile emitter
projectile_emitter_archetype[ 1] = Archetype_EMITTER( EMITS_PROJECTILES,  1,  1, True, False, True, True, 0, 0, 1, 1, 0, 0 )
'projectile emitter 2 - rocket emitter
projectile_emitter_archetype[ 2] = Archetype_EMITTER( EMITS_PROJECTILES,  2,  2, True, False, True, True, 0, 0, 1, 1, 0, 0 )

'______________________________________________________________________________
Global particle_archetype:PARTICLE[50]

'particle 0 - tank cannon muzzle flash
particle_archetype[ 0] = Archetype_PARTICLE( img_muzzle_flash )
'particle 1 - tank cannon projectile shell casing
particle_archetype[ 1] = Archetype_PARTICLE( img_projectile_shell_casing, True )
'particle 2 - tank cannon muzzle smoke
particle_archetype[ 2] = Archetype_PARTICLE( img_muzzle_smoke )
'particle 3 - tank cannon explosion
particle_archetype[ 3] = Archetype_PARTICLE( img_hit )

'particle 4 - machine gun muzzle flash
particle_archetype[ 4] = Archetype_PARTICLE( img_mgun_muzzle_flash )
'particle 5 - machine gun shell casing
particle_archetype[ 5] = Archetype_PARTICLE( img_mgun_shell_casing, True )
'particle 6 - machine gun muzzle smoke
particle_archetype[ 6] = Archetype_PARTICLE( img_mgun_muzzle_smoke )
'particle 7 - machine gun explosion
particle_archetype[ 7] = Archetype_PARTICLE( img_mgun_hit )

'particles 8 through 12 - tank tread debris tiny
particle_archetype[ 8] = Archetype_PARTICLE( img_debris_tiny_0 )
particle_archetype[ 9] = Archetype_PARTICLE( img_debris_tiny_1 )
particle_archetype[10] = Archetype_PARTICLE( img_debris_tiny_2 )
particle_archetype[11] = Archetype_PARTICLE( img_debris_tiny_3 )
particle_archetype[12] = Archetype_PARTICLE( img_debris_tiny_4 )
'particles 13 through 17 - tank tread trail
particle_archetype[13] = Archetype_PARTICLE( img_trail_0, True )
particle_archetype[14] = Archetype_PARTICLE( img_trail_1, True )
particle_archetype[15] = Archetype_PARTICLE( img_trail_2, True )
particle_archetype[16] = Archetype_PARTICLE( img_trail_3, True )
particle_archetype[17] = Archetype_PARTICLE( img_trail_4, True )

'particle 18 - rocket thrust
particle_archetype[18] = Archetype_PARTICLE( img_rocket_thrust )
'particle 19 - rocket explosion
particle_archetype[19] = Archetype_PARTICLE( img_rocket_explode )

'particle 20 - "the box" particle
particle_archetype[22] = Archetype_PARTICLE( img_box )

'______________________________________________________________________________
Global projectile_archetype:PROJECTILE[10]

'projectile 0 - tank cannon projectile
projectile_archetype[ 0] = Archetype_PROJECTILE( img_projectile,  3, 0.020, 50, 3 )
'projectile 1 - machine gun projectile
projectile_archetype[ 1] = Archetype_PROJECTILE( img_mgun,  7, 0.005, 5, 0 )
'projectile 2 - rocket
projectile_archetype[ 2] = Archetype_PROJECTILE( img_rocket, 21, 0.050, 100, 5 )
	projectile_archetype[ 2].thrust_emitter = Copy_EMITTER( particle_emitter_archetype[11] )
	projectile_archetype[ 2].thrust_emitter.attach_to( projectile_archetype[ 2], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 180, 180, 0, 0, 0, 0 )

'______________________________________________________________________________
Global turret_archetype:TURRET[5]

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
	turret_archetype[ 2].projectile_emitter.attach_to( turret_archetype[ 2], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0, 0, 0, 0, 0, 0, 0, 0 )

'______________________________________________________________________________
Global player_archetype:COMPLEX_AGENT[ 4]

'player 0 - temporary testing player - tank cannon, machine gun, two tank tread motivators (substitute with eight emitters for now)
player_archetype[ 0] = Archetype_COMPLEX_AGENT( img_player_tank_chassis, 500, 800, 0, 2, 2 )
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
	
'______________________________________________________________________________
Global enemy_archetype:COMPLEX_AGENT[10]

'enemy 0 - "the box"
enemy_archetype[ 0] = Archetype_COMPLEX_AGENT( img_box, 100, 200, 50, 0, 1 )

'enemy 1 - stationary emplacement 1 (rocket launcher turret)
enemy_archetype[ 1] = Archetype_COMPLEX_AGENT( img_enemy_stationary_emplacement_1_base, 150, 0, 100, 1, 0 )
	enemy_archetype[ 1].turrets[ 0] = Copy_TURRET( turret_archetype[ 2] )
	enemy_archetype[ 1].turrets[ 0].attach_to( enemy_archetype[ 1], 0, 0 )
