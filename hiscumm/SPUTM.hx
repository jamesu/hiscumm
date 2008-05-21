package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban Bedel
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import hiscumm.Common;
#if neko
import neko.io.File;
#else !neko
import utils.Seekable;
#end

#if flash9
import flash.utils.Timer;
import flash.events.TimerEvent;
#else true
import haxe.Timer;
#end

import hiscumm.SCUMM;
import hiscumm.SPUTMResource;
import hiscumm.SPUTMRoom;
import hiscumm.SPUTMObject;
import hiscumm.SPUTMCostume;

/*
	SPUTM
	
	This collection of classes form the core of hiscumm. SCUMM memory, resource lists,
	drawing, and everything related is handled here.
*/

class SPUTMPalette extends MemoryIO 
{
	public function new(data: Input) 
	{
		super();
		prepare(256*3);
		writeInput(data);
		seek(0, SeekBegin);
	}
}

class SPUTMDisplayPalette
{
	private var zeros: Array<Int>;
	private var ones: Array<Int>;
	private var list: Array<Int>;
	
	static public var NULL_POINT: Point = new Point(0,0);
	
	public function new()
	{
		var i: Int;
		zeros = new Array<Int>();
		ones = new Array<Int>();
		list = new Array<Int>();
		
		zeros[255] = 0;
		ones[255] = 0;
		list[255] = 0;
		
		for (i in 0...255)
		{
			zeros[i] = 0x00;
			ones[i] = 0xFF;
			list[i] = 0;
		}
	}
	
	public function load(palette: SPUTMPalette)
	{
		var i: Int;
		var r: Int;
		var g: Int;
		var b: Int;
		
		palette.seek(0, SeekBegin);
		
		for (i in 0...256)
		{
			r = palette.readChar();
			g = palette.readChar();
			b = palette.readChar();
			
			list[i] = (r << 16) | (g << 8) | b;
			
			zeros[i] = 0x00;
			ones[i] = 0xFF;
		}
	}
	
	public function mapTo(bmap: BitmapData)
	{
		bmap.paletteMap(bmap, bmap.rect, NULL_POINT, zeros, zeros, list, null);
	}
}

class SPUTMSoundFactory extends SPUTMResourceFactory
{
	public function new()
	{
		super();
		
		name = "SOUND";
	}
}

class SPUTMCharsetFactory extends SPUTMResourceFactory
{
	public function new()
	{
		super();
		
		name = "CHARSET";
	}
}

enum SPUTMArrayType
{
	ARRAY_BIT;
	ARRAY_NIBBLE;
	ARRAY_BYTE;
	ARRAY_STRING;
	ARRAY_INT;
	ARRAY_DWORD;
	ARRAY_NUM;
}

class SPUTMArray
{
	public var atype: SPUTMArrayType;
	public var dim1: Int;
	public var dim2: Int;
	
	public var data: Array<Int>;

	static public function toArrayType(t: Int) : SPUTMArrayType
	{
		switch (t)
		{
			case 0:
				return ARRAY_BIT;
			case 1:
				return ARRAY_NIBBLE;
			case 2:
				return ARRAY_BYTE;
			case 3:
				return ARRAY_STRING;
			case 4:
				return ARRAY_INT;
			case 5:
				return ARRAY_DWORD;
			default:
				return ARRAY_NUM;
		}
	}

	public function new(type: SPUTMArrayType, x: Int, y: Int)
	{
		atype = type;
		dim1 = x;
		dim2 = y;
		
		data = new Array<Int>();
		data[(x*y)-1] = 0;
	}
	
	public function set(y: Int, x: Int, value: Int) : Void
	{
		var real_value = value;
		
		// Convert to proper representation
		switch (atype)
		{
			case ARRAY_BIT:
				real_value = real_value & 0x1;

			case ARRAY_NIBBLE:
				real_value = real_value & 0xF;

			case ARRAY_BYTE:
				real_value = real_value & 0xFF;

			case ARRAY_STRING:
				real_value = value;

			case ARRAY_INT:
				real_value = SCUMMThread.varIn(value);

			case ARRAY_DWORD:
				real_value = value;

			case ARRAY_NUM:
				real_value = value;
		}
		
		data[x + (dim2*y)] = real_value;
	}
	
	public function get(y: Int, x: Int) : Int
	{
		var real_value: Int = data[x + (dim2*y)];
		
		if (atype == ARRAY_INT)
			return SCUMMThread.varOut(real_value);
		else
			return real_value;		
	}
	
	public function toString() : String
	{
		var str: String = "";
		var d: Int;
		
		for (d in data)
		{
			if (d == 0)
				continue;
			
			str += String.fromCharCode(d);
		}
		
		return str;
	}
}

class SPUTMActor
{
	public var id: Int;
	
	public function new(num: Int)
	{
		id = num;
	}
}

