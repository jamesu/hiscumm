package noflash;
/*
hiscumm
-----------
Copyright (C) 2007 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/*
	ByteArray
	
	This class is a clone of flash9's ByteArray
*/

#if neko

import neko.Int32;
typedef UInt = Int;

class ByteArray
{
	public var curInput: neko.io.StringInput;
	public var curOutput: neko.io.StringOutput;
	
	public var curString: String;
	
	static var defaultObjectEncoding : UInt = 0;

	public var bytesAvailable(getBytesAvailable,null) : UInt;
	public var endian(getEndian, setEndian) : String;
	public var length(getLength, setLength) : UInt;
	public var objectEncoding : UInt;
	public var position(getPosition, setPosition) : UInt; 
	
	// Internal vars
	private var flipBytes: Bool;
	private var curEndian: String;
	private var curLength: Int;
	private var curPos: Int;
	private var isReading(checkReading, null): Bool;

	// Get/Set
	
	private function getEndian()
	{
		return curEndian;
	}
	
	private function setEndian( value: String ) : String
	{ 
		if (value == "littleEndian")
		{
			flipBytes = false;
			curEndian = value;
		}
		else if (value == "bigEndian")
		{
			flipBytes = true;
			curEndian = value;
		}
		
		return curEndian;
	}
	
	private function getBytesAvailable() : UInt
	{
		return curLength - curPos;
	}
	
	private function getLength()
	{
		return curLength;
	}
	
	private function setLength( value: UInt ) : UInt
	{
		if (isReading)
			curInput = new neko.io.StringInput(curString, position, value);
		
		curLength = value;
		return curLength;
	}
	
	private function getPosition()
	{
		return curPos;
	}
	
	private function setPosition( value: UInt ) : UInt
	{
		if (value >= length)
			return curPos; 
		
		if (isReading)
			curInput = new neko.io.StringInput(curString, value, length);
		else
			return curPos; // cannot set when writing!
		
		curPos = value;
		return curPos;
	}
	
	private function checkReading() : Bool
	{
		return (curInput != null);
	}
	
	public function new() : Void
	{
		endian = "littleEndian";
		curLength = 0;
		curPos = 0;
		objectEncoding = defaultObjectEncoding;
		bytesAvailable = 0;
		
		curInput = null;
		curOutput = null;
	}
	
	inline function flipShort(num: Int) : Int
	{
		return 0;
	}
	
	inline function flipInt(num: Int) : Int
	{
		return 0;
	}
	
	inline function flipDouble(num: Float) : Float
	{
		return 0;
	}
	
	function setWriting()
	{
		if (curInput != null)
		{
			curInput = null;
		}
		
		curOutput = new neko.io.StringOutput();
	}
	
	function setReading()
	{
		if (curOutput != null)
		{
			curString = curOutput.toString();
			curOutput = null;
		}
		
		curInput = new neko.io.StringInput(curString, position, length);
	}
	
	public function compress() : Void
	{
	}
	
	public function readBoolean() : Bool
	{
		if (!isReading) setReading();
		return (readByte() == 0);
	}
	
	public function readByte() : Int
	{
		var res: Int = 0;
		if (!isReading) setReading();
		
		res = curInput.readInt8();
		
		curPos += 1;
		return res;
	}
	
	public function readBytes(bytes : ByteArray, ?offset : UInt, ?length : UInt) : Void
	{
		// NOTE: offset not supported!
		bytes.writeBytes(this, position, length);
		
		curPos += length;
	}
	
	public function readDouble() : Float
	{
		var res: Float = 0;
		if (!isReading) setReading();
		
		res = curInput.readFloat();
		if (flipBytes) flipDouble(res);
		
		curPos += 4;
		return res;
	}
	
	public function readFloat() : Float
	{
		var res: Float = 0;
		if (!isReading) setReading();
		
		res = curInput.readFloat();
		if (flipBytes) flipDouble(res);
		
		curPos += 4;
		return res;
	}
	
	public function readInt() : Int
	{
		var res: Int = 0;
		
		res = curInput.readInt32();
		if (!isReading) setReading();
		
		if (flipBytes) flipInt(res);
		
		curPos += 4;
		return res;
	}
	
	public function readMultiByte(length : UInt, charSet : String) : String
	{
		return "";
	}
	
