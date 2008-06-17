package hiscumm;

/*
test
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/*
	TEST
*/

import hiscumm.SPUTM;
import hiscumm.Common;
import utils.JSByteIO;

class JSTest
{
	public static var resources: Array<ResourceIO>;
	public static var engine: SPUTM;
	
	static function main() {
		trace("Preloading resources");
		resources = new Array<ResourceIO>();
		
		// Either load directly if possible, or from javascript data
		if (!(untyped __js__("hiscumm_script_load")))
		{
			resources.push(JSByteIO.fromURL("SCUMMC.000"));
			resources.push(JSByteIO.fromURL("SCUMMC.001"));
		}
		else
		{
			// Grab from scumm_000_data & scumm_001_data in JavaScript
			resources.push(new JSByteIO(untyped __js__("scumm_000_data")));
			resources.push(new JSByteIO(untyped __js__("scumm_001_data")));
		}
		
		trace("Resources loaded");
		
		engine = new SPUTM(resources);
		
		trace("Engine init");
		engine.run();
	}
}