enum SPUTMState
{
	SPUTM_ERROR;
	SPUTM_NONE;
	SPUTM_BOOT;
	SPUTM_BEGIN_CYCLE;
	//SPUTM_START_THREAD;
	SPUTM_START_SCRIPT;
	SPUTM_RUNNING;
	SPUTM_OPEN_ROOM;
	SPUTM_RUN_PRE_EXIT;
	SPUTM_RUN_EXCD;
	SPUTM_RUN_POST_EXIT;
	SPUTM_SETUP_ROOM;
	SPUTM_RUN_PRE_ENTRY;
	SPUTM_RUN_ENCD;
	SPUTM_RUN_POST_ENTRY;
	SPUTM_OK;
}

class SPUTM
{
	public static var instance: SPUTM = null;

	// Resource types
	public static inline var RES_SCRIPT: Int = 0;
	public static inline var RES_SOUND: Int = 1;
	public static inline var RES_COSTUME: Int = 2;
	public static inline var RES_ROOM: Int = 3;
	public static inline var RES_CHARSET: Int = 4;
	public static inline var RES_OBJECT: Int = 5;
	public static inline var RES_MAX: Int = 6;

	static private inline var BLANK_INDEX: Int = 0xff001f;

	// Engine variables
  // 000
	static public inline var VAR_KEYPRESS: Int = 0;
	static public inline var VAR_EGO: Int = 1;
	static public inline var VAR_CAMERA_POS_X: Int = 2;
	static public inline var VAR_HAVE_MSG: Int = 3;
	static public inline var VAR_ROOM: Int = 4;
	static public inline var VAR_OVERRIDE: Int = 5;
	static public inline var VAR_MACHINE_SPEED: Int = 6;
	static public inline var VAR_ME: Int = 7;
	static public inline var VAR_NUM_ACTOR: Int = 8;
	static public inline var VAR_SOUND_MODE: Int = 9;
  // 010
	static public inline var VAR_CURRENT_DRIVE: Int = 10;
	static public inline var VAR_TIMER1: Int = 11;
	static public inline var VAR_TIMER2: Int = 12;
	static public inline var VAR_TIMER3: Int = 13;
	static public inline var VAR_MUSIC_TIMER: Int = 14;
	static public inline var VAR_ACTOR_RANGE_MIN: Int = 15;
	static public inline var VAR_ACTOR_RANGE_MAX: Int = 16;
	static public inline var VAR_CAMERA_MIN_X: Int = 17;
	static public inline var VAR_CAMERA_MAX_X: Int = 18;
	static public inline var VAR_TIMER_NEXT: Int = 19;
  // 020
	static public inline var VAR_VIRTUAL_MOUSE_X: Int = 20;
	static public inline var VAR_VIRTUAL_MOUSE_Y: Int = 21;
	static public inline var VAR_ROOM_RESOURCE: Int = 22;
	static public inline var VAR_LAST_SOUND: Int = 23;
	static public inline var VAR_CUTSCENE_EXIT_KEY: Int = 24;
	static public inline var VAR_TALK_ACTOR: Int = 25;
	static public inline var VAR_CAMERA_FAST_X: Int = 26;
	static public inline var VAR_CAMERA_SCRIPT: Int = 27;
	static public inline var VAR_PRE_ENTRY_SCRIPT: Int = 28;
	static public inline var VAR_POST_ENTRY_SCRIPT: Int = 29;
  // 030
	static public inline var VAR_PRE_EXIT_SCRIPT: Int = 30;
	static public inline var VAR_POST_EXIT_SCRIPT: Int = 31;
	static public inline var VAR_VERB_SCRIPT: Int = 32;
	static public inline var VAR_SENTENCE_SCRIPT: Int = 33;
	static public inline var VAR_INVENTORY_SCRIPT: Int = 34;
	static public inline var VAR_CUTSCENE_START_SCRIPT: Int = 35;
	static public inline var VAR_CUTSCENE_END_SCRIPT: Int = 36;
	static public inline var VAR_CHARINC: Int = 37;
	static public inline var VAR_WALK_TO_OBJECT: Int = 38;
	static public inline var VAR_DEBUG_MODE: Int = 39;
  // 040
	static public inline var VAR_HEAP_SPACE: Int = 40;
	static public inline var VAR_ROOM_WIDTH: Int = 41;
	static public inline var VAR_RESTART_KEY: Int = 42;
	static public inline var VAR_PAUSE_KEY: Int = 43;
	static public inline var VAR_MOUSE_X: Int = 44;
	static public inline var VAR_MOUSE_Y: Int = 45;
	static public inline var VAR_TIMER: Int = 46;
	static public inline var VAR_TIMER4: Int = 47;
	static public inline var VAR_SOUNDCARD: Int = 48;
	static public inline var VAR_VIDEOMODE: Int = 49;
  // 050
	static public inline var VAR_MAINMENU_KEY: Int = 50;
	static public inline var VAR_FIXED_DISK: Int = 51;
	static public inline var VAR_CURSOR_STATE: Int = 52;
	static public inline var VAR_USERPUT: Int = 53;
	static public inline var VAR_ROOM_HEIGHT: Int = 54;
	static public inline var VAR_UNKNOWN1: Int = 55;
	static public inline var VAR_SOUND_RESULT: Int = 56;
	static public inline var VAR_TALK_STOP_KEY: Int = 57;
	static public inline var VAR_UNKNOWN2: Int = 58;
	static public inline var VAR_FADE_DELAY: Int = 59;
  // 060
	static public inline var VAR_NO_SUBTITLES: Int = 60;
	static public inline var VAR_GUI_ENTRY_SCRIPT: Int = 61;
	static public inline var VAR_GUI_EXIT_SCRIPT: Int = 62;
	static public inline var VAR_UNKNOWN3: Int = 63;
	static public inline var VAR_SOUND_PARAM0: Int = 64;
	static public inline var VAR_SOUND_PARAM1: Int = 65;
	static public inline var VAR_SOUND_PARAM2: Int = 66;
	static public inline var VAR_INPUT_MODE: Int = 67;
	static public inline var VAR_MEMORY_PERFORMANCE: Int = 68;
	static public inline var VAR_VIDEO_PERFORMANCE: Int = 69;
  // 070
	static public inline var VAR_ROOM_FLAG: Int = 70;
	static public inline var VAR_GAME_LOADED: Int = 71;
	static public inline var VAR_NEW_ROOM: Int = 72;
	static public inline var VAR_UNKNOWN4: Int = 73;
	static public inline var VAR_LEFT_BUTTON_HOLD: Int = 74;
	static public inline var VAR_RIGHT_BUTTON_HOLD: Int = 75;
	static public inline var VAR_EMS_SPACE: Int = 76;
	static public inline var VAR_UNKNOWN50: Int = 77;
	static public inline var VAR_UNKNOWN51: Int = 78;
	static public inline var VAR_UNKNOWN52: Int = 79;
	static public inline var VAR_UNKNOWN53: Int = 80;
	static public inline var VAR_UNKNOWN54: Int = 81;
	static public inline var VAR_UNKNOWN55: Int = 82;
	static public inline var VAR_UNKNOWN56: Int = 83;
	static public inline var VAR_UNKNOWN57: Int = 84;
	static public inline var VAR_UNKNOWN58: Int = 85;
	static public inline var VAR_UNKNOWN59: Int = 86;
	static public inline var VAR_UNKNOWN510: Int = 87;
	static public inline var VAR_UNKNOWN511: Int = 88;
	static public inline var VAR_UNKNOWN512: Int = 89;
  // 090
	static public inline var VAR_GAME_DISK_MSG: Int = 90;
	static public inline var VAR_OPEN_FAILED_MSG: Int = 91;
	static public inline var VAR_READ_ERROR_MSG: Int = 92;
	static public inline var VAR_PAUSE_MSG: Int = 93;
	static public inline var VAR_RESTART_MSG: Int = 94;
	static public inline var VAR_QUIT_MSG: Int = 95;
	static public inline var VAR_SAVE_BUTTON: Int = 96;
	static public inline var VAR_LOAD_BUTTON: Int = 97;
	static public inline var VAR_PLAY_BUTTON: Int = 98;
	static public inline var VAR_CANCEL_BUTTON: Int = 99;
  // 100
	static public inline var VAR_QUIT_BUTTON: Int = 100;
	static public inline var VAR_OK_BUTTON: Int = 101;
	static public inline var VAR_SAVE_DISK_MSG: Int = 102;
	static public inline var VAR_ENTER_NAME_MSG: Int = 103;
	static public inline var VAR_NOT_SAVED_MSG: Int = 104;
	static public inline var VAR_NOT_LOADED_MSG: Int = 105;
	static public inline var VAR_SAVE_MSG: Int = 106;
	static public inline var VAR_LOAD_MSG: Int = 107;
	static public inline var VAR_SAVE_MENU_TITLE: Int = 108;
	static public inline var VAR_LOAD_MENU_TITLE: Int = 109;
  // 110
	static public inline var VAR_GUI_COLORS: Int = 110;
	static public inline var VAR_DEBUG_PASSWORD: Int = 111;
	static public inline var VAR_UNKNOWN60: Int = 112;
	static public inline var VAR_UNKNOWN61: Int = 113;
	static public inline var VAR_UNKNOWN62: Int = 114;
	static public inline var VAR_UNKNOWN63: Int = 115;
	static public inline var VAR_UNKNOWN64: Int = 116;
	static public inline var VAR_MAIN_MENU_TITLE: Int = 117;
	static public inline var VAR_RANDOM_NUM: Int = 118;
	static public inline var VAR_TIMEDATE_YEAR: Int = 119;
  // 120
	static public inline var VAR_UNKNOWN70: Int = 120;
	static public inline var VAR_UNKNOWN71: Int = 121;
	static public inline var VAR_GAME_VERSION: Int = 122;
	static public inline var VAR_CHARSET_MASK: Int = 123;
	static public inline var VAR_UNKNOWN8: Int = 124;
	static public inline var VAR_TIMEDATE_HOUR: Int = 125;
	static public inline var VAR_TIMEDATE_MINUTE: Int = 126;
	static public inline var VAR_UNKNOWN9: Int = 127;
	static public inline var VAR_TIMEDATE_DAY: Int = 128;
	static public inline var VAR_TIMEDATE_MONTH: Int = 129;
		
