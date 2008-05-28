package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban BedelThis program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import hiscumm.Common;

#if neko
import neko.io.File;
#else !neko
import utils.Seekable;
#end

import utils.SeekableTools;

import hiscumm.SPUTMResource;

/*
	SPUTMImage
	
	The class which handles decoding image blocks with z planes.
	
	Differences between scvm code:
		- while (true) { [code] if (cond) break; } used instead of do {[code]} while (cond);
		- READ_BIT conditions re-arranged as haXe doesn't seem to support the comma operator
		- READ_BIT and FILL_BITS are inline as haXe doesn't support #define
		- Pixels written as 32bit integers so the images can easily be converted to BitmapData.
	
	TODO:
		- *trans decoding
		- zplane decoding
*/

class SPUTMImage
{
	static public var ZP: Int = 0x0;
	
	public var zplanes: Array<BitmapData>;
	public var data: BitmapData;
	
	static var pixels_written = 0;
	
	static var dtrace_on = false;
	static var dtrace_override = false;
	static function dtrace(msg: String)
	{
		#if flash9
		if (dtrace_on && (!dtrace_override))
			flash.Lib.trace(msg);
		#end
	}
	
	public function new(width: Int, height: Int, num_zplanes : Int)
	{
		zplanes = new Array<BitmapData>();
		if (num_zplanes > 0)
			zplanes[num_zplanes-1] = null;
		data = new BitmapData(width, height, false, 0x00000000);
	}
	
	public function nuke()
	{
		var i;
		for (i in 0...zplanes.length)
		{
			zplanes[i].dispose();
			zplanes[i] = null;
		}
		
		zplanes = null;
		data.dispose();
	}
	
	static inline function readBit(bit: Int, cl: Int, bits: Int)
	{
		cl--;bit = bits&1; bits>>=1; // READ_BIT
		dtrace("READ_BIT cl=" + cl + ", bit=" + bit + ", bits=" + bits);
	}
	
	static inline function fillBits(cl: Int, bits: Int, smap: Input)
	{
		if (cl < 8)
		{
			bits |= (smap.readChar()) << cl;
			cl += 8;
			dtrace("FILL_BITS cl=" + cl + ", bits=" + bits);
		}
	}
	
	public function load(reader: ResourceIO) : Bool
	{
		var i: Int;
		
		var chunkID: Int32 = Int32.read(reader, true);
		var chunkSize: Int = Int32.toInt(Int32.read(reader, true));
		
		if (SPUTMResourceChunk.identify(chunkID) != CHUNK_SMAP)
		{
			trace("Bad image type " + ChunkReader.chunkIDToStr(chunkID));
			return false;
		}
		else
		{
			trace("smap size == " + (chunkSize - 8));
			var smap = new MemoryIO();
			smap.prepare(chunkSize - 7);
			smap.writeInput(reader);
			smap.seek(0, SeekBegin);
			reader.seek(-1, SeekCur); // corect overead
			
			pixels_written = 0;
			if (!decode(data.width, data.width, data.height, smap, -1))
			{
				trace("Bad image data");
				return false;
			}
			
			if (data.width != 8)
			{
				trace(pixels_written + " pixels written");
				//return false;
			}
			
			trace("loaded smap");
		}
		
		for ( i in 0...zplanes.length)
		{
			chunkID = Int32.read(reader, true);
			chunkSize = Int32.toInt(Int32.read(reader, true));
			
			trace("zplane ChunkID == " + ChunkReader.chunkIDToStr(chunkID)); // TODO: error check
			
			var zplane: MemoryIO = new MemoryIO();
			zplane.prepare(chunkSize - 8);
			zplane.writeInput(reader);
			zplane.seek(0, SeekBegin);
			
			trace("Dec");
			
			if (!decodeZPlane(i, data.width >> 3 /* div 8 */, data.width, data.height, zplane, -1))
			{
				trace("Bad zplane data");
				return false;
			}
		}
		
		return true;
	}
	
