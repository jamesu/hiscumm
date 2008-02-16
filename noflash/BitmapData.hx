package noflash;
/*
hiscumm
-----------
Copyright (C) 2007 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import noflash.ByteArray;
import noflash.Rectangle;
import noflash.Point;

/*
	BitmapData
	
	This class is a clone of flash9's BitmapData
*/

class BitmapData
{
	public var width: Int;
	public var height: Int;
	
	public var rect: Rectangle;
	
	public function new(width: Int, height: Int, param: Bool, flags: Int) : Void
	{
	}
	
	public function lock()
	{
	}
	
	public function unlock()
	{
	}
	
	public function setPixels(rect: Rectangle, colors: ByteArray)
	{
	}
	
	public function copyPixels(bmap: BitmapData, rect: Rectangle, dest: Point, alpha: BitmapData, alphaPoint: Point, merge: Bool)
	{
	}
	
	public function fillRect(rect: Rectangle, color: Int)
	{
	}
	
	public function paletteMap(bmap: BitmapData, rect: Rectangle, point: Point, zeros: Array<Int>, zeros2: Array<Int>, list:Array<Int>, Void)
	{
	}

}

