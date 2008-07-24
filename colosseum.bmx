Rem
	colosseum.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
Rem
	TO DO
	- alpha values for particles, birth & death
	- tread emitter and manager list
	- damage for player and enemies
	- encapsulate turret logic and make a class for it
	- create xml format for levels
	- create a level editor
	- work on collision resolution
	- use acceleration values to smooth out movement (translation, rotation, etc)
	- apply forces for specified amounts of time
	- create arbitrary forces
	- define the center of mass for objects
	- create gibs for enemies
	- make gibs spawn as particles when enemies die
	- create scars
	- create "shells" to be ejected from the ejector port of turret object
	- create blocks for static environments that can be collided with
	- create example arenas
	- create a rudimentary AI
	- create a few enemies with guns
	- create visible damage which "sticks" to agents
	- separate main components into files
EndRem

'Framework BRL.Max2D

'Rudimentary stuff
SeedRnd MilliSecs()
Global clock:TTimer = CreateTimer( 1000 )

'______________________________________________________________________________
'temporary testing constants
'velocity (pixels per 1/60 second)
Const player_velocity_max# = 1.100
Const player_turret_projectile_muzzle_velocity# = 4.500
'angular velocity (degrees per 1/60 second)
Const player_angular_velocity_max# = 1.500
Const player_turret_angular_velocity_max# = 1.850
'time (ms)
Const infinite_life_time% = -1
Const player_turret_reload_time% = 450
Const player_turret_recoil_time% = 450
Const player_turret_muzzle_life_time% = 125
Const projectile_explode_life_time% = 300
'distance (pixels)
Const player_length% = 25
Const player_width% = 17
Const player_turret_recoil_dist# = 4.000
'Const tread_spacing# = 3
'object manager lists
Global projectile_list:TList = CreateList()
Global particle_list:TList = CreateList()
Global enemy_list:TList = CreateList()
Global emitter_list:TList = CreateList()
'______________________________________________________________________________
'settings flags
Global FLAG_draw_help% = False

'______________________________________________________________________________
Type POINT
	'Position
	Field pos_x#
	Field pos_y#
	'Velocity
	Field vel_x#
	Field vel_y#
	'Rotation
	Field ang#
	'List Manager info
	Field link:TLink
	
	Method New()
	End Method
	
	Method add_me( list:TList )
		link = ( list.AddLast( Self ))
	End Method
End Type
'______________________________________________________________________________
Type PARTICLE Extends POINT
	'Images
	Field img:TImage
	'Lifetime
	Field life_time% 'desired length of time (in milliseconds) until the particle is deleted (0 for infinite)
	Field created_ts% 'timestamp of creation
	'Alpha control
	Field alpha_birth#
	Field alpha_death#
	
	Method New()
	End Method
	
	Method dead%()
		If life_time < 0
			Return False
		Else
			Return clock.Ticks() - created_ts >= life_time
		End If
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method update()
		'prune old particles
		If dead()
			link.Remove()
			Return
		End If
		'update positions
		pos_x :+ vel_x
		pos_y :+ vel_y
		'out-of-bounds kill
		If pos_x > arena_w Then link.Remove()
		If pos_x < 0       Then link.Remove()
		If pos_y > arena_h Then link.Remove()
		If pos_y < 0       Then link.Remove()
	End Method
	
End Type
'if( lifetime == -1 ) then the particle never expires;
'else, the particle expires in (lifetime) milliseconds.
Function Create_PARTICLE:PARTICLE( ..
img:TImage, ..
pos_x#, pos_y#, ..
vel_x#, vel_y#, ..
ang#, ..
alpha_birth#, alpha_death#, ..
life_time% = -1 )
	Local p:PARTICLE = New PARTICLE
	p.img = img
	p.pos_x = pos_x
	p.pos_y = pos_y
	p.vel_x = vel_x
	p.vel_y = vel_y
	p.ang = ang
	p.life_time = life_time
	p.created_ts = clock.Ticks()
	p.link = Null
	p.add_me( particle_list )
	Return p
