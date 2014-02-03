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

class DraggablePressureBody extends PressureBody {
	
	// Variables for dragging point masses in this body	
	private var dragForce:Vector2;
	private var dragPoint:Int;

	var mIndices:Array<Int>;
	var mIndexList:Array<Int>;
	var mColor:Int;
	var mDistressColor:Int;

	public function new(w:World, s:ClosedShape, massPerPoint:Float, gasPressure:Float, shapeSpringK:Float, shapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float, pos:Vector2, angleInRadians:Float, scale:Vector2):Void {
		super(w, s, massPerPoint, gasPressure, shapeSpringK, shapeSpringDamp, edgeSpringK, edgeSpringDamp, pos, angleInRadians, scale, false);
		
		dragForce = Vector2.Zero.clone();
		dragPoint = -1;
		mIndices = new Array<Int>();
		mIndexList = new Array<Int>();
		mColor = 0xFFFFFF;
		mDistressColor = 0xFF0000;
	}

	// add an indexed triangle to this primitive.
	public function addTriangle(A:Int, B:Int, C:Int):Void {
		mIndexList.push(A);
		mIndexList.push(B);
		mIndexList.push(C);
	}
	
	public function finalizeTriangles(c:Int, d:Int):Void {
		mIndices = new Array<Int>();
		
		for (i in 0...mIndexList.length) {
			mIndices.push(mIndexList[i]);
		}

		mColor = c;
		mDistressColor = d;
	}

	public function setDragForce(force:Vector2, pm:Int) : Void {
		dragForce = force;
		dragPoint = pm;
	}

	// add gravity, and drag force.
	public override function accumulateExternalForces() : Void {
		super.accumulateExternalForces();

		// gravity
		for (i in 0...mPointMasses.length) {
			mPointMasses[i].ForceY += -9.8 * mPointMasses[i].Mass;
		}

		// dragging force.
		if (dragPoint != -1) {
			mPointMasses[dragPoint].ForceX += dragForce.X;
			mPointMasses[dragPoint].ForceY += dragForce.Y;
		}

		dragPoint = -1;
	}


	public function drawMe(g:Graphics) : Void {
		super.debugDrawMe(g);
		var pm_count = mPointMasses.length;
		
		var s:Vector2 = RenderingSettings.Scale;
		var p:Vector2 = RenderingSettings.Offset;
		
		g.beginFill(mColor);
		
		var posX:Float;
		var posY:Float;
		for (i in 0...pm_count) {
			posX = mPointMasses[i].PositionX * s.X + p.X;
			posY = mPointMasses[i].PositionY * s.Y + p.Y;
			
			if(i == 0)
				g.moveTo(posX, posY);
			
			g.lineTo(posX, posY);
		}
		
		g.endFill();
	}
}
