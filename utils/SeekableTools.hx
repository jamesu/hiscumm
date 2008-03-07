package utils;
/*
hiscumm
-----------
Copyright (C) 2008 James S Urquhart (jamesu at gmail.com)
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#if neko
import neko.io.File;
typedef ToolSeekable = Dynamic;
#else !neko
import utils.Seekable;
typedef ToolSeekable = Seekable;
#end

class SeekableTools
{
	public static function getSeekableLength(s : ToolSeekable) : Int
	{
		var old_pos = s.tell();
		s.seek(0, SeekEnd);
		var new_pos = s.tell();
		s.seek(old_pos, SeekBegin);
		return new_pos;
	}
}
