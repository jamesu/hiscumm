package noneko;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

interface Output
{
	public function close() : Void;
	
	public function flush() : Void;
	
	public function prepare(nbytes : Int) : Void;
	
	public function write(s : String) : Void;
	
	public function writeBytes(s : String, p : Int, len : Int) : Int;
	
	public function writeChar(c : Int) : Void;
	
	public function writeDouble(c : Float) : Void;
	
	public function writeDoubleB(c : Float) : Void;
	
	public function writeFloat(c : Float) : Void;
	
	public function writeFloatB(c : Float) : Void;
	
	public function writeFullBytes(s : String, pos : Int, len : Int) : Void;
	
	public function writeInput(i : Input, ?bufsize : Int) : Void;
	
	public function writeInt16(x : Int) : Void;
	
	public function writeInt24(x : Int) : Void;
	
	public function writeInt32(x : Int) : Void;
	
	public function writeInt8(c : Int) : Void;
	
	public function writeUInt16(x : Int) : Void;
	
	public function writeUInt16B(x : Int) : Void;
	
	public function writeUInt24(x : Int) : Void;
	
	public function writeUInt24B(x : Int) : Void;
	
	public function writeUInt32(x : Int) : Void;
	
	public function writeUInt32B(x : Int) : Void;
}
