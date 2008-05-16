package utils;
/*
hiscumm
-----------
Copyright (C) 2008 James S Urquhart (jamesu at gmail.com)
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#if js

import noneko.Input;
import noneko.Output;
import noneko.Error;
import noneko.Eof;
import noneko.IOTools;
import utils.Seekable;
import js.XMLHttpRequest;

// NOTE: considering JavaScript strings are immutable, we just use an array here.

class JSByteIO implements Input, implements Output, implements Seekable
{
	public var bytes : Array<Int>;
	public var pos: Int;
	
	public function new(?arr: Array<Int>)
	{
		if (arr == null)
		{
			bytes = new Array<Int>();
		}
		else
		{
			bytes = arr;
		}
		
		pos = 0;
	}
	
	public function close() : Void
	{
		bytes = null;
	}
	
	// Input
	
	public function read(nbytes : Int) : String
	{
		var buf = new StringBuf();
		while( nbytes > 0 ) {
			buf.addChar(bytes[pos]);
			pos += 1;
			nbytes -= 1;
		}
		
		return buf.toString();
	}
	
	public function readAll(?bufsize : Int) : String
	{
		return read(bytes.length);
	}
	
	public function readUntil(end : Int) : String
	{
		return IOTools.readUntil(this, end);
	}

	public function readChar() {
		//trace("readChar @ " + pos + " / " + this.bytes.length);
		if( this.pos + 1 > this.bytes.length )
			throw new Eof();
		var c = bytes[pos];
		//trace("^ == " + c);
		pos += 1;
		return c;
	}
	
	public function readBytes(s : String, p : Int, len : Int) : Int
	{
		// TODO: find equivalent
		return 0;
	}
	
	public function readFullBytes(s : String, pos : Int, len : Int) : Void
	{
		return IOTools.readFullBytes(this, s, pos, len);
	}
	
	public function readFloat() : Float {
		return 0; // TODO
	}

	public function readFloatB() : Float {
		return 0; // TODO
	}

	public function readDouble() : Float {
		return 0; // TODO
	}

	public function readDoubleB() : Float {
		return 0; // TODO
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
		return IOTools.readInt24(this);
	}

	public function readUInt24() {
		return IOTools.readUInt24(this);
	}

	public function readUInt24B() {
		return IOTools.readUInt24B(this);
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

	public function readLine() : String
	{
		return IOTools.readLine(this);
	}
	
	// Output
	
	public function prepare(nbytes : Int) : Void
	{
		var i = nbytes - 1;
		
		while (i >= 0)
		{
			bytes[i] = 0;
			i -= 1;
		}
	}
	
	public function flush() : Void
	{
	}
	
	public function write(s : String) : Void
	{
		var i = 0;
		for (i in 0...s.length)
		{
			writeChar(s.charCodeAt(i));
		} 
	}
	
	public function writeBytes(s : String, p : Int, len : Int) : Int
	{
		var opos: Int = pos;
		
		try
		{
			write(s.substr(p, len));
		}
		catch (e: Dynamic)
		{
			return 0;
		}
			
		return pos - opos;
	}
	
	public function writeChar(c : Int) : Void
	{
		if (this.pos + 1 > this.bytes.length)
			throw new Eof();
		
		c = c & 0xFF;
		bytes[pos] = c;
		pos += 1;
	}
	
	public function writeDouble(c : Float) : Void
	{
		// TODO
	}
	
	public function writeDoubleB(c : Float) : Void
	{
		// TODO
	}
	
	public function writeFloat(c : Float) : Void
	{
		// TODO
	}
	
	public function writeFloatB(c : Float) : Void
	{
		// TODO
	}
	
	public function writeFullBytes(s : String, pos : Int, len : Int) : Void
	{
		writeBytes(s, pos, len);
	}
	
	public function writeInput(i : Input, ?bufsize : Int) : Void
	{
		// Errk... the long way around!
		try
		{
			while (pos != bytes.length)
				writeChar(i.readChar());
		}
		catch (e: Dynamic)
		{
			return;
		}
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
		IOTools.writeInt24(this, x);
	}
	
	public function writeInt32(x : Int) : Void
	{
		if( x < 0 ) throw Error.Overflow;
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
		return IOTools.writeUInt24(this, x);
	}
	
	public function writeUInt24B(x : Int) : Void
	{
		return IOTools.writeUInt24B(this, x);
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

	// Seekable IO
	
	public function seek(p : Int, pos : Seek) : Void
	{
		switch (pos)
		{
			case SeekEnd:
				this.pos = bytes.length - p;
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
	
	// Static utils
	public static function fromURL(url: String) : JSByteIO
	{
		var res = new JSByteIO();
		
		// Grab data from url
		var req: Dynamic = new XMLHttpRequest();
		req.open("GET", url, false);
		req.overrideMimeType("text/plain; charset=x-user-defined");
		req.send(null);
		
		// Write result to byte array
		var str: String = (req.status != 200) ? "" : req.responseText;
		trace("XMLHttpRequest: Loaded " + str.length + " bytes");
		res.prepare(str.length);
		res.write(str);
		res.pos = 0;
		
		return res;
	}
}

#end