	public function readObject() : Dynamic
	{
		return null;
	}
	
	public function readShort() : Int
	{
		var res: Int = 0;
		
		res = curInput.readInt16();
		if (!isReading) setReading();
		
		if (flipBytes) flipShort(res);
		
		curPos += 2;
		return res;
	}
	
	public function readUTF() : String
	{
		return "";
	}
	
	public function readUTFBytes(length : UInt) : String
	{
		return "";
	}
	
	public function readUnsignedByte() : UInt
	{
		return readShort();
	}
	
	public function readUnsignedInt() : UInt
	{
		return readInt();
	}
	
	public function readUnsignedShort() : UInt
	{
		return readShort();
	}
	
	public function toString() : String
	{
		return "";
	}
	
	public function uncompress() : Void
	{
	}
	
	public function writeBoolean(value : Bool) : Void
	{
	}
	
	public function writeByte(value : Int) : Void
	{
	}
	
	public function writeBytes(bytes : ByteArray, ?offset : UInt, ?length : UInt) : Void
	{
		if (isReading) setWriting();
		if (!bytes.isReading) bytes.setReading();
		
		bytes.position = offset;
		
		for (i in 0...length)
		{
			writeByte(bytes.readByte());
		}
	}
	
	public function writeDouble(value : Float) : Void
	{
	}
	
	public function writeFloat(value : Float) : Void
	{
	}
	
	public function writeInt(value : Int) : Void
	{
	}
	
	public function writeMultiByte(value : String, charSet : String) : Void
	{
	}
	
	public function writeObject(object : Dynamic) : Void
	{
	}
	
	public function writeShort(value : Int) : Void
	{
	}
	
	public function writeUTF(value : String) : Void
	{
	}
	
	public function writeUTFBytes(value : String) : Void
	{
	}
	
	public function writeUnsignedInt(value : UInt) : Void
	{
	}
}

import neko.io.File;

class FileByteArray extends ByteArray
{
	public var curFileInput: neko.io.FileInput;
	public var curFileOutput: neko.io.FileInput;
	
	private function setLength( value: UInt ) : UInt
	{
		curLength = value;
		return curLength;
	}
	
	private function setPosition( value: UInt ) : UInt
	{
		if (value >= length)
			return curPos;
		
		curFileInput.seek(value, SeekBegin);
		//curFileOutput.seek(value, SeekBegin);
		
		curPos = value;
		return curPos;
	}
	
	public function new(path: String) : Void
	{
		super();
		
		curFileInput = neko.io.File.read(path, true);
		//curFileOutput = neko.io.File.write(path, true);
		
		curFileInput.seek(0, SeekEnd);
		curLength = curFileInput.tell();
		curFileInput.seek(0, SeekBegin);
	}
	
	function setWriting()
	{
	}
	
	function setReading()
	{
	}
	
	public function compress() : Void
	{
	}
	
	public function readBoolean() : Bool
	{
		if (!isReading) setReading();
		return (readByte() == 0);
	}
	
	public function readByte() : Int
	{
		var res: Int = 0;
		
		res = curFileInput.readInt8();
		
		curPos += 1;
		return res;
	}
	
	public function readBytes(bytes : ByteArray, ?offset : UInt, ?length : UInt) : Void
	{
		bytes.setWriting();
		bytes.writeBytes(this, position, length);
		
		curPos += length;
	}
	
	public function readDouble() : Float
	{
		var res: Float = 0;
		if (!isReading) setReading();
		
		res = curFileInput.readFloat();
		if (flipBytes) flipDouble(res);
		
		curPos += 4;
		return res;
	}
	
	public function readFloat() : Float
	{
		var res: Float = 0;
		if (!isReading) setReading();
		
		res = curFileInput.readFloat();
		if (flipBytes) flipDouble(res);
		
		curPos += 4;
		return res;
	}
	
	public function readInt() : Int
	{
		var res: Int = 0;
		if (!isReading) setReading();
		
		res = curFileInput.readInt32();
		if (flipBytes) flipInt(res);
		
		curPos += 4;
		return res;
	}
	
	public function readMultiByte(length : UInt, charSet : String) : String
	{
		return "";
	}
	
	public function readObject() : Dynamic
	{
		return null;
	}
	
