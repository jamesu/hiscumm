package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import hiscumm.Common;

/*
	ChunkReader
	
	This class is a utility class which handles the processing of chunks in
	SCUMM resource files.
	
	Example:
		var myReader: ChunkReader = new ChunkReader(my_bytes, -1);
		
		while (myReader.nextChunk())
		{
			trace("CHUNK=" + myReader.chunkName() + " @ " + my_bytes.pos);
		}
*/

class ChunkReader
{
	private var reader: Input;
	public var chunkID: Int32;
	public var chunkSize: Int;

	public function new(bytes: Input)
	{
		reader = bytes;
		
		chunkID = Int32.ofInt(0);
		chunkSize = 0;
	}

	public function chunkName() : String
	{
		if (Int32.compare(chunkID, Int32.ofInt(0)) == 0)
			return "????";

		return chunkIDToStr(chunkID);
	}
	
	public static inline function chunkIDToStr(name: Int32) : String
	{
		return (String.fromCharCode(Int32.toInt(Int32.shr(name, 24))) +
		       String.fromCharCode(Int32.toInt(Int32.and(Int32.shr(name, 16), Int32.ofInt(0xFF)))) +
		       String.fromCharCode(Int32.toInt(Int32.and(Int32.shr(name, 8), Int32.ofInt(0xFF)))) +
		       String.fromCharCode(Int32.toInt(Int32.and(name, Int32.ofInt(0xFF)))));
	}
	
	public function readChunkData() : MemoryIO
	{
		var mem = new MemoryIO();
		mem.prepare(chunkSize);
		
		mem.writeInput(reader);
		
		return mem;
	}

	public function nextChunk() : Bool
	{
		try
		{
			chunkID = Int32.read(reader, true);
			chunkSize = Int32.toInt(Int32.read(reader, true)); // 31 bits should suffice...
		}
		catch (e: Dynamic)
		{
			return false;
		}

		return true;
	}
}