	// Memory
	private var vm_vars: Array<Int>;
	private var num_bitvars: Int;
	private var vm_bitvars: Array<Int32>;
	public var vm_array: Array<SPUTMArray>;
	private var vm_actors: Array<SPUTMActor>;
	private var vm_room: SPUTMRoom;
	public var vm_next_room: SPUTMRoom;
	
	private var view_room_start: Int;
	private var view_room_end: Int;
	private var view_camera_x: Int;
	
	private var vm_num_localobject: Int;

	public var vm_res: Array<SPUTMResourceList>;

	public var vm_files: Array<ResourceIO>;
	
	public var vm_current_actor: SPUTMActor;
	
	// Time keeping
	static var UPDATE_INTERVAL: Int = 10;
	var time: Timer;
	var lastTime: Float;
	var curTime: Float;
	static var inTick: Bool = false;
	
	// Display
	static var VIEW_PALETTE_CHANGED: Int = 0x1;
	var view_flags: Int;
	
	public var view: Bitmap;
	private var view_data: BitmapData;
	private var view_width: Int;
	private var view_height: Int;
	
	private var view_palette: SPUTMDisplayPalette;
	
	public function new(resources: Array<ResourceIO>)
	{
	   instance = this;
		
		// Read index
		var index: ChunkReader = new ChunkReader(resources[0]);
		var reader: ResourceIO = resources[0];
		var size: Int = 0;
		var i: Int;

		vm_files = resources;
		view_flags = 0;
		view = new Bitmap();
		view_palette = new SPUTMDisplayPalette();
		setSize(320,200);
		
		vm_next_room = null;
		
		//random.setSeed(Std.int(flash.lib.getTimer()));
		
		SCUMMThread.optable = SCUMM6.optable;
		SCUMMThread.suboptable = SCUMM6.suboptable;
		
		while (index.nextChunk())
		{
			switch(SPUTMResourceChunk.identify(index.chunkID))
			{
				case CHUNK_RNAM:
					//trace("Room Names");
				case CHUNK_MAXS:
					//trace("Maximum Values");

					// Number of vars
					size = reader.readUInt16();
					vm_vars = new Array<Int>();
					vm_vars[size-1] = 0;
					for (i in 0...vm_vars.length)
					{
						vm_vars[i] = 0;
					}
					initVars();

					// Unknown
					reader.readUInt16();

					// Bit vars
					//size = Int32.toInt(Int32.and(Int32.ofInt(reader.readUInt16()+7),
					//                   Int32.complement(Int32.ofInt(7))
					//                  ));
					                  
					size = (reader.readUInt16()+31) & -32; // ~31
					
					num_bitvars = size;
					vm_bitvars = new Array<Int32>();
					vm_bitvars[(size>>5)-1] = Int32.ofInt(0);
					for (i in 0...size>>5)
					{
						vm_bitvars[i] = Int32.ofInt(0);
					}

					// Local objects
					vm_num_localobject = reader.readUInt16();

					// Arrays
					size = reader.readUInt16();
					vm_array = new Array<SPUTMArray>();
					vm_array[size-1] = null;

					// Unknown
					reader.readUInt16();

					// Verbs
					size = reader.readUInt16();

					// FL Objects
					size = reader.readUInt16();

					// Inventory
					size = reader.readUInt16();

					vm_res = new Array<SPUTMResourceList>();

					// Rooms
					vm_res[RES_ROOM] = new SPUTMResourceList(reader.readUInt16(), new SPUTMRoomFactory());

					// Scripts
					vm_res[RES_SCRIPT] = new SPUTMResourceList(reader.readUInt16(), new SCUMMScriptFactory());
					
					// Sounds
					vm_res[RES_SOUND] = new SPUTMResourceList(reader.readUInt16(), new SPUTMSoundFactory());

					// Charsets
					vm_res[RES_CHARSET] = new SPUTMResourceList(reader.readUInt16(), new SPUTMCharsetFactory());

					// Costumes
					vm_res[RES_COSTUME] = new SPUTMResourceList(reader.readUInt16(), new SPUTMCostumeFactory());

					// Objects
					vm_res[RES_OBJECT] = new SPUTMResourceList(reader.readUInt16(), null);
					
					//trace("done lists");
				case CHUNK_DROO:
					//trace("Room objects index");

					var rooms: Array<SPUTMResource> = vm_res[RES_ROOM].res;
					var nfiles = 0;
					size = reader.readUInt16();
					
					if (size != rooms.length)
					{
						trace("Invalid room index block! ( " + size + ", act " + rooms.length + ")");
						return;
					}
					
					//trace("There are " + size + " rooms.");

					for (i in 0...size)
					{
						var res: SPUTMResource = new SPUTMResource();
						rooms[i] = res;
						res.file = reader.readChar();
						res.room = i;
						nfiles = res.file > nfiles ? res.file : nfiles;
						//trace(i + " @ file " + res.file);
					}

					if (nfiles > vm_files.length)
					{
						trace("Warning: files missing! (" + nfiles + " referenced, " + vm_files.length + " avail)");
					}

					//trace("Loading " + vm_files.length + " files");
					
					for (i in 0...size)
					{
						rooms[i].offset = reader.readUInt32();
					}

					// Read LOFF in resource files
					for (i in 1...vm_files.length)
					{
						//trace("Loading offsets [" + i + "]");
						loadResourceOffsets(resources[i]);
					}
					
				case CHUNK_DSCR:
					//trace("Scripts");
					vm_res[RES_SCRIPT].loadResourceIndexes(reader);
				case CHUNK_DSOU:
					//trace("Sounds");
					vm_res[RES_SOUND].loadResourceIndexes(reader);
				case CHUNK_DCOS:
					//trace("Costumes");
					vm_res[RES_COSTUME].loadResourceIndexes(reader);
				case CHUNK_DCHR:
					//trace("Characters");
					vm_res[RES_CHARSET].loadResourceIndexes(reader);
				case CHUNK_DOBJ:
					//trace("Objects");
					vm_res[RES_OBJECT].loadResourceIndexesAlt(reader);
				case CHUNK_AARY:
					//trace("Arrays");
					// Pre-init arrays

					size = reader.readUInt16();
					while (size != 0)
					{
						var dim1: Int = reader.readUInt16();
						var dim2: Int = reader.readUInt16();
						var atype: SPUTMArrayType = SPUTMArray.toArrayType(reader.readUInt16());
						writeVar(size, defineArray(atype, dim1, dim2), null);
					}
				default:
					trace("INVALID CHUNK!");
			}
		}

		// Init actors
		vm_actors = new Array<SPUTMActor>();
		vm_actors[15] = null;
		for (i in 0...16)
		{
			vm_actors[i] = new SPUTMActor(i);
		}
		vm_current_actor = null;

		// Init script
		SCUMMThread.init(vm_res[RES_SCRIPT]);
	}
	
