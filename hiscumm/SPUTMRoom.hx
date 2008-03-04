package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban Bedel
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import hiscumm.Common;

import hiscumm.SCUMM;
import hiscumm.SPUTM;

import hiscumm.SPUTMResource;

/*
	SPUTMRoom
	
	This collection of classes handles the loading and processing of rooms.
*/

class SPUTMRoom
{
	static public var RMHD: Int = 0x524D4844;
	static public var CYCL: Int = 0x4359434C;
	static public var TRNS: Int = 0x54524E53;
	static public var PALS: Int = 0x50414C53;
	static public var RMIM: Int = 0x524D494D;
	static public var OBIM: Int = 0x4F42494D;
	static public var OBCD: Int = 0x4F424344;
	static public var EXCD: Int = 0x45584344;
	static public var ENCD: Int = 0x454E4344;
	static public var NLSC: Int = 0x4E4C5343;
	static public var LSCR: Int = 0x4C534352;
	static public var BOXD: Int = 0x424F5844;
	static public var BOXM: Int = 0x424F584D;
	static public var SCAL: Int = 0x5343414C;
	static public var IM00: Int = 0x494D3030;
	
	static public var WRAP: Int = 0x57524150;
	static public var OFFS: Int = 0x4F464653;
	static public var APAL: Int = 0x4150414C;
	
	public var id: Int;
	public var scripts: Array<SCUMMScript>;
	public var objects: Array<Dynamic>;
	public var palettes: Array<SPUTMPalette>;
	
	public var entry: SCUMMScript;
	public var exit: SCUMMScript;
	
	public var current_palette: SPUTMPalette;
	
	public var width: Int;
	public var height: Int;
	public var num_zplane: Int;
	public var image: SPUTMImage;
	
	public function new(num: Int)
	{
		id = num;
		scripts = new Array<SCUMMScript>();
		objects = new Array<Dynamic>();
		palettes = new Array<SPUTMPalette>();
		image = null;
		
		entry = null;
		exit = null;
		
		current_palette = null;
	}
}

class SPUTMRoomFactory extends SPUTMResourceFactory
{	
	public function new()
	{
		super();
		
		name = "ROOM";
	}