	public function readShort() : Int
	{
		var res: Int = 0;
		
		res = curFileInput.readInt16();
		if (!isReading) setReading();
		
		if (flipBytes) flipShort(res);
		
		curPos += 2;
		return res;
	}
	
	public function readUTF() : String
	{
		return "";
	}
	
	public function readUTFBytes(length : UInt) : String
	{
		return "";
	}
	
	public function readUnsignedByte() : UInt
	{
		return readShort();
	}
	
	public function readUnsignedInt() : UInt
	{
		return readInt();
	}
	
	public function readUnsignedShort() : UInt
	{
		return readShort();
	}
	
	public function toString() : String
	{
		return "";
	}
	
	public function uncompress() : Void
	{
	}
	
	public function writeBoolean(value : Bool) : Void
	{
	}
	
	public function writeByte(value : Int) : Void
	{
	}
	
	public function writeDouble(value : Float) : Void
	{
	}
	
	public function writeFloat(value : Float) : Void
	{
	}
	
	public function writeInt(value : Int) : Void
	{
	}
	
	public function writeMultiByte(value : String, charSet : String) : Void
	{
	}
	
	public function writeObject(object : Dynamic) : Void
	{
	}
	
	public function writeShort(value : Int) : Void
	{
	}
	
	public function writeUTF(value : String) : Void
	{
	}
	
	public function writeUTFBytes(value : String) : Void
	{
	}
	
	public function writeUnsignedInt(value : UInt) : Void
	{
	}
}


#else js

//import neko.Int32;
typedef UInt = Int;

class ByteArray
{
	//public var curIO: neko.io.Input;
	
	static var defaultObjectEncoding : UInt = 0;

	public var bytesAvailable/*(default,null)*/ : UInt;
	public var endian : String;
	public var length : UInt;
	public var objectEncoding : UInt;
	public var position : UInt;

	public function new() : Void
	{
		endian = "littleEndian";
		length = 0;
		position = 0;
		objectEncoding = defaultObjectEncoding;
		bytesAvailable = 0;
	}
	
	inline function flipShort(num: Int) : Int
	{
		return 0;
	}
	
	inline function flipInt(num: Int) : Int
	{
		return 0;
	}
	
	public function compress() : Void
	{
	}
	
	public function readBoolean() : Bool
	{
		return false;
	}
	
	public function readByte() : Int
	{
		return 0;
	}
	
	public function readBytes(bytes : ByteArray, ?offset : UInt, ?length : UInt) : Void
	{
	}
	
	public function readDouble() : Float
	{
		return 0;
	}
	
	public function readFloat() : Float
	{
		return 0;
	}
	
	public function readInt() : Int
	{
		return 0;
	}
	
	public function readMultiByte(length : UInt, charSet : String) : String
	{
		return "";
	}
	
	public function readObject() : Dynamic
	{
		return null;
	}
	
	public function readShort() : Int
	{
		return 0;
	}
	
	public function readUTF() : String
	{
		return "";
	}
	
	public function readUTFBytes(length : UInt) : String
	{
		return "";
	}
	
	public function readUnsignedByte() : UInt
	{
		return 0;
	}
	
	public function readUnsignedInt() : UInt
	{
		return 0;
	}
	
	public function readUnsignedShort() : UInt
	{
		return 0;
	}
	
	public function toString() : String
	{
		return "";
	}
	
	public function uncompress() : Void
	{
	}
	
	public function writeBoolean(value : Bool) : Void
	{
	}
	
	public function writeByte(value : Int) : Void
	{
	}
	
	public function writeBytes(bytes : ByteArray, ?offset : UInt, ?length : UInt) : Void
	{
	}
	
	public function writeDouble(value : Float) : Void
	{
	}
	
	public function writeFloat(value : Float) : Void
	{
	}
	
	public function writeInt(value : Int) : Void
	{
	}
	
	public function writeMultiByte(value : String, charSet : String) : Void
	{
	}
	
	public function writeObject(object : Dynamic) : Void
	{
	}
	
	public function writeShort(value : Int) : Void
	{
	}
	
	public function writeUTF(value : String) : Void
	{
	}
	
	public function writeUTFBytes(value : String) : Void
	{
	}
	
	public function writeUnsignedInt(value : UInt) : Void
	{
	}
}
#end