	public function setSize(width: Int, height: Int)
	{
		view_width = width;
		view_height = height;
		
		view_data = new BitmapData(view_width, view_height, false, 0xffff00ff);
		view.bitmapData = view_data;
	}

	private function loadResourceOffsets(reader: ResourceIO)
	{
		var resource: ChunkReader = new ChunkReader(reader);
		resource.nextChunk();
		if (SPUTMResourceChunk.identify(resource.chunkID) != CHUNK_LECF)
		{
			trace("Invalid resource file (got " + resource.chunkName() + ")");
			return false;
		}
		resource.reset();

		resource.nextChunk();
		if (SPUTMResourceChunk.identify(resource.chunkID) != CHUNK_LOFF)
		{
			trace("Invalid resource file (got " + resource.chunkName() + ")");
			return false;
		}

		var rooms = vm_res[RES_ROOM].res;
		var i: Int;
		var num = reader.readChar();
		for (i in 0...num)
		{
			var room_no = reader.readChar();
			if (room_no > rooms.length)
			{
				trace("Bad room number? (" + room_no + ")");
				return false;
			}
			rooms[room_no].offset = reader.readUInt32();
		}
		
		//trace("Loaded " + num + " room offsets");

		return true;
	}

	private function getFreeArrayId() : Int
	{
		var i: Int;
		for ( i in 1...vm_array.length )
		{
			if (vm_array[i] == null)
				return i;
		}

		return -1;
	}

