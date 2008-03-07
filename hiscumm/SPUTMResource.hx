package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006  Alban Bedel
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import hiscumm.Common;

#if neko
import neko.io.File;
#else !neko
import utils.Seekable;
#end

import hiscumm.SPUTM;

enum SPUTMResourceChunkType
{	
	// Index chunks
	CHUNK_RNAM;
	CHUNK_MAXS;
	CHUNK_DROO;
	CHUNK_DSCR;
	CHUNK_DSOU;
	CHUNK_DCOS;
	CHUNK_DCHR;
	CHUNK_DOBJ;
	CHUNK_AARY;

	// Resource chunks
	CHUNK_LECF;
	CHUNK_LOFF;
	CHUNK_SCRP;
	CHUNK_COST;
	CHUNK_ROOM;
		
	// Image chunks
	CHUNK_SMAP;
		
	// Room chunks
		
	CHUNK_RMHD;
	CHUNK_CYCL;
	CHUNK_TRNS;
	CHUNK_PALS;
	CHUNK_RMIM;
	CHUNK_OBIM;
	CHUNK_OBCD;
	CHUNK_EXCD;
	CHUNK_ENCD;
	CHUNK_NLSC;
	CHUNK_LSCR;
	CHUNK_BOXD;
	CHUNK_BOXM;
	CHUNK_SCAL;
	CHUNK_IM00;
	
	CHUNK_WRAP;
	CHUNK_OFFS;
	CHUNK_APAL;

	CHUNK_UNKNOWN;
}

class SPUTMResourceChunk
{
	public var chunkID: Int32;
	public var chunkType: SPUTMResourceChunkType;
	
	public function new(a: SPUTMResourceChunkType, b: Int32)
	{
		chunkID = b;
		chunkType = a;
	}
	
	public static function identify(value: Int32) : SPUTMResourceChunkType
	{
		for (ct in chunkTypes)
		{
			if (Int32.compare(ct.chunkID, value) == 0)
				return ct.chunkType;
		}
		
		return CHUNK_UNKNOWN;
	}
	
