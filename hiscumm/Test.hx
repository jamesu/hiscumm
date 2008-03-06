package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#if flash9
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
#end

import hiscumm.Common;

import hiscumm.SPUTM;

/*
	TEST
	
	This handy class contains the entry point to hiscumm. It also handles loading the
	resource files and initializing SPUTM.
*/

class Test
{

	private static var loader: URLLoader;
	private static var loadQueue: List<String>;

	public static var engine: SPUTM;
	public static var resources: Array<ResourceIO>;

	static function swfLoaded(e: flash.events.Event) 
	{
		var bytes: ByteArray = cast(loader.data, ByteArray);

		//trace("Loaded file of " + bytes.length + " length!"); 
		resources[resources.length] = new ResourceIO(bytes);

		process_loadQueue();
	}

	static function process_loadQueue()
	{
		if (!loadQueue.isEmpty())
		{
			var next = loadQueue.pop();
			var urlRequest: URLRequest = new URLRequest(next);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(urlRequest);
			loader.addEventListener(flash.events.Event.COMPLETE, swfLoaded);
			return;
		}
		
		initSPUTM();
		
		//trace("Initialization complete");
	}

	static function initSPUTM()
	{
		engine = new SPUTM(resources);
		
		flash.Lib.current.addChild(engine.view);
		engine.run();
	}

	static function main() {
      loader = new URLLoader();
		resources = new Array<ResourceIO>();
		loadQueue = new List<String>();

		loadQueue.push("scummc.001");
		loadQueue.push("scummc.000");

		process_loadQueue();
	}
}

