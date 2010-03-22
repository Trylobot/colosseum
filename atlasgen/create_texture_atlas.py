#!/usr/bin/python

# script for making a texture atlas from myriad individual files
#   original version
#     http://atlasgen.sourceforge.net/

# dependencies:
#   Python 2.6.5 
#     http://www.python.org/download/
#   Python Imaging Library (PIL) 1.1.7
#     http://www.pythonware.com/products/pil/#pil117
#   argparse 1.1
#     http://pypi.python.org/pypi/argparse

from __future__ import with_statement
import rect.rect as Rect
import rect.packer as Packer
import PIL.Image as Image
import sys
import math
import os
import argparse
from string import Template
from math import ceil, log


def get_arg_parser():
    parser = argparse.ArgumentParser(
        description="pass filenames of textures to pack via standard input, one file per line. pass an empty line to stop")
    parser.add_argument('-x','--xmin',type=int,action='store', help='minimum width of the target atlas')
    parser.add_argument('-y','--ymin',type=int,action='store', help='minimum height of the target atlas')
    parser.add_argument('-z','--xmax',type=int,action='store', help='maximum width of the target atlas')
    parser.add_argument('-w','--ymax',type=int,action='store', help='maximum height of the target atlas')
    parser.add_argument('-o','--output',action='store', help='file to which the texture atlas (PNG) will be written')
    parser.add_argument('-c','--chart',action='store', help='file to which the coordinate data (JSON) will be written')
    parser.set_defaults(xmin=1,ymin=1,xmax=8192,ymax=8192)
    return parser

def get_width_height( pr ):
    """
    return a tuple containing, repectively, the width and height
    of the rectangle r
    """
    w,h = pr.bottomright[0] - pr.bottomleft[0], pr.topright[1] - pr.bottomright[1]
    return (w,h)

def log2(n):
    """
    return the log base 2 of n
    """
    return log(n)/log(2)

def pow2( start, stop ):
    """
    generate the powers of 2 in sequence
    from 2^start till 2^stop
    """
    while start <= stop:
      yield pow(2,start)
      start += 1
      
class Success( Exception ):
    """
    Used to break out of a nested loop
    """
    pass

def main():
    parser = get_arg_parser()
    args = parser.parse_args()

    textures = {}
    rects = []
    while True:
        input = sys.stdin.readline().strip().replace( os.getcwd() + '\\', '' )
        if len(input) == 0:
          break
        try:
            tname = input.strip()
            textures[tname] = Image.open( tname )
            rects.append( Rect.Rect( textures[ tname ].size, tname ) )
            args.xmin = max( args.xmin, textures[tname].size[0] )
            args.ymin = max( args.ymin, textures[tname].size[1] )
        except IOError:
            pass

    args.xmin = min( args.xmax, pow( 2, ceil( log2( args.xmin ) ) ) )
    args.ymin = min( args.ymax, pow( 2, ceil( log2( args.ymin ) ) ) )

    ox = int(args.xmin)
    oy = int(args.ymin)

    packed = False

    try:
        for out_x in pow2( log2(args.xmin), log2(args.xmax) ):
            for out_y in pow2( log2(args.ymin), log2(args.ymax) ):
                big_rect = Rect.Rect( (out_x,out_y) )

                try:
                    packed_rects = Packer.pack( big_rect, rects, padding=0 )
                    packed = True
                    ox = int(out_x)
                    oy = int(out_y)
                    raise Success
                except ValueError:
                    pass
    except Success:
        pass
        
    if( not packed ):
        print('Could not pack textures into an atlas of the maximum size')
        sys.exit(1)

    mode = 'RGBA'
    if ( args.output.endswith('.bmp') or args.output.endswith('.BMP') ):
        mode = 'RGB'
    else:
        mode = 'RGBA'
        
    atlas = Image.new( mode, (ox,oy))

    atlas_entry = Template( '\n\t{\n\t\tsource_path:"$source_path",\n\t\tatlas_path:"$atlas_path",\n\t\tx:"$tx",\n\t\ty:"$ty",\n\t\tw:"$tw",\n\t\th:"$th"\n\t}' )

    with open(args.chart,'w') as f:
        f.write( '[' )
        first = True
        for pr in packed_rects:
            if first:
              first = False
            else:
              f.write( ',' )
            
            box = ( int(pr.bottomleft[0]), int(pr.bottomleft[1]), int(pr.topright[0]), int(pr.topright[1]) )
            
            atlas.paste( textures[pr.name], box )  

            path = pr.name
            x,y = int(pr.bottomleft[0]), int(pr.bottomleft[1])
            w,h = int(pr.bottomright[0] - pr.bottomleft[0]), int(pr.topright[1] - pr.bottomright[1])
            
            f.write( atlas_entry.substitute( source_path=pr.name, atlas_path=args.output, tx=x, ty=y, tw=w, th=h ))
        
        f.write( '\n]\n' )
    atlas.save( args.output )
    
if __name__ == '__main__':
    main()    
    sys.exit(0)
