package hiscumm;
/*
hiscumm
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)
Portions derived from code Copyright (C) 2004-2006 Alban BedelThis program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

import hiscumm.Common;

#if neko
import neko.io.File;
#else !neko
import utils.Seekable;
#end

import hiscumm.SPUTM.SPUTMState;
import hiscumm.SPUTMResource;

/*
	SCUMM
	
	This collection of classes handles the loading and processing of SCUMM scripts.
	Also included is a handy SCUMMThread pool which handles the scheduling of SCUMMThread's.
*/

typedef SCUMMStack = List<Int>;
typedef SCUMMOpcode = SPUTM->SCUMMStack->SCUMMThread->Void;

enum SCUMMThreadState
{
	THREAD_NONE;
	THREAD_STOPPED;
	THREAD_RUNNING;
	THREAD_PENDED;
	THREAD_DELAYED;
	THREAD_FROZEN;
}

class SCUMMThread
{
	public var id: Int;
	public var ptr: Int;
	var op_start: Int;
	public var flags: Int;
	public var vars: Array<Int>;
	public var cycle: Int;
	public var delay: Float;
	public var parent: SCUMMThread;
	
	public var override_stack: List<Int>;
	static public var MAX_OVERRIDE = 8;
	
	public var state: SCUMMThreadState;
	public var next_state: SPUTMState;
	public var return_state: SPUTMState;
	public var script: SCUMMScript;
	
	public static var optable: Array<SCUMMOpcode>;
	public static var suboptable: Array<SCUMMOpcode>;
		
	public function new(in_id: Int)
	{
		id = in_id;
		script = null;
		flags = 0;
		ptr = 0;
		op_start = 0;
		cycle = 0;
		delay = 0;
		parent = null;
		
		vars = new Array<Int>();
		vars[15] = 0;
		
		override_stack = new List<Int>();
		
		state = THREAD_STOPPED;
		next_state = SPUTM_NONE;
		return_state = SPUTM_NONE;
		script = null;
	}
	
	public function start(in_script: SCUMMScript, in_flags: Int, in_ptr: Int, 
	                      in_cycle: Int, in_args: Array<Int>, in_parent: SCUMMThread)
	{
		var i: Int;
		
		script = in_script;
		flags = in_flags;
		ptr = in_ptr;
		cycle = in_cycle;
		parent = in_parent;
		delay = 0;
		
		if (in_args != null)
		{
			for (i in 0...in_args.length)
			{
				vars[i] = in_args[i];
			}
		}
		else
		{
			for (i in 0...vars.length)
			{
				vars[i] = 0;
			}
		}
		
		state = THREAD_RUNNING;
	}
	
	public function jump(pos: Int) : Void
	{
		if (pos < 0 || pos >= script.size)
		{
			return_state = SPUTM_ERROR;
			return;
		}
		
		script.code.seek(pos, SeekBegin);
	}
	
	public function jumpRel(offset: Int) : Void
	{
		var newpos: Int = script.code.tell() + offset;
		
		if (newpos < 0 || newpos >= script.size)
		{
			return_state = SPUTM_ERROR;
			return;
		}
		
		script.code.seek(newpos, SeekBegin);
	}
  
	public function beginOverride() : Bool
	{
		if (script.code.tell() + 3 > script.size)
			return false;
		
		override_stack.push(script.code.tell());
		return true;
	}
	
	public function endOverride() : Bool
	{
		override_stack.pop();
		return true;
	}
	
	public function doOverride() : Bool
	{
		script.code.seek(override_stack.pop(), SeekBegin);
		return true;
	}
	
	public function doOp() : Void
	{
		var r: SPUTMState;
		var op: Int;
		
		op = script.code.readChar();
		
		//if (op > 0x5E)
		//  trace("Execing opcode " + op);
		
		if (optable[op] == null)
		{
			trace(op + " not implemented!");
			return_state = SPUTM_ERROR;
			return;
		}
		
		optable[op](SPUTM.instance, vm_stack, this);
		
		if (return_state == SPUTM_ERROR)
		{
			trace("Error execing opcode " + op + " in script " + script.id + " @ " + ptr);
			trace(script.code.readInt8());
			trace(script.code.readInt8());
			trace(script.code.readInt8());
			trace(script.code.readInt8());
			trace(script.code.readInt8());
			trace(script.code.readInt8());
			trace(script.code.readInt8());
			trace(script.code.readInt8());
		}
	}
	
