hiscumm
*******

In order to compile hiscumm, you will need haXe which can be found at http://www.haxe.org/ .
Then all you need to do is compile compile.hxml, like so:

	haxe compile.xml

Which should output test.swf.

Sadly hiscumm does not yet implement all of the functionality required to run a SCUMM game, so 
it is recommended that you download Alban Bedel's scummc compiler and compile the "road" example.
Place its resource files (scummc.000 and scummc.001) in the directory in which "test.html" resides.

The "road" example only requires a limited subset of SCUMM opcodes in order to reach its main 
input processing stage, and so will not error out prior to hiscumm displaying the initial room 
image.

License
*******

hiscumm is licensed under the GNU GPL version 2 and (C) 2007 James S Urquhart. Details should be enclosed in the "LICENSE.txt" 
file included in the distribution.

Contact
*******

Any questions, suggestions, or contributions should be directed to the following email address:
	jamesu (at) gmail.com

