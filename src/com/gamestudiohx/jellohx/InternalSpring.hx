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

class InternalSpring {
	
	/// <summary>
	/// First PointMass the spring is connected to.
	/// </summary>
	public var pointMassA:Int;

	/// <summary>
	/// Second PointMass the spring is connected to.
	/// </summary>
	public var pointMassB:Int;

	/// <summary>
	/// The "rest length" (deisred length) of the spring.  at this length, no force is exerted on the points.
	/// </summary>
	public var springD:Float;

	/// <summary>
	/// spring constant, or "strength" of the spring.
	/// </summary>
	public var springK:Float;

	/// <summary>
	/// coefficient for damping, to reduce overshoot.
	/// </summary>
	public var damping:Float;

	public function new(pmA:Int = 0, pmB:Int = 0, d:Float = 0, k:Float = 0, damp:Float = 0):Void {
		pointMassA = pmA;
		pointMassB = pmB;
		springD = d;
		springK = k;
		damping = damp;
	}
	
}
