package noneko;
/*
hiscumm
-----------

Portions derived from code Copyright (C) 2004-2006 Alban Bedel, 
                           Copyright (C) 2005, The haXe Project Contributors

*/

class Int32
{
	public var value: Int;
	
	public function new(in_value: Int)
	{
		value = in_value;
	}
	
	static public inline function add(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value + b.value);
	}
	
	static public inline function address(addr: Dynamic) : Int32
	{
		return new Int32(0);
	}
	
	static public inline function and(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value & b.value);
	}
	
	static public inline function compare(a : Int32, b : Int32) : Int
	{
		return ((a.value == b.value)?0:(a.value < b.value)?-1:1);
	}
	
	static public inline function complement(a : Int32) : Int32
	{
		return new Int32(~a.value);
	}
	
	static public inline function div(a : Int32, b : Int32) : Int32
	{
		return new Int32(Math.round(a.value / b.value));
	}
	
	static public inline function make(a : Int, b : Int) : Int32
	{
		return new Int32((a << 16) + b);
	}
	
	static public inline function mod(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value % b.value);
	}
	
	static public inline function mul(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value * b.value);
	}
	
	static public inline function neg(a : Int32) : Int32
	{
		return new Int32(-a.value);
	}
	
	static public inline function ofInt(a : Int) : Int32
	{
		return new Int32(a);
	}
	
	static public inline function or(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value | b.value);
	}
	
	static public function read(i : noneko.Input, ?b : Bool) : Int32
	{
		// Copyright (c) 2005, The haXe Project Contributors
		var f = if( b ) i.readUInt16B else i.readUInt16;
		var a = f();
		return if( b ) make(a,f()) else make(f(),a);
	}
	
	static public inline function shl(a : Int32, b : Int) : Int32
	{
		return new Int32(a.value << b);
	}
	
	static public inline function shr(a : Int32, b : Int) : Int32
	{
		return new Int32(a.value >> b);
	}
	
	static public inline function sub(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value - b.value);
	}
	
	static public inline function toFloat(a : Int32) : Float
	{
		return cast(a.value, Float);
	}
	
	static public inline function toInt(a : Int32) : Int
	{
		return a.value;
	}
	
	static public inline function ushr(a : Int32, b : Int) : Int32
	{
		return new Int32(a.value >>> b);
	}
	
	static public function write(o : noneko.Output, i : Int32, ?b : Bool) : Void
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
	
	static public inline function xor(a : Int32, b : Int32) : Int32
	{
		return new Int32(a.value ^ b.value);
	}
}