	public function defineArray(type: SPUTMArrayType, dim1: Int, dim2: Int) : Int
	{
		var id = getFreeArrayId();
		if ( id == -1 )
			return -1;

		vm_array[id] = new SPUTMArray(type, dim1, dim2);
		//trace("DEFINED ARRAY " + id);

		return id;
	}
	
	public function readArray(idx: Int, y: Int, x: Int) : Int
	{
		var array: SPUTMArray = vm_array[idx];
		return array.get(y, x);
	}
	
	public function writeArray(idx: Int, y: Int, x: Int, value: Int) : Void
	{
		var array: SPUTMArray = vm_array[idx];
		var real_value: Int;
		
		array.set(y, x, value);
	}

	public function nukeArray(idx: Int)
	{
		vm_array[idx] = null;
	}

	private function initVars()
	{
  // soundcard: 0 = none
  //            1 = pc speaker
  //            3 = adlib
		vm_vars[VAR_SOUNDCARD] = 0;
  // video mode: 4  = CGA
  //             13 = EGA
  //             19 = VGA?
  //             30 = Hercule
  //             42 = FMTowns
  //             50 = MAC
  //             82 = Amiga
		vm_vars[VAR_VIDEOMODE] = 19;
		vm_vars[VAR_HEAP_SPACE] = 1400; // heap size
		vm_vars[VAR_FIXED_DISK] = 1; // playing from HD
  // Input mode: 0 = keyboard
  //             1 = joystick
  //             3 = mouse
		vm_vars[VAR_INPUT_MODE] = 3;
		vm_vars[VAR_EMS_SPACE] = 10000; // EMS size
		vm_vars[VAR_ROOM_WIDTH] = 320;
		vm_vars[VAR_ROOM_HEIGHT] = 200;
		vm_vars[VAR_CHARINC] = 4; // Subtitle speed
	}
	