	public function decode(stride: Int, width: Int, height: Int, smap: MemoryIO, transparentColor: Int)
	{
		var i: Int;
		var offs: Int = (width >> 3);
		var type: Int;
		var decomp_shr: Int;
		var decomp_mask: Int;
		var stripe_size: Int;
		
		if (height == 144)
			dtrace_on = true;
		
		var offsets: Array<Int> = new Array<Int>();
		offsets[offs-1] = 0;
  	
		var pixels: MemoryIO = new MemoryIO(); // linear array to store pixel data
		pixels.prepare(width*height*4);

		for ( i in 0...offs )
		{
			offsets[i] = smap.readUInt32();
		}
		
		//dtrace("Decode image: " + width + "x" + height + " smap: " + smap.length + ", offs: " + offs);
  	
		for ( i in 0...offs )
		{
			var o: Int = offsets[i]-8;
			
			if (i+1 < offs)
				stripe_size = offsets[i+1] - offsets[i];
			else
				stripe_size = SeekableTools.getSeekableLength(smap) - o;
  		
			dtrace(stripe_size + "=size, " + o + "=pos, " + offs + "=dest");
			stripe_size--;
 			smap.seek(o, SeekBegin);
 			type = smap.readChar();
			
			dtrace("type=" + type + " @ " + o);
			decomp_shr = type % 10;
			decomp_mask = 0xFF >> (8 - decomp_shr);
  		
			dtrace("decomp shr " + decomp_shr + " " + decomp_mask);
			
			if (type == 104 && o == 6555)
				dtrace_override = false;
			else
				dtrace_override = true;
			
			if (type > 13 && type < 19)
			{
 				pixels.seek(i*8*4, SeekBegin);
				unkDecodeC(pixels, stride*4, smap, height, 0, decomp_mask, decomp_shr);
			}
			else if (type > 23 && type < 29)
			{
 				pixels.seek(i*8*4, SeekBegin);
				unkDecodeB(pixels, stride*4, smap, height, 0, decomp_mask, decomp_shr);
			}
			else if (type > 33 && type < 39)
			{
 				pixels.seek(i*8*4, SeekBegin);
				if (transparentColor < 0)
 					unkDecodeC(pixels, stride*4, smap, height, 0, decomp_mask, decomp_shr);
				else
					unkDecodeC_trans(pixels, stride*4, smap, height, 0, transparentColor, decomp_mask, decomp_shr);
			}
			else if (type > 43 && type < 49)
			{
 				pixels.seek(i*8*4, SeekBegin);
				if (transparentColor < 0)
					unkDecodeB(pixels, stride*4, smap, height, 0, decomp_mask, decomp_shr);
				else
					unkDecodeB_trans(pixels, stride*4, smap, height, 0, transparentColor, decomp_mask, decomp_shr);
			}
			else if (type > 64 && type < 69)
			{
 				pixels.seek(i*8*4, SeekBegin);
				unkDecodeA(pixels, stride*4, smap, height, 0, decomp_mask, decomp_shr);
			}
			else if (type > 103 && type < 109)
			{
 				pixels.seek(i*8*4, SeekBegin);
				unkDecodeA(pixels, stride*4, smap, height, 0, decomp_mask, decomp_shr);
			}
			else if (type > 83 && type < 129)
			{
 				pixels.seek(i*8*4, SeekBegin);
				if (transparentColor < 0)
					unkDecodeA(pixels, stride*4, smap, height, 0, decomp_mask, decomp_shr);
				else
					unkDecodeA_trans(pixels, stride*4, smap, height, 0, transparentColor, decomp_mask, decomp_shr);
			}
			else
			{
				dtrace("Unknown codec type " + type);
				return false;
			}
		}
		
		dtrace("setting pixels " + width + "x" + height + "(" + SeekableTools.getSeekableLength(pixels) + ")");
  		
		// Finally set the darn pixels!
		data.lock();
		
		#if js
		var end = SeekableTools.getSeekableLength(pixels);
		var nonblanks = 0;
		pixels.seek(0, SeekBegin);
		while (end != 0)
		{
			if (pixels.readChar() != 0)
				nonblanks++;
			end--;
		}
		
		if (nonblanks == 0)
			haxe.Firebug.trace("Odd, SPUTMImage has blank pixels?!");
		else
			haxe.Firebug.trace(nonblanks + " non-blank pixels in SPUTMImage");
		#end
		
		pixels.seek(0, SeekBegin);
		
		#if flash9
		data.setPixels(new Rectangle(0,0,width,height), pixels.byteArray);
		#else true
		data.setPixels(new Rectangle(0,0,width,height), pixels);
		#end
		data.unlock();
		
		dtrace_on = false;
		
		return true;
	}
	
	public function decodeZPlane(idx: Int, stride: Int, width: Int, height: Int, zplane: MemoryIO, transparentColor: Int)
	{
		return true;
	}
	  
	static public function unkDecodeA(pixels: MemoryIO, stride : Int, smap : MemoryIO, height : Int, pal_mod : Int, decomp_mask : Int, decomp_shr : Int) : Void
	{
		var color: Int = smap.readChar();
		var bits: Int = 0; bits = smap.readChar();
		var cl: Int = 8;
		var bit: Int = 0;
		var incm: Int;
		var reps: Int;
				
		//trace("unkDecodeA (" + smap.length + ", " + color + "," + bits  + ")...");
		
		while (true)
		{
			var x: Int = 8;
			
			while (true)
			{
				fillBits(cl, bits, smap);
				pixels.writeUInt32(color + pal_mod);
				pixels_written++;
				
				while (true) // againPos:
				{
					//dtrace("againPos");
					readBit(bit, cl, bits);
					if (bit > 0) // if (!READ_BIT)  [collapsed]
					{
						readBit(bit, cl, bits);
						if (bit == 0)	// else if (!READ_BIT)
						{
							fillBits(cl, bits, smap);
						
							color = bits & decomp_mask;
							bits >>= decomp_shr;
							cl -= decomp_shr;
							
							//dtrace("nrb2");
						}
						else
						{
							//dtrace("nrb3");
							incm = (bits & 7) - 4;
							cl -= 3;
							bits >>= 3;
							if (incm != 0)
							{
								color += incm;
								dtrace("incm " + incm);
							}
							else
							{
								fillBits(cl, bits, smap);

								reps = (bits & 0xFF);
								while (true)
								{
									x--;
									if (x == 0)
									{
										x = 8;
										
										pixels.seek(stride - (8 * 4), SeekCur);
										height--;
										if (height == 0)
										{
											dtrace("HEIGHT EXIT " + height);
											return;
										}
									}
									//dtrace("REPS X=" + x + " @  " + reps);
														
									pixels.writeUInt32(color + pal_mod);
									pixels_written++;
									
									reps--;
								
									if (dtrace_on && reps == 0) // always reads reps+1 bytes?
										break;
									
									if (reps < 0) // incorrect
										break;
								}
							
								bits >>= 8;
								bits |= (smap.readChar()) << (cl-8);
							
								continue; //goto againPos;
							}
						}
					}
					else
					{
						//dtrace("nrb1");
					}
					
					break;
				} // end againPos
				dtrace("END againPos");
				x--;
				
				if (x == 0)
					break;
			}
			pixels.seek(stride - (8 * 4), SeekCur);
			height--;
			
			dtrace("NXT H " + height);
			
			if (height == 0)
				break;
		}
	}
	
