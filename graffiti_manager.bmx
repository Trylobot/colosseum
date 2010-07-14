Rem
	graffiti_manager.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "box.bmx"
'Import "texture_manager.bmx"
'Import "particle.bmx"

'______________________________________________________________________________
Type GRAFFITI_MANAGER
	Field cairo:TCairo
	Field pixmap:TPixmap
	Field brush:TCairoSurface
	Field brush_px:TPixmap
	Field ox#, oy#
	Field x%, y%
	Field t:BOX
	
	Method New()
		t = New BOX
	End Method
	
	Function Create:GRAFFITI_MANAGER( pixmap:TPixmap ) 'background_clean:TImage, backbuffer_width%, backbuffer_height% )
		Local g:GRAFFITI_MANAGER = New GRAFFITI_MANAGER
		g.cairo = TCairo.Create( TCairoImageSurface.CreateForPixmap( pixmap.width, pixmap.height, pixmap.format ))
		Local surface:TCairoSurface = TCairoImageSurface.CreateFromPixmap( pixmap )
		g.cairo.SetSourceSurface( surface, 0,0 )
		g.cairo.Paint()
		g.pixmap = TCairoImageSurface( g.cairo.GetTarget() ).pixmap()
		Return g
	End Function
	
	Method draw()
		GetOrigin( ox, oy )
		x = Max( 0, ox )
		y = Max( 0, oy )
		t.x = Max( 0, -ox )
		t.y = Max( 0, -oy )
		t.w = Min( pixmap.width - t.x, SETTINGS_REGISTER.WINDOW_WIDTH.get() - x )
		t.h = Min( pixmap.height - t.y, SETTINGS_REGISTER.WINDOW_HEIGHT.get() - y )
		If t.w <= 0 Or t.h <= 0
			Return
		End If
		DrawPixmap( pixmap.Window( t.x, t.y, t.w, t.h ), x, y )
	End Method
	
	Method add_graffiti( p:PARTICLE )
		cairo.IdentityMatrix()
		Local x#, y#
		cairo.Translate( ..
			p.pos_x - p.handle.r*Cos(p.handle.a + p.ang), ..
			p.pos_y - p.handle.r*Sin(p.handle.a + p.ang) )
		cairo.Rotate( p.ang )
		brush_px = p.get_pixmap() 
		brush = TCairoImageSurface.CreateFromPixmap( brush_px )
		cairo.SetSourceSurface( brush, 0,0 )
		cairo.Paint()
	End Method
	
End Type