	public function readByte() : Int
	{
		return script.code.readChar();
	}
	
	public function readShort() : Int
	{
		return script.code.readUInt16();
	}
	
	public function readShortSigned() : Int
	{
		return script.code.readInt16();
	}
	
	/*
	public function readInt() : Int
	{
		return script.code.readUnsignedInt();
	}
	
	public function readIntSigned() : Int
	{
		return script.code.readInt();
	}
	*/
  
	public function getStrLen() : Int
	{
		var oldPos: Int = script.code.tell();
		var cur: Int = -1;
		
		while ((script.size - script.code.tell()) != 0)
		{
			cur = script.code.readChar();
			
			if (cur == 0)
				break;
			
			if (cur == 0xFF)
			{
				var type: Int = script.code.readChar();
				//script.code.readByte();
				if ((type < 1 || type > 3) && type != 8)
				{
					script.code.readUInt16(); // len += 2
				}
			}
		}
  
		cur = script.code.tell() - oldPos;
		script.code.seek(oldPos, SeekBegin);
		
		return cur-1;
	}
	
	public function run() : SPUTMState
	{
		var i: Int = 0;
		
		script.code.seek(ptr, SeekBegin);
		return_state = SPUTM_NONE;
		
		while (state == THREAD_RUNNING &&
		      cycle <= vm_cycle)
		{
			op_start = ptr;
			
			// Run, but stop to check interupts every 64 ops
			//while (state == THREAD_RUNNING &&
			//       cycle <= SPUTM.instance.vm_cycle &&
			//       i < 64)
			//{
			//	op_start = ptr;
				
				if (script.code.tell() >= script.size)
				{
					trace("End of script, abort!");
					return SPUTM_ERROR;
				}
				
				doOp();
				if (return_state != SPUTM_NONE)
				{
					break;
				}
				//i++;
			//}
			
			//break;
		}
		
		ptr = script.code.tell();
		
		return return_state;
	}
	
	public function stop()
	{
		state = THREAD_STOPPED;
	}
	
	public function printArgs()
	{
		for (tvar in vars)
		{
			if (tvar != 0)
				trace("VAR=" + tvar);
		}
	}
	
	// Thread flags
	
	static public var THREAD_FLAG_RECURSIVE = 0x1;
	static public var THREAD_FLAG_DELAYED = 0x2;
	
	// Thread pool
	
	static public var vm_threads: Array<SCUMMThread>;
	
	static public var vm_current_thread: SCUMMThread;
	static public var vm_next_thread: SCUMMThread;
	
	static public var vm_state: SPUTMState;
	static public var vm_cycle: Int;
	
	static public var vm_scripts: SPUTMResourceList;
	
	static public var vm_stack: SCUMMStack;
	
	static public var vm_time: Float; // redundant?
	
	static public function init(scripts: SPUTMResourceList)
	{
		vm_stack = new SCUMMStack();
		vm_scripts = scripts;
		
		vm_threads = new Array<SCUMMThread>();
		vm_threads[15] = null;
		for (i in 0...16)
		{
			vm_threads[i] = new SCUMMThread(i);
		}
		
		vm_current_thread = null;
		vm_next_thread = null;
		vm_cycle = 0;
		vm_time = 0;
		
		vm_state = SPUTM_BOOT;
	}
	
