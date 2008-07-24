Rem
	archetypes.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'object archetypes
Global particle_archetype_lib:PARTICLE[18]
'particle 0 - tank cannon muzzle flash
particle_archetype_lib[ 0] = Create_PARTICLE( img_muzzle_flash, 0, 0, 0, 0, 0, 1.000, 0.500, 100 )
'particle 1 - tank cannon projectile shell casing
particle_archetype_lib[ 1] = Create_PARTICLE( img_projectile_shell_casing, 0, 0, 0, 0, 0, 1.000, 1.000, 2000 )
'particle 2 - tank cannon muzzle smoke
'particle_archetype_lib[2] = Create_PARTICLE( img_muzzle_smoke, 0, 0, 0, 0, 0, 1.000, 0.000, 1000 )
'particle 3 - tank cannon projectile explosion
particle_archetype_lib[ 3] = Create_PARTICLE( img_hit, 0, 0, 0, 0, 0, 1.000, 0.200, 333 )
'particle 4 - machine gun muzzle flash
particle_archetype_lib[ 4] = Create_PARTICLE( img_mgun_muzzle_flash, 0, 0, 0, 0, 0, 1.000, 0.500, 75 )
'particle 5 - machine gun shell casing
particle_archetype_lib[ 5] = Create_PARTICLE( img_mgun_shell_casing, 0, 0, 0, 0, 0, 1.000, 1.000, 1750 )
'particle 6 - machine gun muzzle smoke
'particle_archetype_lib[6] = Create_PARTICLE( img_mgun_muzzle_smoke, 0, 0, 0, 0, 0, 1.000, 0.000, 500 )
'particle 7 - machine gun explosion
particle_archetype_lib[ 7] = Create_PARTICLE( img_mgun_hit, 0, 0, 0, 0, 0, 1.000, 0.200, 200 )
'particles 8 through 12 - debris tiny
particle_archetype_lib[ 8] = Create_PARTICLE( img_debris_tiny_0, 0, 0, 0, 0, 0, 1.000, 1.000 )
particle_archetype_lib[ 9] = Create_PARTICLE( img_debris_tiny_1, 0, 0, 0, 0, 0, 1.000, 1.000 )
particle_archetype_lib[10] = Create_PARTICLE( img_debris_tiny_2, 0, 0, 0, 0, 0, 1.000, 1.000 )
particle_archetype_lib[11] = Create_PARTICLE( img_debris_tiny_3, 0, 0, 0, 0, 0, 1.000, 1.000 )
particle_archetype_lib[12] = Create_PARTICLE( img_debris_tiny_4, 0, 0, 0, 0, 0, 1.000, 1.000 )
'particles 13 through 17 - trail
particle_archetype_lib[13] = Create_PARTICLE( img_trail_0, 0, 0, 0, 0, 0, 1.000, 1.000 )
particle_archetype_lib[14] = Create_PARTICLE( img_trail_1, 0, 0, 0, 0, 0, 1.000, 1.000 )
particle_archetype_lib[15] = Create_PARTICLE( img_trail_2, 0, 0, 0, 0, 0, 1.000, 1.000 )
particle_archetype_lib[16] = Create_PARTICLE( img_trail_3, 0, 0, 0, 0, 0, 1.000, 1.000 )
particle_archetype_lib[17] = Create_PARTICLE( img_trail_4, 0, 0, 0, 0, 0, 1.000, 1.000 )

Global projectile_archetype_lib:PROJECTILE[ 3]
'projectile 0 - tank cannon projectile
projectile_archetype_lib[ 0] = Create_PROJECTILE( ?

Global turret_archetype_lib:TURRET[ 3]

Global enemy_archetype_lib:COMPLEX_AGENT[ 1]

Global player_archetype_lib:COMPLEX_AGENT[ 1]
'player 0 - tank cannon, machine gun, two tank tread motivators
player_archetype_lib[ 0] = Create_COMPLEX_AGENT( img_player_tank_chassis, 0, 0, 0, player_max_health, 2, 2 )




'player tank's turret
Global player_turret:TURRET = Create_TURRET()
player_turret.img = img_player_tank_turret
player_turret.muz_img = img_muzzle_flash
player_turret.proj_img = img_projectile
player_turret.hit_img = img_hit
player_turret.set_offset( -5, 0 )
player_turret.set_muz_offset( 19, 0 )
player_turret.muz_vel = player_turret_projectile_muzzle_velocity
player_turret.reload_time = player_turret_reload_time
player.add_turret( player_turret )

'player tank's mgun
Global player_mgun:TURRET = Create_TURRET()
player_mgun.img = img_player_mgun_turret
player_mgun.muz_img = img_mgun_muzzle_flash
player_mgun.proj_img = img_mgun
player_mgun.hit_img = img_mgun_hit
player_mgun.set_offset( -5, 0 )
player_mgun.set_muz_offset( 13, 2 )
player_mgun.muz_vel = player_turret_mgun_muzzle_velocity
player_mgun.reload_time = player_mgun_reload_time
player.add_turret( player_mgun )

'player tank's emitters
player.tread_debris_emitter[0].set( imglib_debris_tiny, 12, -7, -90, 90, 1, 4.5, 100, 250, 20, 50, 0, 0 )
player.tread_debris_emitter[1].set( imglib_debris_tiny, 12, 7, -90, 90, 1, 4.5, 100, 250, 20, 50, 0, 0 )
player.tread_debris_emitter[2].set( imglib_debris_tiny, -12, 7, 90, 270, 1, 4.5, 100, 250, 20, 50, 0, 0 )
player.tread_debris_emitter[3].set( imglib_debris_tiny, -12, -7, 90, 270, 1, 4.5, 100, 250, 20, 50, 0, 0 )

'enemy tanks
For Local i% = 1 To 10
	Local e:AGENT = Create_AGENT()
	e.img = img_box
	e.pos_x = Rand( 10, arena_w - 10 )
	e.pos_y = Rand( 10, arena_h - 10 )
	e.ang = Rand( 0, 359 )
	Local vel# = 0.001 * Double( Rand( 200, 500 ))
	e.vel_x = vel * Cos( e.ang )
	e.vel_y = vel * Sin( e.ang )
	e.add_me( enemy_list )
Next

