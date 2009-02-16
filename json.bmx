Rem
	json.bmx
	This is a COLOSSEUM project BlitzMax source file.
	original author: grable
	derivative author: Tyler W Cole
	downloaded from http://www.blitzbasic.com/codearcs/codearcs_bmx/2066.bmx at 12:57 PM on Sunday, August 24th, 2008
EndRem

'SuperStrict

'Import BRL.LinkedList
'Import BRL.Map

Rem

	'TJSONValue is the generic container for all JSON data types
	
	Type TJSONValue
		' determines the type of value
		Field Class:Int 
		
		' returns value by index (only valid for arrays)
		Method GetByIndex:TJSONValue( index:Int)
		
		' returns value by name (only valid for objects)
		Method GetByName:TJSONValue( name:Object)
		
		Method SetByIndex( index:Int, value:TJSONValue)
		Method SetByName( name:Object, value:TJSONValue)
		
		' lookup value by string (either a number or a name, valid for arrays & objects)
		Method LookupValue:TJSONValue( value:Object)
		
		' returns properly indented source representation of JSON data
		Method ToSource:String( level:Int = 0)
		
		' returns JSON data as string
		Method ToString:String()
	EndType
	
	Type TJSONNumber Extends TJSONValue
		Field Value:Double
	EndType
	
	Type TJSONString Extends TJSONValue
		Field Value:String
	EndType
	
	Type TJSONBoolean Extends TJSONValue
		Field Value:Int
	EndType
	
	Type TJSONObject Extends TJSONValue
		Field Items:TMap ' holds actual fields
		Field List:TList ' holds field order 
	EndType
	
	Type TJSONArray Extends TJSONValue
		Field Items:TJSONValue[]
	EndType
	
	The methods are implemented in the various subclasses.
		
**********************************************************************************************************************************
* TJSON handles all reading/writing of json data, and allows for easy acces to elements via "paths"
*	
	Type TJSON
		' the root JSON value
		Field Root:TJSONValue
		
		' create a new JSON from any source
		Function Create:TJSON( source:Object)
	
		' read JSON data from a TJSONValue, TStream or String
		Method Read:TJSONValue( source:Object)
		
		' write JSON data to a TStream or a file (as String)
		Method Write( dest:Object)
		
		' parses a string into its JSON data representation
		Method ParseString:TJSONValue( s:Object)
		
		' lookup a JSON value at at specified path, returns NULL on failure
		Method Lookup:TJSONValue( path:String)
	
		' sets a JSON value at path to value, value can be a TJSONValue or JSON data as a string
		Method SetValue( path:String, value:Object)
		
		' returns the json value at specified
		Method GetValue:TJSONValue( path:String)	
		
		' returns blitz specific types from specified paths
		Method GetNumber:Double( path:String)
		Method GetString:String( path:String)
		Method GetBoolean:Int( path:String)
		
		' returns only these specific objects
		Method GetObject:TJSONObject( path:String)
		Method GetArray:TJSONArray( path:String)
	
		' get a blitz array from a JSON array or NULL on failure
		Method GetArrayInt:Int[]( path:String)
		Method GetArrayDouble:Double[]( path:String)
		Method GetArrayString:String[]( path:String)
	EndType
	
**********************************************************************************************************************************
* PATHS
*		
	identifiers are seperated with ".", and has special syntax for array indices
		
	example:
		"users.joe.age"		' direct access
		"users.joe.medals.0" 	' array index, arrays are 0 based
	
endrem
		
'
' JSON value classes
'
Const JSON_UNDEFINED:Int = -1
Const JSON_NULL:Int	= 1
Const JSON_OBJECT:Int	= 2
Const JSON_ARRAY:Int	= 3
Const JSON_STRING:Int	= 4
Const JSON_NUMBER:Int	= 5
Const JSON_BOOLEAN:Int	= 6

Function JSON_Class_toString$( class% )
	Select class
		Case JSON_NULL
			Return "null"
		Case JSON_OBJECT
			Return "object"
		Case JSON_ARRAY
			Return "array"
		Case JSON_STRING
			Return "string"
		Case JSON_NUMBER
			Return "number"
		Case JSON_BOOLEAN
			Return "boolean"
		Case JSON_UNDEFINED
			Return "undefined"
	End Select
	Return ""
End Function