	static public function startScript(flags: Int, num: Int, args: Array<Int>) : Int
	{
		var script: Dynamic;
		
		// Grab the resource
		if (num >= 200)
		{
			// Local room script
			if ((script = SPUTM.instance.getRoomScript(num)) == null)
			{
				trace("Bad local script " + num);
				return -1;
			}
		}
		else
		{
			// Global script, needs to be loaded!
			script = vm_scripts.loadResource(num);
			if (script == null)
			{
				trace("Failed to load global script " + num);
				return -1; 
			}
		}
		
		// Run script
		if ((flags & THREAD_FLAG_RECURSIVE) != 0)
			stopScript(num);
		
		return startThread(cast(script, SCUMMScript), 0, flags, args);
	}
	
	static function stopScript(id: Int) : Int
	{
		var i: Int = 0;
		var n: Int = 0;
		
		for (i in 0...vm_threads.length)
		{
			var thread: SCUMMThread = vm_threads[i];
			
			if (thread.state == THREAD_STOPPED ||
			    thread.script == null ||
			    thread.script.id != id)
				continue;
			
			thread.stop();
			n++;
		}
		
		return n;
	}
	
	public static function startThread(script: SCUMMScript, ptr: Int, flags: Int, args: Array<Int>) : Int
	{
		//trace("startThread (script=" + script.id + " @ " + ptr + ")");
		
		var i: Int;
		var thread: SCUMMThread;
		
		thread = getFreeThread();
		if (thread == null)
		{
			trace("No Threads left to start script " + script.id);
			return -1;
		}
		
		thread.start(script, flags, ptr, vm_cycle, args, null);
		
		return thread.id;
	}
	
	static public function isScriptRunning(id: Int) : Bool
	{
		var thread: SCUMMThread = null;
		for (thread in vm_threads)
		{
			if (thread.state == THREAD_STOPPED ||
			    thread.script == null ||
			    thread.script.id != id)
				continue;
			return true;
		}
		
		return false;
	}
	
	static function getFreeThread() : SCUMMThread
	{
		var thread: SCUMMThread = null;
		for (thread in vm_threads)
		{
			if (thread.state == THREAD_STOPPED)
				return thread;
		}
		return null;
	}
	
	static public function switchToThread(thid: Int, next_state: SPUTMState) : Void
	{
		var thread: SCUMMThread = vm_threads[thid];
		vm_current_thread.state = THREAD_PENDED;
		thread.parent = vm_current_thread;
		thread.next_state = next_state;
		vm_current_thread = thread;
	}
	
