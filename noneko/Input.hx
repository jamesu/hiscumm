package noneko;
/*
hiscumm
-----------
Copyright (C) 2008 James S Urquhart (jamesu at gmail.com)
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

interface Input
{
	public function close() : Void;
	
	public function read(nbytes : Int) : String;
	
	public function readAll(?bufsize : Int) : String;
	
	public function readBytes(s : String, p : Int, len : Int) : Int;
	
	public function readChar() : Int;
	
	public function readDouble() : Float;
	
	public function readDoubleB() : Float;
	
	public function readFloat() : Float;
	
	public function readFloatB() : Float;
	
	public function readFullBytes(s : String, pos : Int, len : Int) : Void;
	
	public function readInt16() : Int;
	
	public function readInt24() : Int;
	
	public function readInt32() : Int;
	
	public function readInt8() : Int;
	
	public function readLine() : String;
	
	public function readUInt16() : Int;
	
	public function readUInt16B() : Int;
	
	public function readUInt24() : Int;
	
	public function readUInt24B() : Int;
	
	public function readUInt32() : Int;
	
	public function readUInt32B() : Int;
	
	public function readUntil(end : Int) : String;
}
