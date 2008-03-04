package noneko;
/*
hiscumm
-----------
Copyright (C) 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2005, The haXe Project Contributors
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

class Input
{
	public f9dynamic function close() : Void
	{
		readBytes = function(_,_,_) { return throw Error.Closed; };
		readChar = function() { return throw Error.Closed; };
		close = function() { };
	}
	
	public function read(nbytes : Int) : String
	{
		return "";
	}
	
	public function readAll(?bufsize : Int) : String
	{
		return "";
	}
	
	public f9dynamic function readBytes(s : String, p : Int, len : Int) : Int
	{
		return 0;
	}
	
	public f9dynamic function readChar() : Int
	{
		return throw "Not implemented";
	}
	
	public function readDouble() : Float
	{
		return 0;
	}
	
	public function readDoubleB() : Float
	{
		return 0;
	}
	
	public function readFloat() : Float
	{
		return 0;
	}
	
	public function readFloatB() : Float
	{
		return 0;
	}
	
	public function readFullBytes(s : String, pos : Int, len : Int) : Void
	{
		while( len > 0 ) {
			var k = readBytes(s,pos,len);
			pos += k;
			len -= k;
		}
	}
	
	public function readInt16() : Int
	{
		var ch1 = readChar();
		var ch2 = readChar();
		var n = ch1 | (ch2 << 8);
		if( ch2 & 128 != 0 )
			return n - 65536;
		return n;
	}
	
	public function readInt24() : Int
	{
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		var n = ch1 | (ch2 << 8) | (ch3 << 16);
		if( ch3 & 128 != 0 )
			return n - (1 << 24);
		return n;
	}
	
	public function readInt32() : Int
	{
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		var ch4 = readChar();
		if( (ch4 & 128) != 0 ) {
			if( ch4 & 64 == 0 ) throw Error.Overflow;
			return ch1 | (ch2 << 8) | (ch3 << 16) | ((ch4 & 127) << 24);
		} else {
			if( ch4 & 64 != 0 ) throw Error.Overflow;
			return ch1 | (ch2 << 8) | (ch3 << 16) | (ch4 << 24);
		}
	}
	
	public function readInt8() : Int
	{
		var n = readChar();
		if( n >= 128 )
			return n - 256;
		return n;
	}
	
	public function readLine() : String
	{
		return "";
	}
	
	public function readUInt16() : Int
	{
		var ch1 = readChar();
		var ch2 = readChar();
		return ch1 | (ch2 << 8);
	}
	
	public function readUInt16B() : Int
	{
		var ch1 = readChar();
		var ch2 = readChar();
		return ch2 | (ch1 << 8);
	}
	
	public function readUInt24() : Int
	{
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		return ch1 | (ch2 << 8) | (ch3 << 16);
	}
	
	public function readUInt24B() : Int
	{
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		return ch3 | (ch2 << 8) | (ch1 << 16);
	}
	
	public function readUInt32() : Int
	{
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		var ch4 = readChar();
		if( ch4 >= 64 ) throw Error.Overflow;
		return ch1 | (ch2 << 8) | (ch3 << 16) | (ch4 << 24);
	}
	
	public function readUInt32B() : Int
	{
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		var ch4 = readChar();
		if( ch1 >= 64 ) throw Error.Overflow;
		return ch4 | (ch3 << 8) | (ch2 << 16) | (ch1 << 24);
	}
	
	public function readUntil(end : Int) : String
	{
		var buf = new StringBuf();
		var last : Int;
		while( (last = readChar()) != end )
			buf.addChar( last );
		return buf.toString();
	}
}