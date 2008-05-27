package noflash;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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


#else js

//import neko.Int32;
typedef UInt = Int;

class ByteArray
{
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