End Function
'______________________________________________________________________________
Type PROJECTILE Extends PARTICLE
	'projectile information (for explosion, damage calculation, and visual damage)
	Field exp_img:TImage
	Field damage#
	Field radius#
	
	Method New()
	End Method
End Type
'if( lifetime == -1 ) then it never expires;
'else, the particle expires in (lifetime) seconds.
Function Create_PROJECTILE:PROJECTILE( ..
img:TImage, exp_img:TImage, ..
pos_x#, pos_y#, ..
vel_x#, vel_y#, ..
ang#, ..
damage#, radius#, ..
life_time% = -1 )
	Local p:PROJECTILE = New PROJECTILE
	p.img = img
	p.pos_x = pos_x
	p.pos_y = pos_y
	p.vel_x = vel_x
	p.vel_y = vel_y
	p.ang = ang
	p.life_time = life_time
	p.created_ts = clock.Ticks()
	p.add_me( projectile_list )
	Return p
End Function
'______________________________________________________________________________
Type AGENT Extends POINT
	'Acceleration 
	Field acc_x#
	Field acc_y#
	'Angular Velocity 
	Field ang_vel#
	'Angular Acceleration
	Field ang_acc#
	'Images
	Field img_chassis:TImage
	'Health
	Field max_health#
	Field cur_health#
	'Mass
	Field mass#
	
	Method New()
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img_chassis, pos_x, pos_y )
	End Method
	
	Method update()
		'update positions
		pos_x :+ vel_x
		pos_y :+ vel_y
		'wrap at physical boundaries
		If pos_x > arena_w Then pos_x :- arena_w
		If pos_x < 0       Then pos_x :+ arena_w
		If pos_y > arena_h Then pos_y :- arena_h
		If pos_y < 0       Then pos_y :+ arena_h
		'update angles
		ang :+ ang_vel
		If ang >= 360 Then ang :- 360
		If ang <  0   Then ang :+ 360
	End Method
	
End Type
Function Create_AGENT:AGENT() 'more arguments?
	Local new_entity:AGENT = New AGENT
	'initializers?
	Return new_entity
End Function
'______________________________________________________________________________
Type TANK Extends AGENT
	'Turret Angle, Angular Velocity and Angular Acceleration
	Field tur_ang#
	Field tur_ang_vel#
	Field tur_ang_acc#
	'Turret Distance from Chassis handle, along axis of chassis symmetry
	Field tur_offset%
	'Turret Offset x,y components from Chassis handle
	Field tur_off_x#
	Field tur_off_y#
	'Muzzle Distance from Turret handle, along axis of chassis symmetry
	Field muz_offset%
	'Muzzle Offset x,y components from Turret
	Field muz_off_x#
	Field muz_off_y#
	'Reloading
	Field last_reloaded_ts% 'timestamp of last reload
	'Recoil (distance backwards from chassis mounting point, reduces over time)
	Field recoil#
	'Emitters
	Field tread_emit_tiny:EMITTER[4] 'front left, front right, back right, back left
	Field muzzle_emit_smoke:EMITTER
	
	'Images
	Field img_turret:TImage
	
	Method New()
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img_chassis, pos_x, pos_y )
		SetRotation( tur_ang )
		DrawImage( img_turret, pos_x + tur_off_x, pos_y + tur_off_y )
	End Method
	
	Method reloading%()
		Return (clock.Ticks() - last_reloaded_ts) < player_turret_reload_time
	End Method
	
	Method reload()
		last_reloaded_ts = clock.Ticks()
	End Method
		
	'think of this method like a request, safe to call at any time.
	'ie, if the player is currently reloading, this method will do nothing.
	Method fire()
		'if currently reloading, return without doing anything
		If reloading()
			Return
		End If
		
		'create muzzle flash
		Create_PARTICLE( ..
			img_muzzle_flash, ..
			pos_x + tur_off_x + muz_off_x, pos_y + tur_off_y + muz_off_y, ..
			0, 0, ..
			tur_ang, ..
			0, 0, ..
			player_turret_muzzle_life_time)
		
		'create projectile
		Create_PROJECTILE( ..
			img_projectile, ..
			img_hit, ..
			pos_x + player.tur_off_x + muz_off_x, pos_y + player.tur_off_y + muz_off_y, ..
			player.vel_x + player_turret_projectile_muzzle_velocity * Cos( tur_ang ), player.vel_y + player_turret_projectile_muzzle_velocity * Sin( tur_ang ), ..
			tur_ang, ..
			50, 10, ..
			infinite_life_time )
		
		'force player to wait until reloaded
		reload()
		
	End Method
	
	Method fire_secondary()
		
	End Method
	
	Method update()
		'update positions and offsets
		pos_x :+ vel_x
		pos_y :+ vel_y
		tur_off_x = tur_offset * Cos( ang )
		tur_off_y = tur_offset * Sin( ang )
		muz_off_x = muz_offset * Cos( tur_ang )
		muz_off_y = muz_offset * Sin( tur_ang )
		'wrap at physical boundaries
		If pos_x > arena_w Then pos_x :- arena_w
		If pos_x < 0       Then pos_x :+ arena_w
		If pos_y > arena_h Then pos_y :- arena_h
		If pos_y < 0       Then pos_y :+ arena_h
		'update angles
		ang :+ ang_vel
		tur_ang :+ ang_vel + tur_ang_vel
		'logical wrap (degrees boundary wrap)
		If ang >= 360     Then ang :- 360
		If ang <  0       Then ang :+ 360
		If tur_ang >= 360 Then tur_ang :- 360
		If tur_ang <  0   Then tur_ang :+ 360
	End Method
	