	static public function unkDecodeA_trans(pixels: MemoryIO, stride : Int, smap : MemoryIO, height : Int, pal_mod : Int, transparentColor: Int,  decomp_mask : Int, decomp_shr : Int) : Void
	{
		trace("CRAP");
	}
	
	static public function unkDecodeB(pixels: MemoryIO, stride : Int, smap : MemoryIO, height : Int, pal_mod : Int, decomp_mask : Int, decomp_shr : Int) : Void
	{
		var color: Int = smap.readChar();
		var bits: Int = 0; bits = smap.readChar();
		var cl: Int = 8;
		var bit: Int = 100;
		var inc: Int = -1;
		
		while (true)
		{
			var x: Int = 8;
			
			while (true)
			{
				fillBits(cl, bits, smap);
				
				pixels.writeUInt32(color + pal_mod);
				
				readBit(bit, cl, bits);
				if (bit > 0) // if (!READ_BIT) [collapsed]
				{
					readBit(bit, cl, bits);
					if (bit == 0) // else if (!READ_BIT)
					{
						fillBits(cl, bits, smap);
						
						color = bits & decomp_mask;
						bits >>= decomp_shr;
						cl -= decomp_shr;
						inc = -1;
					}
					else
					{
						readBit(bit, cl, bits);
						if (bit == 0) // else if (!READ_BIT)
						{
							color += inc;
						}
						else
						{
							inc = -inc;
							color += inc;
						}
					}
				}
				
				if (--x == 0)
					break;
			}
			
			pixels.seek(stride - (8*4), SeekCur);
			
			if (--height == 0)
				break;
		}
	}
	
	static public function unkDecodeB_trans(pixels: MemoryIO, stride : Int, smap : MemoryIO, height : Int, pal_mod : Int, transparentColor: Int,  decomp_mask : Int, decomp_shr : Int) : Void
	{
		trace("CRAP 3");
	}
	
	static public function unkDecodeC(pixels: MemoryIO, stride : Int, smap : MemoryIO, height : Int, pal_mod : Int, decomp_mask : Int, decomp_shr : Int) : Void
	{
		var color: Int = smap.readChar();
		var bits: Int = 0; bits = smap.readChar();
		var cl: Int = 8;
		var bit: Int = 100;
		var inc: Int = -1;
		
		var x: Int = 8;

		
		while (true)
		{
			var h: Int = height;
			while (true)
			{  
				fillBits(cl, bits, smap);
				
				pixels.writeUInt32(color + pal_mod);
				pixels.seek(stride-4, SeekCur);
				h--;
				
				readBit(bit, cl, bits);
				if (bit > 0) // if (!READ_BIT) [collapsed]
				{
					readBit(bit, cl, bits);
					if (bit == 0) // else if (!READ_BIT)
					{
						fillBits(cl, bits, smap);
						
						color = bits & decomp_mask;
						bits >>= decomp_shr;
						cl -= decomp_shr;
						inc = -1;
						
						if (h == 0)
							break;
						else
							continue;
					}			 
					
					readBit(bit, cl, bits);				
					if (bit == 0) // if (!READ_BIT)
					{
						color += inc;
						
						if (h == 0)
							break;
						else
							continue;
					}
				}
				else
				{
					if (h == 0)
						break;
					else
						continue;
				}
				
				// Default
				inc = -inc;
				color += inc;
				
				if (h == 0)
					break;
			}
			
			pixels.seek(-((height * stride) - 4), SeekCur);
			
			x--;
			if (x == 0)
				break;
		}
	}
	
	static public function unkDecodeC_trans(pixels: MemoryIO, stride : Int, smap : MemoryIO, height : Int, pal_mod : Int, transparentColor: Int, decomp_mask : Int, decomp_shr : Int) : Void
	{
		trace("CRAP 5");
	}
}

