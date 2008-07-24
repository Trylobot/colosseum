Rem
	archetypes.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global particle_archetype:PARTICLE[22]

'particle 0 - tank cannon muzzle flash
particle_archetype[ 0] = Archetype_PARTICLE( img_muzzle_flash )
'particle 1 - tank cannon projectile shell casing
particle_archetype[ 1] = Archetype_PARTICLE( img_projectile_shell_casing )
'particle 2 - tank cannon muzzle smoke
particle_archetype[ 2] = Archetype_PARTICLE( img_muzzle_smoke )
'particle 3 - tank cannon explosion
particle_archetype[ 3] = Archetype_PARTICLE( img_hit )

'particle 4 - machine gun muzzle flash
particle_archetype[ 4] = Archetype_PARTICLE( img_mgun_muzzle_flash )
'particle 5 - machine gun shell casing
particle_archetype[ 5] = Archetype_PARTICLE( img_mgun_shell_casing )
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
particle_archetype[13] = Archetype_PARTICLE( img_trail_0 )
particle_archetype[14] = Archetype_PARTICLE( img_trail_1 )
particle_archetype[15] = Archetype_PARTICLE( img_trail_2 )
particle_archetype[16] = Archetype_PARTICLE( img_trail_3 )
particle_archetype[17] = Archetype_PARTICLE( img_trail_4 )

'particle 18 - rocket launcher flash
'...?
'particle 19 - rocket trail
'...?
'particle 20 - rocket thrust
'...?
'particle 21 - rocket explosion
'...?

'______________________________________________________________________________
Global projectile_archetype:PROJECTILE[ 3]

'projectile 0 - tank cannon projectile
projectile_archetype[ 0] = Archetype_PROJECTILE( img_projectile,  3, 0.020, 50, 3 )
'projectile 1 - machine gun projectile
projectile_archetype[ 1] = Archetype_PROJECTILE( img_mgun,  7, 0.005, 5, 0 )
'projectile 2 - rocket
'projectile_archetype[ 2] = Archetype_PROJECTILE( img_rocket, 21, 0.050, 50, 5 )

'______________________________________________________________________________
Global particle_emitter_archetype:EMITTER[10]

'particle emitter 0 - tank cannon muzzle flash emitter
particle_emitter_archetype[ 0] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE,  0,  0, 0, 0, 1, 1, 100, 100 )
'particle emitter 1 - tank cannon projectile shell casing emitter
particle_emitter_archetype[ 1] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE,  1,  1, 0, 0, 1, 1, 1800, 2200 )
'particle emitter 2 - tank cannon muzzle smoke emitter
particle_emitter_archetype[ 2] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE,  2,  2, 0, 0, 2, 4, 500, 600, 0.25, 0.50, -0.0012, -0.0013, 0.25, 0.50, 0.0010, 0.0016 )
'particle emitter 3 - tank cannon explosion emitter
particle_emitter_archetype[ 3] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE,  3,  3, 0, 0, 1, 1, 300, 350 )

'particle emitter 4 - machine gun muzzle flash emitter
particle_emitter_archetype[ 4] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE,  4,  4, 0, 0, 1, 1, 35, 35 )
'particle emitter 5 - machine gun projectile shell casing emitter
particle_emitter_archetype[ 5] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE,  5,  5, 0, 0, 1, 1, 1400, 1800 )
'particle emitter 6 - machine gun muzzle smoke emitter
particle_emitter_archetype[ 6] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE,  6,  6, 0, 0, 1, 2, 500, 600, 0.30, 0.50, -0.0012, -0.0013, 0.25, 0.50, 0.0010, 0.0016 )
'particle emitter 7 - machine gun explosion emitter
particle_emitter_archetype[ 7] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE,  7,  7, 0, 0, 1, 1, 200, 300 )

'particle emitter 8 - tank tread debris emitter
particle_emitter_archetype[ 8] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE,  8, 12, 100, 150, 0, 0, 30, 70, 0.75, 1.00, -0.0025, -0.0050 )
'particle emitter 9 - tank tread trail emitter
particle_emitter_archetype[ 9] = Archetype_EMITTER( EMITTER_TYPE_PARTICLE, 13, 17, 50, 50, 1, 1, 20000, 20000, 0.2, 0.5, -0.0005, -0.0010 )

'______________________________________________________________________________
Global projectile_emitter_archetype:EMITTER[ 3]

'projectile emitter 0 - tank cannon projectile emitter
projectile_emitter_archetype[ 0] = Archetype_EMITTER( EMITTER_TYPE_PROJECTILE,  0,  0, 0, 0, 1, 1, 0, 0 )
'projectile emitter 1 - machine gun projectile emitter
projectile_emitter_archetype[ 1] = Archetype_EMITTER( EMITTER_TYPE_PROJECTILE,  1,  1, 0, 0, 1, 1, 0, 0 )
'projectile emitter 2 - rocket emitter
'...?

'______________________________________________________________________________
Global turret_archetype:TURRET[ 3]

