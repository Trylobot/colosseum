Rem
	emitter.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "managed_object.bmx"
Import "point.bmx"
Import "range.bmx"
Import "json.bmx"

'this class should be considered ABSTRACT (even though it isn't)
'don't initialize it directly
'instead, use one of the concrete classes:
'  PARTICLE_EMITTER
'  PROJECTILE_LAUNCHER
'______________________________________________________________________________
Type EMITTER Extends MANAGED_OBJECT
	Const MODE_DISABLED% = 0
	Const MODE_ENABLED_WITH_COUNTER% = 1
	Const MODE_ENABLED_WITH_TIMER% = 2
	Const MODE_ENABLED_FOREVER% = 3
	
	Field parent:POINT 'parent object (for position and angle offsets)
	Field trigger_event% 'optional parent field to indicate the event that triggers this emitter
	Field mode% 'emitter mode (off/counter/timer)
	Field interval:RANGE_Int 'delay between particles
	Field interval_cur% '(private) delay between particles - pre-calculated
	Field last_emit_ts% '(private) timestamp of last emitted particle
	Field time_to_live% 'time until this emitter is disabled
	Field prune_on_disable%
	Field last_enable_ts% '(private) timestamp of the last time this emitter was enabled
	Field count:RANGE_Int 'number of particles to emit - upper bound
	Field count_cur% '(private) number of particles remaining to emit - pre-calculated and tracked
	Field combine_vel_with_parent_vel% 'setting - whether to add the parent's velocity to the emitted particle's velocity
	Field combine_vel_ang_with_parent_ang% 'setting - whether to add the parent's orientation to the emitted particle's direction of travel
	Field inherit_ang_from_dist_ang% 'setting - whether to set the angle to the already-determined "dist_ang" or a new angle
	Field inherit_vel_ang_from_ang% 'setting - whether to set the velocity angle to the already-determined "ang" or a new angle
	Field inherit_acc_ang_from_vel_ang% 'setting - whether to set the acceleration angle to the already-determined "vel_ang" or a new angle
	Field attach_x# 'original attachment position (when parent.ang = 0)
	Field attach_y# 'original attachment position (when parent.ang = 0)
	Field offset# 'offset vector magnitude (added to parent's position)
	Field offset_ang# 'offset vector angle (added to parent's position)
	
	Field dist:RANGE 'additional emitted particle offset magnitude
	Field dist_ang:RANGE 'direction of additional emitted particle  offset
	Field vel:RANGE 'velocity of emitted particle
	Field vel_ang:RANGE 'direction of velocity of emitted particle 
	Field acc:RANGE 'acceleration of emitted particle 
	Field acc_ang:RANGE 'direction of acceleration emitted particle 
	Field ang:RANGE 'orientation of emitted particle 
	Field ang_vel:RANGE 'angular velocity of emitted particle 
	Field ang_acc:RANGE 'angular acceleration of emitted particle 
	Field life_time:RANGE_Int 'life time of emitted particle 
	Field alpha:RANGE 'initial alpha value of emitted particle 
	Field alpha_delta:RANGE 'alpha rate of change of emitted particle 
	Field scale:RANGE 'initial scale value of emitted particle 
	Field scale_delta:RANGE 'scale rate of change of emitted particle 
	Field red:RANGE, green:RANGE, blue:RANGE 'color of emitted particle
	Field red_delta:RANGE, green_delta:RANGE, blue_delta:RANGE 'emitted particle's change in color over time
	
	Method New()
		interval = New RANGE_Int
		count = New RANGE_Int
		
		dist = New RANGE; dist_ang = New RANGE
		vel = New RANGE; vel_ang = New RANGE
		acc = New RANGE; acc_ang = New RANGE
		ang = New RANGE
		ang_vel = New RANGE
		ang_acc = New RANGE
		life_time = New RANGE_Int
		alpha = New RANGE; alpha_delta = New RANGE
		scale = New RANGE; scale_delta = New RANGE
		red = New RANGE; green = New RANGE; blue = New RANGE 
		red_delta = New RANGE; green_delta = New RANGE; blue_delta = New RANGE 
	End Method
	
	Method update()
		Select mode
			Case MODE_ENABLED_WITH_COUNTER
				If (count_cur <= 0) Then disable()
			Case MODE_ENABLED_WITH_TIMER
				If (now() - last_enable_ts) >= time_to_live Then disable()
		End Select
	End Method
	
	Method prune()
		If Not is_enabled() Then unmanage()
	End Method
	
	Method enable( new_mode% = MODE_ENABLED_FOREVER )
		mode = new_mode
		Select mode
			Case MODE_ENABLED_WITH_COUNTER
				count_cur = count.get()
			Case MODE_ENABLED_WITH_TIMER
				last_enable_ts = now()
		End Select
	End Method

	Method disable()
		mode = MODE_DISABLED
	End Method
	
	Method is_enabled%()
		Return (parent <> Null) And (Not (mode = MODE_DISABLED))
	End Method
	
	Method ready%()
		Return (now() - last_emit_ts >= interval_cur)
	End Method
	
	Method attach_at( ..
	off_x_new# = 0.0, off_y_new# = 0.0, ..
	dist_min_new# = 0.0, dist_max_new# = 0.0, ..
	dist_ang_min_new# = 0.0, dist_ang_max_new# = 0.0, ..
	vel_min_new# = 0.0, vel_max_new# = 0.0, ..
	vel_ang_min_new# = 0.0, vel_ang_max_new# = 0.0, ..
	acc_min_new# = 0.0, acc_max_new# = 0.0, ..
	acc_ang_min_new# = 0.0, acc_ang_max_new# = 0.0, ..
	ang_min_new# = 0.0, ang_max_new# = 0.0, ..
	ang_vel_min_new# = 0.0, ang_vel_max_new# = 0.0, ..
	ang_acc_min_new# = 0.0, ang_acc_max_new# = 0.0 )
		attach_x = off_x_new; attach_y = off_y_new
		cartesian_to_polar( attach_x, attach_y, offset, offset_ang )
		dist.set( dist_min_new, dist_max_new )
		dist_ang.set( dist_ang_min_new, dist_ang_max_new )
		vel.set( vel_min_new, vel_max_new )
		vel_ang.set( vel_ang_min_new, vel_ang_max_new )
		acc.set( acc_min_new, acc_max_new )
		acc_ang.set( acc_ang_min_new, acc_ang_max_new )
		ang.set( ang_min_new, ang_max_new )
		ang_vel.set( ang_vel_min_new, ang_vel_max_new )
		ang_acc.set( ang_acc_min_new, ang_acc_max_new )
	End Method
	
End Type

Function initialize_generic_EMITTER:EMITTER( ..
em:EMITTER, ..
mode% = EMITTER.MODE_DISABLED, ..
combine_vel_with_parent_vel% = False, ..
combine_vel_ang_with_parent_ang% = False, ..
inherit_ang_from_dist_ang% = False, ..
inherit_vel_ang_from_ang% = False, ..
inherit_acc_ang_from_vel_ang% = False, ..
interval_min% = 0, interval_max% = 0, ..
count_min% = 1, count_max% = 1, ..
life_time_min% = INFINITY, life_time_max% = INFINITY, ..
alpha_min# = 1.0, alpha_max# = 1.0, ..
alpha_delta_min# = 0.0, alpha_delta_max# = 0.0, ..
scale_min# = 1.0, scale_max# = 1.0, ..
scale_delta_min# = 0.0, scale_delta_max# = 0.0, ..
red_min# = 1.0, red_max# = 1.0, ..
green_min# = 1.0, green_max# = 1.0, ..
blue_min# = 1.0, blue_max# = 1.0, ..
red_delta_min# = 0.0, red_delta_max# = 0.0, ..
green_delta_min# = 0.0, green_delta_max# = 0.0, ..
blue_delta_min# = 0.0, blue_delta_max# = 0.0, ..
off_x_new# = 0.0, off_y_new# = 0.0, ..
dist_min_new# = 0.0, dist_max_new# = 0.0, ..
dist_ang_min_new# = 0.0, dist_ang_max_new# = 0.0, ..
vel_min_new# = 0.0, vel_max_new# = 0.0, ..
vel_ang_min_new# = 0.0, vel_ang_max_new# = 0.0, ..
acc_min_new# = 0.0, acc_max_new# = 0.0, ..
acc_ang_min_new# = 0.0, acc_ang_max_new# = 0.0, ..
ang_min_new# = 0.0, ang_max_new# = 0.0, ..
ang_vel_min_new# = 0.0, ang_vel_max_new# = 0.0, ..
ang_acc_min_new# = 0.0, ang_acc_max_new# = 0.0 )
	If Not em Then Return Null
	'static fields
	em.mode = mode
	em.combine_vel_with_parent_vel = combine_vel_with_parent_vel
	em.combine_vel_ang_with_parent_ang = combine_vel_ang_with_parent_ang
	em.inherit_ang_from_dist_ang = inherit_ang_from_dist_ang
	em.inherit_vel_ang_from_ang = inherit_vel_ang_from_ang
	em.inherit_acc_ang_from_vel_ang = inherit_acc_ang_from_vel_ang
	em.interval.set( interval_min, interval_max )
	em.count.set( count_min, count_max )
	'emitter attributes and attribute ranges
	em.parent = Null
	em.interval_cur = em.interval.get()
	em.count_cur = em.count.get()
	em.life_time.set( life_time_min, life_time_max )
	em.alpha.set( alpha_min, alpha_max )
	em.alpha_delta.set( alpha_delta_min, alpha_delta_max )
	em.scale.set( scale_min, scale_max )
	em.scale_delta.set( scale_delta_min, scale_delta_max )
	em.red.set( red_min, red_max ); em.green.set( green_min, green_max); em.blue.set( blue_min, blue_max )
	em.red_delta.set( red_delta_min, red_delta_max ); em.green_delta.set( green_delta_min, green_delta_max ); em.blue_delta.set( blue_delta_min, blue_delta_max )
	em.last_enable_ts = now()
	'initial attachment variables (optional)
	em.attach_at( ..
		off_x_new, off_y_new, ..
		dist_min_new, dist_max_new, ..
		dist_ang_min_new, dist_ang_max_new, ..
		vel_min_new, vel_max_new, ..
		vel_ang_min_new, vel_ang_max_new, ..
		acc_min_new, acc_max_new, ..
		acc_ang_min_new, acc_ang_max_new, ..
		ang_min_new, ang_max_new, ..
		ang_vel_min_new, ang_vel_max_new, ..
		ang_acc_min_new, ang_acc_max_new )
	Return em
End Function

'this copies other_em into em as an abstract emitter only (omitting the concrete fields)
Function copy_generic_EMITTER:EMITTER( em:EMITTER, other_em:EMITTER, managed_list:TList = Null, new_parent:POINT = Null )
	If Not other_em Or Not em Then Return Null
	em = initialize_generic_EMITTER( ..
		em, ..
		other_em.mode, ..
		other_em.combine_vel_with_parent_vel, ..
		other_em.combine_vel_ang_with_parent_ang, ..
		other_em.inherit_ang_from_dist_ang, ..
		other_em.inherit_vel_ang_from_ang, ..
		other_em.inherit_acc_ang_from_vel_ang, ..
		other_em.interval.low, other_em.interval.high, ..
		other_em.count.low, other_em.count.high, ..
		other_em.life_time.low, other_em.life_time.high, ..
		other_em.alpha.low, other_em.alpha.high, ..
		other_em.alpha_delta.low, other_em.alpha_delta.high, ..
		other_em.scale.low, other_em.scale.high, ..
		other_em.scale_delta.low, other_em.scale_delta.high, ..
		other_em.red.low, other_em.red.high, ..
		other_em.green.low, other_em.green.high, ..
		other_em.blue.low, other_em.blue.high, ..
		other_em.red_delta.low, other_em.red_delta.high, ..
		other_em.green_delta.low, other_em.green_delta.high, ..
		other_em.blue_delta.low, other_em.blue_delta.high, ..
		other_em.attach_x, other_em.attach_y, ..
		other_em.dist.low, other_em.dist.high, ..
		other_em.dist_ang.low, other_em.dist_ang.high, ..
		other_em.vel.low, other_em.vel.high, ..
		other_em.vel_ang.low, other_em.vel_ang.high, ..
		other_em.acc.low, other_em.acc.high, ..
		other_em.acc_ang.low, other_em.acc_ang.high, ..
		other_em.ang.low, other_em.ang.high, ..
		other_em.ang_vel.low, other_em.ang_vel.high, ..
		other_em.ang_acc.low, other_em.ang_acc.high )
	'argument fields
	If managed_list Then em.manage( managed_list )
	em.parent = new_parent
	'emitter-specific fields
	em.count_cur = em.count.get()
	em.last_enable_ts = now()
	'return
	Return em
End Function

Function initialize_generic_EMITTER_from_json( e:EMITTER, json:TJSON )
	If Not e Or Not json Then Return
	'read and assign optional fields as available
	If json.TypeOf( "mode" ) <> JSON_UNDEFINED                            Then e.mode = json.GetNumber( "mode" )
	If json.TypeOf( "combine_vel_with_parent_vel" ) <> JSON_UNDEFINED     Then e.combine_vel_with_parent_vel = json.GetBoolean( "combine_vel_with_parent_vel" )
	If json.TypeOf( "combine_vel_ang_with_parent_ang" ) <> JSON_UNDEFINED Then e.combine_vel_ang_with_parent_ang = json.GetBoolean( "combine_vel_ang_with_parent_ang" )
	If json.TypeOf( "inherit_ang_from_dist_ang" ) <> JSON_UNDEFINED       Then e.inherit_ang_from_dist_ang = json.GetBoolean( "inherit_ang_from_dist_ang" )
	If json.TypeOf( "inherit_vel_ang_from_ang" ) <> JSON_UNDEFINED        Then e.inherit_vel_ang_from_ang = json.GetBoolean( "inherit_vel_ang_from_ang" )
	If json.TypeOf( "inherit_acc_ang_from_vel_ang" ) <> JSON_UNDEFINED    Then e.inherit_acc_ang_from_vel_ang = json.GetBoolean( "inherit_acc_ang_from_vel_ang" )
	If json.TypeOf( "interval_min" ) <> JSON_UNDEFINED                    Then e.interval.low = json.GetNumber( "interval_min" )
	If json.TypeOf( "interval_max" ) <> JSON_UNDEFINED                    Then e.interval.high = json.GetNumber( "interval_max" )
	If json.TypeOf( "count_min" ) <> JSON_UNDEFINED                       Then e.count.low = json.GetNumber( "count_min" )
	If json.TypeOf( "count_max" ) <> JSON_UNDEFINED                       Then e.count.high = json.GetNumber( "count_max" )
	If json.TypeOf( "life_time_min" ) <> JSON_UNDEFINED                   Then e.life_time.low = json.GetNumber( "life_time_min" )
	If json.TypeOf( "life_time_max" ) <> JSON_UNDEFINED                   Then e.life_time.high = json.GetNumber( "life_time_max" )
	If json.TypeOf( "alpha_min" ) <> JSON_UNDEFINED                       Then e.alpha.low = json.GetNumber( "alpha_min" )
	If json.TypeOf( "alpha_max" ) <> JSON_UNDEFINED                       Then e.alpha.high = json.GetNumber( "alpha_max" )
	If json.TypeOf( "alpha_delta_min" ) <> JSON_UNDEFINED                 Then e.alpha_delta.low = json.GetNumber( "alpha_delta_min" )
	If json.TypeOf( "alpha_delta_max" ) <> JSON_UNDEFINED                 Then e.alpha_delta.high = json.GetNumber( "alpha_delta_max" )
	If json.TypeOf( "scale_min" ) <> JSON_UNDEFINED                       Then e.scale.low = json.GetNumber( "scale_min" )
	If json.TypeOf( "scale_max" ) <> JSON_UNDEFINED                       Then e.scale.high = json.GetNumber( "scale_max" )
	If json.TypeOf( "scale_delta_min" ) <> JSON_UNDEFINED                 Then e.scale_delta.low = json.GetNumber( "scale_delta_min" )
	If json.TypeOf( "scale_delta_max" ) <> JSON_UNDEFINED                 Then e.scale_delta.high = json.GetNumber( "scale_delta_max" )
	If json.TypeOf( "red_min" ) <> JSON_UNDEFINED                         Then e.red.low = json.GetNumber( "red_min" )
	If json.TypeOf( "red_max" ) <> JSON_UNDEFINED                         Then e.red.high = json.GetNumber( "red_max" )
	If json.TypeOf( "green_min" ) <> JSON_UNDEFINED                       Then e.green.low = json.GetNumber( "green_min" )
	If json.TypeOf( "green_max" ) <> JSON_UNDEFINED                       Then e.green.high = json.GetNumber( "green_max" )
	If json.TypeOf( "blue_min" ) <> JSON_UNDEFINED                        Then e.blue.low = json.GetNumber( "blue_min" )
	If json.TypeOf( "blue_max" ) <> JSON_UNDEFINED                        Then e.blue.high = json.GetNumber( "blue_max" )
	If json.TypeOf( "red_delta_min" ) <> JSON_UNDEFINED                   Then e.red_delta.low = json.GetNumber( "red_delta_min" )
	If json.TypeOf( "red_delta_max" ) <> JSON_UNDEFINED                   Then e.red_delta.high = json.GetNumber( "red_delta_max" )
	If json.TypeOf( "green_delta_min" ) <> JSON_UNDEFINED                 Then e.green_delta.low = json.GetNumber( "green_delta_min" )
	If json.TypeOf( "green_delta_max" ) <> JSON_UNDEFINED                 Then e.green_delta.high = json.GetNumber( "green_delta_max" )
	If json.TypeOf( "blue_delta_min" ) <> JSON_UNDEFINED                  Then e.blue_delta.low = json.GetNumber( "blue_delta_min" )
	If json.TypeOf( "blue_delta_max" ) <> JSON_UNDEFINED                  Then e.blue_delta.high = json.GetNumber( "blue_delta_max" )
End Function

Function initialize_generic_EMITTER_from_json_reference( e:EMITTER, json:TJSON )
	If Not e Or Not json Then Return
	If json.TypeOf( "attach_at" ) <> JSON_UNDEFINED
		Local obj:TJSONObject = json.GetObject( "attach_at" )
		If obj And Not obj.IsNull()
			Local attach_at:TJSON = TJSON.Create( obj )
			e.attach_at( ..
				attach_at.GetNumber( "offset_x" ), ..
				attach_at.GetNumber( "offset_y" ), ..
				attach_at.GetNumber( "dist_min" ), ..
				attach_at.GetNumber( "dist_max" ), ..
				attach_at.GetNumber( "dist_ang_min" ), ..
				attach_at.GetNumber( "dist_ang_max" ), ..
				attach_at.GetNumber( "vel_min" ), ..
				attach_at.GetNumber( "vel_max" ), ..
				attach_at.GetNumber( "vel_ang_min" ), ..
				attach_at.GetNumber( "vel_ang_max" ), ..
				attach_at.GetNumber( "acc_min" ), ..
				attach_at.GetNumber( "acc_max" ), ..
				attach_at.GetNumber( "acc_ang_min" ), ..
				attach_at.GetNumber( "acc_ang_max" ), ..
				attach_at.GetNumber( "ang_min" ), ..
				attach_at.GetNumber( "ang_max" ), ..
				attach_at.GetNumber( "ang_vel_min" ), ..
				attach_at.GetNumber( "ang_vel_max" ), ..
				attach_at.GetNumber( "ang_acc_min" ), ..
				attach_at.GetNumber( "ang_acc_max" ))
		End If
	End If
End Function

