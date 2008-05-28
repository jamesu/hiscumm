package noflash;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/*
	Rectangle
	
	This class is a clone of flash9's Rectangle
*/

class Rectangle
{
	public var x: Int;
	public var y: Int;
	public var width: Int;
	public var height: Int;
	
	public function new(x: Int, y: Int, w: Int, h: Int) : Void
	{
		this.x = x;
		this.y = y;
		this.width = w;
		this.height = h;
	}
	
	public function intersection(other: Rectangle)
	{
		var dx = x;
		var dy = y;
		var dw = width;
		var dh = height;
		
		if (dx < other.x)
		{
			width -= (other.x-dx);
			dx = other.x;
		}
		if (dy < other.y)
		{
			height -= (other.y-dy);
			dy = other.y;
		}
		if (dx >= other.x+other.width)
		{
			width -= (other.x+other.width-dx);
			dx = other.x+other.width;
		}
		if (dy > other.y+other.height)
		{
			height -= (other.y+other.height-dy);
			dy = other.y+other.height;
		}
		
		if (dx + dw > other.x+other.width)
		{
			width = (other.x+other.width)-dx;
		}
		if (dx + dh > other.x+other.height)
		{
			height = (other.y+other.height)-dy;
		}
		
		return new Rectangle(dx, dy, dw, dh);
	}
	
	public function clone() : Rectangle
	{
		return new Rectangle(x, y, width, height);
	}

}

