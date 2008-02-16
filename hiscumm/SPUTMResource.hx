package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006  Alban Bedel
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#if flash9
import flash.utils.ByteArray;
import flash.display.Bitmap;
import flash.display.BitmapData;
#else neko
import noflash.ByteArray;
import noflash.Bitmap;
import noflash.BitmapData;
#else js
import noflash.ByteArray;
import noflash.Bitmap;
import noflash.BitmapData;
#end

import hiscumm.SPUTM;

/*
	SPUTMResource
	
	This collection of classes handles the loading and processing of resource files and the
	resources located wherein.
*/

class SPUTMResource
{
	// instance vars
	
	public var file: Int;
	public var room: Int;
	public var offset: Int;
	public var flags: Int;

	public var instance: Dynamic;
	
	// FLAGS
	
	public static var FLAG_LOCKED : Int = 0x1;

	public function new()
	{
		instance = null;
		flags=0;
		file=-1;
		room=-1;
		offset=0;
	}
	
	public function lock() : Bool
	{
		flags |= FLAG_LOCKED;
		return true;
	}
	
	public function unlock() : Bool
	{
		flags &= -2; // ~FLAG_LOCKED
		return true;
	}
	
	private function isLocked() : Int
	{
		return (flags & FLAG_LOCKED);
	}
}

class SPUTMResourceFactory
{
	public var name: String;
	
	public function new()
	{
		name = "UNKNOWN";
	}
	
	public function load(num: Int, reader: ByteArray) : Dynamic
	{
		return null;
	}
	
	public function nuke(res: SPUTMResource)
	{
		res.instance = null;
	}
}

class SPUTMResourceList
{
	public var num_res: Int;
	var factory: SPUTMResourceFactory;
	
	public var res: Array<SPUTMResource>;

	public function new(num: Int, fct: SPUTMResourceFactory)
	{	
		res = new Array<SPUTMResource>();
		res[num-1] = null;
		
		trace("YAYAYAYAY");
		num_res = num;
		factory = fct;
	}

	public function loadResourceIndexes(reader: ByteArray)
	{
		var i: Int;
		var sputm: SPUTM = SPUTM.instance;
		var rooms: Array<SPUTMResource> = sputm.vm_res[SPUTM.RES_ROOM].res;
		var resource: SPUTMResource;
		var num: Int;

		num = reader.readShort();
		if (num != num_res)
		{
			trace("Invalid index block!");
			return;
		}
		
		trace("Loading " + num + " indexes");
		
		for (i in 0...num)
		{
			resource = new SPUTMResource();
			res[i] = resource;

			resource.room = reader.readByte();
			if (resource.room >= sputm.vm_res[SPUTM.RES_ROOM].res.length)
			{
			   //trace(resource.room + "," + sputm.vm_res[SPUTM.RES_ROOM].res.length);
				resource.room = 0;
				continue;
			}
			
			resource.file = sputm.vm_res[SPUTM.RES_ROOM].res[resource.room].file;
		}

		//trace("Calculating offsets");

		for (i in 0...num)
		{
			resource = res[i];
			resource.offset = reader.readInt() + sputm.vm_res[SPUTM.RES_ROOM].res[resource.room].offset;
		}
	}
	
	public function loadResourceIndexesAlt(reader: ByteArray)
	{
		var i: Int;
		var sputm: SPUTM = SPUTM.instance;
		var rooms: Array<SPUTMResource> = sputm.vm_res[SPUTM.RES_ROOM].res;
		var resource: SPUTMResource;
		var num: Int;

		num = reader.readShort();
		if (num != num_res)
		{
			trace("Invalid index block!");
			return;
		}
		
		trace("Loading " + num + " indexes");
		
		for (i in 0...num)
		{
			resource = new SPUTMResource();
			res[i] = resource;

			resource.room = reader.readByte(); // i.e. owner | state
		}
	}

	public function loadResource(idx: Int) : Dynamic
	{
		var resource: SPUTMResource = res[idx];
		if (idx != 0)
			trace("Loading resource " + idx + " from file " + resource.file + " (" + factory.name + ")");
		else
		{
			trace("Invalid resource 0!");
			return null;
		}
		var reader: ByteArray = SPUTM.instance.vm_files[resource.file];
		reader.position = resource.offset;
		resource.instance = factory.load(idx, reader);
		return resource.instance;
	}

	public function nukeResource(idx: Int)
	{
		return factory.nuke(res[idx]);
	}
}