	public function readVar(addr: Int, thread: SCUMMThread) : Int
	{
		//trace("readVar @ " + addr);
		
		var idx: Int;
		
		// Decode the address
		
		if ((addr & 0x8000) > 0) // bit var
		{
			idx = addr & 0x7FFF;
			if (idx >= num_bitvars)
			{
				trace("Invalid bit var " + idx);
				thread.return_state = SPUTM_ERROR;
				return 0;
			}
			
			return Int32.toInt(
				Int32.and(Int32.shr(vm_bitvars[idx>>5], idx&31), Int32.ofInt(1))
			);
		}
		else if ((addr & 0x4000) > 0) // local var
		{
			idx = addr & 0x3FFF;
			if (thread == null || idx >= thread.vars.length)
			{
				trace("Invalid local var " + idx);
				thread.return_state = SPUTM_ERROR;
				return 0;
			}
			
			return SCUMMThread.varOut(thread.vars[idx]);
		}
		else // global var
		{
			idx = addr & 0x3FFF;
			if (addr >= vm_vars.length)
			{
				trace("Invalid global var " + idx);
				thread.return_state = SPUTM_ERROR;
				return 0;
			}
			
			// NOTE: scvm seems to allow for idx < 0x100 vars to be dynamically
			// grabbed via function pointers.
			return SCUMMThread.varOut(vm_vars[idx]);
		}
	}
	
	public function writeVar(addr: Int, value: Int, thread: SCUMMThread)
	{
		//trace("writeVar @ " + addr);
		var idx: Int;
		
		// Decode the address
		
		if ((addr & 0x8000) > 0) // bit var
		{
			idx = addr & 0x7FFF;
			if (idx > num_bitvars)
			{
				trace("Invalid bit var " + idx);
				thread.return_state = SPUTM_ERROR;
				return;
			}
			
			//vm_bitvars[idx>>5] &= ~(1 << (idx & 31)); // clear
			//vm_bitvars[idx>>5] |= (value & 1) << (idx & 31); // set new
			
			vm_bitvars[idx>>5] = Int32.and(vm_bitvars[idx>>5], 
			                                    Int32.complement(
			                                      Int32.shl(Int32.ofInt(1), idx & 31)
			                                    )); // clear
			vm_bitvars[idx>>5] = Int32.or(vm_bitvars[idx>>5], 
			                                   Int32.ofInt((value & 1) << (idx & 31))
			                                   ); // set new
		}
		else if ((addr & 0x4000) > 0) // local var
		{
			idx = addr & 0x3FFF;
			if (thread == null || idx >= thread.vars.length)
			{
				trace("Invalid local var " + idx);
				thread.return_state = SPUTM_ERROR;
				return;
			}
			
			thread.vars[idx] = SCUMMThread.varIn(value);
		}
		else // global var
		{
			idx = addr & 0x3FFF;
			if (addr >= vm_vars.length)
			{
				trace("Invalid global var " + idx);
				thread.return_state = SPUTM_ERROR;
				return;
			}
			
			// NOTE: scvm seems to allow for idx < 0x100 vars to be dynamically
			// grabbed via function pointers.
			vm_vars[idx] = SCUMMThread.varIn(value);
		}
	}
	
	public function setVar(addr: Int, value: Int)
	{
		vm_vars[addr] = SCUMMThread.varIn(value);
	}
	
	public function getVar(addr: Int) : Int
	{
		return SCUMMThread.varOut(vm_vars[addr]);
	}
	
	public function incVar(addr: Int, value: Int) : Void
	{
		vm_vars[addr] = SCUMMThread.varIn(SCUMMThread.varOut(vm_vars[addr]) + value);
	}
	
