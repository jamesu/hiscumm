package justjs;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

typedef MemoryIO = utils.JSByteIO;
import noflash.Rectangle;
import noflash.Point;
import utils.SeekableTools;

/*
	BitmapData
	
	This class is a clone of flash9's BitmapData
	
	The initial pixels are grabbed via getImageData. Whenever these are updated, they are drawn back
	on the canvas using putImageData.
	
	Note that there appears to be no way of explicitly freeing ImageData objects so this is likely the best way to 
	go about this.
*/

class BitmapData
{
	public var width: Int;
	public var height: Int;
	
	public var rect: Rectangle;
	
	public var canvas: Dynamic;
	public var imgdata: Dynamic;
	public var pixels: Dynamic;
	
	public function new(width: Int, height: Int, param: Bool, flags: Int) : Void
	{
		this.width = width;
		this.height = height;
		
		this.canvas = js.Lib.document.createElement('canvas');
		this.canvas.setAttribute('width', width);
		this.canvas.setAttribute('height', height);
		
		var ctx = this.canvas.getContext("2d");
		this.pixels = ctx.getImageData(0,0,this.canvas.width, this.canvas.height);
	}
	
	public function dispose()
	{
		this.pixels = null;
		this.canvas = null;
	}
	
	public function lock()
	{
		//var context = canvas.getContext('2d');
		//imgdata = context.createImageData(width, height);
	}
	
	public function unlock()
	{
		var context = canvas.getContext('2d');
		
	    // Reload pixels
		this.pixels = null;
		this.pixels = context.getImageData(0,0,this.canvas.width, this.canvas.height);
	}
	
	public function setPixels(rect: Rectangle, colors: MemoryIO)
	{
		var context = canvas.getContext('2d');
		
		var end = SeekableTools.getSeekableLength(colors);
		var data = pixels.data;
		var pos = 0;
		while (end > 0)
		{
			data[pos] = colors.readChar();
			data[pos+1] = colors.readChar();
			data[pos+2] = colors.readChar();
			data[pos+3] = 0xFF; colors.readChar();
			pos += 4;
			end -= 4;
		}
		
		context.putImageData(pixels, 0, 0);
	}
	
	public function copyPixels(source_bmap: BitmapData, rect: Rectangle, dest: Point, alpha: BitmapData, alphaPoint: Point, merge: Bool)
	{
		var context = canvas.getContext('2d');
		
		var source_stride = source_bmap.pixels.width;
		var dest_stride = pixels.width;
		var sx = 0;
		var sy = 0;
		var sw = 0;
		var sh = 0;
		
		// Get source rect
		if (rect == null)
		{
			sx = 0; sy = 0; sw = source_bmap.pixels.width; sh = source_bmap.pixels.height;
		}
		else
		{
			sx = rect.x; sy = rect.y; sw = rect.width; sh = rect.height;
		}
		
		// Accelerated draw using canvas operations
		context.putImageData(source_bmap.pixels, dest.x, dest.y, sx, sy, sw, sh);
	}
	
	public function fillRect(rect: Rectangle, color: Int)
	{
		var context = canvas.getContext('2d');
		
		var dx = 0;
		var dy = 0;
		var dw = 0;
		var dh = 0;
		var stride = pixels.width;
		
		// Clip rect
		if (rect == null)
		{
			dx = 0; dy = 0; dw = pixels.width; dh = pixels.height;
		}
		else
		{
			var clipped_rect = rect.intersection(new Rectangle(0, 0, pixels.width, pixels.height));
			dx = clipped_rect.x;
			dy = clipped_rect.y;
			dw = clipped_rect.width;
			dh = clipped_rect.height;
		}
		
		// Accelerated draw using canvas operations
		context.fillStyle = "rgb(" + color + "," + color + "," + color + ")";
		context.fillRect(dx, dy, dw, dh);
	}
	
	public function paletteMap(bmap: BitmapData, rect: Rectangle, point: Point, zeros: Array<Int>, zeros2: Array<Int>, list:Array<Int>, Void)
	{
		var context = canvas.getContext('2d');
		var old_imgdata = null;
	}
	
	public function fastPaletteRemap(correct_colors: Array<Int>)
	{
		var context = canvas.getContext('2d');
		
	    // Reload pixels
		this.pixels = null;
		this.pixels = context.getImageData(0,0,this.canvas.width, this.canvas.height);
		
		var end_pos = pixels.width*pixels.height;
		var cur_pos = 0;
		var writ = 0;
		var data = pixels.data;
		var color = 0;
		
		while (cur_pos != end_pos)
		{
			color = correct_colors[data[writ]];
			
			//list[i] = (r << 16) | (g << 8) | b;
			data[writ] = (color >> 16) & 0xFF; writ++; // R
			data[writ] = (color >> 8) & 0xFF; writ++;  // G
			data[writ] = color & 0xFF; writ += 2;      // B
			                                           // Alpha (skip)
			
			
			cur_pos++;
		}
		
		context.putImageData(pixels, 0, 0);
	}

}

