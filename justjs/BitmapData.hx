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
		
		/*
		var foo = ctx.getImageData(0,0,this.canvas.width,this.canvas.height);
		haxe.Firebug.trace("New BitmapData, " + foo.width + "," + foo.height);
		haxe.Firebug.trace("IMGDATA == " + ctx.createImageData + ", " + ctx.getImageData + ", " + ctx.putImageData);*/
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
		//var context = canvas.getContext('2d');
		//context.putImageData(pixels, 0, 0);
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
		
		//context.putImageData(source_bmap.pixels, dest.x, dest.y); // TEST
		
		
		//return;
		
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
		
		// Get dest rect
		var dx = dest.x;
		var dy = dest.y;
		var dw = sw;
		var dh = sh;
		
		var src_data = source_bmap.pixels.data;
		var dst_data = pixels.data;
		var end_pixels = rect.width * rect.height;
		
		var count = 0;
		var cur_sx = sx;
		var cur_sy = sy;
		var cur_dx = dx;
		var cur_dy = dy;
		while (count != end_pixels)
		{
			var src_r = 0;
			//var src_g = 0;
			//var src_b = 0;
			
			// Grab src_* from source
			if (cur_sx > source_bmap.pixels.width || cur_sy > source_bmap.pixels.height ||
			    cur_sx < 0 || cur_sy < 0)
			{
				src_r = 0;
				//src_g = 0;
				//src_b = 0;
			}
			else
			{
				var pos = ((cur_sy*source_stride)+cur_sx)*4;
				src_r = src_data[pos];
				//src_g = src_data[pos+1];
				//src_b = src_data[pos+2];
			}
			
			// Plot to dest
			if (!(cur_dx >= pixels.width || cur_dy >= pixels.height ||
			    cur_dx < 0 || cur_dy < 0))
			{
				var pos = ((cur_dy*dest_stride)+cur_dx)*4;
				
				dst_data[pos] = src_r;
				//dst_data[pos+1] = src_g;
				//dst_data[pos+2] = src_b;
			}
			
			// Increment copy
			cur_sx += 1;
			cur_dx += 1;
			
			// Check for new row
			if (cur_sx >= (sx+sw))
			{
				cur_sx = sx;
				cur_sy += 1;
			}
			
			if (cur_dx >= (dx+dw))
			{
				cur_dx = dx;
				cur_dy += 1;
			}
			
			count++;
		}
		
		//fillRect(new Rectangle(dest.x, dest.y, canvas.width, canvas.height), 0x55);
				
		context.putImageData(pixels, 0, 0);
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
		
		// Now fill
		var start_pos = ((dy*stride)+dx)*4;
		var end_pos = (((dy+dh)*stride)+(dx+dw))*4;
		var cur_pos = start_pos;
		var cur_x = 0;
		var cur_row = 0;
		var data = pixels.data;
		
		while (cur_pos != end_pos)
		{
			if (cur_x == dw)
			{
				cur_row += 1;
				cur_pos = start_pos + (cur_row*stride);
				cur_x = 0;
			}
			
			data[cur_pos] = color; cur_pos += 1;
			data[cur_pos] = color; cur_pos += 1;
			data[cur_pos] = color; cur_pos += 1;
			data[cur_pos] = 0xFF; cur_pos += 1;
			cur_x += 1;
		}
		
		context.putImageData(pixels, 0, 0);
	}
	
	public function paletteMap(bmap: BitmapData, rect: Rectangle, point: Point, zeros: Array<Int>, zeros2: Array<Int>, list:Array<Int>, Void)
	{
		var context = canvas.getContext('2d');
		var old_imgdata = null;
	}
	
	public function fastPaletteRemap(correct_colors: Array<Int>)
	{
		//return;
		var context = canvas.getContext('2d');
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