	static public function processThreads(cycles: Int, now: Float) : Int
	{
		var i: Int = 0;
		var r: Int = 0;
		var delta: Float = 0;
		var now: Int = 0;
		var parent: SCUMMThread = null;
		var thread: SCUMMThread = null;
		
		// Note: continue used instead of break since haxe doesn't
		// support break in switch!
		//trace(vm_state);
		while (cycles > 0)
		{	
			switch(vm_state)
			{
				case SPUTM_ERROR:
					return -1;
				
				case SPUTM_BOOT:
					trace("boot state");
					r = startScript(0, 1, null);
					trace("Started");
					if (r < 0)
					{
						trace("Failed to start boot script!");
						return r;
					}
					//trace("switching to cycle");
					vm_state = SPUTM_BEGIN_CYCLE;
				case SPUTM_BEGIN_CYCLE:
					// Reschedule the delayed threads
					
					if (now < vm_time)
						delta = 0;
					else
						delta = now - vm_time;
					
					for (thread in vm_threads)
					{
						if (thread.state != THREAD_DELAYED)
							continue;
						
						if ((thread.flags & THREAD_FLAG_DELAYED) == 0)
							thread.flags |= THREAD_FLAG_DELAYED;
						else if (thread.delay > delta)
							thread.delay -= delta;
						else
						{
							thread.delay = 0;
							thread.flags &= -3; // ~THREAD_FLAG_DELAYED
							
							thread.state = THREAD_RUNNING;
						}
					}
					
					// Update the timers
					i = SPUTM.instance.getVar(SPUTM.VAR_TIMER_NEXT);
					SPUTM.instance.setVar(SPUTM.VAR_TIMER, 0);
					SPUTM.instance.incVar(SPUTM.VAR_TIMER1, i);
					SPUTM.instance.incVar(SPUTM.VAR_TIMER2, i);
					SPUTM.instance.incVar(SPUTM.VAR_TIMER3, i);
					
					// Run the scripts
					vm_state = SPUTM_RUNNING;
					vm_time = now;
      		
      		case SPUTM_START_SCRIPT:
      			
      			// reminds me of switchToThread...
      			parent = vm_current_thread;
      			vm_current_thread = vm_next_thread;
      			vm_next_thread = null;
      			vm_current_thread.parent = parent;
      			if (parent != null)
      				parent.state = THREAD_PENDED;
      			vm_state = SPUTM_RUNNING;
      		
				case SPUTM_RUNNING:
					cycles--;
					vm_cycle++;
					
					if (vm_current_thread == null)
					{
						i=0;
						for (thread in vm_threads)
						{
							if (thread.state == THREAD_RUNNING && 
							    thread.cycle <= vm_cycle)
							    	break;
							i++;
						}
						
						if (i >= vm_threads.length)
						{
							cycles--;
							vm_cycle++;
							vm_state = SPUTM_BEGIN_CYCLE;
							continue;
						}
						
						vm_current_thread = vm_threads[i];
					}
					
					//trace("THID=" + vm_current_thread.id + " SCRP=" + vm_current_thread.script.id + " @ " + vm_current_thread.ptr);
					var res_state = vm_current_thread.run();
					
					if (res_state == SPUTM_ERROR)
					{
						trace("Error running script");
						return -1;
					}
					else if (res_state != SPUTM_NONE)
					{
						trace("switch to " + res_state);
						vm_state = res_state;
						continue;
					}
										
					// Done with this thread for this cycle
					if (vm_current_thread.cycle <= vm_cycle)
						vm_current_thread.cycle = vm_cycle + 1;
					
					// Continue a job
					if (vm_current_thread.next_state != SPUTM_NONE)
					{
						vm_state = vm_current_thread.next_state;
						parent = vm_current_thread.parent;
						
						if (parent != null)
							parent.state = THREAD_RUNNING;
						
						vm_current_thread.next_state = SPUTM_NONE;
						vm_current_thread.parent = null;
						vm_current_thread = parent;
						
						continue;
					}
					
					// Nested call, switch back to the parent
					if (vm_current_thread.parent != null &&
					    vm_current_thread.parent.state == THREAD_PENDED)
					{
						parent = vm_current_thread.parent;
						vm_current_thread.parent = null;
						parent.state = THREAD_RUNNING;
						vm_current_thread = parent;
						
						trace("switch to parent (" + parent + ")");
						
						continue;
					}
					else
					{
						vm_current_thread = null;
					}
      				
				default:
					// For states not handled here, we switch over to SPUTM
					vm_state = SPUTM.instance.handleState(vm_state);
					if (vm_state == SPUTM_ERROR)
					{
						trace("Invalid State! " + vm_state);
						return -1;
					}
			}
		}
		
		return r;
	}
}

class SCUMMScript
{
	public var id: Int;
	public var code: MemoryIO;
	public var size: Int;
	
	public function new(num: Int)
	{
		id = num;
		code = null;
	}
}

class SCUMMScriptFactory extends SPUTMResourceFactory
{
	public function new()
	{
		super();
		
		name = "SCRIPT";
	}
	
	public function load(idx: Int, reader: ResourceIO) : Dynamic
	{
		// Need to load the bytecode from the offset
		var chunkID: Int32 = Int32.read(reader, true);
		var chunkSize: Int = Int32.toInt(Int32.read(reader, true));
		
		if (SPUTMResourceChunk.identify(chunkID) != CHUNK_SCRP)
		{
			trace("Bad script block (" + ChunkReader.chunkIDToStr(chunkID) + " )");
			return null;
		}
		
		var instance: SCUMMScript = new SCUMMScript(idx);
		
		instance.code = new MemoryIO();
		instance.code.prepare(chunkSize - 8);
		
		instance.code.writeInput(reader);
		instance.size = chunkSize - 8;
		
		return instance;
	}
}

