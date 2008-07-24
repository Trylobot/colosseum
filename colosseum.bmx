'classes
Type point
	
	Field x#
	Field y#
	Field a#
	
	Method New()
	EndMethod
	
	Function createPoint:point( ix#, iy#, ia# )
		Local p:point = New point
		p.x = ix; p.y = iy; p.a = ia
		Return p
	EndFunction
	
EndType

'window & graphics
Const width = 550, height = 550
Graphics width, height
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

'objects
Local tank_chassis:TImage = LoadImage( "tank_chassis.png" )
SetImageHandle( tank_chassis, 16, 16 )
Local tank_turret:TImage = LoadImage( "tank_turret.png" )
SetImageHandle( tank_turret, 16, 16 )
Local tread:TImage = LoadImage( "tread.png" )
SetImageHandle( tread, 1, 16 )
Local scar:TImage = LoadImage( "scar.png" )
SetImageHandle( scar, 50, 50 )
Local bg:TImage = LoadImage( "bg.png" )

'constants
Const vc# = 1.800
Const ac# = 2.500
Const treadspacing# = 3

'variables
Local px# = width/2, py# = height/2
Local vx# = 0, vy# = 0
Local a# = 0
Local a_t# = 0
Local va# = 0
Local va_t# = 0
Local dist# = 0

'managers
treadlist:TList = CreateList()
Local FLAG_emit_tread = False

Local t:TTimer = CreateTimer( 60 )
lastTicks = 0


'main game loop
Repeat

	If TimerTicks( t ) - lastTicks >= 1
		
		lastTicks = TimerTicks( t )
		
		dist :+ vc
		If dist >= treadspacing
			FLAG_emit_tread = True
			'reset distance counter
			dist = 0
			
		Else
			FLAG_emit_tread = False
			
		EndIf
		
		'update velocity and emit a tread sprite if necessary
		If KeyDown( Key_W )
			vx = vc * Cos( a )
			vy = vc * Sin( a )
			'place a trail at rear of tank
			If FLAG_emit_tread
				treadlist.AddLast( point.createPoint( px + (-15*Cos(a)), py + (-15*Sin(a)), a ))
				FLAG_emit_tread = False
				
			EndIf
			
		ElseIf KeyDown( Key_S )
			vx = -vc * Cos( a )
			vy = -vc * Sin( a )
			'place a trail at front of tank
			If FLAG_emit_tread
				treadlist.AddLast( point.createPoint( px + (15*Cos(a)), py + (15*Sin(a)), a ))
				FLAG_emit_tread = False
				
			EndIf
			
		Else
			vx = 0
			vy = 0
			
		EndIf
		
		If KeyDown( Key_D )
			va = vc
			
		ElseIf KeyDown( Key_A )
			va = -vc
			
		Else
			va = 0
			
		EndIf
		
		If KeyDown( Key_L )
			va_t = vc
			
		ElseIf KeyDown( Key_J )
			va_t = -vc
			
		Else
			va_t = 0
			
		EndIf
		
		'update position
		px :+ vx
		py :+ vy
		
		If px > width  Then px :- width
		If px < 0      Then px :+ width
		If py > height Then py :- height
		If py < 0      Then py :+ height
		
		'update angle (rotation)
		a :+ va
		a_t :+ va
		a_t :+ va_t
		If a > 360 Then a :- 360
		If a < 0   Then a :+ 360
		If a_t > 360 Then a_t :- 360
		If a_t < 0   Then a_t :+ 360
		
	EndIf
		
	'draw
	Cls
	
	'drag bg
	SetRotation( 0 )
	DrawImage( bg, 25, 25 )
	
	'draw scars
	DrawImage( scar, 250, 250 )
	
	'draw treadmarks
	For Local tp:point = EachIn treadlist
		SetRotation( tp.a )
		DrawImage( tread, tp.x, tp.y )
	Next

	'draw tank
	SetRotation( a )
	DrawImage( tank_chassis, px, py )
	SetRotation( a_t )
	DrawImage( tank_turret, px, py )
	
	Flip(1)

Until KeyDown( Key_Escape ) Or AppTerminate()


