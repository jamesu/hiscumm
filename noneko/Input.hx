package noneko;
/*
hiscumm
-----------

Portions derived from code Copyright (C) 2005, The haXe Project Contributors

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
		var buf = new StringBuf();
		var last : Int;
		var s;
		try {
			while( (last = readChar()) != 10 )
				buf.addChar( last );
			s = buf.toString();
			if( s.charCodeAt(s.length-1) == 13 ) s = s.substr(0,-1);
		} catch( e : Eof ) {
			s = buf.toString();
			// TODO: fix for noneko
			//if( s.length == 0 )
			//	neko.Lib.rethrow(e);
		}
		return s;
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