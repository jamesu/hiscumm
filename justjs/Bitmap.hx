package justjs;
/*
hiscumm
-----------

*/

import justjs.BitmapData;

/*
	Bitmap
	
	This class is a clone of flash9's Bitmap
*/

class Bitmap
{
	public var bitmapData: BitmapData;
	
	public function new() : Void
	{
	}
	
	public function dispose()
	{
		bitmapData.dispose();
		bitmapData = null;
	}

}