	public function getActor(idx: Int) : SPUTMActor
	{
		if (idx < vm_actors.length)
			return vm_actors[idx];
		
		return null;
	}
	
	public function getRoomScript(num: Int)
	{
		if (vm_room == null || (num-200 >= vm_room.scripts.length))
			return null;
		
		return vm_room.scripts[num-200];
	}
	
	public function handleState(state: SPUTMState) : SPUTMState
	{
		var r: Int;
		
		switch (state)
		{
			case SPUTM_OPEN_ROOM:
				vm_vars[VAR_NEW_ROOM] = vm_next_room.id;
				return SPUTM_RUN_PRE_EXIT;
			
			case SPUTM_RUN_PRE_EXIT:
				if (vm_vars[VAR_PRE_EXIT_SCRIPT] != 0)
				{
					r = SCUMMThread.startScript(0, vm_vars[VAR_PRE_EXIT_SCRIPT], null);
					if (r < 0)
					{
						trace("Failed to start pre-exit script!");
						return SPUTM_ERROR;
					}
					
					SCUMMThread.switchToThread(r, SPUTM_RUN_EXCD);
					return SPUTM_RUNNING;
				}
				
				return SPUTM_RUN_EXCD;
				
			case SPUTM_RUN_EXCD:
			
				if (vm_room != null && vm_room.exit != null)
				{
					r = SCUMMThread.startThread(vm_room.exit, 0, 0, null);
					if (r < 0)
					{
						trace("Failed to start room exit script!");
						return SPUTM_ERROR;
					}
					
					SCUMMThread.switchToThread(r, SPUTM_RUN_POST_EXIT);
					return SPUTM_RUNNING;
				}
					
				return SPUTM_RUN_POST_EXIT;
				
			case SPUTM_RUN_POST_EXIT:
				
				if (vm_vars[VAR_POST_EXIT_SCRIPT] != 0)
				{
					r = SCUMMThread.startScript(0, vm_vars[VAR_POST_EXIT_SCRIPT], null);
					if (r < 0)
					{
						trace("Failed to start post-exit script!");
						return SPUTM_ERROR;
					}
					
					SCUMMThread.switchToThread(r, SPUTM_SETUP_ROOM);
					return SPUTM_RUNNING;
				}
				
				return SPUTM_SETUP_ROOM;
				
			case SPUTM_SETUP_ROOM:
					
				if (vm_next_room == null)
				{
					return SPUTM_RUNNING;
				}
				else
				{
					var room: SPUTMRoom = vm_next_room;
						
					if (room == null)
					{
						trace("Invalid room or room isn't loaded!");
						return SPUTM_ERROR;
					}
						
					if (room.palettes.length > 0)
					{
						room.current_palette = room.palettes[0];
						view_palette.load(room.current_palette);
						view_flags |= VIEW_PALETTE_CHANGED;
					}
						
					vm_vars[VAR_CAMERA_MIN_X] = Std.int(view_width / 2);
					vm_vars[VAR_CAMERA_MAX_X] = SCUMMThread.varIn(room.width - vm_vars[VAR_CAMERA_MIN_X]);
						
					vm_vars[VAR_ROOM] = room.id;
						
					vm_room = room;
				}
				
				return SPUTM_RUN_PRE_ENTRY;
				
			case SPUTM_RUN_PRE_ENTRY:
				if (vm_vars[VAR_PRE_ENTRY_SCRIPT] != 0)
				{
					r = SCUMMThread.startScript(0, vm_vars[VAR_PRE_ENTRY_SCRIPT], null);
					if (r < 0)
					{
						trace("Failed to start pre-entry script!");
						return SPUTM_ERROR;
					}
					
					SCUMMThread.switchToThread(r, SPUTM_RUN_ENCD);
					return SPUTM_RUNNING;
				}
					
				return SPUTM_RUN_ENCD;
					
			case SPUTM_RUN_ENCD:
				if (vm_room.entry != null)
				{
					trace("RUNNING ENTRY");
					r = SCUMMThread.startThread(vm_room.entry, 0, 0, null);
					if (r < 0)
					{
						trace("Failed to start room entry script!");
						return SPUTM_ERROR;
					}
					
					SCUMMThread.switchToThread(r, SPUTM_RUN_POST_ENTRY);
					return SPUTM_RUNNING;
				}
					
				return SPUTM_RUN_POST_ENTRY;
					
			case SPUTM_RUN_POST_ENTRY:
				if (vm_vars[VAR_POST_ENTRY_SCRIPT] != 0)
				{
					r = SCUMMThread.startScript(0, vm_vars[VAR_POST_ENTRY_SCRIPT], null);
					if (r < 0)
					{
						trace("Failed to start post-entry script!");
						return SPUTM_ERROR;
					}
						
					SCUMMThread.switchToThread(r, SPUTM_RUNNING);
				}
					
				return SPUTM_RUNNING;
			
			default:
				return SPUTM_ERROR;
		}
	}
	
