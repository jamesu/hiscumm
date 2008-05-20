package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban Bedel 
and Copyright (C) 2001-2007 The SCUMMVM Developers.
This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import hiscumm.Common;

import hiscumm.SCUMM;
import hiscumm.SPUTM.SPUTMState;
import hiscumm.SPUTM.SPUTMArray;
import hiscumm.SPUTM.SPUTMArrayType;
import hiscumm.SPUTM.SPUTMActor;

/*
	SCUMM6
	
	This class implements the opcode table and opcodes for SCUMM version 6.
	
	TODO:
		- Handle integer overflow
		- Implement the rest of the bytecode's
		- Explore using subop's instead of switch(subOp) { }
*/

class SCUMM6
{
	static function pushByte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		vm_stack.push(thread.readByte());	
	}
	
	static function pushWord(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		vm_stack.push(thread.readShortSigned());
	}
	
	static function readByte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		vm_stack.push(engine.readVar(thread.readByte(), thread));
	}
	
	static function readWord(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		vm_stack.push(engine.readVar(thread.readShort(), thread));
	}
	
	static function readArrayByte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var addr: Int;
		var x: Int;
		var vaddr: Int;
		
		vaddr = thread.readByte();
		addr = engine.readVar(vaddr, thread);
		x = vm_stack.pop();
		vm_stack.push(engine.readArray(addr, 0, x));
	}
	
	static function readArrayWord(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var addr: Int;
		var x: Int;
		var vaddr: Int;
		
		vaddr = thread.readShort();
		addr = engine.readVar(vaddr, thread);
		x = vm_stack.pop();
		vm_stack.push(engine.readArray(addr, 0, x));
	}
	
	static function readArray2Byte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var addr: Int;
		var x: Int;
		var y: Int;
		var vaddr: Int;
		
		vaddr = thread.readByte();
		addr = engine.readVar(vaddr, thread);
		x = vm_stack.pop();
		y = vm_stack.pop();
		vm_stack.push(engine.readArray(addr, y, x));
	}

	static function readArray2Word(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var addr: Int;
		var x: Int;
		var y: Int;
		var vaddr: Int;
		
		vaddr = thread.readShort();
		addr = engine.readVar(vaddr, thread);
		x = vm_stack.pop();
		y = vm_stack.pop();
		vm_stack.push(engine.readArray(addr, y, x));
	}
	
	static function doDUP(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(a);
		vm_stack.push(a);
	}

	static function testNOT(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		vm_stack.push(vm_stack.pop() == 0 ? 1 : 0);
	}
	
	static function testEQ(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() == a ? 1 : 0);
	}
	
	static function testNEQ(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() != a ? 1 : 0);
	}
	
	static function testGT(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() > a ? 1 : 0);
	}
	
	static function testLT(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() < a ? 1 : 0);
	}
	
	static function testLE(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() <= a ? 1 : 0);
	}
	
	static function testGE(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() >= a ? 1 : 0);
	}
	
	static function doADD(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() + a);
	}
	
	static function doSUB(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() - a);
	}
	
	static function doMUL(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() * a);
	}
	
	static function doDIV(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(Std.int(vm_stack.pop() / a));
	}
	
	static function testAND(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		vm_stack.push((vm_stack.pop() == 1 && 
		                      vm_stack.pop() == 1) ? 1 : 0);
	}
	
	static function testOR(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		vm_stack.push((vm_stack.pop() == 1 || 
		                      vm_stack.pop() == 1) ? 1 : 0);
	}
	
	static function pop(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		vm_stack.pop();
	}
	
	static function writeByte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		engine.writeVar(thread.readByte(), vm_stack.pop(), thread);
	}

	static function writeWord(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		engine.writeVar(thread.readShort(), vm_stack.pop(), thread);
	}

	static function writeArrayByte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var value: Int;
		var x: Int;
		var vaddr: Int;
		
		vaddr = engine.readVar(thread.readByte(), thread);
		value = vm_stack.pop();
		x = vm_stack.pop();
		
		engine.writeArray(vaddr, 0, x, value);
	}

	static function writeArrayWord(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var value: Int;
		var x: Int;
		var vaddr: Int;
		
		vaddr = engine.readVar(thread.readShort(), thread);
		value = vm_stack.pop();
		x = vm_stack.pop();
		
		engine.writeArray(vaddr, 0, x, value);
	}

	static function writeArray2Byte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var value: Int;
		var x: Int;
		var y: Int;
		var vaddr: Int;
		
		vaddr = engine.readVar(thread.readByte(), thread);
		value = vm_stack.pop();
		x = vm_stack.pop();
		y = vm_stack.pop();
		
		engine.writeArray(vaddr, y, x, value);
	}

	static function writeArray2Word(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var value: Int;
		var x: Int;
		var y: Int;
		var vaddr: Int;
		
		vaddr = engine.readVar(thread.readShort(), thread);
		value = vm_stack.pop();
		x = vm_stack.pop();
		y = vm_stack.pop();
		
		engine.writeArray(vaddr, y, x, value);
	}

	static function incByte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var vaddr: Int = thread.readByte();
		engine.writeVar(vaddr, engine.readVar(vaddr, thread) + 1, thread);
	}

	static function incWord(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var vaddr: Int = thread.readShort();
		engine.writeVar(vaddr, engine.readVar(vaddr, thread) + 1, thread);
	}

	static function incArrayByte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var addr: Int = engine.readVar(thread.readByte(), thread);
		var base: Int = vm_stack.pop();
		
		engine.writeArray(addr, 0, base, engine.readArray(addr, 0, base) + 1);
	}

	static function incArrayWord(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var addr: Int = engine.readVar(thread.readShort(), thread);
		var base: Int = vm_stack.pop();
		
		engine.writeArray(addr, 0, base, engine.readArray(addr, 0, base) + 1);
	}

	static function decByte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var vaddr: Int = thread.readByte();
		engine.writeVar(vaddr, engine.readVar(vaddr, thread) - 1, thread);
	}

	static function decWord(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var vaddr: Int = thread.readShort();
		engine.writeVar(vaddr, engine.readVar(vaddr, thread) - 1, thread);
	}

	static function decArrayByte(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var addr: Int = engine.readVar(thread.readByte(), thread);
		var base: Int = vm_stack.pop();
		
		engine.writeArray(addr, 0, base, engine.readArray(addr, 0, base) - 1);
	}

	static function decArrayWord(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var addr: Int = engine.readVar(thread.readShort(), thread);
		var base: Int = vm_stack.pop();
		
		engine.writeArray(addr, 0, base, engine.readArray(addr, 0, base) - 1);
	}

	static function jmpNotZero(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var offs: Int = thread.readShortSigned();
		var val: Int = vm_stack.pop();
		
		if (val != 0)
			thread.jumpRel(offs);
	}

	static function jmpZero(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var offs: Int = thread.readShortSigned();
		var val: Int = vm_stack.pop();
		
		if (val == 0)
			thread.jumpRel(offs);
	}

	static function startScript(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var num_args: Int = vm_stack.pop();
		
		var args: Array<Int> = new Array<Int>();
		if (num_args > 0) args[num_args-1] = 0;
		args[0] = num_args;
		
		while (num_args > 0)
		{
			args[num_args-1] = vm_stack.pop();
			num_args--;
		}
		
		var script: Int = vm_stack.pop();
		var flags: Int = vm_stack.pop();
		var id: Int = SCUMMThread.startScript(flags, script, args);
		if (id < 0)
		{
			trace("Failed to exec startScript!");
			thread.return_state = SPUTM_ERROR;
			return;
		}
		
		SCUMMThread.vm_next_thread = SCUMMThread.vm_threads[id];
		thread.return_state = SPUTM_START_SCRIPT;
	}

	static function startScriptQuick(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var num_args: Int = vm_stack.pop();
		
		var args: Array<Int> = new Array<Int>();
		if (num_args > 0) args[num_args-1] = 0;
		args[0] = num_args;
		
		while (num_args > 0)
		{
			args[num_args-1] = vm_stack.pop();
			num_args--;
		}
		
		var script: Int = vm_stack.pop();
		var id: Int = SCUMMThread.startScript(0, script, args);
		if (id < 0)
		{
			trace("Failed to exec startScript!");
			thread.return_state = SPUTM_ERROR;
			return;
		}
		
		SCUMMThread.vm_next_thread = SCUMMThread.vm_threads[id];
		thread.return_state = SPUTM_START_SCRIPT;
	}

	static function startObject(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function drawObject(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function drawObjectAt(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function drawBlastObject(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function drawBlastObjectWindow(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function stopObjectCode(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.stop();
	}

	static function endCutscene(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function cutscene(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function stopMusic(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function freezeUnfreeze(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function cursorOp(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var subOp: Int = thread.readByte();
		var a: Int;
		
		switch (subOp)
		{
			case 0x90: //SO_CURSOR_ON
				// _cursor.state = 1
				// verbMouseOver(0)
			case 0x91: // SO_CURSOR_OFF
				// _cursor.state = 0
				// verbMouseOver(0)
			case 0x92: // SO_USERPUT_ON
				//_userPut = 1;
			case 0x93: // SO_USERPUT_OFF
				// _userPut = 0
			case 0x94: // SO_CURSOR_SOFT_ON
				// _cursor.state++
				// if (_cursor.state > 1)
				// < error>
				// verbMouseOver(0);
			case 0x95: // SO_CURSOR_SOFT_OFF
				// _cursor.state--;
				// verbMouseOver(0);
			case 0x96: // SO_USERPUT_SOFT_ON
				// _userPut++;
			case 0x97: // SO_USERPUT_SOFT_OFF
				// _userPut--;
			case 0x99: // SO_CURSOR_IMAGE
				var obj: Int;
				var room: Int;
				
				room = vm_stack.pop();
				obj = vm_stack.pop();
				
				// setCursorFromImg(obj, room, 1);
			case 0x9A: // SO_CURSOR_HOTSPOT
				a = vm_stack.pop();
				
				// setCursorHotspot(pop(), a);
				// updateCursor();
			case 0x9C: // SO_CHARSET_SET
				vm_stack.pop();
				//initCharset(<stack>);
			case 0x9D: // SO_CHARSET_COLOR
			
			case 0xD6: // SO_CURSOR_TRANSPARENT
				vm_stack.pop();
				//setCursorTransparency(<stack>);
			default:
				trace("default cursorOp");
				thread.return_state = SPUTM_ERROR;
		}

		//VAR(VAR_CURSORSTATE) = _cursor.state;
		//VAR(VAR_USERPUT) = _userPut;
	}

	static function breakScript(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.cycle = SCUMMThread.vm_cycle + 1;
	}

	static function ifClassOfIs(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function setClass(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getObjectState(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function setObjectState(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function setObjectOwner(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getObjectOwner(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function jmp(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.jumpRel(thread.readShortSigned());
	}

	static function startSound(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function stopSound(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function startMusic(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function stopObjectScript(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function panCameraTo(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		// x pos?
		trace("panCameraTo=" + vm_stack.pop());
	}

	static function followCameraActor(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		// actor number?
		trace("followCameraActor=" + vm_stack.pop());
	}

	static function setCameraAt(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		// x pos?
		trace("setCameraAt=" + vm_stack.pop());
	}

	static function startRoom(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		engine.setNextRoom(vm_stack.pop());
		
		thread.return_state = SPUTM_OPEN_ROOM;
	}

	static function stopScript(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function walkActorToObject(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function walkActorTo(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var y: Int = vm_stack.pop();
		var x: Int = vm_stack.pop();
		var actornum: Int = vm_stack.pop();
		
		trace("walkActorTo=" + x + "," + y + "," + actornum);
	}

	static function putActorAt(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var room: Int;
		var x: Int;
		var y: Int;
		var act: Int;
		
		var a: SPUTMActor;
		
		room = vm_stack.pop();
		y = vm_stack.pop();
		x = vm_stack.pop();
		act = vm_stack.pop();
		
		// TODO
	}

	static function putActorAtObject(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function faceActor(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function animateActor(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function doSentence(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function pickupObject(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var room: Int = vm_stack.pop();
		var obj: Int = vm_stack.pop();
	}

	static function startRoomWithEgo(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getRandomNumber(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
		var max: Int = vm_stack.pop();
		
		vm_stack.push(Std.random(max));
	}

	static function getRandomNumberRange(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
		var max: Int = vm_stack.pop();
		var min: Int = vm_stack.pop();
		
		vm_stack.push(min + (Std.random(max) % (max-min)));
	}

	static function getActorMoving(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function isScriptRunning(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var id: Int = vm_stack.pop();
		
		vm_stack.push(SCUMMThread.isScriptRunning(id) ? 1 : 0);
	}

	static function getActorRoom(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getObjectX(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getObjectY(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getObjectOldDir(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getActorWalkBox(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getActorCostume(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function findInventory(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getInventoryCount(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getVerbFrom(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var y: Int = vm_stack.pop();
		var x: Int = vm_stack.pop();
		
		var r: Int = 0; // getVerbFromPos(x, y)
		// (evaluate .id...)
		vm_stack.push(r);
	}

	static function beginOverride(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		if (!thread.beginOverride())
		{
			thread.return_state = SPUTM_ERROR;
			return;
		}
		
		thread.jumpRel(3); // skip the jump
		engine.writeVar(SPUTM.VAR_OVERRIDE, 1, thread);
	}

	static function endOverride(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.endOverride();
		engine.writeVar(SPUTM.VAR_OVERRIDE, 0, thread);
	}

	static function setObjectName(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function isSoundRunning(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function setBoxFlags(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function createBoxMatrix(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function resourceOp(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var subOp: Int = thread.readByte();
		var res: Int = vm_stack.pop();
		
		if (subOp == 0x65) // ignore sounds
			return;
		
		trace(subOp + ', ' + thread.script.code.tell());
		
		if (subOp >= 0x64 && subOp <= 0x67)
		{
			if (engine.vm_res[subOp-0x64].loadResource(res) == null)
			{
				trace("Bad resource");
				thread.return_state = SPUTM_ERROR;
			}
			return;
		}
		else if (subOp >= 0x6C && subOp <= 0x6F)
		{
			if (!engine.vm_res[subOp-0x6C].res[res].lock())
			{
				trace("Bad resource");
				thread.return_state = SPUTM_ERROR;
			}
			return;
		}
		else if (subOp >= 0x80 && subOp <= 0x73)
		{
			if (engine.vm_res[subOp-0x80].res[res].unlock())
			{
				trace("Bad resource");
				thread.return_state = SPUTM_ERROR;
			}
			return;
		}
		
		switch (subOp)
		{
			case 0x75: // load charset
				if (engine.vm_res[SPUTM.RES_CHARSET].loadResource(res) == null)
				{
					trace("Bad resource");
					thread.return_state = SPUTM_ERROR;
				}
				return;
			case 0x77: // load fl object
				vm_stack.pop();
		}
	}

	static function roomOp(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int;
		var b: Int;
		var c: Int;
		var d: Int;
		var e: Int;
		
		var subOp: Int = thread.readByte();
		
		switch (subOp)
		{
			case 172: // SO_ROOM_SCROLL
			
				b = vm_stack.pop();
				a = vm_stack.pop();
			
			/*
		if (a < (_screenWidth / 2))
			a = (_screenWidth / 2);
		if (b < (_screenWidth / 2))
			b = (_screenWidth / 2);
		if (a > _roomWidth - (_screenWidth / 2))
			a = _roomWidth - (_screenWidth / 2);
		if (b > _roomWidth - (_screenWidth / 2))
			b = _roomWidth - (_screenWidth / 2);
			*/
			
				engine.writeVar(SPUTM.VAR_CAMERA_MIN_X, a, thread);
				engine.writeVar(SPUTM.VAR_CAMERA_MAX_X, b, thread);
			
			case 174: // SO_ROOM_SCREEN
			
				b = vm_stack.pop();
				a = vm_stack.pop();
			
				engine.initScreens(a, b);
				
			case 175: // SO_ROOM_PALETTE
				
				d = vm_stack.pop();
				c = vm_stack.pop();
				b = vm_stack.pop();
				a = vm_stack.pop();
				
				//engine.setPalColor(d, a, b, c);
			
			case 176: // SO_ROOM_SHAKE_ON
			
				//engine.setShake(1);
			
			case 177: // SO_ROOM_SHAKE_OFF
			
				//engine.setShake(0);
			
			case 179: // SO_ROOM_INTENSITY
			
				c = vm_stack.pop();
				b = vm_stack.pop();
				a = vm_stack.pop();
				
				//engine.darkenPalette(a, a, a, b, c);
			
			case 180: // SO_ROOM_SAVEGAME
			
				b = vm_stack.pop();
				a = vm_stack.pop();
				
			case 181: // SO_ROOM_FADE
			
				a = vm_stack.pop();
			
			case 182: // SO_RGB_ROOM_INTENSITY
			
				e = vm_stack.pop();
				d = vm_stack.pop();
				c = vm_stack.pop();
				b = vm_stack.pop();
				a = vm_stack.pop();
				
				//engine.darkenPalette(a, b, c, d, e);
				
			case 183: // SO_ROOM_SHADOW
			
				e = vm_stack.pop();
				d = vm_stack.pop();
				c = vm_stack.pop();
				b = vm_stack.pop();
				a = vm_stack.pop();
				
				//engine.setShadowPalette(a, b, c, d, e, 0, 256);
			
			case 184: // SO_SAVE_STRING
				trace("save string n/a");
				
				thread.return_state = SPUTM_ERROR;
			
			case 185: // SO_LOAD_STRING
				
				trace("load string n/a");
				
				thread.return_state = SPUTM_ERROR;
			
			case 186: // SO_ROOM_TRANSFORM
			
				d = vm_stack.pop();
				c = vm_stack.pop();
				b = vm_stack.pop();
				a = vm_stack.pop();
				
				//engine.palManipulateInit(a, b, c, d);
			
			case 187: // SO_CYCLE_SPEED
			
				b = vm_stack.pop();
				a = vm_stack.pop();
				
				// TODO
			
			case 213: // SO_ROOM_NEW_PALETTE
			
				a = vm_stack.pop();
			
			default:
			
				trace("roomOps N/A (" + subOp + ")");
				thread.return_state = SPUTM_ERROR;
		}
	}

	static function actorOp(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: SPUTMActor = null;
		var i: Int;
		var j: Int;
		var k: Int;
		
		var args: Array<Int>;
		var subOp: Int = thread.readByte();
		
		if (subOp == 197) // setCurrentActor()
		{
			engine.vm_current_actor = engine.getActor(vm_stack.pop());
			return;
		}
		
		a = engine.vm_current_actor;
		if (a == null)
			return;
		
		switch (subOp)
		{
			case 76: // SO_COSTUME
				//a.setCostume(vm_stack.pop());
				vm_stack.pop();
			case 77: // SO_STEP_DIST
				j = vm_stack.pop();
				i = vm_stack.pop();
				//a.setWalkSpeed(i, j);
			case 78: // SO_SOUND
				var num_args: Int = vm_stack.pop();
		
				var args: Array<Int> = new Array<Int>();
				if (num_args > 0) args[num_args-1] = 0;
				args[0] = num_args;
		
				while (num_args > 0)
				{
					args[num_args-1] = vm_stack.pop();
					num_args--;
				}
				
				// a.sound[i] = pop();
		
			case 79: // SO_WALK_ANIMATION
				//a.walkFrame = vm_stack.pop();
				vm_stack.pop();
			case 80: // SO_TALK_ANIMATION
				//a.talkStopFrame = vm_stack.pop();
				//a.talkStartFrame = vm_stack.pop();
				vm_stack.pop();
				vm_stack.pop();
			case 81: // SO_STAND_ANIMATION
				//a.standFrame = vm_stack.pop();
				vm_stack.pop();
			case 82:
				// dummy case in scumm6
				vm_stack.pop();
				vm_stack.pop();
				vm_stack.pop();
			case 83: // SO_DEFAULT
				//a.init(0);
			case 84: // SO_ELEVATION
				//a.setElevation(vm_stack.pop());
				vm_stack.pop();
			case 85: // SO_ANIMATION_DEFAULT
				//a.initFrame = 1;
				//a.walkFrame = 2;
				//a.standFrame = 3;
				//a.talkStartFrame = 4;
				//a.talkStopFrame = 5;
			case 86: // SO_PALETTE
				j = vm_stack.pop();
				i = vm_stack.pop();
				// check slot range for i (0, 255) ...
				// a.setPalette(i, j);
			case 87: // SO_TALK_COLOR
				//a.talkColor = vm_stack.pop();
				vm_stack.pop();
			case 88: // SO_ACTOR_NAME
				// loadPtrToResource
				i = thread.getStrLen();
				thread.jumpRel(i+1);
				
			case 89: // SO_INIT_ANIMATION
				//a.initFrame = vm_stack.pop();
				vm_stack.pop();
			case 91: // SO_ACTOR_WIDTH
				//a.width = vm_stack.pop();
				vm_stack.pop();
			case 92: // SO_SCALE
				i = vm_stack.pop();
				// a.setScale(i, i);
			case 93: // SO_NEVER_ZCLIP
				//a.forceClip = 0;
			case 225: // SO_ALWAYS_ZCLIP
				//a.forceClip = vm_stack.pop();
				vm_stack.pop();
			case 94: // SO_ALWAYS_ZCLIP
				//a.forceClip = vm_stack.pop();
				vm_stack.pop();
			case 95: // SO_IGNORE_BOXES
				// a.ignoreBoxes = 1;
				// a.forceClip = 0;
				// if (a.isInCurrentRoom())
				//    a.putActor();
			case 96: // SO_FOLLOW_BOXES
				// a.ignoreBoxes = 0;
				// a.forceClip = 0;
				// if (a.isInCurrentRoom())
				//    a.putActor();
			case 97: // SO_ANIMATION_SPEED
				//a.setAnimSpeed(vm_stack.pop());
				vm_stack.pop();
			case 98: // SO_SHADOW
				//a.shadowMode = vm_stack.pop();
				vm_stack.pop();
			case 99: // SO_TEXT_OFFSET
				//a.talkPosY = vm_stack.pop();
				//a.talkPosX = vm_stack.pop();
				vm_stack.pop();
				vm_stack.pop();
			case 198: // SO_ACTOR_VARIABLE
				i = vm_stack.pop();
				// a.setAnimVar(vm_stack.pop(), i);
				vm_stack.pop();
			case 215: // SO_ACTOR_IGNORE_TURNS_ON
				//a.ignoreTurns = true;
			case 216: // SO_ACTOR_IGNORE_TURNS_OFF
				//a.ignoreTurns = false;
			case 217: // SO_ACTOR_NEW
				//a.init(2);
			case 227: // SO_ACTOR_DEPTH
				//a.layer = vm_stack.pop();
				vm_stack.pop();
			case 228: // SO_ACTOR_WALK_SCRIPT
				//a.walkScript = vm_stack.pop();
				vm_stack.pop();
			case 229: // SO_ACTOR_STOP
				//a.stopMoving();
				//a.startAnim(a.standFrame);
			case 230: // SO_ACTOR_SET_DIRECTION
				//a.moving &= ~MF_TURN;
				//a.setDirection(vm_stack.pop());
				vm_stack.pop();
			case 231: // SO_ACTOR_TURN_TO_DIRECTION
				//a.turnToDirection(vm_stack.pop());
				vm_stack.pop();
			case 233: // SO_ACTOR_WALK_PAUSE
				//a.moving |= MF_FROZEN;
			case 234: // SO_ACTOR_WALK_RESUME
				//a.moving &= ~MF_FROZEN;
			case 235: // SO_ACTOR_TALK_SCRIPT
				//a.talkScript = vm_stack.pop();
				vm_stack.pop();
			default:
				trace("Default actorOps case!");
				thread.return_state = SPUTM_ERROR;
		}
	}

	static function verbOp(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int;
		var b: Int;
		var i: Int;
		var slot: Int;
		var subOp: Int = thread.readByte();
		
		if (subOp == 196)
		{
			//trace("setverb");
			vm_stack.pop();
			return;
		}
		
		//trace("verbop " + subOp);
		switch (subOp)
		{
			case 124: // SO_VERB_IMAGE
				a = vm_stack.pop();
			case 125: // SO_VERB_NAME
				// loadPtrToResource
				a = thread.getStrLen();
				//trace("len=" + a);
				thread.jumpRel(a+1);
			case 126: // SO_VERB_COLOR
				vm_stack.pop();
			case 127: // SO_VERB_HICOLOR
				vm_stack.pop();
			case 128: // SO_VERB_AT
				vm_stack.pop();
				vm_stack.pop();
			case 129: // SO_VERB_ON
			case 130: // SO_VERB_OFF
			case 131: // SO_VERB_DELETE
			case 132: // SO_VERB_NEW
			case 133: // SO_VERB_DIMCOLOR
				vm_stack.pop();
			case 134: // SO_VERB_DIM
			case 135: // SO_VERB_KEY
				vm_stack.pop();
			case 136: // SO_VERB_CENTER
				vm_stack.pop();
			case 137: // SO_VERB_NAME_STR
				a = vm_stack.pop();
				if (a == 0)
				{
					i = thread.getStrLen();
					thread.jumpRel(i+1);
				}
			case 139: // SO_VERB_IMAGE_IN_ROOM
				b = vm_stack.pop();
				a = vm_stack.pop();
			case 140: // SO_VERB_BAKCOLOUR
				vm_stack.pop();
			case 255: // redraw?
			default:
				trace("Default verbOps case!");
				thread.return_state = SPUTM_ERROR;
		}
	}

	static function getActorFrom(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var y: Int = vm_stack.pop();
		var x: Int = vm_stack.pop();
		
		var r: Int = 0; // getActorFromPos(x, y)
		vm_stack.push(r);
	}

	static function findObject(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var y: Int = vm_stack.pop();
		var x: Int = vm_stack.pop();
		
		var r: Int = 0; // findObject(x, y)
		vm_stack.push(r);
	}

	static function pseudoRoom(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getActorElevation(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getVerbEntrypoint(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function arrayOps(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var subOp: Int = thread.readByte();
		var array: Int = thread.readShort();
		
		var b: Int;
		var c: Int;
		var d: Int = engine.readVar(array, thread);
		var y: Int;
		var len: Int;
		
		switch(subOp)
		{
			case 205: // assign string
				b = vm_stack.pop();
				len = thread.getStrLen();
				
				engine.nukeArray(d);
				d = engine.defineArray(ARRAY_STRING, 0, b + len + 1);
				
				var adata: Array<Int> = engine.vm_array[d].data;
				len = thread.getStrLen()+1;
				y = -1;
				c = b;
				while (len > 0)
				{
					adata[c] = thread.readByte();
					c++;
					len--;
				}
				
				trace("ARRAY = \"" + engine.vm_array[d].toString() + "\"");
			case 208: // assign int list
				b = vm_stack.pop();
				len = vm_stack.pop();
				
				if (d == 0) // array not defined?
				{
					d = engine.defineArray(ARRAY_INT, 0, b + len);
				}
				
				var ainst: SPUTMArray = engine.vm_array[d];
				
				c = b;
				while (len > 0)
				{
					ainst.set(0, c, vm_stack.pop());
					//engine.writeArray(d, 0, c, vm_stack.pop());
					len--;
					c++;
				}
			case 212: // assign 2dim list
				b = vm_stack.pop();
				len = vm_stack.pop();
				
				if (d == 0) // array defined?
				{
					trace("2dim array needs to be dim'd!");
					thread.return_state = SPUTM_ERROR;
					return;
				}
				
				var temp: Array<Int> = new Array<Int>();
				c = len-1;
				while(c > -1)
				{
					temp[c] = vm_stack.pop(); 
					c--;
				}
				y = vm_stack.pop();
				
				var ainst: SPUTMArray = engine.vm_array[d];
				
				c = len-1;
				while (c > 0)
				{
					ainst.set(y, b + c, temp[y]);
					//engine.writeArray(d, y, b + c, temp[y]);
					c--;
				}
			default:
				trace("Invalid subop!");
				thread.return_state = SPUTM_ERROR;
				return;
		}
		
		engine.writeVar(array, d, thread);
	}

	static function saveRestoreVerbs(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function drawBox(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getActorWidth(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function wait(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var actnum: Int = 0;
		var offs: Int = -2;
		var a: SPUTMActor;
		
		var subOp: Int = thread.readByte();
		
		// Note that any op which doesn't return causes the thread
		// to revert back and break
		
		switch (subOp)
		{
			case 168: // wait for actor
				offs = thread.readShortSigned();
				actnum = vm_stack.pop();
				
				// if (actor moving) break
				// else return
				
				return;
			case 169: // wait for message
				//if (engine.readVar(SPUTM.VAR_HAVE_MSG, thread) != 1)
				//	return;
				return;
			case 170: // wait for camera
				// if (!(camera._cur.x / 8 != camera._dest.x / 8))
				// return;
				
				return;
			case 171: // wait for sentence
				/*
						if (_sentenceNum) {
			if (_sentence[_sentenceNum - 1].freezeCount && !isScriptInUse(VAR(VAR_SENTENCE_SCRIPT)))
				return;
			break;
		}
		if (!isScriptInUse(VAR(VAR_SENTENCE_SCRIPT)))
			return;
				*/
				
				return;
			case 226: // wait for animation
				offs = thread.readShortSigned();
				actnum = vm_stack.pop();
				/*		if (a->isInCurrentRoom() && a->_needRedraw)
			break;*/
				return;
			case 232: // wait for actor turn
				offs = thread.readShortSigned();
				actnum = vm_stack.pop();
				// if (actnum % 45 == 0)
				// actnum = _curActor
				
				// if (a->isInCurrentRoom() && a->_moving && MF_TURN)
				//    break;
				
				return;
			default:
				trace("Default waitOps case!");
				thread.return_state = SPUTM_ERROR;
		}
		
		thread.jumpRel(offs);
		thread.cycle = SCUMMThread.vm_cycle + 1;
	}

	static function getActorXScale(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getActorAnimCounter(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function soundKludge(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function isAnyOf(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function systemOps(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function isActorInBox(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function delay(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function delaySeconds(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function delayMinutes(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function stopSentence(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function print(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var subOp: Int = thread.readByte();
		
		switch (subOp)
		{
			case 65: // at
				vm_stack.pop();
				vm_stack.pop();
			case 66: // color
			case 67: // clipped
				vm_stack.pop();
			case 69: // center
			case 71: // left
			case 72: // overhead
			case 74: // mumble
			case 75: // ??
				thread.jumpRel(thread.getStrLen()+1);
				vm_stack.pop();
			case 254: // begin
			case 255: // end
			
			default:
				trace("print default case!");
		}
	}
 // (printLine)
	static function printCursor(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var subOp: Int = thread.readByte();
		
		switch (subOp)
		{
			case 65: // at
				vm_stack.pop();
				vm_stack.pop();
			case 66: // color
			case 67: // clipped
				vm_stack.pop();
			case 69: // center
			case 71: // left
			case 72: // overhead
			case 74: // mumble
			case 75: // ??
				thread.jumpRel(thread.getStrLen()+1);
				vm_stack.pop();
			case 254: // begin
			case 255: // end
			
			default:
				trace("print default case!");
		}
	}
 // (printText)
	static function printDebug(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var subOp: Int = thread.readByte();
		
		switch (subOp)
		{
			case 65: // at
				vm_stack.pop();
				vm_stack.pop();
			case 66: // color
			case 67: // clipped
				vm_stack.pop();
			case 69: // center
			case 71: // left
			case 72: // overhead
			case 74: // mumble
			case 75: // ??
				thread.jumpRel(thread.getStrLen()+1);
				vm_stack.pop();
			case 254: // begin
			case 255: // end
			
			default:
				trace("print default case!");
		}
	}

	static function printSystem(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var subOp: Int = thread.readByte();
		
		switch (subOp)
		{
			case 65: // at
				vm_stack.pop();
				vm_stack.pop();
			case 66: // color
			case 67: // clipped
				vm_stack.pop();
			case 69: // center
			case 71: // left
			case 72: // overhead
			case 74: // mumble
			case 75: // ??
				thread.jumpRel(thread.getStrLen()+1);
				vm_stack.pop();
			case 254: // begin
			case 255: // end
			
			default:
				trace("print default case!");
		}
	}

	static function printActor(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var subOp: Int = thread.readByte();
		
		switch (subOp)
		{
			case 65: // at
				vm_stack.pop();
				vm_stack.pop();
			case 66: // color
			case 67: // clipped
				vm_stack.pop();
			case 69: // center
			case 71: // left
			case 72: // overhead
			case 74: // mumble
			case 75: // ??
				thread.jumpRel(thread.getStrLen()+1);
				vm_stack.pop();
			case 254: // begin
			case 255: // end
			
			default:
				trace("print default case!");
		}
	}
	
	static function printEgo(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var subOp: Int = thread.readByte();
		
		switch (subOp)
		{
			case 65: // at
				vm_stack.pop();
				vm_stack.pop();
			case 66: // color
			case 67: // clipped
				vm_stack.pop();
			case 69: // center
			case 71: // left
			case 72: // overhead
			case 74: // mumble
			case 75: // ??
				thread.jumpRel(thread.getStrLen()+1);
				vm_stack.pop();
			case 254: // begin
			case 255: // end
			
			default:
				trace("print default case!");
		}
	}

	static function talkActor(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var actornum: Int = vm_stack.pop();
		
		// _string[0].loadDefault
		// actorTalk();
		
		thread.jumpRel(thread.getStrLen() + 1);
	}

	static function talkEgo(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		vm_stack.push(engine.readVar(SPUTM.VAR_EGO, thread));
		
		talkActor(engine, vm_stack, thread);
	}

	static function dimArray(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var arrayType: SPUTMArrayType;
		var subOp: Int = thread.readByte();
		var array: Int;
		var d: Int;
		
		//trace(subOp + "!!");
		
		switch (subOp)
		{
			case 199:
				arrayType = ARRAY_INT;
			case 200:
				arrayType = ARRAY_BIT;
			case 201:
				arrayType = ARRAY_NIBBLE;
			case 202:
				arrayType = ARRAY_BYTE;
			case 203:
				arrayType = ARRAY_STRING;
			case 204: // nuke array!
				engine.nukeArray(engine.readVar(thread.readShort(), thread));
				return;
			default:
				trace("dimArray default!");
				thread.return_state = SPUTM_ERROR;
		}
		
		array = thread.readShort();
		trace(array);
		
		d = engine.readVar(array, thread);
		engine.nukeArray(d);
		d = engine.defineArray(arrayType, 0, vm_stack.pop());
		
		engine.writeVar(array, d, thread);
	}

	static function dummy(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function startObjectQuick(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function startScriptRecursive(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var num_args: Int = vm_stack.pop();
		
		var args: Array<Int> = new Array<Int>();
		if (num_args > 0) args[num_args-1] = 0;
		args[0] = num_args;
		
		while (num_args > 0)
		{
			args[num_args-1] = vm_stack.pop();
			num_args--;
		}
		
		var script: Int = vm_stack.pop();
		var id: Int = SCUMMThread.startScript(SCUMMThread.THREAD_FLAG_RECURSIVE, script, args);
		if (id < 0)
		{
			trace("Failed to exec startScript!");
			thread.return_state = SPUTM_ERROR;
			return;
		}
		
		SCUMMThread.vm_next_thread = SCUMMThread.vm_threads[id];
		thread.return_state = SPUTM_START_SCRIPT;  
	}

	static function dimArray2(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var arrayType: SPUTMArrayType;
		var subOp: Int = thread.readByte();
		var array: Int;
		var d: Int;
		
		var b: Int;
		var a: Int;
		
		switch (subOp)
		{
			case 199:
				arrayType = ARRAY_INT;
			case 200:
				arrayType = ARRAY_BIT;
			case 201:
				arrayType = ARRAY_NIBBLE;
			case 202:
				arrayType = ARRAY_BYTE;
			case 203:
				arrayType = ARRAY_STRING;
			case 204: // nuke array!
				engine.nukeArray(engine.readVar(thread.readShort(), thread));
				return;
			default:
				trace("dimArray default!");
				thread.return_state = SPUTM_ERROR;
		}
		
		array = thread.readShort();
		
		b = vm_stack.pop();
		a = vm_stack.pop();
		
		d = engine.readVar(array, thread);
		engine.nukeArray(d);
		d = engine.defineArray(arrayType, a, b);
		
		engine.writeVar(array, d, thread);
	}

	static function abs(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function distObjectObject(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function distObjectPt(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function distPtPt(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function kernelGetFunctions(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function kernelSetFunctions(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function breakScriptNTimes(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var n: Int = vm_stack.pop();
		thread.cycle = SCUMMThread.vm_cycle + n;
	}

	static function pickOneOf(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function pickOneOfDefault(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function stampObject(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}
		
	static function getDateTime(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function stopTalking(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getAnimateVariable(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function shuffle(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function jumpToScript(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function bitAND(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() & a);
	}

	static function bitOR(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		var a: Int = vm_stack.pop();
		vm_stack.push(vm_stack.pop() | a);
	}

	static function isRoomScriptRunning(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}
	
	static function findAllObjects(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}
	
	static function getPixel(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function pickRandomVar(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function setBoxSet(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getActorLayer(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function getObjectNewDir(engine: SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		thread.return_state = SPUTM_ERROR;
	}

	static function invalid(engine:SPUTM, vm_stack: SCUMMStack, thread: SCUMMThread) : Void
	{
		trace("Invalid opcode!");
		thread.return_state = SPUTM_ERROR;
	}
		
	// Opcode tables
	static public var optable: Array<SCUMMOpcode> = [
	                             pushByte,
	                             pushWord,
	                             readByte,
	                             readWord,
	                             null,
	                             null,
	                             readArrayByte,
	                             readArrayWord,
	                             null,
	                             null,
	                             readArray2Byte,
	                             readArray2Word,
	                             doDUP,
	                             testNOT,
	                             testEQ,
	                             testNEQ,
	                             testGT,
	                             testLT,
	                             testLE,
	                             testGE,
	                             doADD,
	                             doSUB,
	                             doMUL,
	                             doDIV,
	                             testAND,
	                             testOR,
	                             pop,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             null,
	                             writeByte,
	                             writeWord,
	                             null,
	                             null,
	                             writeArrayByte,
	                             writeArrayWord,
	                             null, // 48
	                             null,
	                             writeArray2Byte,
	                             writeArray2Word,
	                             null, // 4C
	                             null,
	                             incByte,
	                             incWord,
	                             null, // 50
	                             null,
	                             incArrayByte,
	                             incArrayWord,
	                             null, // 54
	                             null,
	                             decByte,
	                             decWord,
	                             null, // 58
	                             null,
	                             decArrayByte,
	                             decArrayWord,
	                             jmpNotZero, // 5C
	                             jmpZero,
	                             startScript,
	                             startScriptQuick,
	                             startObject, // 60
	                             drawObject,
	                             drawObjectAt,
	                             drawBlastObject,
	                             drawBlastObjectWindow, // 64
	                             stopObjectCode].concat([ // NEKO HACK
	                             stopObjectCode,
	                             endCutscene,
	                             cutscene, // 68
	                             stopMusic,
	                             freezeUnfreeze,
	                             cursorOp,
	                             breakScript, // 6C
	                             ifClassOfIs,
	                             setClass,
	                             getObjectState,
	                             setObjectState, // 70
	                             setObjectOwner,
	                             getObjectOwner,
	                             jmp,
	                             startSound, // 74
	                             stopSound,
	                             startMusic,
	                             stopObjectScript,
	                             panCameraTo, // 78
	                             followCameraActor,
	                             setCameraAt,
	                             startRoom,
	                             stopScript, // 7C
	                             walkActorToObject,
	                             walkActorTo,
	                             putActorAt,
	                             putActorAtObject, // 80
	                             faceActor,
	                             animateActor,
	                             doSentence,
	                             pickupObject, // 84
	                             startRoomWithEgo,
	                             null,
	                             getRandomNumber,
	                             getRandomNumberRange, // 88
	                             null,
	                             getActorMoving,
	                             isScriptRunning,
	                             getActorRoom,
	                             getObjectX,
	                             getObjectY,
	                             getObjectOldDir,
	                             getActorWalkBox, // 90
	                             getActorCostume,
	                             findInventory,
	                             getInventoryCount,
	                             getVerbFrom, // 94
	                             beginOverride,
	                             endOverride,
	                             setObjectName,
	                             isSoundRunning, // 98
	                             setBoxFlags,
	                             createBoxMatrix,
	                             resourceOp,
	                             roomOp, // 9C
	                             actorOp,
	                             verbOp,
	                             getActorFrom,
	                             findObject, // A0
	                             pseudoRoom,
	                             getActorElevation,
	                             getVerbEntrypoint,
	                             arrayOps, // A4
	                             saveRestoreVerbs,
	                             drawBox,
	                             pop,
	                             getActorWidth, // A8
	                             wait,
	                             getActorXScale,
	                             getActorAnimCounter,
	                             soundKludge, // AC
	                             isAnyOf,
	                             systemOps,
	                             isActorInBox,
	                             delay, // B0
	                             delaySeconds,
	                             delayMinutes,
	                             stopSentence,
	                             print, // B4  (printLine
	                             printCursor, // (printText)
	                             printDebug,
	                             printSystem,
	                             printActor, // B8
	                             printEgo,
	                             talkActor,
	                             talkEgo,
	                             dimArray, // BC
	                             dummy,
	                             startObjectQuick,
	                             startScriptRecursive,
	                             dimArray2, // C0
	                             null,
	                             null,
	                             null,
	                             abs, // C4
	                             distObjectObject,
	                             distObjectPt,
	                             distPtPt,
	                             kernelGetFunctions, // C8
	                             kernelSetFunctions,
	                             breakScriptNTimes]).concat([ // NEKO HACK
	                             pickOneOf,
	                             pickOneOfDefault, // CC
	                             stampObject,
	                             null,
	                             null,		
	                             getDateTime, // D0
	                             stopTalking,
	                             getAnimateVariable,
	                             null,
	                             shuffle, // D4
	                             jumpToScript,
	                             bitAND,
	                             bitOR,
	                             isRoomScriptRunning, // D8
	                             null,
	                             null,
	                             null,
	                             null, // DC
	                             findAllObjects,
	                             null,
	                             null,		
	                             null, // E0
	                             getPixel,
	                             null,
	                             pickRandomVar,
	                             setBoxSet, // E4
	                             null,
	                             null,
	                             null,
	                             null, // E8
	                             null,
	                             null,
	                             null,
	                             getActorLayer, // EC
	                             getObjectNewDir,
	                             null,
	                             null,		
	                             null, // F0
	                             null,
	                             null,
	                             null,
	                             null, // F4
	                             null,
	                             null,
	                             null,
	                             null, // F8
	                             null,
	                             null,
	                             null,
	                             null, // FC
	                             null,
	                             null,
	                             null
	                             ]); // NEKO HACK
	static public var suboptable: Array<SCUMMOpcode> = [];
}
