package noneko;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban Bedel, 
                           Copyright (C) 2005, The haXe Project Contributors
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

class Int32
{
	private var value: Int;
	
	private function new(in_value: Int)
	{
		value = in_value;
	}
	
	static function add(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value + b.value);
	}
	
	static function address(addr: Dynamic) : Int32
	{
		return new Int32(0);
	}
	
	static function and(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value & b.value);
	}
	
	static function compare(a : Int32, b : Int32) : Int
	{
		return ((a.value == b.value)?0:(a.value < b.value)?-1:1);
	}
	
	static function complement(a : Int32) : Int32
	{
		return new Int32(~a.value);
	}
	
	static function div(a : Int32, b : Int32) : Int32
	{
		return new Int32(Math.round(a.value / b.value));
	}
	
	static function make(a : Int, b : Int) : Int32
	{
		return Int32.add(Int32.shl(cast a,16),cast b);
	}
	
	static function mod(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value % b.value);
	}
	
	static function mul(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value * b.value);
	}
	
	static function neg(a : Int32) : Int32
	{
		return new Int32(-a.value);
	}
	
	static function ofInt(a : Int) : Int32
	{
		return new Int32(a);
	}
	
	static function or(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value | b.value);
	}
	
	static function read(i : noneko.Input, ?b : Bool) : Int32
	{
		// Copyright (c) 2005, The haXe Project Contributors
		var f = if( b ) i.readUInt16B else i.readUInt16;
		var a = f();
		return if( b ) make(a,f()) else make(f(),a);
	}
	
	static function shl(a : Int32, b : Int) : Int32
	{
		return new Int32(a.value << b);
	}
	
	static function shr(a : Int32, b : Int) : Int32
	{
		return new Int32(a.value >> b);
	}
	
	static function sub(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value - b.value);
	}
	
	static function toFloat(a : Int32) : Float
	{
		return cast(a.value, Float);
	}
	
	static function toInt(a : Int32) : Int
	{
		return a.value;
	}
	
	static function ushr(a : Int32, b : Int) : Int32
	{
		return new Int32(a.value >>> b);
	}
	
	static function write(o : noneko.Output, i : Int32, ?b : Bool) : Void
	{
		// Copyright (c) 2005, The haXe Project Contributors
		var low = cast Int32.and(i,cast 0xFFFF);
		var high = cast Int32.ushr(i,16);
		if( b ) {
			o.writeUInt16B(high);
			o.writeUInt16B(low);
		} else {
			o.writeUInt16(low);
			o.writeUInt16(high);
		}
	}
	
	static function xor(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value ^ b.value);
	}
}