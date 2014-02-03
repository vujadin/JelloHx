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
class VectorTools {
	
	/// <summary>
	///  rotate a vector by a given angle (in radians).
	/// </summary>
	/// <param name="vec">vector</param>
	/// <param name="angleRadians">angle in radians</param>
	/// <returns>rotated vector</returns>
	inline public static function rotateVector(vec:Vector2, angleRadians:Float):Vector2 {
		var ret:Vector2 = new Vector2();
		// If ther's nothing to rotate, then don't!
		if(angleRadians == 0) {
			ret = vec.clone();
		} else {
			var c:Float = Math.cos(angleRadians);
			var s:Float = Math.sin(angleRadians);
			
			ret.X = (c * vec.X) - (s * vec.Y);
			ret.Y = (c * vec.Y) + (s * vec.X);
		}
		return ret;
	}
		
	/// <summary>
	/// Reflect a vector about a normal.  Normal must be a unit vector.
	/// </summary>
	/// <param name="V">vector</param>
	/// <param name="N">normal</param>
	/// <returns>reflected vector</returns>
	inline public static function reflectVector(V:Vector2, N:Vector2):Vector2 {
		return V.minus(N.mult(2 * Vector2.Dot(V, N)));
	}
		
	/// <summary>
	/// get a vector perpendicular to this vector.
	/// </summary>
	/// <param name="vec">vector</param>
	/// <returns>perpendicular vector</returns>
	inline public static function getPerpendicular1(vec:Vector2):Vector2 {
		return new Vector2(-vec.Y, vec.X);
	}
	
	/// <summary>
	/// get a vector perpendicular to this vector (reference type version)
	/// </summary>
	/// <param name="vIn">vector int</param>
	/// <param name="vOut">perpendicular vector out</param>
	inline public static function getPerpendicular(vIn:Vector2, vOut:Vector2):Void {
		vOut.X = -vIn.Y;
		vOut.Y = vIn.X;
	}
	
	/// <summary>
	/// make this vector perpendicular to itself
	/// </summary>
	/// <param name="vIn">vector in / out</param>
	inline public static function makePerpendicular(v:Vector2):Void {
		v.perpendicular();
	}
		
	/// <summary>
	/// is rotating from A to B Counter-Clockwise?
	/// </summary>
	/// <param name="A">vector A</param>
	/// <param name="B">vector B</param>
	/// <returns>true = CCW or opposite (180 degrees), false = CW</returns>
	private static var perp:Vector2 = new Vector2();
	inline public static function isCCW(A:Vector2, B:Vector2):Bool {
		VectorTools.getPerpendicular(A, perp);		
		return (B.dot(perp) >= 0.0);
	}
		
	/// <summary>
	/// turn a Vector2 into a Vector3, specifying the Z component to use.
	/// </summary>
	/// <param name="vec">input Vector2</param>
	/// <param name="Z">Z component</param>
	/// <returns>result Vector3</returns>
	inline public static function vec3FromVec2(vec:Vector2, Z:Float = 0):Vector3 {
		return new Vector3(vec.X, vec.Y, Z);
	}
		
	/// <summary>
	/// see if 2 line segments intersect. (line AB collides with line CD) (reference type version)
	/// </summary>
	/// <param name="ptA">first point on line AB</param>
	/// <param name="ptB">second point on line AB</param>
	/// <param name="ptC">first point on line CD</param>
	/// <param name="ptD">second point on line CD</param>
	/// <param name="hitPt">resulting point of intersection</param>
	/// <param name="Ua">distance along AB to intersection [0,1]</param>
	/// <param name="Ub">distance along CD to intersection [0,1]</param>
	/// <returns>true / false</returns>
	// TODO: Fix out those out parameters
	inline public static function lineIntersect(ptA:Vector2, ptB:Vector2, ptC:Vector2, ptD:Vector2, hitPt:Vector2, Ua:Array<Float>, Ub:Array<Float>):Bool {
		var ret = false;
		hitPt = Vector2.Zero;
		Ua[0] = 0.0;
		Ub[0] = 0.0;
		
		var denom:Float = ((ptD.Y - ptC.Y) * (ptB.X - ptA.X)) - ((ptD.X - ptC.X) * (ptB.Y - ptA.Y));
		
		// if denom == 0, lines are parallel - being a bit generous on this one..
		if ((denom < 0 ? - denom : denom) < 0.000001) {
			ret = false;
		} else {
			var UaTop:Float = ((ptD.X - ptC.X) * (ptA.Y - ptC.Y)) - ((ptD.Y - ptC.Y) * (ptA.X - ptC.X));
			var UbTop:Float = ((ptB.X - ptA.X) * (ptA.Y - ptC.Y)) - ((ptB.Y - ptA.Y) * (ptA.X - ptC.X));
			
			var revDenom = 1 / denom;
			
			Ua[0] = UaTop * revDenom;
			Ub[0] = UbTop * revDenom;
			
			if ((Ua[0] >= 0) && (Ua[0] <= 1) && (Ub[0] >= 0) && (Ub[0] <= 1)) {
				// these lines intersect!
				hitPt = ptA.plus(ptB.minus(ptA).mult(Ua[0]));
				
				ret = true;
			}
		}
		
		return ret;
	}
	