	public static var chunkTypes: Array<SPUTMResourceChunk> = [
	
		// Index chunks
		new SPUTMResourceChunk(CHUNK_RNAM, Int32.make(0x524E, 0x414D)),
		new SPUTMResourceChunk(CHUNK_MAXS, Int32.make(0x4D41, 0x5853)),
		new SPUTMResourceChunk(CHUNK_DROO, Int32.make(0x4452, 0x4F4F)),
		new SPUTMResourceChunk(CHUNK_DSCR, Int32.make(0x4453, 0x4352)),
		new SPUTMResourceChunk(CHUNK_DSOU, Int32.make(0x4453, 0x4F55)),
		new SPUTMResourceChunk(CHUNK_DCOS, Int32.make(0x4443, 0x4F53)),
		new SPUTMResourceChunk(CHUNK_DCHR, Int32.make(0x4443, 0x4852)),
		new SPUTMResourceChunk(CHUNK_DOBJ, Int32.make(0x444F, 0x424A)),
		new SPUTMResourceChunk(CHUNK_AARY, Int32.make(0x4141, 0x5259)),

		// Resource chunks
		new SPUTMResourceChunk(CHUNK_LECF, Int32.make(0x4C45, 0x4346)),
		new SPUTMResourceChunk(CHUNK_LOFF, Int32.make(0x4C4F, 0x4646)),
		new SPUTMResourceChunk(CHUNK_SCRP, Int32.make(0x5343, 0x5250)),
		new SPUTMResourceChunk(CHUNK_COST, Int32.make(0x434F, 0x5354)),
		new SPUTMResourceChunk(CHUNK_ROOM, Int32.make(0x524F, 0x4F4D)),
		
		// Image chunks
		new SPUTMResourceChunk(CHUNK_SMAP, Int32.make(0x534D, 0x4150)),
		
		// Room chunks
		
		new SPUTMResourceChunk(CHUNK_RMHD, Int32.make(0x524D, 0x4844)),
		new SPUTMResourceChunk(CHUNK_CYCL, Int32.make(0x4359, 0x434C)),
		new SPUTMResourceChunk(CHUNK_TRNS, Int32.make(0x5452, 0x4E53)),
		new SPUTMResourceChunk(CHUNK_PALS, Int32.make(0x5041, 0x4C53)),
		new SPUTMResourceChunk(CHUNK_RMIM, Int32.make(0x524D, 0x494D)),
		new SPUTMResourceChunk(CHUNK_OBIM, Int32.make(0x4F42, 0x494D)),
		new SPUTMResourceChunk(CHUNK_OBCD, Int32.make(0x4F42, 0x4344)),
		new SPUTMResourceChunk(CHUNK_EXCD, Int32.make(0x4558, 0x4344)),
		new SPUTMResourceChunk(CHUNK_ENCD, Int32.make(0x454E, 0x4344)),
		new SPUTMResourceChunk(CHUNK_NLSC, Int32.make(0x4E4C, 0x5343)),
		new SPUTMResourceChunk(CHUNK_LSCR, Int32.make(0x4C53, 0x4352)),
		new SPUTMResourceChunk(CHUNK_BOXD, Int32.make(0x424F, 0x5844)),
		new SPUTMResourceChunk(CHUNK_BOXM, Int32.make(0x424F, 0x584D)),
		new SPUTMResourceChunk(CHUNK_SCAL, Int32.make(0x5343, 0x414C)),
		new SPUTMResourceChunk(CHUNK_IM00, Int32.make(0x494D, 0x3030)),
	
		new SPUTMResourceChunk(CHUNK_WRAP, Int32.make(0x5752, 0x4150)),
		new SPUTMResourceChunk(CHUNK_OFFS, Int32.make(0x4F46, 0x4653)),
		new SPUTMResourceChunk(CHUNK_APAL, Int32.make(0x4150, 0x414C))
	];
}

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
	
	public function load(num: Int, reader: ResourceIO) : Dynamic
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
		
		num_res = num;
		factory = fct;
	}

	public function loadResourceIndexes(reader: Input)
	{
		var i: Int;
		var sputm: SPUTM = SPUTM.instance;
		var rooms: Array<SPUTMResource> = sputm.vm_res[SPUTM.RES_ROOM].res;
		var resource: SPUTMResource;
		var num: Int;

		num = reader.readUInt16();
		if (num != num_res)
		{
			trace("Invalid index block!");
			return;
		}
		
		//trace("Loading " + num + " indexes");
		
		for (i in 0...num)
		{
			resource = new SPUTMResource();
			res[i] = resource;

			resource.room = reader.readInt8();
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
			resource.offset = reader.readUInt32() + sputm.vm_res[SPUTM.RES_ROOM].res[resource.room].offset;
		}
	}
	
	public function loadResourceIndexesAlt(reader: Input)
	{
		var i: Int;
		var sputm: SPUTM = SPUTM.instance;
		var rooms: Array<SPUTMResource> = sputm.vm_res[SPUTM.RES_ROOM].res;
		var resource: SPUTMResource;
		var num: Int;

		num = reader.readUInt16();
		if (num != num_res)
		{
			trace("Invalid index block!");
			return;
		}
		
		//trace("Loading " + num + " indexes");
		
		for (i in 0...num)
		{
			resource = new SPUTMResource();
			res[i] = resource;

			resource.room = reader.readInt8(); // i.e. owner | state
		}
	}

	public function loadResource(idx: Int) : Dynamic
	{
		var resource: SPUTMResource = res[idx];
		if (idx != 0)
			trace("Loading resource " + idx + " from file " + resource.file + ", room " + resource.room + " (" + factory.name + ")");
		else
		{
			trace("Invalid resource 0!");
			return null;
		}
		
		var reader: ResourceIO = SPUTM.instance.vm_files[resource.file];
		reader.seek(resource.offset, SeekBegin);
		resource.instance = factory.load(idx, reader);
		return resource.instance;
	}

	public function nukeResource(idx: Int)
	{
		return factory.nuke(res[idx]);
	}
}

