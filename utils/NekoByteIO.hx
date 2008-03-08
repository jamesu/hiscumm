package utils;
/*
hiscumm
-----------
 * Copyright (c) 2005, The haXe Project Contributors
 * Copyright (c) 2008 James S Urquhart (jamesu at gmail.com)
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
*/

#if neko

//import noneko.Input;
//import noneko.Output;
import neko.io.Input;
import neko.io.Error;
import neko.io.Eof;
import noneko.IOTools;
import neko.io.File;
//import utils.Seekable;

class NekoByteIO extends Input //, implements Output, implements Seekable
{
	var s : String;
	var pos : Int;
	var len : Int;
	
	public function new(?data: String)
	{
		this.s = data == null ? "" : data;
		this.pos = 0;
		this.len = if( data == null ) 0 else data.length;
		if( this.pos < 0 || this.len < 0 )
			throw "Invalid parameter";
	}
	
	public function close() : Void
	{
		s = null;
	}
	
	public function flush() : Void
	{
	}
	
	public function prepare(nbytes: Int) : Void
	{
		len = nbytes;
		
		var olddata = s;
		s = neko.Lib.makeString(nbytes);
		if (olddata != null)
		{
			// TODO: stick back into data
		}
	}
	
	// Input

	public function readChar() {
		if( this.pos + 1 > this.len )
			throw new Eof();
		var c = untyped __dollar__sget(s.__s,pos);
		pos += 1;
		return c;
	}

	public function readBytes( buf : String, bpos, blen ) : Int {
		if( (this.len == this.pos) && blen > 0 )
			throw new Eof();
		if( len < pos + blen )
			blen = len - pos;
		untyped __dollar__sblit(buf.__s,bpos,s.__s,pos,blen);
		pos += blen;
		return blen;
	}
	
	public function readAll( ?bufsize : Int ) : String {
		if( bufsize == null )
			bufsize = (1 << 14); // 16 Ko
		var buf = neko.Lib.makeString(bufsize);
		var total = new StringBuf();
		try {
			while( true ) {
				var len = readBytes(buf,0,bufsize);
				if( len == 0 )
					throw Error.Blocked;
				total.addSub(buf,0,len);
			}
		} catch( e : Eof ) {
		}
		return total.toString();
	}

	public function readFullBytes( s : String, pos : Int, len : Int ) {
		while( len > 0 ) {
			var k = readBytes(s,pos,len);
			pos += k;
			len -= k;
		}
	}

	public function read( nbytes : Int ) : String {
		var s = neko.Lib.makeString(nbytes);
		var p = 0;
		while( nbytes > 0 ) {
			var k = readBytes(s,p,nbytes);
			if( k == 0 ) throw Error.Blocked;
			p += k;
			nbytes -= k;
		}
		return s;
	}

	public function readUntil( end : Int ) : String {
		var buf = new StringBuf();
		var last : Int;
		while( (last = readChar()) != end )
			buf.addChar( last );
		return buf.toString();
	}

