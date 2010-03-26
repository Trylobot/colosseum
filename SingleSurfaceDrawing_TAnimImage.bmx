Type TAnimImage
	
	Field Image		:TImage
	Field width		:Int
	Field height		:Int
	Field u0			:Float[]
	Field v0			:Float[]
	Field u1			:Float[]
	Field v1			:Float[] 

        Function         Load:TAnimImage(url:Object,cell_width:Float,cell_height:Float,start:Int,frames:Int,flags=-1)
		Local t:TAnimImage = New TAnimImage
		Local tx:Float
		Local ty:Float
		Local x_Cells:Int
		t.u0		= New Float[frames]
		t.v0		= New Float[frames]
		t.u1		= New Float[frames]
		t.v1		= New Float[frames]
		t.Image 	= LoadImage(url,flags)
		Local xDelta:Float = t.Image.Width / Pow2Size(t.image.width)		
		Local yDelta:Float = t.Image.Height / Pow2Size(t.image.height)
		x_cells	= t.Image.Width  / cell_width
		For Local f = start To frames - 1
			tx = (f Mod x_cells * cell_width) * xdelta
			ty 	= (f / x_cells * cell_Height) * ydelta
			t.u0[f]	= Float(tx) / Float(t.Image.Width)
			t.v0[f] 	= Float(ty) / Float(t.Image.Height)
			t.u1[f]	= Float(tx + cell_width * xdelta)  / Float(t.Image.Width)
			t.v1[f]	= Float(ty + cell_Height * ydelta) / Float(t.Image.Height)
		Next
		Return t		
	End Function
	
	Function  Pow2Size:Float( n )
		Local t=1
		While t<n
			t:*2
		Wend
		Return t
	End Function

	
	Function Free(t:TAnimImage)
		t.Image = Null
		t = Null
		FlushMem()
	End Function
	
	Method Draw(x:Float,y:Float,width:Float,height:Float,frame:Int=0)
		Local DXFrame:TDX7ImageFrame = TDX7ImageFrame (image.frame(0))
		If DXFrame
                   DXFrame.setUV(u0[frame],v0[frame],u1[frame],v1[frame])
                Else
                    Local GLFrame:TGLImageFrame = TGLImageFrame(image.frame(0))
                    GLFrame.u0 = u0[frame]
                    GLFrame.u1 = u1[frame]
                    GLFrame.v0 = v0[frame]
                    GLFrame.v1 = v1[frame]
                EndIf
		DrawImageRect(Self.Image,x,y,width,height)
	End Method
End Type

REM
Graphics 640,480,0,NOSYNC

Print "Start Memory " + MemAlloced()

Local now:Int = MilliSecs()

Local blob:TAnimImage = TAnimImage.Load("gfx/stoneset0.png",32,64,0,32,FILTEREDIMAGE)
'Local blob:TImage = LoadAnimImage("gfx/stoneset0.png",32,64,0,32,FILTEREDIMAGE)

For Local a = 1 To 100
	Cls
	For Local b = 1 To 10000
		blob.Draw(Rand(0,640),Rand(0,480),20,40,Rand(0,31))
		'DrawImageRect(blob,Rand(0,640),Rand(0,480),20,40,Rand(0,31))
	Next
	Flip
Next

Print "End Memory " + MemAlloced()
Local time:Int = MilliSecs()-now
Print "Time Taken " + time

WaitKey()
ENDREM

