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

import flash.display.Graphics;
import flash.geom.Vector3D;

/**
 * ...
 * @author Luiz
 */
class PressureBody extends SpringBody {
	
	// PRIVATE VARIABLES
	private var mVolume:Float;
	private var mGasAmount:Float;
	private var mNormalList:Array<Vector2>;
	private var mEdgeLengthList:Array<Float>;
	
	// CONSTRUCTORS
	/// <summary>
	/// Default constructor, with shape-matching ON.
	/// </summary>
	/// <param name="w">World object to add this body to</param>
	/// <param name="s">ClosedShape for this body</param>
	/// <param name="massPerPoint">mass per PointMass</param>
	/// <param name="gasPressure">amount of gas inside the body</param>
	/// <param name="shapeSpringK">shape-matching spring constant</param>
	/// <param name="shapeSpringDamp">shape-matching spring damping</param>
	/// <param name="edgeSpringK">spring constant for edges</param>
	/// <param name="edgeSpringDamp">spring damping for edges</param>
	/// <param name="pos">global position</param>
	/// <param name="angleInRadians">global angle</param>
	/// <param name="scale">scale</param>
	/// <param name="kinematic">kinematic control boolean</param>
	public function new(w:World, s:ClosedShape, massPerPoint:Float, gasPressure:Float, shapeSpringK:Float, shapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float, pos:Vector2, angleInRadians:Float, scale:Vector2, kinematic:Bool):Void {
		super(w, s, massPerPoint, shapeSpringK, shapeSpringDamp, edgeSpringK, edgeSpringDamp, pos, angleInRadians, scale, kinematic);
		
		mGasAmount = gasPressure;
		mNormalList = new Array<Vector2>();
		//mNormalList.length = mPointMasses.length;
		
		mEdgeLengthList = new Array<Float>();
		//mEdgeLengthList.length = mPointMasses.length;
	}

	// PRESSURE
	/// <summary>
	/// Amount of gas inside the body.
	/// </summary>
	public var GasPressure(get, set):Float;
	public function get_GasPressure():Float {
		return mGasAmount;
	}	
	public function set_GasPressure(value:Float):Float {
		mGasAmount = value;
		return value;
	}
	
	// VOLUME
	/// <summary>
	/// Gets the last calculated volume for the body.
	/// </summary>
	public var Volume(get, never):Float;
	public function get_Volume():Float {
		return mVolume;
	}
	
	// ACCUMULATING FORCES
	inline public override function accumulateInternalForces():Void {
		super.accumulateInternalForces();
		
		// internal forces based on pressure equations.  we need 2 loops to do this.  one to find the overall volume of the
		// body, and 1 to apply forces.  we will need the normals for the edges in both loops, so we will cache them and remember them.
		mVolume = 0;
		
		var edge1NX:Float, edge1NY:Float, edge2NX:Float, edge2NY:Float, t:Float;
		var normX:Float, normY:Float;
		
		var prev:Int;
		var next:Int;
		var nL:Float;
		var edgeL:Float;
		var xdist:Float;
		var volumeProduct:Float;
		for (i in 0...mPointMasses.length) {
			prev = (i > 0) ? i - 1 : mPointMasses.length - 1;
			next = (i + 1) % (mPointMasses.length);
			
			// currently we are talking about the edge from i --> j.
			// first calculate the volume of the body, and cache normals as we go.
			edge1NX = mPointMasses[i].PositionX - mPointMasses[prev].PositionX;
			edge1NY = mPointMasses[i].PositionY - mPointMasses[prev].PositionY;
			
			t = edge1NX;
			
			edge1NX = -edge1NY;
			edge1NY = t;			
			
			edge2NX = mPointMasses[next].PositionX - mPointMasses[i].PositionX;
			edge2NY = mPointMasses[next].PositionY - mPointMasses[i].PositionY;
			
			t = edge2NX;
			
			edge2NX = -edge2NY;
			edge2NY = t;			
			
			normX = edge1NX + edge2NX;
			normY = edge1NY + edge2NY;
			
			nL = (normX * normX) + (normY * normY);
			
			if (nL > 0.001) {
				normX /= nL;
				normY /= nL;
			}
			
			edgeL = Math.sqrt((edge2NX * edge2NX) + (edge2NY * edge2NY));
			
			// cache normal and edge length
			mNormalList[i] = new Vector2(normX, normY);
			mEdgeLengthList[i] = edgeL;
			
			xdist = Math.abs(mPointMasses[i].PositionX - mPointMasses[next].PositionX);
			
			volumeProduct = xdist * (normX < 0 ? -normX : normX) * edgeL;
			
			// add to volume
			mVolume += 0.5 * volumeProduct;
		}
		
		// now loop through, adding forces!
		var invVolume:Float = 1 / mVolume;
		var j:Int;
		var pressureV:Float;
		for (i in 0...mPointMasses.length) {
			j = (i < mPointMasses.length - 1) ? i + 1 : 0;
			
			pressureV = (invVolume * mEdgeLengthList[i] * mGasAmount);
			
			mPointMasses[i].ForceX += mNormalList[i].X * pressureV;
			mPointMasses[i].ForceY += mNormalList[i].Y * pressureV;
			
			mPointMasses[j].ForceX += mNormalList[j].X * pressureV;
			mPointMasses[j].ForceY += mNormalList[j].Y * pressureV;
		}
	}
	
	// DEBUG VISUALIZATION
	public override function debugDrawMe(g:Graphics):Void {		
		var s:Vector2 = RenderingSettings.Scale;
		var p:Vector2 = RenderingSettings.Offset;
		
		var edge1N:Vector2;
		var edge2N:Vector2;
		var norm:Vector2;
		var nL:Float;
		var prev:Int;
		var next:Int;
		for (i in 0...mPointMasses.length) {
			prev = (i > 0) ? i - 1 : mPointMasses.length - 1;
			next = (i < mPointMasses.length - 1) ? i + 1 : 0;
			
			// currently we are talking about the edge from i --> j.
			// first calculate the volume of the body, and cache normals as we go.
			edge1N = new Vector2(mPointMasses[i].PositionX - mPointMasses[prev].PositionX,
											 mPointMasses[i].PositionY - mPointMasses[prev].PositionY).perpendicular();
			
			edge1N.normalizeThis();
			
			edge2N = new Vector2(mPointMasses[next].PositionX - mPointMasses[i].PositionX,
											 mPointMasses[next].PositionY - mPointMasses[i].PositionY).perpendicular();
			
			edge2N.normalizeThis();
			
			norm = edge1N.plus(edge2N);
			nL = norm.magnitude();
			
			if (nL > 0.001)
				norm.normalizeThis();
			
			norm.multEquals(mPointMasses[i].Mass);
			
			g.lineStyle(1, 0xF0FFF0);
			g.moveTo(mPointMasses[i].PositionX * s.X + p.X, mPointMasses[i].PositionY * s.Y + p.Y);
			g.lineTo((mPointMasses[i].PositionX + norm.X) * s.X + p.X, (mPointMasses[i].PositionY + norm.Y) * s.Y + p.Y);
		}
		
		super.debugDrawMe(g);
	}
}
