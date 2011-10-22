'gibs editor

'imports and constants
SuperStrict
Import TWRC.rJSON
Import "editor_common.bmx"
Import "data_structures.bmx"
Const W% = 1024
Const H% = 768
Const data_path$ = "data/gibs.media.json"
Const font_path$ = ""

'externs and containers
Global all_gibsets:gibset_meta[]
Global entities:entity[]
'editor state
Global current_entity% = 0
Global zoom# = 8.0

load_json_data()
load_entities()

init_graphics()

Repeat
	Cls

	'update
	check_commands()
	update_zoom()

	'draw
	draw_entity( entities[current_entity] )

	Flip
Until AppTerminate()


'//////////////////////////////////////////////////////////////////////////////
'Runtime Functions

Function draw_entity( ent:entity )
	SetScale( zoom, zoom )
	SetOrigin( W/2, H/2 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetColor( 255, 255, 255 )
	For Local i% = 0 Until ent.images.length
		Local offset_x# = ent.gibs[i].offset_x * zoom
		Local offset_y# = ent.gibs[i].offset_y * zoom
		DrawImage( ent.images[i], offset_x, offset_y )
	Next
EndFunction

Function update_zoom()
	Local z_speed% = MouseZSpeed()
	If z_speed < 0
		zoom :/ 1.5
	ElseIf z_speed > 0
		zoom :* 1.5
	EndIf
EndFunction

Function check_commands()
	Local CTRL% = KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL )
	Local S% = KeyDown( KEY_S )
	'Save
	If CTRL and S
		Local gibs_json_str$
		gibs_json_str = gibset_meta.encode( all_gibsets )
		SaveString( gibs_json_str, data_path )
	EndIf
EndFunction

'//////////////////////////////////////////////////////////////////////////////
'Initialization and Loading functions

Function load_json_data()
	Local gibs_json_str$
	gibs_json_str = LoadString( data_path )
	all_gibsets = gibset_meta[]( gibset_meta.decode( gibs_json_str ))
EndFunction

Function load_entities()
	AutoMidHandle( true )
	AutoImageFlags( 0 )
	entities = new entity[all_gibsets.length]
	For Local i% = 0 Until entities.length
		entities[i] = new entity
		entities[i].gibs = all_gibsets[i].object_.gibs
		entities[i].images = new TImage[entities[i].gibs.length]
		For Local j% = 0 Until entities[i].gibs.length
			entities[i].images[j] = LoadImage( entities[i].gibs[j].image_path )
		Next
	Next
EndFunction

Function init_graphics()
	Graphics( W, H )
	SetBlend( ALPHABLEND )
EndFunction

'//////////////////////////////////////////////////////////////////////////////
'Helper classes

Type entity
	Field gibs:gib_data[]
	Field images:TImage[]
EndType