End Type
Function Create_TANK:TANK() 'more arguments?
	Local ent:TANK = New TANK
	ent.last_reloaded_ts = clock.Ticks()
	For Local i% = 0 To 3
		ent.tread_emit_tiny[i] = New EMITTER
		ent.tread_emit_tiny[i].parent = ent
		emitter_list.AddLast( ent.tread_emit_tiny[i] )
	Next
	Return ent
End Function
'______________________________________________________________________________
Type TURRET
	
End Type
'______________________________________________________________________________
Type EMITTER
	'Parent entity (optional, null if not applicable)
	Field parent:POINT
	'Image set to use for particle emission
	Field images:TImage[]
	'Position offset for emitted particles (from location of parent entity, or origin if no parent)
	Field off_x#
	Field off_y#
	Field offset#
	Field offset_ang#
	'Velocity range for emitted particles
	Field vel_min#
	Field vel_max#
	'Angle range for emitted particles
	Field ang_min#
	Field ang_max#
	'Distance range for emitted particles
	Field dist_min#
	Field dist_max#
	'Time delay range for emitted particles
	Field p_life_min#
	Field p_life_max#
	'Time delay range for emission interval
	Field interval_min%
	Field interval_max%
	'Actual time delay until next particle
	Field interval_next%
	'Timestamp of last emitted particle
	Field last_emit_ts%
	'Enable-disable time interval
	Field enable_time% 'desired length of time (in milliseconds) until the object is disabled (-1 for infinite)
	Field last_enabled_ts% 'timestamp of last enable
	
	Method New()
	End Method
	
	Method set( ..
	images_new:TImage[], ..
	off_x_new#, off_y_new#, ..
	ang_min_new#, ang_max_new#, ..
	dist_min_new#, dist_max_new#, ..
	p_life_min_new#, p_life_max_new#, ..
	interval_min_new%, interval_max_new%, ..
	enable_time_new% = -1 )
		images = images_new
		off_x = off_x_new; off_y = off_y_new
		offset = Sqr( off_x*off_x + off_y*off_y )
		offset_ang = ATan( off_y/off_x )
		If off_x < 0
			offset_ang :- 180
		End If
		ang_min = ang_min_new; ang_max = ang_max_new
		dist_min = dist_min_new; dist_max = dist_max_new
		p_life_min = p_life_min_new; p_life_max = p_life_max_new
		interval_min = interval_min_new; interval_max = interval_max_new
		interval_next = Rand( interval_min_new, interval_max_new )
		last_enabled_ts = clock.Ticks()
	End Method
	
	Method alive%()
		Return enable_time < 0 Or clock.Ticks() - last_enabled_ts <= enable_time
	End Method
	
	Method ready%()
		Return clock.Ticks() - last_emit_ts >= interval_next
	End Method
	
	Method enable( new_enable_time% = -1 )
		enable_time = new_enable_time
		last_enabled_ts = clock.Ticks()
	End Method
	
	Method disable()
		enable_time = 0
	End Method
	
	'like the fire() method of the TANK type, this method should be treated like a request.
	'ie, this method will emit only if it appropriate to do so.
	Method emit()
		If alive() And ready()
			Local em_part:PARTICLE = New PARTICLE
			em_part.img = images[ Rand( 0, 4 )]
			If parent <> Null
				ang_min :+ parent.ang
				ang_max :+ parent.ang
			End If
			em_part.ang = Rand( ang_min, ang_max )
			Local dist# = 0.001 * Rand( 1000 * dist_min, 1000 * dist_max )
			If parent <> Null
				em_part.pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang ) + dist * Cos( em_part.ang )
				em_part.pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang ) + dist * Sin( em_part.ang )
			Else
				em_part.pos_x = off_x + dist * Cos( em_part.ang )
				em_part.pos_y = off_y + dist * Sin( em_part.ang )
			End If
			Local vel# = 0.001 * Rand( vel_min * 1000, vel_max * 1000 )
			em_part.vel_x = vel * Cos( em_part.ang )
			em_part.vel_y = vel * Sin( em_part.ang )
			'If parent <> Null
			'	em_part.vel_x :+ parent.vel_x
			'	em_part.vel_y :+ parent.vel_y
			'End If
			em_part.created_ts = clock.Ticks()
			em_part.life_time = Rand( p_life_min, p_life_max )
	
			em_part.add_me( particle_list )
			
			last_emit_ts = clock.Ticks()
			interval_next = Rand( interval_min, interval_max )
		End If
	End Method
	
