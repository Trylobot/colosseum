Rem
	managed_object.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const NULL_ID% = -1 'this should be a static member of MANAGED_OBJECT
Global next_managed_object_id% = 0 'this should be a static member of MANAGED_OBJECT

Type MANAGED_OBJECT
	Field id% 'unique integer id
	Field name$ 'optional name
	Field link:TLink 'back-reference to the list link which points to this object
	
	Method New()
		id = get_new_id()
	End Method
	
	Method managed%()
		Return (link <> Null)
	End Method
	
	Method manage( list:TList )
		If managed() Then unmanage()
		link = ( list.AddLast( Self ))
	End Method
	
	Method unmanage()
		If link <> Null
			link.Remove()
			link = Null
		End If
	End Method
	
	Function get_new_id%()
		next_managed_object_id :+ 1
		Return next_managed_object_id
	End Function
	
End Type