'
' used by TJSON / TJSONObject for identifier lookup
'
Type TJSONKey
	Field Value:String
	
	Method ToString:String()
		Return "~q" + Value + "~q"
	EndMethod
	
	Method Compare:Int( o:Object)
		Local key:TJSONKey = TJSONKey(o)
		If key Then Return Value.Compare( key.Value)		
		If String(o) Then Return Value.Compare( o)
		Return 1
	EndMethod
EndType


'
' JSON Value objects
'
Type TJSONValue Abstract
	Field Class:Int
	
	Method IsNull%()
		Return (Class = JSON_NULL)
	End Method
	
	Method GetByIndex:TJSONValue( index:Int)
		Return Null
	EndMethod
	
	Method GetByName:TJSONValue( name:Object) 
		Return Null
	EndMethod	
	
	Method SetByIndex( index:Int, value:TJSONValue)
	EndMethod
	
	Method SetByName( name:Object, value:TJSONValue)
	EndMethod	
	
	Method LookupValue:TJSONValue( value:Object)
		Return Self
	EndMethod
	
	Method ToSource:String( level:Int = 0) Abstract
EndType

Type TJSONObject Extends TJSONValue
	Field Items:TMap = New TMap
	Field List:TList = New TList ' for keeping the order of fields
	
	Method New()
		Class = JSON_OBJECT
	EndMethod	

	Method ToString:String()
		Local s:String, lines:Int = 0
		If List.Count() <= 0 Then Return "{}"
		For Local o:TNode = EachIn List
			If lines > 0 Then s :+ ","
			s :+ o._key.ToString() +":"
			Local jsv:TJSONValue = TJSONValue(o._value)
			If jsv.Class = JSON_STRING Then
				s :+ jsv.ToSource()
			Else
				s :+ jsv.ToString()
			EndIf
			lines :+ 1
		Next
		Return "{"+ s +"}"
	EndMethod
	
	Method ToSource:String( level:Int = 0)
		Local s:String, lines:Int = 0
		If List.Count() <= 0 Then Return "{}"
		For Local o:TNode = EachIn List
			If lines > 0 Then s :+ ",~n" + RepeatString( "~t", level + 1)			
			s :+ o._key.ToString() +": "+ TJSONValue(o._value).ToSource( level + 1)
			lines :+ 1
		Next
		'If lines > 1 Then Return "{~n"+ RepeatString( "~t", level + 1) + s + "~n" + RepeatString( "~t", level) + "}"
		'Return "{ "+ s +" }"
		Return "{~n"+ RepeatString( "~t", LEVEL + 1) + s + "~n" + RepeatString( "~t", LEVEL) + "}"
	EndMethod		
	
	Method GetByName:TJSONValue( name:Object)
		Return TJSONValue( Items.ValueForKey( name))
	EndMethod
	
	Method SetByName( name:Object, value:TJSONValue)
		If value = Null Then value = TJSON.NIL
		Local node:TNode
		If TJSONKey(name) Then
			Items.Insert( name, value)
			node = Items._FindNode( name)
			If Not List.Contains( node) Then List.AddLast( node)
		ElseIf String(name) Then
			Local s:String = String(name)
			If s.Length > 0 Then
				Items.Insert( s, value)
				node = Items._FindNode( s)
				If Not List.Contains( node) Then List.AddLast( node)
			EndIf
		EndIf
	EndMethod	
	
	Method LookupValue:TJSONValue( value:Object)
		If TJSONKey(value) Then
			Return GetByName( value)
		ElseIf String(value) Then
			If Not IsNumber( String(value)) Then Return GetByName( value)
		EndIf
	EndMethod
EndType

