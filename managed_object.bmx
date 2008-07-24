Rem
	point.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Type MANAGED_OBJECT
	
	Field link:TLink 'back-reference to the TList:TLink which references this object as a value
	
	Method New()
	End Method
	
	Method add_me( list:TList )
		link = ( list.AddLast( Self ))
	End Method
	Method remove_me()
		link.Remove()
	End Method

End Type
