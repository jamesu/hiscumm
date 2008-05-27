package justjs;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

typedef MemoryIO = utils.JSByteIO;
import noflash.Rectangle;
import noflash.Point;

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
		//context.putImageData(imgdata, rect.x, rect.y);
	}
	
	public function setPixels(rect: Rectangle, colors: MemoryIO)
	{
		var context = canvas.getContext('2d');
		
		var cx = rect.x;
		var cy = rect.y;
		var ex = rect.x+rect.width;
		var data = pixels.data;
		var pw = pixels.width;
		var ph = pixels.height;
		var stride = rect.height;
		var end = rect.width*rect.height;
		var pos = 0;
		var dw = 0;
		while (pos != end)
		{
			if (cx == ex)
			{
				cx = 0;
				cy += 1;
			}
			
			if (!(cx > pw || cy > ph || cx < 0 || cy < 0))
			{
				dw = ((cy*stride)+cx)*4;
				data[dw] = colors.readChar(); dw++;
				data[dw] = colors.readChar(); dw++;
				data[dw] = colors.readChar(); dw++;
				data[dw] = 0xFF;colors.readChar(); // TEST
			}
			else
			{
				colors.readChar();
				colors.readChar();
				colors.readChar();
				colors.readChar();
			}
			
			cx += 1;
			pos += 1;
		}
		
		/*
		var data = imgdata ? imgdata.data : context.getImageData(0,0,width,height);
		var i = 0;
		
		var pitch = pixels.width;
		for (i in 0...(rect.width*rect.height*4))
		{
			data[i] = 200;//Math.round((Math.random()*256)/255); //colors.readChar();
		}
		*/
		context.putImageData(pixels, 0, 0);
	}
	
	public function copyPixels(source_bmap: BitmapData, rect: Rectangle, dest: Point, alpha: BitmapData, alphaPoint: Point, merge: Bool)
	{
		var context = canvas.getContext('2d');
		var src_context = source_bmap.canvas.getContext('2d');
		/*var src_imgdata = src_context.getImageData(rect.x, rect.y, rect.width, rect.height);
		*/
		context.putImageData(source_bmap.pixels, dest.x, dest.y); // TEST
		
		//fillRect(new Rectangle(dest.x, dest.y, canvas.width, canvas.height), 0x55);
	}
	
	public function fillRect(rect: Rectangle, color: Int)
	{
		var context = canvas.getContext('2d');
		context.fillStyle = "rgb(" + color + "," + color + "," + color + ")";
		
		
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
			dx = rect.x;
			dy = rect.y;
			dw = rect.width;
			dh = rect.height;
			
			var delta = 0;
			if (dx < 0)
				dx = 0;
			if (dy < 0)
				dy = 0;
			if (dx >= pixels.width)
				dx = pixels.width;
			if (dy > pixels.height)
				dy = pixels.height;
			
			if (dx + dw > pixels.width)
				dw = pixels.width-dx;
			if (dy + dh > pixels.height)
				dh = pixels.height-dx;
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
		/*
		if (rect == null)
			old_imgdata = context.getImageData(0, 0, width, height);
		else
			old_imgdata = context.getImageData(rect.x, rect.y, rect.width, rect.height);
		*/
		/*
		var new_imgdata = context.createImageData(rect.width, rect.height);
		var data = imgdata.data;
		var i = 0;
		for (i in 0...(rect.width*rect.height))
		{
			var ofs = i*4;
			data[i] = colors.readByte();
		}
		
		context.putImageData(new_imgdata, rect.x, rect.y);
		*/
	}

}

