package hiscumm;

#if flash9
typedef ByteArray = flash.utils.ByteArray;
typedef Bitmap = flash.display.Bitmap;
typedef BitmapData = flash.display.BitmapData;
typedef Rectangle = flash.geom.Rectangle;
typedef Point = flash.geom.Point;
typedef Timer = flash.utils.Timer;
typedef TimerEvent = flash.events.TimerEvent;
#else neko
typedef ByteArray = noflash.ByteArray;
typedef Bitmap = noflash.ByteArray;
typedef BitmapData = noflash.BitmapData;
typedef Rectangle = noflash.Rectangle;
typedef Point = noflash.Point;
typedef Timer = noflash.Timer;
typedef TimerEvent = noflash.TimerEvent;
#else js
typedef ByteArray = noflash.ByteArray;
typedef ByteArray = noflash.ByteArray;
typedef Bitmap = noflash.ByteArray;
typedef BitmapData = noflash.BitmapData;
typedef Rectangle = noflash.Rectangle;
typedef Point = noflash.Point;
typedef Timer = noflash.Timer;
typedef TimerEvent = noflash.TimerEvent;
#end