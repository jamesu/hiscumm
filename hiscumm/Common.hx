package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban Bedel
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#if flash9
typedef ByteArray = flash.utils.ByteArray;
typedef Bitmap = flash.display.Bitmap;
typedef BitmapData = flash.display.BitmapData;
typedef Rectangle = flash.geom.Rectangle;
typedef Point = flash.geom.Point;
typedef Int32 = noneko.Int32;
typedef MemoryIO = utils.FlashByteIO;
typedef ResourceIO = utils.FlashByteIO;
typedef Input = noneko.Input;
typedef Output = noneko.Output;
#elseif neko
typedef ByteArray = noflash.ByteArray;
typedef Bitmap = noflash.Bitmap;
typedef BitmapData = noflash.BitmapData;
typedef Rectangle = noflash.Rectangle;
typedef Point = noflash.Point;
typedef Int32 = neko.Int32;
typedef MemoryIO = utils.NekoByteIO; 
typedef ResourceIO = neko.io.FileInput;
typedef Input = neko.io.Input;
typedef Output = neko.io.Output;
#elseif js
typedef ByteArray = noflash.ByteArray;
typedef Bitmap = justjs.Bitmap;
typedef BitmapData = justjs.BitmapData;
typedef Rectangle = noflash.Rectangle;
typedef Point = noflash.Point;
typedef Int32 = noneko.Int32;
typedef MemoryIO = utils.JSByteIO;
typedef ResourceIO = utils.JSByteIO;
typedef Input = noneko.Input;
typedef Output = noneko.Output;
#end