'turret 0 - tank cannon
turret_archetype[ 0] = Archetype_TURRET( img_player_tank_turret, 450, -20, 0 )
	turret_archetype[ 0].projectile_emitter = Copy_EMITTER( projectile_emitter_archetype[ 0] )
	turret_archetype[ 0].projectile_emitter.attach_to( turret_archetype[ 0], 20, 0, 0, 0, 0, 0, 4.3, 4.7, 0, 0, -1, 1, 0, 0 )
	turret_archetype[ 0].muzzle_flash_emitter = Copy_EMITTER( particle_emitter_archetype[ 0] )
	turret_archetype[ 0].muzzle_flash_emitter.attach_to( turret_archetype[ 0], 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 0].muzzle_smoke_emitter = Copy_EMITTER( particle_emitter_archetype[ 2] )
	turret_archetype[ 0].muzzle_smoke_emitter.attach_to( turret_archetype[ 0], 20, 0, 5, 15, -45, 45, 0.01, 0.03, -45, 45, 0, 0, 0, 0 )
	turret_archetype[ 0].ejector_port_emitter = Copy_EMITTER( particle_emitter_archetype[ 1] )
	turret_archetype[ 0].ejector_port_emitter.attach_to( turret_archetype[ 0], -3, 3, 0, 0, 0, 0, 0.25, 0.50, 80, 100, -10, 10, -3.5, 3.5 )

'turret 1 - machine gun
turret_archetype[ 1] = Archetype_TURRET( img_player_mgun_turret, 75, 0, 0 )
	turret_archetype[ 1].projectile_emitter = Copy_EMITTER( projectile_emitter_archetype[ 1] )
	turret_archetype[ 1].projectile_emitter.attach_to( turret_archetype[ 1], 14, 2, 0, 0, 0, 0, 5.300, 5.700, 0, 0, -3, 3, 0, 0 )
	turret_archetype[ 1].muzzle_flash_emitter = Copy_EMITTER( particle_emitter_archetype[ 4] )
	turret_archetype[ 1].muzzle_flash_emitter.attach_to( turret_archetype[ 1], 14, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	turret_archetype[ 1].muzzle_smoke_emitter = Copy_EMITTER( particle_emitter_archetype[ 6] )
	turret_archetype[ 1].muzzle_smoke_emitter.attach_to( turret_archetype[ 1], 14, 2, 3, 9, 0, 45, 0.01, 0.03, 0, 45, 0, 0, 0, 0 )
	turret_archetype[ 1].ejector_port_emitter = Copy_EMITTER( particle_emitter_archetype[ 5] )
	turret_archetype[ 1].ejector_port_emitter.attach_to( turret_archetype[ 1], 8, 2, 0, 0, 0, 0, 0.40, 0.55, 85, 95, -5, 5, -5, 5 )

'turret 2 - rocket turret
'...?

'______________________________________________________________________________
Global player_archetype:COMPLEX_AGENT[ 4]

'player 0 - temporary testing player - tank cannon, machine gun, two tank tread motivators (substitute with eight emitters for now)
player_archetype[ 0] = Archetype_COMPLEX_AGENT( img_player_tank_chassis, 1000, 800, 2, 2 )
	player_archetype[ 0].turrets[ 0] = Copy_TURRET( turret_archetype[ 0] )
	player_archetype[ 0].turrets[ 0].attach_to( player_archetype[ 0], -5, 0 )
	player_archetype[ 0].turrets[ 1] = Copy_TURRET( turret_archetype[ 1] )
	player_archetype[ 0].turrets[ 1].attach_to( player_archetype[ 0], -5, 0 )
	'to do: replace the following eight emitters with motivator archetype copies
	player_archetype[ 0].forward_debris_emitters[ 0] = Copy_EMITTER( particle_emitter_archetype[ 8] )
	player_archetype[ 0].forward_debris_emitters[ 0].attach_to( player_archetype[ 0], 12, -7, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0 )
	player_archetype[ 0].forward_debris_emitters[ 1] = Copy_EMITTER( particle_emitter_archetype[ 8] )
	player_archetype[ 0].forward_debris_emitters[ 1].attach_to( player_archetype[ 0], 12, 7, 0, 2, -45, 45, 0.3, 0.6, -45, 45, 0, 0, 0, 0 )
	player_archetype[ 0].rear_debris_emitters[ 0] = Copy_EMITTER( particle_emitter_archetype[ 8] )
	player_archetype[ 0].rear_debris_emitters[ 0].attach_to( player_archetype[ 0], -12, -7, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0 )
	player_archetype[ 0].rear_debris_emitters[ 1] = Copy_EMITTER( particle_emitter_archetype[ 8] )
	player_archetype[ 0].rear_debris_emitters[ 1].attach_to( player_archetype[ 0], -12, 7, 0, 2, 135, 225, 0.3, 0.6, 135, 225, 0, 0, 0, 0 )
	player_archetype[ 0].forward_trail_emitters[ 0] = Copy_EMITTER( particle_emitter_archetype[ 9] )
	player_archetype[ 0].forward_trail_emitters[ 0].attach_to( player_archetype[ 0], 12, -7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].forward_trail_emitters[ 1] = Copy_EMITTER( particle_emitter_archetype[ 9] )
	player_archetype[ 0].forward_trail_emitters[ 1].attach_to( player_archetype[ 0], 12, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_trail_emitters[ 0] = Copy_EMITTER( particle_emitter_archetype[ 9] )
	player_archetype[ 0].rear_trail_emitters[ 0].attach_to( player_archetype[ 0], -12, -7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	player_archetype[ 0].rear_trail_emitters[ 1] = Copy_EMITTER( particle_emitter_archetype[ 9] )
	player_archetype[ 0].rear_trail_emitters[ 1].attach_to( player_archetype[ 0], -12, 7, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )

'player 1
'...?
'player 2
'...?
'player 3 - "King Bam" - dual mega cannons, machine gun, four tank tread motivators
'...?
	
'______________________________________________________________________________
Global enemy_archetype:COMPLEX_AGENT[ 1]

'enemy 0 - "the box"
enemy_archetype[ 0] = Archetype_COMPLEX_AGENT( img_box, 100, 200, 0, 0 )
'enemy 1 - stationary emplacement 1 (rocket launcher turret)
'...?
