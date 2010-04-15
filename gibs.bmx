Rem
	gibs.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
Global gibs_map:TMap = CreateMap()

Function get_gibs:TGibs( key$ )
	If Not key Then Return Null
  Local g:TGibs = TGibs( gibs_map.ValueForKey( key.toLower() ))
	Return g
End Function

'______________________________________________________________________________
Type TGibs
  'public fields
  Field destruct_force#
  Field gib_count%
  Field gib_image:IMAGE_ATLAS_REFERENCE[]
  Field gib_speed#[]
  Field gib_direction#[]
  'constants
  Const gibs_coefficient_of_friction# = 0.0100
  
  Method emit( parent:POINT, particle_list:TList )
    Local g:PARTICLE
    For Local i% = 0 Until gib_count
      g = PARTICLE(PARTICLE.Create( ..
        PARTICLE_TYPE_IMG, ..
        gib_image[i],,,,,, ..
        LAYER_FOREGROUND, ..
        True, ..
        gibs_coefficient_of_friction,,,,,,, ..
        LIFETIME_WHILE_MOVING, ..
        parent.pos_x, ..
        parent.pos_y, ..
        parent.vel_x + gib_speed[i]*Cos( gib_direction[i] ), ..
        parent.vel_y + gib_speed[i]*Sin( gib_direction[i] ), ..
        parent.ang ))
      particle_list.AddLast( g )
    Next
  End Method
  
  Method load_from_json:TGibs( json:TJSON )
    Return Null
  End Method
  
  Method generate_json:TJSON()
    Return Null
  End Method
  
End Type

