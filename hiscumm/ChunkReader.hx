package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#if flash9
import flash.utils.ByteArray;
#else neko
import noflash.ByteArray;
#else js
import noflash.ByteArray;
#end

/*
	ChunkReader
	
	This class is a utility class which handles the processing of chunks in
	SCUMM resource files.
	
	Example:
		var myReader: ChunkReader = new ChunkReader(my_bytes, -1);
		
		while (myReader.nextChunk())
		{
			trace("CHUNK=" + myReader.chunkName() + " @ " + myReader.chunkOffs);
		}
*/

class ChunkReader
{
	private var byteReader: ByteArray;
	public var chunkID: Int;
	public var chunkSize: Int;
	public var chunkOffs: Int;

	private var maxPos: Int;

	public function new(bytes: ByteArray, max: Int)
	{
		byteReader = bytes;
		maxPos = max;
		
		chunkID = 0;
		chunkSize = 0;
		chunkOffs = 0;
	}

	public function nest() : ChunkReader
	{
		var newReader: ChunkReader = new ChunkReader(byteReader, chunkOffs + chunkSize);
		newReader.chunkOffs = byteReader.position;
		return newReader;
	}

	public function chunkName() : String
	{
		if (chunkID == 0)
			return "????";

		return (String.fromCharCode(chunkID >> 24) +
		       String.fromCharCode((chunkID >> 16) & 0xFF) +
		       String.fromCharCode((chunkID >> 8) & 0xFF) +
		       String.fromCharCode(chunkID & 0xFF));
	}

	public function bytesAvailable() : Int
	{
		if (maxPos != -1)
		{
			return (maxPos - byteReader.position);
		}
		else
		{
			return byteReader.bytesAvailable;
		}
	}

	public function nextChunk() : Bool
	{
		var oldEndian: String;

		byteReader.position = chunkOffs + chunkSize;
		if (bytesAvailable() < 8)
			return false;

		oldEndian = byteReader.endian;
		byteReader.endian = "bigEndian";

		chunkOffs = byteReader.position;
		chunkID = byteReader.readUnsignedInt();
		chunkSize = byteReader.readUnsignedInt();

		byteReader.endian = oldEndian;

		return true;
	}
}