Type TJSONArray Extends TJSONValue
	Field Items:TJSONValue[]
	Field AutoGrow:Int = True
	
	Function Create:TJSONArray( size:Int)
		Local jso:TJSONArray = New TJSONArray
		jso.Items = New TJSONValue[ size]
		Return jso
	EndFunction
	
	Method New()
		Class = JSON_ARRAY
	EndMethod
	
	Method Size:Int()
		If Items Then Return Items.Length ..
		Else Return 0
	End Method

	Method ToString:String()
		Local s:String, lines:Int = 0
		If Items.Length <= 0 Then Return "[]"
		For Local o:TJSONValue = EachIn Items
			If lines > 0 Then s :+ ","			
			If o.Class = JSON_STRING Then
				s :+ o.ToSource()
			Else
				s :+ o.ToString()
			EndIf			
			lines :+ 1
		Next
		Return "["+ s +"]"
	EndMethod
	
	Method ToSource:String( level:Int = 0)
		If Items.Length <= 0 Then Return "[]"
		Local s:String, lines:Int = 0
		For Local o:TJSONValue = EachIn Items
			If lines > 0 Then s :+ ",~n" + RepeatString( "~t", level + 1)
			s :+ o.ToSource( level + 1)
			lines :+ 1
		Next
		'If lines > 1 Then Return "[~n" + RepeatString( "~t", LEVEL + 1) + s + "~n" + RepeatString( "~t", LEVEL) + "]"
		'Return "[ "+ s +" ]"
		Return "[~n" + RepeatString( "~t", LEVEL + 1) + s + "~n" + RepeatString( "~t", LEVEL) + "]"
	EndMethod
	
	Method GetByIndex:TJSONValue( index:Int)
		If (index >= 0) And (index < Size()) Then
			Return TJSONValue( Items[ index])
		EndIf
	EndMethod
	
	Method SetByIndex( index:Int, value:TJSONValue)
		If (index >= 0) And (index < Items.Length) Then
			Items[ index] = value
		ElseIf AutoGrow And (Index >= Items.Length) Then
			Local oldlen:Int = Items.Length
			Items = Items[..index + 1]
			For Local i:Int = oldlen Until Items.Length
				Items[i] = TJSON.NIL
			Next
			Items[index] = value
		EndIf
	EndMethod
	
	Method LookupValue:TJSONValue( value:Object)
		If TJSONKey(value) Then
			Local s:String = TJSONKey(value).Value
			If IsNumber( s) Then Return GetByIndex( s.ToInt())
		ElseIf String(value) Then
			If IsNumber( String(value)) Then Return GetByIndex( String(value).ToInt())
		EndIf	
	EndMethod
EndType


Type TJSONString Extends TJSONValue
	Field Value:String	
	
	Method New()
		Class = JSON_STRING
	EndMethod
	
	Function Create:TJSONString( value:String)
		Local jso:TJSONString = New TJSONString
		jso.Value = value
		Return jso
	EndFunction
		
	Method ToString:String()
		Return Value
	EndMethod
	
	Method ToSource:String( level:Int = 0)
		Return "~q" + Value + "~q"
	EndMethod
EndType

Type TJSONNumber Extends TJSONValue
	Field Value:Double
	
	Method New()
		Class = JSON_NUMBER
	EndMethod	

	Function Create:TJSONNumber( value:Double)
		Local jso:TJSONNumber = New TJSONNumber
		jso.Value = value
		Return jso
	EndFunction
	
	Method ToString:String()
		Return DoubleToString( Value)
	EndMethod	
	
	Method ToSource:String( level:Int = 0)
		Return DoubleToString( Value)
	EndMethod		
EndType

Type TJSONBoolean Extends TJSONValue
	Field Value:Int
	
	Method New()
		Class = JSON_BOOLEAN
	EndMethod	
	
	Function Create:TJSONBoolean( value:Int)
		Local jso:TJSONBoolean = New TJSONBoolean 
		jso.Value = value
		Return jso
	EndFunction
	
	Method ToString:String()
		If Value Then Return "true"
		Return "false"
	EndMethod	
	
	Method ToSource:String( level:Int = 0)
		If Value Then Return "true"
		Return "false"
	EndMethod		
EndType

Type TJSONNull Extends TJSONValue
	Method New()
		Class = JSON_NULL
	EndMethod

	Method ToString:String()
		Return "null"
	EndMethod
	
	Method ToSource:String( level:Int = 0)
		Return "null"
	EndMethod	
EndType