	public function load(idx: Int, reader: ByteArray) : Dynamic
	{
		// Need to load the bytecode from the offset
		
		reader.endian = "bigEndian";
		var chunkID: Int = reader.readUnsignedInt();
		var chunkSize: Int = reader.readUnsignedInt();
		reader.endian = "littleEndian";
		
		if (chunkID != SPUTM.ROOM)
		{
			trace("Bad room block (" + chunkID + ", " + String.fromCharCode(chunkID >> 24) +
		       String.fromCharCode((chunkID >> 16) & 0xFF) +
		       String.fromCharCode((chunkID >> 8) & 0xFF) +
		       String.fromCharCode(chunkID & 0xFF) + " )");
			return null;
		}
		
		var room: SPUTMRoom = new SPUTMRoom(idx);
		var croom: ChunkReader = new ChunkReader(reader, reader.position + chunkSize - 8);
		var num: Int;
		var num_lscr: Int = 0;
		var i: Int;
		var base_ptr: Int;
		var num_pal: Int;
		croom.chunkOffs = reader.position;
		
		while (croom.nextChunk())
		{
			switch (croom.chunkID)
			{
				case SPUTMRoom.RMHD:
					//trace("RMHD == " + croom.chunkName());
					room.width = reader.readShort();
					room.height = reader.readShort();
					num = reader.readShort();
					if (num > 0)
						room.objects[num-1] = null;
				case SPUTMRoom.CYCL:
					//trace("CYCL == " + croom.chunkName());
				case SPUTMRoom.TRNS:
					//trace("TRNS == " + croom.chunkName());
				case SPUTMRoom.PALS:
					//trace("PALS == " + croom.chunkName());

					reader.endian = "bigEndian";
					chunkID = reader.readUnsignedInt();
					chunkSize = reader.readUnsignedInt();
					
					if (chunkID != SPUTMRoom.WRAP)
					{
						trace("Bad room WRAP block " + chunkID);
						reader.endian = "littleEndian";
						return null;
					}
					
					chunkID = reader.readUnsignedInt();
					chunkSize = reader.readUnsignedInt();
					reader.endian = "littleEndian";
					
					if (chunkID != SPUTMRoom.OFFS)
					{
						trace("Bad room OFFS block " + chunkID);
						return null;
					}
					
					// Now we can load in the palette!
					base_ptr = reader.position-8;
					num_pal = Math.round((chunkSize - 8) / 4);
					
					var offset: Array<Int> = new Array<Int>();
					if (num_pal > 0)
					{
						offset[num_pal-1] = 0;
						for (i in 0...num_pal)
						{
							offset[i] = base_ptr + reader.readUnsignedInt();
						}
						
						reader.endian = "bigEndian";
						
						room.palettes[num_pal - 1] = null;
						for (i in 0...num_pal)
						{
							reader.position = offset[i];
							
							chunkID = reader.readUnsignedInt();
							chunkSize = reader.readUnsignedInt();
							
							if (chunkID != SPUTMRoom.APAL)
							{
								trace("Bad room APAL block " + chunkID);
								reader.endian = "littleEndian";
								return null;
							}
							
							room.palettes[i] = new SPUTMPalette(reader);
						}
						
						reader.endian = "littleEndian";
					}
      
				case SPUTMRoom.RMIM:
					trace("RMIM == " + croom.chunkName());
					
					reader.endian = "bigEndian";
					chunkID = reader.readUnsignedInt();
					chunkSize = reader.readUnsignedInt();
					reader.endian = "littleEndian";
					
					room.num_zplane = reader.readUnsignedShort();
					
					reader.endian = "bigEndian";
					chunkID = reader.readUnsignedInt();
					chunkSize = reader.readUnsignedInt();
					reader.endian = "littleEndian";
					
					if (chunkID != SPUTMRoom.IM00)
					{
						trace("Bad room image block " + chunkID);
						return null;
					}
					
					room.image = new SPUTMImage(room.width, room.height, room.num_zplane);
					if (!(room.image.load(reader)))
					{
						trace("Problem loading room image!");
						room.image = null;
						return null;
					}
					
					trace("Room image appears to have loaded!");
				case SPUTMRoom.OBIM:
					//trace("OBIM == " + croom.chunkName());
					
					// Object images
				case SPUTMRoom.OBCD:
					//trace("OBCD == " + croom.chunkName());
					
					// Object verb info, etc
				case SPUTMRoom.EXCD:
					//trace("EXCD == " + croom.chunkName());
					
					var script: SCUMMScript = new SCUMMScript(0x1ECD0000);
					script.code = new ByteArray();
					script.code.endian = "littleEndian";
					script.code.length = croom.chunkSize - 8;
					
					reader.readBytes(script.code, 0, script.code.length);
					
					room.exit = script;
				case SPUTMRoom.ENCD:
					//trace("ENCD == " + croom.chunkName());
					
					var script: SCUMMScript = new SCUMMScript(0x0ECD0000);
					script.code = new ByteArray();
					script.code.endian = "littleEndian";
					script.code.length = croom.chunkSize - 8; 
					
					reader.readBytes(script.code, 0, script.code.length);
					
					room.entry = script;
				case SPUTMRoom.NLSC:
					//trace("NLSC == " + croom.chunkName());
					num = reader.readShort();
					if (num > 0)
						room.scripts[num-1] = null;
				case SPUTMRoom.LSCR:
					//trace("LSCR == " + croom.chunkName());
					
					if (num_lscr >= room.scripts.length)
					{
						trace("Too many local scripts in room!");
						return null;
					}
					
					i = reader.readUnsignedByte();
					if (i < 200 || i-200 >= room.scripts.length)
					{
						trace("Invalid script id " + i);
						return null;
					}
					
					var script: SCUMMScript = new SCUMMScript(i+200);
					script.code = new ByteArray();
					script.code.endian = "littleEndian";
					script.code.length = croom.chunkSize - 9;
					
					trace("Read local script " + i); 
					
					reader.readBytes(script.code, 0, script.code.length);
					
					room.scripts[i] = script;
					num_lscr++;
				case SPUTMRoom.BOXD:
					//trace("BOXD == " + croom.chunkName());
				case SPUTMRoom.BOXM:
					//trace("BOXM == " + croom.chunkName());
				case SPUTMRoom.SCAL:
					//trace("SCAL == " + croom.chunkName());
				default:
					trace("Room chunk " + croom.chunkName() + " (" + croom.chunkID + ")");
			}
		}
		
		//trace("ROOM NOT LOADED");
		//return null;
		
		return room;
		
/*		
  uint32_t type,size,block_size,sub_block_size;
  unsigned len = 8,num_obim = 0, num_obcd = 0, num_lscr = 0;
  int i;
  scvm_room_t* room;
  off_t next_block;
  scvm_object_t *objlist[vm->num_local_object],*obj;

  memset(objlist,0,sizeof(scvm_object_t*)*vm->num_local_object);
  
  type = scc_fd_r32(fd);
  size = scc_fd_r32be(fd);
  if(type != MKID('R','O','O','M') || size < 16) {
    scc_log(LOG_ERR,"Bad ROOM block %d: %c%c%c%c %d\n",num,
            UNMKID(type),size);
    return NULL;
  }
  room = calloc(1,sizeof(scvm_room_t));
  room->id = num;
  while(len < size) {
    type = scc_fd_r32(fd);
    block_size = scc_fd_r32be(fd);
    next_block = scc_fd_pos(fd)-8+block_size;
    len += block_size;
    switch(type) {
    case MKID('C','Y','C','L'):
      if(block_size < 1+8) goto bad_block;
      room->num_cycle = 17;
      room->cycle = calloc(room->num_cycle,sizeof(scvm_cycle_t));
      while(1) {
        unsigned freq,id = scc_fd_r8(fd);
        if(!id) break;
        if(id >= room->num_cycle) goto bad_block;
        room->cycle[id].id = id;
        scc_fd_r16(fd); // unknown
        freq = scc_fd_r16be(fd);
        room->cycle[id].delay = freq ? 0x4000/freq : 0;
        room->cycle[id].flags = scc_fd_r16be(fd);
        room->cycle[id].start = scc_fd_r8(fd);
        room->cycle[id].end = scc_fd_r8(fd);
      }
      break;
      
    case MKID('T','R','N','S'):
      if(block_size != 2+8) goto bad_block;
      room->trans = scc_fd_r16le(fd);
      break;

    case MKID('P','A','L','S'):
      if(block_size < 16) goto bad_block;
      type = scc_fd_r32(fd);
      sub_block_size = scc_fd_r32be(fd);
      if(type != MKID('W','R','A','P') ||
         sub_block_size != block_size-8) goto bad_block;
      type = scc_fd_r32(fd);
      sub_block_size = scc_fd_r32be(fd);
      if(type != MKID('O','F','F','S') || sub_block_size<8) goto bad_block;
      else {
        off_t base_ptr = scc_fd_pos(fd)-8;
        int npal = (sub_block_size-8)/4;
        off_t offset[npal];
        for(i = 0 ; i < npal ; i++)
          offset[i] = base_ptr + scc_fd_r32le(fd);
        room->num_palette = npal;
        room->palette = malloc(npal*sizeof(scvm_palette_t));
        for(i = 0 ; i < npal ; i++) {
          int c;
          scc_fd_seek(fd,offset[i],SEEK_SET);
          type = scc_fd_r32(fd);
          sub_block_size = scc_fd_r32be(fd);
          if(type != MKID('A','P','A','L') ||
             sub_block_size-8!= SCVM_PALETTE_SIZE*3) goto bad_block;
          for(c = 0 ; c < SCVM_PALETTE_SIZE ; c++) {
            room->palette[i][c].r = scc_fd_r8(fd);
            room->palette[i][c].g = scc_fd_r8(fd);
            room->palette[i][c].b = scc_fd_r8(fd);
          }
        }
      }
      break;
      
    case MKID('R','M','I','M'):
      if(block_size < 8+8+2+8+8+(room->width/8)*4) goto bad_block;
      type = scc_fd_r32(fd);
      sub_block_size = scc_fd_r32be(fd);
      if(type != MKID('R','M','I','H') ||
         sub_block_size != 8+2) goto bad_block;
      room->num_zplane = scc_fd_r16le(fd);
      type = scc_fd_r32(fd);
      sub_block_size = scc_fd_r32be(fd);
      if(type != MKID('I','M','0','0') ||
         sub_block_size < 8+8) goto bad_block;
      if(!scvm_load_image(room->width,room->height,room->num_zplane,
                          &room->image,fd))
        goto bad_block;
      break;
      
    case MKID('O','B','I','M'):
      if(num_obim >= vm->num_local_object) {
        scc_log(LOG_ERR,"Too many objects in room.\n");
        goto bad_block;
      }
      if(block_size < 8+8+20 ||
         !(obj = scvm_load_obim(vm,room,fd))) goto bad_block;
      if(!objlist[num_obim])
        objlist[num_obim] = obj;
      else if(objlist[num_obim] != obj) {
        scc_log(LOG_ERR,"OBIM and OBCD are badly ordered.\n");
        goto bad_block;
      }
      num_obim++;
      break;
      
    case MKID('O','B','C','D'):
      if(num_obcd >= vm->num_local_object) {
        scc_log(LOG_ERR,"Too many objects in room.\n");
        goto bad_block;
      }
      if(block_size < 8+8+17 ||
         !(obj = scvm_load_obcd(vm,room,fd))) goto bad_block;
      if(!objlist[num_obcd])
        objlist[num_obcd] = obj;
      else if(objlist[num_obcd] != obj) {
        scc_log(LOG_ERR,"OBIM and OBCD are badly ordered.\n");
        goto bad_block;
      }
      num_obcd++;
      break;
      
    case MKID('E','X','C','D'):
      if(block_size <= 8) {
        scc_log(LOG_WARN,"Ignoring empty EXCD.\n");
        break;
      }
      block_size -= 8;
      room->exit = malloc(sizeof(scvm_script_t)+block_size);
      room->exit->id = 0x1ECD0000;
      room->exit->size = block_size;
      if(scc_fd_read(fd,room->exit->code,block_size) != block_size)
        goto bad_block;
      break;

    case MKID('E','N','C','D'):
      if(block_size <= 8) {
        scc_log(LOG_WARN,"Ignoring empty ENCD.\n");
        break;
      }
      block_size -= 8;
      room->entry = malloc(sizeof(scvm_script_t)+block_size);
      room->entry->id = 0x0ECD0000;
      room->entry->size = block_size;
      if(scc_fd_read(fd,room->entry->code,block_size) != block_size)
        goto bad_block;
      break;

    case MKID('N','L','S','C'):
      if(block_size != 8+2)
        goto bad_block;
      room->num_script = scc_fd_r16le(fd);
      if(room->num_script)
        room->script = calloc(room->num_script,sizeof(scvm_script_t*));
      break;
      
    default:
      scc_log(LOG_WARN,"Unhandled room block: %c%c%c%c %d\n",
              UNMKID(type),block_size);
    }
    scc_fd_seek(fd,next_block,SEEK_SET);
  }
  
  if(num_lscr < room->num_script)
    scc_log(LOG_WARN,"Room %d is missing some local scripts?\n",num);

  // Resolve the object parent
  for(i=0 ; i < num_obim ; i++) {
    uint8_t num = (uint8_t)((uintptr_t)objlist[i]->parent);
    if(!num) continue;
    if(num > num_obim) {
      scc_log(LOG_WARN,"Object %d has an invalid parent.\n",obj->id);
      continue;
    }
    objlist[i]->parent = objlist[num-1];
  }
  if(num_obcd > num_obim) num_obim = num_obcd;
  room->num_object = num_obim;
  room->object = malloc(num_obim*sizeof(scvm_object_t*));
  for(i=0 ; i < num_obim ; i++)
    room->object[i] = objlist[i];
  
  return room;
  
bad_block:
  scc_log(LOG_ERR,"Bad ROOM subblock %d: %c%c%c%c %d\n",num,
          UNMKID(type),block_size);
  free(room);
  return NULL;
  */
	}
}