	/// calculate a spring force, given position, velocity, spring constant, and damping factor. (reference type version)
	/// @param posA position of point A on spring
	/// @param velA velocity of point A on spring
	/// @param posB position of point B on spring
	/// @param velB velocity of point B on spring
	/// @param springD rest distance of the springs
	/// @param springK spring constant
	/// @param damping coefficient for damping
	/// @param forceOut rsulting force Vector2
	inline public static function calculateSpringForce(posA:Vector2, velA:Vector2, posB:Vector2, velB:Vector2, springD:Float, springK:Float, damping:Float, forceOut:Vector2):Void {
		var BtoAX:Float = (posA.X - posB.X);
		var BtoAY:Float = (posA.Y - posB.Y);
		
		var dist:Float = Math.sqrt((BtoAX * BtoAX) + (BtoAY * BtoAY));
		
		if (dist > 0.0001) {
			var revDist = 1 / dist;
			
			BtoAX *= revDist;
			BtoAY *= revDist;
			
			dist = springD - dist;
		
			var relVelX:Float = velA.X - velB.X;
			var relVelY:Float = velA.Y - velB.Y;
			
			var totalRelVel:Float = (relVelX * BtoAX) + (relVelY * BtoAY);
			
			forceOut.X = BtoAX * ((dist * springK) - (totalRelVel * damping));
			forceOut.Y = BtoAY * ((dist * springK) - (totalRelVel * damping));
		
		} else {
			forceOut.X = 0;
			forceOut.Y = 0;
		}
	}
	
	inline public static function calculateSpringForceNum(posAX:Float, posAY:Float, velAX:Float, velAY:Float, posBX:Float, posBY:Float, velBX:Float, velBY:Float, springD:Float, springK:Float, damping:Float, forceOut:Vector2):Void {
		var BtoAX:Float = (posAX - posBX);
		var BtoAY:Float = (posAY - posBY);
		
		var dist:Float = Math.sqrt((BtoAX * BtoAX) + (BtoAY * BtoAY));
		
		if (dist > 0.0001) {
			var revDist = 1 / dist;
			
			BtoAX *= revDist;
			BtoAY *= revDist;
			
			dist = springD - dist;
		
			var relVelX:Float = velAX - velBX;
			var relVelY:Float = velAY - velBY;
			
			var totalRelVel:Float = (relVelX * BtoAX) + (relVelY * BtoAY);
			
			forceOut.X = BtoAX * ((dist * springK) - (totalRelVel * damping));
			forceOut.Y = BtoAY * ((dist * springK) - (totalRelVel * damping));
			
		} else {
			forceOut.X = 0;
			forceOut.Y = 0;
		}	
	}
	
	inline public static function calculateSpringForceRetPos(posAX:Float, posAY:Float, velAX:Float, velAY:Float, posBX:Float, posBY:Float, velBX:Float, velBY:Float, springD:Float, springK:Float, damping:Float):Vector2 {
		var ret:Vector2 = Vector2.Zero.clone();
		var BtoAX:Float = (posAX - posBX);
		var BtoAY:Float = (posAY - posBY);
		
		var dist:Float = Math.sqrt((BtoAX * BtoAX) + (BtoAY * BtoAY));
		
		if (dist > 0.0001) {
			BtoAX /= dist;
			BtoAY /= dist;
			
			dist = springD - dist;
		
			var relVelX:Float = velAX - velBX;
			var relVelY:Float = velAY - velBY;
			
			var totalRelVel:Float = (relVelX * BtoAX) + (relVelY * BtoAY);
			
			ret = new Vector2(BtoAX * ((dist * springK) - (totalRelVel * damping)), BtoAY * ((dist * springK) - (totalRelVel * damping)));
			
		} 
		
		return ret;
	}
	
	inline public static function calculateSpringForceRet(posA:Vector2, velA:Vector2, posB:Vector2, velB:Vector2, springD:Float, springK:Float, damping:Float):Vector2 {
		var ret:Vector2 = Vector2.Zero.clone();
		var BtoAX:Float = (posA.X - posB.X);
		var BtoAY:Float = (posA.Y - posB.Y);
		
		var dist:Float = Math.sqrt((BtoAX * BtoAX) + (BtoAY * BtoAY));
		
		if (dist > 0.0001) {
			BtoAX /= dist;
			BtoAY /= dist;
			
			dist = springD - dist;
			
			var relVelX:Float = velA.X - velB.X;
			var relVelY:Float = velA.Y - velB.Y;
			
			var totalRelVel:Float = (relVelX * BtoAX) + (relVelY * BtoAY);
			
			ret = new Vector2(BtoAX * ((dist * springK) - (totalRelVel * damping)), BtoAY * ((dist * springK) - (totalRelVel * damping)));
		} 
		
		return ret;
	}
}
