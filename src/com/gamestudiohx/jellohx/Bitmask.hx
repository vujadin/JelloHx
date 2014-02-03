/*
Copyright (c) 2007 Walaber

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package com.gamestudiohx.jellohx;

/**
 * ...
 * @author Luiz
 */
class Bitmask {
	
	public var mask:Int;
	
	public function new(m:Int = 0):Void {
		mask = m;
	}
	
	public function clear():Void { 
		mask = 0x00;
	}
	
	public function setOn(bit:Int):Void {
		mask |= (0x01 << ((bit > 0) ? (bit - 1) : 0));
	}
	
	public function setOff(bit:Int):Void {
		mask &= ~(0x01 << ((bit > 0) ? (bit - 1) : 0));
	}
	
	public function clone():Bitmask {
		return new Bitmask(mask);
	}
}
