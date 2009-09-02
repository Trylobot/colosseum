Rem
	hud.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "widget.bmx"

'______________________________________________________________________________
Const	health_bar_w% = 85
Const health_bar_h% = 12

Global health_bits:TList = CreateList() 'TList<WIDGET> when the player loses any amount of life, a chunk of the life bar falls off; this list keeps track of them

