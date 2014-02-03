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
class PointMass {
	
	// PRIVATE VARIABLES
	////////////////////////////////////////////////////////////////
	/// <summary>
	/// Mass of thie PointMass.
	/// </summary>
	public var Mass:Float;

	/// <summary>
	/// Global position of the PointMass.
	/// </summary>	
	public var PositionX:Float;
	public var PositionY:Float;

	
	/// Global velocity of the PointMass.
	public var VelocityX:Float = 0;
	public var VelocityY:Float = 0;
	
	public var ForceX:Float = 0;
	public var ForceY:Float = 0;

	// CONSTRUCTOR
	public function new(mass:Float = 0.0, pos:Vector2 = null):Void {
		Mass = mass;
				
		PositionX = (pos == null ? 0 : pos.X);
		PositionY = (pos == null ? 0 : pos.Y);
	}

	// INTEGRATION
	////////////////////////////////////////////////////////////////
	/// <summary>
	/// integrate Force >> Velocity >> Position, and reset force to zero.
	/// this is usually called by the World.update() method, the user should not need to call it directly.
	/// </summary>
	/// <param name="elapsed">time elapsed in seconds</param>
	inline public function integrateForce(elapsed:Float):Void {
		if (Mass != Math.POSITIVE_INFINITY) {
			var elapMass:Float = elapsed / Mass;
			
			VelocityX += (ForceX * elapMass);
			VelocityY += (ForceY * elapMass);

			PositionX += (VelocityX * elapsed);
			PositionY += (VelocityY * elapsed);
		}

		ForceX = 0.0;
		ForceY = 0.0;
	}
	
	public function VecPos():Vector2 {
		return new Vector2(PositionX, PositionY);
	}
}