End Type
Function Create_EMITTER:EMITTER( ..
images:TImage[], ..
off_x#, off_y#, ..
ang_min#, ang_max#, ..
dist_min#, dist_max#, ..
p_life_min#, p_life_max#, ..
interval_min%, interval_max%, ..
enable_time% = -1 )
	Local em:EMITTER = New EMITTER
	em.set( ..
		images, ..
		off_x, off_y, ..
		ang_min, ang_max, ..
		dist_min, dist_max, ..
		p_life_min, p_life_max, ..
		interval_min, interval_max, ..
		enable_time )
	Return em
End Function

'misc utility functions
'______________________________________________________________________________
Function draw_health( cur_health#, max_health#, pos_x_exact#, pos_y_exact# )
	Local pos_x% = Int(pos_x_exact), pos_y% = Int(pos_y_exact)
	SetRotation( 0 )
	DrawImage( img_health_bar, pos_x - 22/2, pos_y - 5 )
	Local threshold# = 0.100
	While threshold <= 1.000 And cur_health > threshold * max_health
		DrawImage( img_health_pip, Int(pos_x) - 22/2 + threshold * 20, Int(pos_y) - 5 )
		threshold :+ 0.100
	End While
End Function
'______________________________________________________________________________
Function draw_help()
	DrawImage( img_help, 5, 5 )
End Function


'______________________________________________________________________________
'load images
Global img_help:TImage = LoadImage( "help.png" )
SetImageHandle( img_help, 0, 0 )

Global img_arena_bg:TImage = LoadImage( "arena_bg.png" )
SetImageHandle( img_arena_bg, 0, 0 )
Const arena_w% = 500
Const arena_h% = 500
Const arena_offset% = 25

Global img_player_tank_chassis:TImage = LoadImage( "player_tank_chassis.png" )
SetImageHandle( img_player_tank_chassis, 17, 12 )
Global img_player_tank_turret:TImage = LoadImage( "player_tank_turret.png" )
SetImageHandle( img_player_tank_turret, 12, 12 )

Global img_enemy_agent:TImage = LoadImage( "enemy_agent.png" )
SetImageHandle( img_enemy_agent, 8, 8 )

Global img_muzzle_flash:TImage = LoadImage( "muzzle_flash.png" )
SetImageHandle( img_muzzle_flash, 1, 12 )

Global img_projectile:TImage = LoadImage( "projectile.png" )
SetImageHandle( img_projectile, 0, 1 )

Global img_hit:TImage = LoadImage( "hit.png" )
SetImageHandle( img_hit, 14, 14 )

AutoMidHandle( True )
Global img_tiny:TImage[5]
img_tiny[0] = LoadImage( "tiny1.png" )
img_tiny[1] = LoadImage( "tiny2.png" )
img_tiny[2] = LoadImage( "tiny3.png" )
img_tiny[3] = LoadImage( "tiny4.png" )
img_tiny[4] = LoadImage( "tiny5.png" )
AutoMidHandle( False )

Global img_health_bar:TImage = LoadImage( "health_bar.png" )
SetImageHandle( img_health_bar, 0, 0 )

Global img_health_pip:TImage = LoadImage( "health_pip.png" )
SetImageHandle( img_health_pip, 0, 0 )


'temporary testing functions
'______________________________________________________________________________
Function draw_arena()
	DrawImage( img_arena_bg, 0, 0 )
End Function
'______________________________________________________________________________
Function process_input()
	'capture input and update pertinent physical_objects
	'update player velocity
	If KeyDown( KEY_W ) Or KeyDown( KEY_I )
		player.vel_x = player_velocity_max * Cos( player.ang )
		player.vel_y = player_velocity_max * Sin( player.ang )
		'If FLAG_emit_tread
		'	treadlist.AddLast( point.createPoint( px + (-15*Cos(a)), py + (-15*Sin(a)), a ))
		'	FLAG_emit_tread = False
		'EndIf
		player.tread_emit_tiny[0].disable()
		player.tread_emit_tiny[1].disable()
		player.tread_emit_tiny[2].enable()
		player.tread_emit_tiny[3].enable()
	ElseIf KeyDown( KEY_S ) Or KeyDown( KEY_K )
		player.vel_x = -player_velocity_max * Cos( player.ang )
		player.vel_y = -player_velocity_max * Sin( player.ang )
		'If FLAG_emit_tread
		'	treadlist.AddLast( point.createPoint( px + (15*Cos(a)), py + (15*Sin(a)), a ))
		'	FLAG_emit_tread = False
		'EndIf
		player.tread_emit_tiny[0].enable()
		player.tread_emit_tiny[1].enable()
		player.tread_emit_tiny[2].disable()
		player.tread_emit_tiny[3].disable()
	Else
		player.vel_x = 0
		player.vel_y = 0
		player.tread_emit_tiny[0].disable()
		player.tread_emit_tiny[1].disable()
		player.tread_emit_tiny[2].disable()
		player.tread_emit_tiny[3].disable()
	EndIf
	
	If KeyDown( Key_D )
		player.ang_vel = player_angular_velocity_max
	ElseIf KeyDown( KEY_A )
		player.ang_vel = -player_angular_velocity_max
	Else
		player.ang_vel = 0
	EndIf
	
	If KeyDown( Key_L )
		player.tur_ang_vel = player_turret_angular_velocity_max
	ElseIf KeyDown( Key_J )
		player.tur_ang_vel = -player_turret_angular_velocity_max
	Else
		player.tur_ang_vel = 0
	EndIf
	
	If KeyDown( KEY_SPACE )
		player.fire()
	End If
	
	If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
		player.fire_secondary()
	End If
	
	If KeyHit( KEY_F1 )
		FLAG_draw_help = Not FLAG_draw_help
	End If
	
End Function
'______________________________________________________________________________
Function update_objects()
	'player
	player.update()
	'enemies
	For Local nme:AGENT = EachIn enemy_list
		nme.update()
	Next
	'emitters
	For Local em:EMITTER = EachIn emitter_list
		em.emit()
	Next
	'projectiles
	For Local proj:PROJECTILE = EachIn projectile_list
		proj.update()
	Next	
	'particles
	For Local part:PARTICLE = EachIn particle_list
		part.update()
	Next
	
End Function
'______________________________________________________________________________
Const GENERIC_COLLIDE_LAYER% = 1
Const PLAYER_COLLIDE_LAYER% = 2
Const ENEMY_COLLIDE_LAYER% = 4
Const PROJECTILE_COLLIDE_LAYER% = 8
Const STATIC_COLLIDE_LAYER% = 16

Function collide()
	ResetCollisions()
	'Test for projectile-enemy collisions
	For Local nme:AGENT = EachIn enemy_list
		SetRotation( nme.ang )
		'CollideImage( nme.img_chassis, nme.pos_x, nme.pos_y, 0, 0, GENERIC_COLLIDE_LAYER )
		CollideImage( nme.img_chassis, nme.pos_x, nme.pos_y, 0, 0, ENEMY_COLLIDE_LAYER )
	Next
	For Local proj:PROJECTILE = EachIn projectile_list
		'if a collision occurred between {proj} and ENEMY_COLLIDE_LAYER
		SetRotation( proj.ang )
		If CollideImage( proj.img, proj.pos_x, proj.pos_y, 0, ENEMY_COLLIDE_LAYER, PROJECTILE_COLLIDE_LAYER )
			'create explosion particle at position of projectile, with random angle
			Local explode:PARTICLE = Create_PARTICLE( ..
				img_hit, proj.pos_x, proj.pos_y, 0, 0, Rand( 0, 359 ), 0, 0, projectile_explode_life_time )
				'old line: this references an image that becomes null when the projectile is removed, unfortunately
				'proj.exp_img, proj.pos_x, proj.pos_y, 0, 0, Rand( 0, 359 ), projectile_explode_life_time )
			'activate collision response for any nearby entities
			
			'remove original projectile
			proj.link.Remove()
		End If
	Next
End Function
'______________________________________________________________________________
Function draw()
	
	SetOrigin( arena_offset, arena_offset )
	SetViewport( arena_offset, arena_offset, arena_w, arena_h )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	'arena & environment
	draw_arena()
	'player
	player.draw()
	'enemies
	For Local nme:AGENT = EachIn enemy_list
		nme.draw()
	Next
	'projectile particles
	For Local proj:PARTICLE = EachIn projectile_list
		proj.draw()
	Next
	'generic particles
	For Local part:PARTICLE = EachIn particle_list
		part.draw()
	Next
	
	SetViewport( 0, 0, window_w, window_h )
	SetColor( 255, 50, 50 )
	'gui
	
	'debug
	draw_misc_debug_info()
	
	SetOrigin( 0, 0 )
	SetRotation( 0 )
	If FLAG_draw_help Then draw_help()
End Function

'______________________________________________________________________________
'temporary testing entities
'player tank
Global player:TANK = Create_TANK()
player.img_chassis = img_player_tank_chassis
player.img_turret = img_player_tank_turret
player.pos_x = arena_w/2
player.pos_y = arena_h/2
player.tur_offset = -5
player.muz_offset = 20
player.ang = 270
player.tur_ang = 270
player.max_health = 100
player.cur_health = player.max_health
'player emitters
player.tread_emit_tiny[0].set( img_tiny, 12, -7, -90, 90, 1, 4.5, 100, 250, 20, 50, -1 )
player.tread_emit_tiny[1].set( img_tiny, 12, 7, -90, 90, 1, 4.5, 100, 250, 20, 50, -1 )
player.tread_emit_tiny[2].set( img_tiny, -12, 7, 90, 270, 1, 4.5, 100, 250, 20, 50, -1 )
player.tread_emit_tiny[3].set( img_tiny, -12, -7, 90, 270, 1, 4.5, 100, 250, 20, 50, -1 )
'enemy tanks
For Local i% = 1 To 10
	Local e:AGENT = Create_AGENT()
	e.img_chassis = img_enemy_agent
	e.pos_x = Rand( 10, arena_w - 10 )
	e.pos_y = Rand( 10, arena_h - 10 )
	e.ang = Rand( 0, 359 )
	Local vel# = 0.001 * Double( Rand( 200, 500 ))
	e.vel_x = vel * Cos( e.ang )
	e.vel_y = vel * Sin( e.ang )
	enemy_list.AddLast( e )
Next


'______________________________________________________________________________
'open window and initialize graphics
Const window_w% = 550
Const window_h% = 550
Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

'______________________________________________________________________________
'misc defines
Local clock_ticks%
Local input_delay_timer_last_value% = 0

'______________________________________________________________________________
'         ####################################################################
'  MAIN   ####################################################################
'         ####################################################################
Repeat
	clock_ticks = clock.Ticks()
	If clock_ticks - input_delay_timer_last_value > (1000/60) '60 physics intervals a second
		input_delay_timer_last_value = clock_ticks
		process_input()
		update_objects()
		collide()
	EndIf
	Cls	
	draw()
	Flip( 1 ) 'draw to screen with vsync enabled
Until KeyHit( KEY_ESCAPE ) Or AppTerminate() 'kill app when ESC or close button pressed

'______________________________________________________________________________
Global test_timer:TTimer = CreateTimer( 1.000/0.250 )
Function draw_misc_debug_info()
	SetRotation( 0 )
	Local offset% = 1
	Local line% = 0
'	DrawText( "projectiles " + projectile_list.Count(), offset, offset + 10*line ); line :+ 1
'	DrawText( "particles " + particle_list.Count(), offset, offset + 10*line ); line :+ 1
'	DrawText( DEBUG_COUNTER, offset, offset + 10*line ); line :+ 1
'	DrawText( test_timer.Ticks(), offset, offset + 10*line ); line :+ 1
'	If Not particle_list.IsEmpty()
'		Local p:PARTICLE = PARTICLE(particle_list.Last())
'		DrawText( "--- latest particle ---", offset, offset + 10*line ); line :+ 1
'		Local L% = p.life_time
'		DrawText( "life_time       L = " + L, offset, offset + 10*line ); line :+ 1
'		Local C% = clock.Ticks()
'		DrawText( "clock           C = " + C, offset, offset + 10*line ); line :+ 1
'		Local T% = p.created_ts
'		DrawText( "created_ts      T = " + T, offset, offset + 10*line ); line :+ 1
'		
'		DrawText( "              C-T = " + (C-T), offset, offset + 10*line ); line :+ 1
'		DrawText( "          C-T > L = " + ((C-T) > L), offset, offset + 10*line ); line :+ 1
'	End If
'	DrawText( display_name + ".pos_x       " + pos_x, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".pos_y       " + pos_y, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".vel_x       " + vel_x, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".vel_y       " + vel_y, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".ang         " + ang, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".ang_vel     " + ang_vel, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".tur_ang     " + tur_ang, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".tur_ang_vel " + tur_ang_vel, x, line*10 + y ); line :+ 1
'	SetLineWidth(2)
'	For Local i% = 0 To 3
'		If player.tread_emit_tiny[i].alive()
'			DrawText( "emitter " + i + " active", offset, i * 10 + offset )
'			DrawLine( player.pos_x, player.pos_y, player.pos_x + player.tread_emit_tiny[i].offset * Cos( player.tread_emit_tiny[i].offset_ang + player.ang ), player.pos_y + player.tread_emit_tiny[i].offset * Sin( player.tread_emit_tiny[i].offset_ang + player.ang ))
'		End If
'	Next
End Function
'end of file colosseum.bmx
