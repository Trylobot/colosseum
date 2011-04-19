Rem
	tween.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type TWEEN
  Field time!
  Field begin!
  Field change!
  Field duration!
  Field ease!(t!,b!,c!,d!)
  
  Function Create:TWEEN( begin!, change!, duration!, easing_function!(t!,b!,c!,d!) )
    Local k:TWEEN = New TWEEN
    k.time = 0.0
    k.begin = begin
    k.change = change
    k.duration = duration
    k.ease = easing_function
    Return k
  End Function
  
  Method set_values( begin!, change!, duration! )
    Self.begin = begin
    Self.change = change
    Self.duration = duration
  End Method
  
  Method rewind()
    time = 0.0
  End Method
  
  Method service( elapsed! )
    time :+ elapsed
    If time > duration Then time = duration
  End Method
  
  Method get!( time! = -1 )
    If time = -1 Then time = Self.time
    Return ease( time, begin, change, duration )
  End Method
  
  Method is_finished%()
    Return (time >= duration)
  End Method
  
  
  'easing functions: credit to Robbert Penner, 2003
  
  Function linear_ease!( t!, b!, c!, d! )
    t :/ d
    Return c*t + b
  End Function
  
  Function quadratic_ease_in!( t!, b!, c!, d! )
    t :/ d
    Return c*t*t + b
  End Function
  
  Function quadratic_ease_out!( t!, b!, c!, d! )
    t :/ d
    Return -c*t*(t - 2.0) + b
  End Function
  
  Function quadratic_ease_in_out!( t!, b!, c!, d! )
    t :/ d
    If( t/2.0 < 1.0 )
      Return c/2.0*t*t + b
    Else
      t :- 1.0
      Return -c/2.0*(t*(t - 2.0) - 1.0) + b
    End If
  End Function
  
  Function sinusoidal_ease_in!( t!, b!, c!, d! )
    t :/ d
    Return -c*Cos(t*(Pi/2.0)) + c + b
  End Function
  
  Function sinusoidal_ease_out!( t!, b!, c!, d! )
    t :/ d
    Return c*Sin(t*(Pi/2.0)) + b
  End Function
  
  Function sinusoidal_ease_in_out!( t!, b!, c!, d! )
    t :/ d
    return -c/2.0*(Cos(t*Pi) - 1.0) + b
  End Function
  
End Type

