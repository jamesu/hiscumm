package tools;

/*
ToScript
-----------
Copyright (C) 2008 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/*
	ToScript
	toscript <in> <array_name>
	
	A Tool to convert binary files to JavaScript sources which define an equivalent array.
*/

class ToScript
{	
	static function main() {
	   var args = neko.Sys.args();
	   var in_name = args[0];
	   var out_array = args[1];
	   var out_file = in_name + ".js";
	   
	   neko.Lib.println("// Converted " + in_name + " to " + out_array + " in " + out_file);
	   var in_file = neko.io.File.read(in_name, true);
	   var in_str = in_file.readAll();
	   in_file.close();
	   
	   // Print to stdout
	   neko.Lib.print("var " + out_array + " = [");
	   var i = 0;
	   while (i < in_str.length)
	   {
	       neko.Lib.print(in_str.get(i));
	       i += 1;
	       if (i < in_str.length)
	           neko.Lib.print(",");
	   }
	   neko.Lib.print("];");
	}
}

