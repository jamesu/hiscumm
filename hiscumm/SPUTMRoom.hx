package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban Bedel
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import hiscumm.Common;

#if neko
import neko.io.File;
#else
import utils.Seekable;
#end

import hiscumm.SCUMM;
import hiscumm.SPUTM;

import hiscumm.SPUTMResource;

/*
	SPUTMRoom
	
	This collection of classes handles the loading and processing of rooms.
*/

class SPUTMRoom
{	
	public var id: Int;
	public var scripts: Array<SCUMMScript>;
	public var objects: Array<Dynamic>;
	public var palettes: Array<SPUTMPalette>;
	
	public var entry: SCUMMScript;
	public var exit: SCUMMScript;
	
	public var current_palette: SPUTMPalette;
	
	public var width: Int;
	public var height: Int;
	public var num_zplane: Int;
	public var image: SPUTMImage;
	
	public function new(num: Int)
	{
		id = num;
		scripts = new Array<SCUMMScript>();
		objects = new Array<Dynamic>();
		palettes = new Array<SPUTMPalette>();
		image = null;
		
		entry = null;
		exit = null;
		
		current_palette = null;
	}
	
	public function nuke()
	{
		if (image != null)
			image.nuke();
		image = null;
	}
}

class SPUTMRoomFactory extends SPUTMResourceFactory
{	
	public function new()
	{
		super();
		
		name = "ROOM";
	}

	override public function load(idx: Int, reader: ResourceIO) : Dynamic
	{
		// Need to load the bytecode from the offset
		
		var chunkID: Int32 = Int32.read(reader, true);
		var chunkSize: Int = Int32.toInt(Int32.read(reader, true));
		
		if (SPUTMResourceChunk.identify(chunkID) != CHUNK_ROOM)
		{
			trace("Bad room block (" + ChunkReader.chunkIDToStr(chunkID) + ")");
			return null;
		}
		
		var room: SPUTMRoom = new SPUTMRoom(idx);
		var croom: ChunkReader = new ChunkReader(reader);
		var num: Int;
		var num_lscr: Int = 0;
		var i: Int;
		var base_ptr: Int;
		var num_pal: Int;
		
		while (croom.nextChunk())
		{
			switch (SPUTMResourceChunk.identify(croom.chunkID))
			{
				case CHUNK_RMHD:
					//trace("RMHD == " + croom.chunkName());
					room.width = reader.readUInt16();
					room.height = reader.readUInt16();
					num = reader.readUInt16();
					if (num > 0)
						room.objects[num-1] = null;
				case CHUNK_CYCL:
					//trace("CYCL == " + croom.chunkName());
				case CHUNK_TRNS:
					//trace("TRNS == " + croom.chunkName());
				case CHUNK_PALS:
					//trace("PALS == " + croom.chunkName());

					chunkID = Int32.read(reader, true);
					chunkSize = Int32.toInt(Int32.read(reader, true));
					
					if (SPUTMResourceChunk.identify(chunkID) != CHUNK_WRAP)
					{
						trace("Bad room WRAP block " + chunkID);
						return null;
					}
					
					chunkID = Int32.read(reader, true);
					chunkSize = Int32.toInt(Int32.read(reader, true));
					
					if (SPUTMResourceChunk.identify(chunkID) != CHUNK_OFFS)
					{
						trace("Bad room OFFS block " + chunkID);
						return null;
					}
					
					// Now we can load in the palette!
					base_ptr = reader.tell()-8;
					num_pal = Math.round((chunkSize - 8) / 4);
					
					var offset: Array<Int> = new Array<Int>();
					if (num_pal > 0)
					{
						offset[num_pal-1] = 0;
						for (i in 0...num_pal)
						{
							offset[i] = base_ptr + reader.readUInt32();
						}
						
						room.palettes[num_pal - 1] = null;
						for (i in 0...num_pal)
						{
							reader.seek(offset[i], SeekBegin);
							
							chunkID = Int32.read(reader, true);
							chunkSize = Int32.toInt(Int32.read(reader, true));
							
							if (SPUTMResourceChunk.identify(chunkID) != CHUNK_APAL)
							{
								trace("Bad room APAL block " + chunkID);
								return null;
							}
							
							room.palettes[i] = new SPUTMPalette(reader);
						}
					}
      
				case CHUNK_RMIM:
					trace("RMIM == " + croom.chunkName());
					
					chunkID = Int32.read(reader, true);
					chunkSize = Int32.toInt(Int32.read(reader, true));
					
					room.num_zplane = reader.readUInt16();
					
					chunkID = Int32.read(reader, true);
					chunkSize = Int32.toInt(Int32.read(reader, true));
					
					if (SPUTMResourceChunk.identify(chunkID) != CHUNK_IM00)
					{
						trace("Bad room image block " + chunkID);
						return null;
					}
					
					room.image = new SPUTMImage(room.width, room.height, room.num_zplane);
					if (!(room.image.load(reader)))
					{
						trace("Problem loading room image!");
						room.image = null;
						return null;
					}
					
					trace("Room image appears to have loaded!");
				case CHUNK_OBIM:
					//trace("OBIM == " + croom.chunkName());
					
					// Object images
				case CHUNK_OBCD:
					//trace("OBCD == " + croom.chunkName());
					
					// Object verb info, etc
				case CHUNK_EXCD:
					//trace("EXCD == " + croom.chunkName());
					
					var script: SCUMMScript = new SCUMMScript(0x1ECD0000);
					script.code = new MemoryIO();
					script.size = croom.chunkSize - 8;
					script.code.prepare(script.size);
					
					script.code.writeInput(reader);
					
					room.exit = script;
				case CHUNK_ENCD:
					//trace("ENCD == " + croom.chunkName());
					
					var script: SCUMMScript = new SCUMMScript(0x0ECD0000);
					script.code = new MemoryIO();
					script.size = croom.chunkSize - 8;
					script.code.prepare(script.size);
					
					script.code.writeInput(reader);
					
					room.entry = script;
				case CHUNK_NLSC:
					//trace("NLSC == " + croom.chunkName());
					num = reader.readUInt16();
					if (num > 0)
						room.scripts[num-1] = null;
				case CHUNK_LSCR:
					//trace("LSCR == " + croom.chunkName());
					
					if (num_lscr >= room.scripts.length)
					{
						trace("Too many local scripts in room!");
						return null;
					}
					
					i = reader.readChar();
					if (i < 200 || i-200 >= room.scripts.length)
					{
						trace("Invalid script id " + i);
						return null;
					}
					
					var script: SCUMMScript = new SCUMMScript(i+200);
					script.code = new MemoryIO();
					script.size = croom.chunkSize - 9;
					script.code.prepare(script.size);
					
					trace("Read local script " + i); 
					
					script.code.writeInput(reader);
					
					room.scripts[i] = script;
					num_lscr++;
				case CHUNK_BOXD:
					//trace("BOXD == " + croom.chunkName());
				case CHUNK_BOXM:
					//trace("BOXM == " + croom.chunkName());
				case CHUNK_SCAL:
					//trace("SCAL == " + croom.chunkName());
				default:
					trace("Room chunk " + croom.chunkName() + " (" + croom.chunkID + ")");
			}
		}
		
		//trace("ROOM NOT LOADED");
		//return null;
		
		return room;
		
	}
}