	public function readLine() : String {
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
			if( s.length == 0 )
				neko.Lib.rethrow(e);
		}
		return s;
	}

	public function readFloat() : Float {
		return _float_of_bytes(untyped read(4).__s,false);
	}

	public function readFloatB() : Float {
		return _float_of_bytes(untyped read(4).__s,true);
	}

	public function readDouble() : Float {
		return _double_of_bytes(untyped read(8).__s,false);
	}

	public function readDoubleB() : Float {
		return _double_of_bytes(untyped read(8).__s,true);
	}

	public function readInt8() {
		var n = readChar();
		if( n >= 128 )
			return n - 256;
		return n;
	}

	public function readInt16() {
		var ch1 = readChar();
		var ch2 = readChar();
		var n = ch1 | (ch2 << 8);
		if( ch2 & 128 != 0 )
			return n - 65536;
		return n;
	}

	public function readUInt16() {
		var ch1 = readChar();
		var ch2 = readChar();
		return ch1 | (ch2 << 8);
	}

	public function readUInt16B() {
		var ch1 = readChar();
		var ch2 = readChar();
		return ch2 | (ch1 << 8);
	}

	public function readInt24() {
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		var n = ch1 | (ch2 << 8) | (ch3 << 16);
		if( ch3 & 128 != 0 )
			return n - (1 << 24);
		return n;
	}

	public function readUInt24() {
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		return ch1 | (ch2 << 8) | (ch3 << 16);
	}

	public function readUInt24B() {
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		return ch3 | (ch2 << 8) | (ch1 << 16);
	}

	public function readInt32() {
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

	public function readUInt32() {
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		var ch4 = readChar();
		if( ch4 >= 64 ) throw Error.Overflow;
		return ch1 | (ch2 << 8) | (ch3 << 16) | (ch4 << 24);
	}

	public function readUInt32B() {
		var ch1 = readChar();
		var ch2 = readChar();
		var ch3 = readChar();
		var ch4 = readChar();
		if( ch1 >= 64 ) throw Error.Overflow;
		return ch4 | (ch3 << 8) | (ch2 << 16) | (ch1 << 24);
	}

	static var _float_of_bytes = neko.Lib.load("std","float_of_bytes",2);
	static var _double_of_bytes = neko.Lib.load("std","double_of_bytes",2);
		
	// Output
	
	public function writeBytes(s : String, p : Int, blen : Int) : Int
	{
		if( (this.len == this.pos) && blen > 0 )
			throw new Eof();
		if( len < pos + blen )
			blen = len - pos;
		
		neko.Lib.copyBytes(this.s, this.pos, s, p, blen);
		this.pos += blen;
		return len;
	}
	
	public function writeChar(c : Int) : Void
	{
		if (this.pos + 1 > this.len)
			throw new Eof();
		
		neko.Lib.copyBytes(s, pos, String.fromCharCode(c), 0, 1);
		this.pos += 1;
	}
	
	public function write( s : String ) : Void {
		var l = s.length;
		var p = 0;
		while( l > 0 ) {
			var k = writeBytes(s,p,l);
			if( k == 0 ) throw Error.Blocked;
			p += k;
			l -= k;
		}
	}

	public function writeFullBytes( s : String, pos : Int, len : Int ) {
		while( len > 0 ) {
			var k = writeBytes(s,pos,len);
			pos += k;
			len -= k;
		}
	}

	public function writeFloat( c : Float ) {
		write(new String(_float_bytes(c,false)));
	}

	public function writeFloatB( c : Float ) {
		write(new String(_float_bytes(c,true)));
	}

	public function writeDouble( c : Float ) {
		write(new String(_double_bytes(c,false)));
	}

	public function writeDoubleB( c : Float ) {
		write(new String(_double_bytes(c,true)));
	}

	public function writeInt8( c : Int ) {
		if( c < -0x80 || c > 0x7F )
			throw Error.Overflow;
		writeChar(c & 0xFF);
	}

	public function writeInt16( x : Int ) {
		if( x < -0x8000 || x > 0x7FFF ) throw Error.Overflow;
		if( x < 0 )
			writeUInt16(0x10000 + x);
		else
			writeUInt16(x);
	}

	public function writeUInt16( x : Int ) {
		if( x < 0 || x > 0xFFFF ) throw Error.Overflow;
		writeChar(x & 0xFF);
		writeChar(x >> 8);
	}

	public function writeUInt16B( x : Int ) {
		if( x < 0 || x > 0xFFFF ) throw Error.Overflow;
		writeChar(x >> 8);
		writeChar(x & 0xFF);
	}

	public function writeInt24( x : Int ) {
		if( x < -0x800000 || x > 0x7FFFFF ) throw Error.Overflow;
		if( x < 0 )
			writeUInt24(0x1000000 + x);
		else
			writeUInt24(x);
	}
	
	public function writeUInt24( x : Int ) {
		if( x < 0 || x > 0xFFFFFF ) throw Error.Overflow;
		writeChar(x & 0xFF);
		writeChar((x >> 8) & 0xFF);
		writeChar(x >> 16);
	}
	
	public function writeUInt24B( x : Int ) {
		if( x < 0 || x > 0xFFFFFF ) throw Error.Overflow;
		writeChar(x >> 16);
		writeChar((x >> 8) & 0xFF);
		writeChar(x & 0xFF);
	}

	public function writeInt32( x : Int ) {
		writeChar(x & 0xFF);
		writeChar((x >> 8) & 0xFF);
		writeChar((x >> 16) & 0xFF);
		writeChar(x >>> 24);
	}

	public function writeUInt32( x : Int ) {
		if( x < 0 ) throw Error.Overflow;
		writeInt32(x);
	}
	
	public function writeUInt32B( x : Int ) {
		if( x < 0 ) throw Error.Overflow;
		writeChar(x >>> 24);
		writeChar((x >> 16) & 0xFF);
		writeChar((x >> 8) & 0xFF);
		writeChar(x & 0xFF);
	}

	public function writeInput( i : Input, ?bufsize : Int ) {
		if( bufsize == null )
			bufsize = 4096;
		var buf = neko.Lib.makeString(bufsize);
		try {
			while( true ) {
				var len = i.readBytes(buf,0,bufsize);
				if( len == 0 )
					throw Error.Blocked;
				var p = 0;
				while( len > 0 ) {
					var k = writeBytes(buf,p,len);
					if( k == 0 )
						throw Error.Blocked;
					p += k;
					len -= k;
				}
			}
		} catch( e : Eof ) {
		}
	}

	static var _float_bytes = neko.Lib.load("std","float_bytes",2);
	static var _double_bytes = neko.Lib.load("std","double_bytes",2);

	// Seekable IO
	
	public function seek(p : Int, pos : FileSeek) : Void
	{
		switch (pos)
		{
			case SeekEnd:
				this.pos = len - p;
			case SeekCur:
				this.pos += p;
			case SeekBegin:
				this.pos = p;
		}
	}
	
	public function tell() : Int
	{
		return pos;
	}
}

#end
