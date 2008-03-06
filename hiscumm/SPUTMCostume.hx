package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban BedelThis program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import hiscumm.Common;

import hiscumm.SPUTM;
import hiscumm.SPUTMResource;

/*
	SPUTMCostume
	
	This collection of classes handles the loading and processing of actor costumes.
*/

class SPUTMCostume
{
	public var id: Int;
	
	public function new(num: Int)
	{
		id = num;
	}
}

class SPUTMCostumeFactory extends SPUTMResourceFactory
{
	public function new()
	{
		super();
		
		name = "COSTUME";
	}

	public function load(idx: Int, reader: ResourceIO) : Dynamic
	{
		// Need to load the costume from the offset
		var chunkID: Int32 = Int32.read(reader, true);
		var chunkSize: Int = Int32.toInt(Int32.read(reader, true));
		
		if (SPUTMResourceChunk.identify(chunkID) != CHUNK_COST)
		{
			trace("Bad costume block (" + ChunkReader.chunkIDToStr(chunkID) + " )");
			return null;
		}
		
		var instance: SPUTMCostume = new SPUTMCostume(idx);
		
		return instance;
	}
}
