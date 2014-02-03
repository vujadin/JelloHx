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
// collision information
class BodyCollisionInfo
{
	public var bodyA : Body;
	public var bodyApm : Int;
	public var bodyB : Body;
	public var bodyBpmA : Int;
	public var bodyBpmB : Int;
	public var hitPt : Vector2;
	public var edgeD : Float;
	public var normal : Vector2;
	public var penetration : Float;

	public function new() : Void {
		bodyA = bodyB = null; 
		bodyApm = bodyBpmA = bodyBpmB = -1; 
		hitPt = new Vector2(); 
		edgeD = 0; 
		normal = new Vector2(); 
		penetration = 0;
	}

	public function Clear() : Void {
		bodyA = bodyB = null; 
		bodyApm = bodyBpmA = bodyBpmB = -1; 
		hitPt.setTo(0, 0); 
		edgeD = 0; 
		normal.setTo(0, 0); 
		penetration = 0;
	}
		
	public function clone() : BodyCollisionInfo {
		var r:BodyCollisionInfo = new BodyCollisionInfo();
		
		r.bodyA = this.bodyA;
		r.bodyApm = this.bodyApm;
		r.bodyB = this.bodyB;
		r.bodyBpmA = this.bodyBpmA;
		r.bodyBpmB = this.bodyBpmB;
		r.hitPt = this.hitPt.clone();
		r.edgeD = this.edgeD;
		r.normal = this.normal.clone();
		r.penetration = this.penetration;
		
		return r;
	}
	
	public function toString() : String {
		return hitPt + ":" + edgeD + ":" + normal + ":" + penetration;
	}
}