	public function getTimer() : Float
	{
		#if flash9
		return flash.Lib.getTimer();
		#else true
		return Timer.stamp() * 1000;
		#end
	}
	
	public function run()
	{
		lastTime = getTimer();
		#if flash9
		time = new Timer(UPDATE_INTERVAL);
		time.addEventListener(TimerEvent.TIMER, onTime);
		time.start();
		#else !neko
		time = new Timer(UPDATE_INTERVAL);
		time.run = function() { SPUTM.instance.onTime(); }
		#else true
		while (true)
		{
			onTime();
			neko.Sys.sleep(0.01);
		}
		#end
	}
	
	public function stop()
	{
		#if neko
		neko.Sys.exit(0);
		#else true
		time.stop();
		#end
	}
	
	#if flash9
	public function onTime(evt: TimerEvent)
	{
		//trace("Update!");
		curTime = getTimer();
		onTick(curTime - lastTime);
		lastTime = curTime;
	}
	#else !flash9
	public function onTime()
	{
		//trace("Update!");
		curTime = Timer.stamp();
		onTick(curTime - lastTime);
		lastTime = curTime;
	}
	
	#end
	
	public function onTick(ms: Float)
	{
		// TODO
		
		try
		{
			var r: Int = SCUMMThread.processThreads(1, curTime);
			if (r < 0)
			{
				trace("Script error!");
				stop();
				return;
			}
		}
		catch ( unknown: Dynamic ) 
		{
			trace("Internal exception, aborting! (state=" + SCUMMThread.vm_state + ")");
			trace(unknown);
			stop();
		}
		
		processPalette();
		
		if (view_flags & VIEW_PALETTE_CHANGED > 0)
		{
			updatePalette();
			#if flash9
			view_flags &= ~VIEW_PALETTE_CHANGED;
			#else js
			view_flags &= ~VIEW_PALETTE_CHANGED;
			#else neko
			view_flags = Int32.toInt(
			                              Int32.and(Int32.ofInt(view_flags),
			                              Int32.complement(Int32.ofInt(VIEW_PALETTE_CHANGED))
			                              ));
			#end
		}
		
		draw();
		
		updateActors();
		
		flip();
	}
	
	public function initScreens(start: Int, end: Int)
	{
		view_room_start = start;
		view_room_end = end;
	}
	
	public function setNextRoom(idx: Int) : Bool
	{
		var room: SPUTMRoom = vm_res[RES_ROOM].res[idx].instance;
		
		if (room != null)
		{
			vm_next_room = room;
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public function processPalette()
	{
		// cycle palette colours
	}
	
	public function updatePalette()
	{
		// shouldn't be needed?
	}
	
	public function draw()
	{
		var sx: Int;
		var dx: Int;
		var w: Int;
		var h: Int;
		var x: Int;
		var y: Int;
		var a: Int;
		
		if (view_palette == null)
			return;
			
		// Update camera position
		view_camera_x = SCUMMThread.varIn(vm_vars[VAR_CAMERA_POS_X]);
		if (view_camera_x > SCUMMThread.varIn(vm_vars[VAR_CAMERA_MAX_X]))
			view_camera_x = SCUMMThread.varIn(vm_vars[VAR_CAMERA_MAX_X]);
		if (view_camera_x > SCUMMThread.varIn(vm_vars[VAR_CAMERA_MIN_X]))
			view_camera_x = SCUMMThread.varIn(vm_vars[VAR_CAMERA_MIN_X]);
		
		//trace(view_room_start + "," + view_room_end);
		
		if (view_width < 320 || view_height < 200 || vm_room == null)
			return;
		
		h = vm_room.height;
		if (view_room_start + h != view_room_end)
			trace("View setup doesn't match the room height!");
		
		if (view_room_start + h > view_height)
			h = view_height - view_room_start;
		
		if (h <= 0)
			return;
		
		w = vm_room.width;
		if (w > view_width)
			w = view_width;
		
		sx = Std.int(view_camera_x - w / 2);
		if (sx + w / 2 > vm_room.width)
			sx = vm_room.width - w;
		if (sx < 0)
			sx = 0;
		
		dx = Std.int((view_width - w) / 2);
           
		view_data.lock();
		view_data.fillRect(view_data.rect, 0xff000000 | BLANK_INDEX);
		
		var srect: Rectangle = new Rectangle(sx,
                                           0,
                                           w,
                                           h);
		var dpoint: Point = new Point(dx,
                                    view_room_start);
                                                          
		view_data.copyPixels(vm_room.image.data, srect, dpoint, null,  SPUTMDisplayPalette.NULL_POINT, false);
		
		view_palette.mapTo(view_data); // Convert to RGB
		view_data.unlock();
	}
	
	public function updateActors()
	{
	}
	
	public function flip()
	{
	}
}