'
' Parses any string into its JSONValue representation
'
Type TJSONParser
	Const ARRAY_GROW_SIZE:Int = 32

	Const OBJECT_START:Byte = Asc("{")
	Const OBJECT_STOP:Byte = Asc("}")		
	Const ARRAY_START:Byte = Asc("[")
	Const ARRAY_STOP:Byte = Asc("]")
	Const FIELD_SEP:Byte = Asc(":")
	Const ELEM_SEP:Byte = Asc(",")
	Const IDENT_START1:Byte = Asc("a")
	Const IDENT_STOP1:Byte = Asc("z")
	Const IDENT_START2:Byte = Asc("A")
	Const IDENT_STOP2:Byte = Asc("Z")
	Const UNDERSCORE:Byte = Asc("_")
	Const MINUS:Byte = Asc("-")		
	Const NUMBER_START:Byte = Asc("0")
	Const NUMBER_STOP:Byte = Asc("9")
	Const NUMBER_SEP:Byte = Asc(".")
	Const STRING_START1:Byte = Asc("~q")
	Const STRING_START2:Byte = Asc("'")
	Const STRING_ESC:Byte = Asc("\")
	Const SPACE:Byte = Asc(" ")
	Const TAB:Byte = Asc("~t")
	Const CR:Byte = Asc("~r")
	Const LF:Byte = Asc( "~n")

	Field Source:String
	Field Index:Int
	Field MakeLowerCase:Int
	
	Method Parse:TJSONValue()
		Local c:Byte
		' skip whitspace & crlf		
		While Index < Source.Length
			c = Source[Index]			
			If (c = SPACE) Or (c = TAB) Or (c = CR) Or (c = LF) Then
				Index :+ 1
				Continue
			EndIf
			Exit
		Wend
		' at end allready ?
		If (Index >= Source.Length) Or (Source[Index] = 0) Then Return Null
		
		c = Source[Index]
		If c = OBJECT_START Then
			' OBJECT
			Local jso:TJSONObject = New TJSONObject
			Index :+ 1			
			While Index < Source.Length
				' skip whitespace & crlf
				While Index < Source.Length
					c = Source[Index]			
					If (c = SPACE) Or (c = TAB) Or (c = CR) Or (c = LF) Then
						Index :+ 1
						Continue
					EndIf
					Exit
				Wend
				
				If c = ELEM_SEP Then
					Index :+ 1
				ElseIf c = OBJECT_STOP
					Index :+ 1
					' return json object
					Return jso
				Else				
					Local start:Int = Index, idinstr:Int = False
					Local name:String
					If c = STRING_START1 Or c = STRING_START2 Then						
						' get name enclosed in string tags
						Local strchar:Byte = c
						Index :+ 1
						start = Index
						While (Index < Source.Length) And (Source[Index] <> strchar)
							If Source[Index] = STRING_ESC Then
								Index :+ 1
							EndIf
							Index :+ 1
						Wend
						name = Source[start..Index]					
						' escape string			
						'name = name.Replace( "\/", "/") ' wtf???
						name = name.Replace( "\~q", "~q")
						name = name.Replace( "\'", "'")
						name = name.Replace( "\t", "~t")
						name = name.Replace( "\r", "~r")
						name = name.Replace( "\n", "~n")
						name = name.Replace( "\\", "\")
						Index :+ 1
						idinstr = True
					Else
						' get name as an identifier
						Index :+ 1
						While Index < Source.Length
							c = Source[Index]
							If ((c >= IDENT_START1) And (c <= IDENT_STOP1)) Or ((c >= IDENT_START2) And (c <= IDENT_STOP2)) Or ..
								((c >= NUMBER_START) And (c <= NUMBER_STOP)) Or (c = UNDERSCORE) Or (c = MINUS) Then
								Index :+ 1
								Continue
							EndIf
							name = Source[start..Index]
							Exit 
						Wend
					EndIf									
					' skip whitespace & crlf
					While Index < Source.Length
						c = Source[Index]			
						If (c = SPACE) Or (c = TAB) Or (c = CR) Or (c = LF) Then
							Index :+ 1
							Continue
						EndIf
						Exit
					Wend
					' check for field seperator
					If c <> FIELD_SEP Then
						Error( "expected field seperator ~q:~q")
						Return Null
					EndIf
					Index :+ 1
					' parse value
					Local val:TJSONValue = Parse()
					If val = Null Then Return Null
					If idinstr Then
						Local key:TJSONKey = New TJSONKey
						key.Value = name
						jso.SetByName( key, val)
					Else
						jso.SetByName( name, val)
					EndIf
				EndIf
			Wend
		ElseIf c = ARRAY_START Then
			' ARRAY
			Local jso:TJSONArray = TJSONArray.Create( ARRAY_GROW_SIZE)
			Local count:Int = 0
			Index :+ 1			
			While Index < Source.Length
				' skip whitespace & crlf
				While Index < Source.Length
					c = Source[Index]			
					If (c = SPACE) Or (c = TAB) Or (c = CR) Or (c = LF) Then
						Index :+ 1
						Continue
					EndIf
					Exit
				Wend	
				' parse value
				If c = ELEM_SEP Then
					Index :+ 1
					count :+ 1
				ElseIf c = ARRAY_STOP Then
					Index :+ 1
					' return json array
					jso.Items = jso.Items[..count+1]					
					Return jso
				Else
					Local val:TJSONValue = Parse()
					If val = Null Then Return Null
					' expand array if needed
					If count >= jso.Items.Length Then
						jso.Items = jso.Items[..jso.Items.Length+ARRAY_GROW_SIZE]
					EndIf					
					jso.SetByIndex( count, val)
				EndIf
			Wend
		ElseIf c = STRING_START1 Or c = STRING_START2 Then			
			' STRING
			Local strchar:Byte = c
			Index :+ 1
			Local start:Int = Index
			While (Index < Source.Length) And (Source[Index] <> strchar)
				If Source[Index] = STRING_ESC Then
					Index :+ 1
				EndIf				
				Index :+ 1				
			Wend
			Index :+ 1
			' escape string
			Local s:String = Source[start..Index-1]
			's = s.Replace( "\/", "/") ' wtf???
			s = s.Replace( "\~q", "~q")
			s = s.Replace( "\'", "'")
			s = s.Replace( "\t", "~t")
			s = s.Replace( "\r", "~r")
			s = s.Replace( "\n", "~n")
			s = s.Replace( "\\", "\")
			' return json string
			Return TJSONString.Create( s)
			
		ElseIf ((c >= NUMBER_START) And (c <= NUMBER_STOP)) Or (c = MINUS) Then
			' NUMBER
			Local start:Int = Index, gotsep:Int = False
			' scan for rest of number
			Index :+ 1
			While Index < Source.Length
				c = Source[Index]
				If (c >= NUMBER_START) And (c <= NUMBER_STOP) Then
					Index :+ 1
					Continue
				ElseIf c = NUMBER_SEP Then
					If gotsep Then 
						Error( "invalid floating point number")
						Return Null
					EndIf
					gotsep = True
					Index :+ 1
					Continue
				EndIf
				Exit
			Wend
			' return json number
			Return TJSONNumber.Create( Source[start..Index].ToDouble())
			
		ElseIf (c >= IDENT_START1) And (c <= IDENT_STOP1)  Then
			' TRUE FALSE NULL		
			Local start:Int = Index
			' scan for rest of identifier
			While Index < Source.Length
				c = source[Index]
				If (c >= IDENT_START1) And (c <= IDENT_STOP1) Then
					Index :+ 1
					Continue
				EndIf
				Exit
			Wend
			' validate identifier
			Local s:String = Source[start..Index]
			If s = "false" Then Return TJSONBoolean.Create( False)
			If s = "true" Then Return TJSONBoolean.Create( True)
			If s = "null" Then Return TJSON.NIL
			Error( "expected ~qtrue~q,~qfalse~q Or ~qnull~q")
			Return Null
		Else
			Error( "unknown character: " + Chr(c) )
		EndIf
	EndMethod
	
	Method Error( msg:String)
		global_error_message :+ "JSON_PARSER_ERROR; index: "+Index+"; " + msg
		load_error()
	EndMethod
EndType




'
' Main JSON object, allows access to values via paths and for reading/writing
'
Type TJSON
	Global NIL:TJSONValue = New TJSONNull
	
	Field Root:TJSONValue = NIL
	Field LookupKey:TJSONKey = New TJSONKey
	
	Method isNull%()
		Return Root = NIL
	End Method
	
	Function Create:TJSON( source:Object)
		Local json:TJSON = New TJSON
		json.Read( source)
		Return json
	EndFunction
	
	Method Read:TJSONValue( source:Object)
		Root = NIL
		If TJSONValue(source) Then
			' set root	
			Root = TJSONValue( source)
			Return Root
		ElseIf TStream(source) Then
			' read strings from stream
			Local s:String, stream:TStream = TStream(source)
			While Not stream.Eof()
				s :+ stream.ReadLine() + "~n"
			Wend
			' parse string
			Local parser:TJSONParser = New TJSONParser
			parser.Source = s
			Root = parser.Parse()
			If Root Then Return Root
			Root = NIL
		ElseIf String(source) Then
			' parse string
			Local parser:TJSONParser = New TJSONParser
			parser.Source = String(source)
			Root = parser.Parse()
			If Root Then Return Root			
			Root = NIL
		EndIf
		Return Null
	EndMethod
	
	Method Write( dest:Object)
		If TStream(dest) Then
			TStream(dest).WriteString( Root.ToSource() + "~n" )
		ElseIf String(dest) Then
			Local stream:TStream = WriteFile( String(dest))
			If Not stream Then Return
			stream.WriteString( Root.ToSource() + "~n" )
			stream.Close()
		EndIf
	EndMethod
	
	Method ParseString:TJSONValue( s:Object)
		If TJSONValue(s) Then Return TJSONValue(s)
		If Not String(s) Then Return NIL
		Local parser:TJSONParser = New TJSONParser
		parser.Source = String(s)
		Local val:TJSONValue = parser.Parse()
		If val Then Return val
		Return NIL
	EndMethod

	Method Lookup:TJSONValue( path:String)
		If (path.Length = 0) Or (path.ToLower() = "root") Then Return Root
		LookupKey.Value = GetNext( path, ".")
		Local val:TJSONValue = Root.LookupValue( LookupKey)
		If val Then
			Local last:TJSONValue = val
			While path.Length > 0
				last = val
				LookupKey.Value = GetNext( path, ".")
				val = last.LookupValue( LookupKey)
			Wend			
			Return val
		EndIf
	EndMethod
	
	Method TypeOf%( path$ )
		Local val:TJSONValue = Lookup( path )
		If val Then Return val.Class ..
		Else Return JSON_UNDEFINED
	End Method
	
	Method SetValue( path:String, value:Object)
		LookupKey.Value = GetNext( path, ".")
		Local val:TJSONValue = Root.LookupValue( LookupKey)
		If val Then
			Local last:TJSONValue = Root
			While (path.Length > 0) And val
				last = val
				LookupKey.Value = GetNext( path, ".")
				val = last.LookupValue( LookupKey)
			Wend			
			If (last.Class = JSON_ARRAY) And IsNumber( LookupKey.Value) Then
				last.SetByIndex( LookupKey.Value.ToInt(), ParseString(value))
			ElseIf (last.Class = JSON_OBJECT) And (Not IsNumber( LookupKey.Value)) Then
				last.SetByName( LookupKey.Value, ParseString(value))
			EndIf
		Else
			If (Root.Class = JSON_ARRAY) And IsNumber( LookupKey.Value) Then
				Root.SetByIndex( LookupKey.Value.ToInt(), ParseString(value))
			ElseIf (Root.Class = JSON_OBJECT) And (Not IsNumber( LookupKey.Value)) Then
				Root.SetByName( LookupKey.Value, ParseString(value))
			EndIf			
		EndIf
	EndMethod
		
	Method GetValue:TJSONValue( path:String)
		Local val:TJSONValue = Lookup( path)
		If val Then Return val
		Return NIL
	EndMethod
	
	Method GetNumber:Double( path:String)
		Local val:TJSONValue = Lookup( path)
		If val And val.Class = JSON_NUMBER Then Return TJSONNumber(val).Value
		Return 0.0
	EndMethod
	
	Method GetString:String( path:String)
		Local val:TJSONValue = Lookup( path)
		If val And val.Class = JSON_STRING Then Return TJSONString(val).Value
		Return Null
	EndMethod	
	
	Method GetBoolean:Int( path:String)
		Local val:TJSONValue = Lookup( path)
		If val And val.Class = JSON_BOOLEAN Then Return TJSONBoolean(val).Value
		Return False
	EndMethod
	
	Method GetObject:TJSONObject( path:String)
		Local val:TJSONValue = Lookup( path)
		If val And val.Class = JSON_OBJECT Then Return TJSONObject(val)
		Return Null
	EndMethod
	
	Method GetArray:TJSONArray( path:String)
		Local val:TJSONValue = Lookup( path)
		If val And val.Class = JSON_ARRAY Then Return TJSONArray(val)
		Return Null
	EndMethod	

'
' not realy sure if these GetArrayXXX are necessary
'	
	Method GetArrayInt:Int[]( path:String)
		Local val:TJSONArray = GetArray( path)
		If val And (val.Items.Length > 0) Then
			Local a:Int[] = New Int[ val.Items.Length]
			For Local i:Int = 0 Until val.Items.Length
				Select val.Items[i].Class
					Case JSON_NUMBER
						a[i] = Int TJSONNumber( val.Items[i]).Value
					Case JSON_STRING
						a[i] = TJSONString( val.Items[i]).Value.ToInt()
					Case JSON_BOOLEAN
						a[i] = TJSONBoolean( val.Items[i]).Value
				EndSelect
			Next
			Return a
		EndIf
		Return Null
	EndMethod
	
	Method GetArrayDouble:Double[]( path:String)
		Local val:TJSONArray = GetArray( path)
		If val And (val.Items.Length > 0) Then
			Local a:Double[] = New Double[ val.Items.Length]
			For Local i:Int = 0 Until val.Items.Length
				Select val.Items[i].Class
					Case JSON_NUMBER
						a[i] = TJSONNumber( val.Items[i]).Value
					Case JSON_STRING
						a[i] = TJSONString( val.Items[i]).Value.ToDouble()
					Case JSON_BOOLEAN
						a[i] = Double TJSONBoolean( val.Items[i]).Value
				EndSelect
			Next
			Return a
		EndIf
		Return Null
	EndMethod	
	
	Method GetArrayString:String[]( path:String)
		Local val:TJSONArray = GetArray( path)
		If val And (val.Items.Length > 0) Then
			Local a:String[] = New String[ val.Items.Length]
			For Local i:Int = 0 Until val.Items.Length
				Select val.Items[i].Class
					Case JSON_NUMBER, JSON_STRING, JSON_BOOLEAN, JSON_NULL
						a[i] = val.Items[i].ToString()
					Case JSON_OBJECT
						a[i] = "{}"
					Case JSON_ARRAY
						a[i] = "[]"
				EndSelect
			Next
			Return a
		EndIf
		Return Null
	EndMethod	
		
	Method ToString:String()
		Return Root.ToString()
	EndMethod
	
	Method ToSource:String( level:Int = 0)
		Return Root.ToSource( level)
	EndMethod	
EndType

Private

Function GetNext:String( value:String Var, sep:String)	
	If (value.Length <= 0) Or (sep.Length <= 0) Then Return Null
	Local res:String, index:Int = value.Find( sep)
	If index = 0 Then
		value = value[1..]
		Return Null
	ElseIf index >= 1 Then
		res = value[..index]
		value = value[ 1 + res.Length..]
		Return res
	EndIf	
	res = value
	value = Null
	Return res
EndFunction

Function IsNumber:Int( value:String)
	For Local i:Int = 0 Until value.Length
		Local c:Byte = value[i]  
		If (c < TJSONParser.NUMBER_START) Or (c > TJSONParser.NUMBER_STOP) Then Return False
	Next
	Return True
EndFunction

Function DoubleToString:String( value:Double)
	Const STR_FMT:String = "%f"
	Const CHAR_0:Byte = Asc("0")
	Const CHAR_DOT:Byte = Asc(".")
	Extern "C"
		Function modf_:Double( x:Double, iptr:Double Var) = "modf"
		Function snprintf_:Int( s:Byte Ptr, n:Int, Format$z, v1:Double) = "snprintf"
	EndExtern	

	Local i:Double
	If modf_( value, i) = 0.0 Then
		Return String.FromLong( Long i)
	Else
		Local buf:Byte[32]
		Local sz:Int = snprintf_( buf, buf.Length, STR_FMT, value)
		sz :- 1
		While (sz > 0) And (buf[ sz] = CHAR_0)
			If buf[ sz-1] = CHAR_DOT Then Exit
			sz :- 1
		Wend
		sz :+ 1
		If sz > 0 Then Return String.FromBytes( buf, sz)
	EndIf
	Return "0"
EndFunction

Function RepeatString:String( s:String, count:Int)
	Local res:String
	While count > 0
		res :+ s
		count :- 1
	Wend
	Return res	
EndFunction

Public

Function Create_TJSONArray_from_Int_array:TJSONArray( arr%[], boolean_mode% = False  )
	If arr = Null Or arr.Length = 0
		Return TJSONArray( TJSON.NIL )
	End If
	Local this_json:TJSONArray = TJSONArray.Create( arr.Length )
	For Local index% = 0 To arr.Length - 1
		Local val:TJSONValue
		If boolean_mode
			val = TJSONBoolean.Create( arr[index] )
		Else 'Not boolean_mode
			val = TJSONNumber.Create( arr[index] )
		End If
		this_json.SetByIndex( index, val )
	Next
	Return this_json
End Function

Function Create_Int_array_from_TJSONArray:Int[]( json:TJSONArray, boolean_mode% = False  )
	If json = Null Then Return Null
	Local index%
	Local arr%[] = New Int[json.Size()]
	For index = 0 To json.Size() - 1
		If boolean_mode
			arr[index] = TJSONBoolean( json.getbyindex( index )).Value
		Else 'Not boolean_mode
			arr[index] = TJSONNumber( json.GetByIndex( index )).Value
		End If
	Next
	Return arr
End Function

Function Create_TJSONArray_from_Int_array_array:TJSONArray( arr%[][] )
	If arr = Null Or arr.Length = 0
		Return TJSONArray( TJSON.NIL )
	End If
	Local this_json:TJSONArray = TJSONArray.Create( arr.Length )
	For Local index% = 0 To arr.Length - 1
		this_json.SetByIndex( index, Create_TJSONArray_from_Int_array( arr[index] ))
	Next
	Return this_json
End Function

Function Create_Int_array_array_from_TJSONArray:Int[][]( json:TJSONArray )
	If json = Null Then Return Null
	Local index%, sub_index%
	Local arr%[][] = Null
	If json <> Null And json.Size() > 0
		arr = New Int[][json.Size()]
		Local sub_json:TJSONArray
		For index = 0 To json.Size() - 1
			sub_json = TJSONArray( json.GetByIndex( index ))
			arr[index] = New Int[sub_json.Size()]
			For sub_index = 0 To sub_json.Size() - 1
				arr[index][sub_index] = TJSONNumber( sub_json.GetByIndex( sub_index )).Value
			Next
		Next
	End If
	Return arr
End Function

Function Create_TJSONArray_from_2D_Int_array:TJSONArray( arr%[,], boolean_mode% = False )
	Local this_json:TJSONArray = TJSONArray( TJSON.NIL )
	If arr <> Null
		Local rows%, cols%, r%, c%, dim%[]
		dim = arr.Dimensions()
		If dim.Length = 2
			rows = dim[0]
			cols = dim[1]
			If rows > 0 And cols > 0
				this_json = TJSONArray.Create( rows )
				For r = 0 To rows - 1
					Local this_row_json:TJSONArray = TJSONArray.Create( cols )
					For c = 0 To cols - 1
						Local val:TJSONValue
						If boolean_mode
							val = TJSONBoolean.Create( arr[r,c] )
						Else
							val = TJSONNumber.Create( arr[r,c] )
						End If
						this_row_json.SetByIndex( c, val )
					Next
					this_json.SetByIndex( r, this_row_json )
				Next
			End If
		End If
	End If
	Return this_json
End Function

Function Create_2D_Int_array_from_TJSONArray:Int[,]( json:TJSONArray, boolean_mode% = False )
	If json = Null Then Return Null
	Local arr%[,] = Null
	If json <> Null And Not json.IsNull()
		Local rows%, cols%, r%, c%
		rows = json.Size()
		If rows > 0
			cols = TJSONArray( json.GetByIndex( 0 )).Size()
			If cols > 0
				arr = New Int[rows,cols]
				For r = 0 To rows - 1
					Local this_row_json:TJSONArray = TJSONArray( json.GetByIndex( r ))
					For c = 0 To cols - 1
						If boolean_mode
							arr[r,c] = TJSONBoolean( this_row_json.GetByIndex( c )).Value
						Else
							arr[r,c] = TJSONNumber( this_row_json.GetByIndex( c )).Value
						End If
					Next
				Next
			End If
		End If
	End If
	Return arr
End Function

Function Create_String_array_from_TJSONArray:String[]( json:TJSONArray )
	If json = Null Then Return Null
	Local index%
	Local arr$[] = New String[json.Size()]
	For index = 0 To json.Size() - 1
		Local jval:TJSONString = TJSONString( json.GetByIndex( index ))
		If jval Then arr[index] = jval.Value
	Next
	Return arr
End Function

Function Create_TJSONArray_from_String_array:TJSONArray( str$[] )
	If Not str Then Return Null
	Local arr:TJSONArray = TJSONArray.Create( str.Length )
	For Local i% = 0 To str.Length - 1
		arr.SetByIndex( i, TJSONString.Create( str[i] ))
	Next
	Return arr
End Function

Function Create_String_array_array_from_TJSONArray:String[][]( json:TJSONArray )
	If Not json Or json.IsNull() Then Return Null
	Local index%
	Local arr$[][] = New String[][json.Size()]
	For index = 0 To json.Size() - 1
		Local jval:TJSONArray = TJSONArray( json.GetByIndex( index ))
		If jval Then arr[index] = Create_String_array_from_TJSONArray( jval )
	Next
	Return arr
End Function

Function Create_TJSONArray_from_String_array_array:TJSONArray( str$[][] )
	If Not str Then Return Null
	Local arr:TJSONArray = TJSONArray.Create( str.Length )
	For Local i% = 0 To str.Length - 1
		Local jval:TJSONValue = Create_TJSONArray_from_String_array( str[i] )
		If jval
			arr.SetByIndex( i, jval )
		Else
			arr.SetByIndex( i, TJSON.NIL )
		End If
	Next
	Return arr
End Function

