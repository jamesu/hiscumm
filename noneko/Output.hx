package noneko;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban Bedel, 
                           Copyright (C) 2005, The haXe Project Contributors
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

class Output
{
	public f9dynamic function close() : Void
	{
		writeBytes = function(_,_,_) { return throw Error.Closed; };
		writeChar = function(_) { throw Error.Closed; };
		flush = function() { throw Error.Closed; };
		close = function() { };
	}
	
	public f9dynamic function flush() : Void
	{
	}
	
	public function prepare(nbytes : Int) : Void
	{
	}
	
	public function write(s : String) : Void
	{
		var l = s.length;
		var p = 0;
		while( l > 0 ) {
			var k = writeBytes(s,p,l);
			if( k == 0 ) throw Error.Blocked;
			p += k;
			l -= k;
		}
	}
	
	public f9dynamic function writeBytes(s : String, p : Int, len : Int) : Int
	{
		return 0;
	}
	
	public f9dynamic function writeChar(c : Int) : Void
	{
		throw "Not implemented";
	}
	
	public function writeDouble(c : Float) : Void
	{
	}
	
	public function writeDoubleB(c : Float) : Void
	{
	}
	
	public function writeFloat(c : Float) : Void
	{
	}
	
	public function writeFloatB(c : Float) : Void
	{
	}
	
	public function writeFullBytes(s : String, pos : Int, len : Int) : Void
	{
		while( len > 0 ) {
			var k = writeBytes(s,pos,len);
			pos += k;
			len -= k;
		}
	}
	
	public function writeInput(i : Input, ?bufsize : Int) : Void
	{
	}
	
	public function writeInt16(x : Int) : Void
	{
		if( x < -0x8000 || x > 0x7FFF ) throw Error.Overflow;
		if( x < 0 )
			writeUInt16(0x10000 + x);
		else
			writeUInt16(x);
	}
	
	public function writeInt24(x : Int) : Void
	{
		if( x < 0 || x > 0xFFFFFF ) throw Error.Overflow;
		writeChar(x & 0xFF);
		writeChar((x >> 8) & 0xFF);
		writeChar(x >> 16);
	}
	
	public function writeInt32(x : Int) : Void
	{
		writeChar(x & 0xFF);
		writeChar((x >> 8) & 0xFF);
		writeChar((x >> 16) & 0xFF);
		writeChar(x >>> 24);
	}
	
	public function writeInt8(c : Int) : Void
	{
		if( c < -0x80 || c > 0x7F )
			throw Error.Overflow;
		writeChar(c & 0xFF);
	}
	
	public function writeUInt16(x : Int) : Void
	{
		if( x < 0 || x > 0xFFFF ) throw Error.Overflow;
		writeChar(x & 0xFF);
		writeChar(x >> 8);
	}
	
	public function writeUInt16B(x : Int) : Void
	{
		if( x < 0 || x > 0xFFFF ) throw Error.Overflow;
		writeChar(x >> 8);
		writeChar(x & 0xFF);
	}
	
	public function writeUInt24(x : Int) : Void
	{
		if( x < -0x800000 || x > 0x7FFFFF ) throw Error.Overflow;
		if( x < 0 )
			writeUInt24(0x1000000 + x);
		else
			writeUInt24(x);
	}
	
	public function writeUInt24B(x : Int) : Void
	{
		if( x < 0 || x > 0xFFFFFF ) throw Error.Overflow;
		writeChar(x >> 16);
		writeChar((x >> 8) & 0xFF);
		writeChar(x & 0xFF);
	}
	
	public function writeUInt32(x : Int) : Void
	{
		if( x < 0 ) throw Error.Overflow;
		writeInt32(x);
	}
	
	public function writeUInt32B(x : Int) : Void
	{
		if( x < 0 ) throw Error.Overflow;
		writeChar(x >>> 24);
		writeChar((x >> 16) & 0xFF);
		writeChar((x >> 8) & 0xFF);
		writeChar(x & 0xFF);
	}
}