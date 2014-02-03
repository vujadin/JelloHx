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

/**
 * ...
 * @author Luiz
 */
class SpringBody extends Body {
	
	// PRIVATE VARIABLES
	public var mSprings:Array<InternalSpring>;
	
	// shape-matching spring constants.
	public var mShapeMatchingOn:Bool;
	public var mEdgeSpringK:Float;
	public var mEdgeSpringDamp:Float;
	public var mShapeSpringK:Float;
	public var mShapeSpringDamp:Float;
	
	//// debug visualization variables
	// VertexDeclaration mVertexDecl = null;
	
	// CONSTRUCTOR	
	// <summary>
	/// Create a SpringBody with shape matching turned ON.
	/// </summary>
	/// <param name="w"></param>
	/// <param name="shape">ClosedShape shape for this body</param>
	/// <param name="massPerPoint">mass per PointMass.</param>
	/// <param name="shapeSpringK">shape-matching spring constant</param>
	/// <param name="shapeSpringDamp">shape-matching spring damping</param>
	/// <param name="edgeSpringK">spring constant for edges.</param>
	/// <param name="edgeSpringDamp">spring damping for edges</param>
	/// <param name="pos">global position</param>
	/// <param name="angleinRadians">global angle</param>
	/// <param name="scale">scale</param>
	/// <param name="kinematic">kinematic control boolean</param>
	public function new(w:World, shape:ClosedShape, massPerPoint:Float, shapeSpringK:Float, shapeSpringDamp:Float, edgeSpringK:Float, edgeSpringDamp:Float, pos:Vector2, angleinRadians:Float, scale:Vector2, kinematic:Bool):Void {
		super(w, shape, Utils.fillArray(massPerPoint, shape.mLocalVertices.length), pos, angleinRadians, scale, kinematic);
		
		mSprings = new Array<InternalSpring>();
		
		super.setPositionAngle(pos, angleinRadians, scale);
		
		mShapeMatchingOn = true;
		mShapeSpringK = shapeSpringK;
		mShapeSpringDamp = shapeSpringDamp;
		mEdgeSpringK = edgeSpringK;
		mEdgeSpringDamp = edgeSpringDamp;
		
		// build default springs.
		_buildDefaultSprings();
	}
	
	// SPRINGS
	/// <summary>
	/// Add an internal spring to this body.
	/// </summary>
	/// <param name="pointA">point mass on 1st end of the spring</param>
	/// <param name="pointB">point mass on 2nd end of the spring</param>
	/// <param name="springK">spring constant</param>
	/// <param name="damping">spring damping</param>
	public function addInternalSpring(pointA:Int, pointB:Int, springK:Float, damping:Float):Void {		
		var dx:Float = mPointMasses[pointB].PositionX - mPointMasses[pointA].PositionX;
		var dy:Float = mPointMasses[pointB].PositionY - mPointMasses[pointA].PositionY;
		
		var dist:Float = Math.sqrt(dx * dx + dy * dy);
		
		var s:InternalSpring = new InternalSpring(pointA, pointB, dist, springK, damping);
		
		mSprings.push(s);
	}
	
	/// <summary>
	/// Clear all springs from the body.
	/// </summary>
	/// <param name="k"></param>
	/// <param name="damp"></param>
	public function clearAllSprings():Void {
		mSprings = [];
		
		_buildDefaultSprings();
	}
	
	private function _buildDefaultSprings():Void {
		for (i in 0...mPointMasses.length) {
			i < (mPointMasses.length - 1) ? addInternalSpring(i, i + 1, mEdgeSpringK, mEdgeSpringDamp) : addInternalSpring(i, 0, mEdgeSpringK, mEdgeSpringDamp);
		}
	}
	
	// SHAPE MATCHING
	/// <summary>
	/// Set shape-matching on/off.
	/// </summary>
	/// <param name="onoff">boolean</param>
	public function setShapeMatching(onoff:Bool):Void { 
		mShapeMatchingOn = onoff; 
	}
	
	/// <summary>
	/// Set shape-matching spring constants.
	/// </summary>
	/// <param name="springK">spring constant</param>
	/// <param name="damping">spring damping</param>
	public function setShapeMatchingConstants(springK:Float, damping:Float):Void { 
		mShapeSpringK = springK; 
		mShapeSpringDamp = damping; 
	}
	
	// ADJUSTING EDGE VALUES
	/// <summary>
	/// Change the spring constants for the springs around the shape itself (edge springs)
	/// </summary>
	/// <param name="edgeSpringK">spring constant</param>
	/// <param name="edgeSpringDamp">spring damping</param>
	public function setEdgeSpringConstants(edgeSpringK:Float, edgeSpringDamp:Float):Void {
		// we know that the first n springs in the list are the edge springs.
		for (i in 0...mPointMasses.length) {
			mSprings[i].springK = edgeSpringK;
			mSprings[i].damping = edgeSpringDamp;
		}
	}
	
	// ADJUSTING SPRING VALUES
	public function setSpringConstants(springID:Int, springK:Float, springDamp:Float):Void {
		// index is for all internal springs, AFTER the default internal springs.
		var index:Int = mPointMasses.length + springID;
		
		mSprings[index].springK = springK;
		mSprings[index].damping = springDamp;
	}
	
	public function getSpringK(springID:Int):Float {
		var index:Int = mPointMasses.length + springID;		
		return mSprings[index].springK;
	}
	
	public function getSpringDamping(springID:Int):Float {
		var index:Int = mPointMasses.length + springID;		
		return mSprings[index].damping;
	}
	
	// ACCUMULATING FORCES
	public override function accumulateInternalForces():Void {
		super.accumulateInternalForces();
		
		// internal spring forces.
		var force:Vector2 = new Vector2();
		
		var s:InternalSpring;
		var p1:PointMass;
		var p2:PointMass;
		for (i in 0...mSprings.length) {
			s = mSprings[i];
			
			p1 = mPointMasses[s.pointMassA];
			p2 = mPointMasses[s.pointMassB];
			
			VectorTools.calculateSpringForceNum(p1.PositionX, p1.PositionY,
												p1.VelocityX, p1.VelocityY,
												p2.PositionX, p2.PositionY,
												p2.VelocityX, p2.VelocityY,
												s.springD, s.springK, s.damping, force);
				
			p1.ForceX += force.X;
			p1.ForceY += force.Y;
			
			p2.ForceX -= force.X;
			p2.ForceY -= force.Y;
		}
		
		// shape matching forces.
		if (mShapeMatchingOn) {
			mGlobalShape = mBaseShape.transformVertices(mDerivedPos, mDerivedAngle, mScale);
			var p:PointMass = null;
			
			for (i in 0...mPointMasses.length) {
				p = mPointMasses[i];
				
				if (mShapeSpringK > 0) {
					if (!mKinematic) {
						VectorTools.calculateSpringForceNum(p.PositionX, p.PositionY, 
															p.VelocityX, p.VelocityY,
															mGlobalShape[i].X, mGlobalShape[i].Y,
															p.VelocityX, p.VelocityY,
															0.0, mShapeSpringK, mShapeSpringDamp, force);
					} else {						
						VectorTools.calculateSpringForceNum(p.PositionX, p.PositionY,
															p.VelocityX, p.VelocityY,
															mGlobalShape[i].X, mGlobalShape[i].Y,
															0, 0,
															0.0, mShapeSpringK, mShapeSpringDamp, force);
					}
					
					p.ForceX += force.X;
					p.ForceY += force.Y;
				}
			}
		}
	}
	
	// DEBUG VISUALIZATION
	public override function debugDrawMe(g:Graphics):Void {
		
		var s:Vector2 = RenderingSettings.Scale;
		var p:Vector2 = RenderingSettings.Offset;
		
		g.lineStyle(0, 0, 0);
		
		var x:Float;
		var y:Float;
		var w:Float;
		var h:Float;
		for (i in 0...mPointMasses.length) {
			g.beginFill(0x7CFC00);
			
			x = mPointMasses[i].PositionX;// - RenderingSettings.PointSize / 2;
			y = mPointMasses[i].PositionY;// - RenderingSettings.PointSize / 2;
			w = RenderingSettings.PointSize * 2;
			h = RenderingSettings.PointSize * 2;
			
			g.drawRect(x * s.X + p.X - RenderingSettings.PointSize, y * s.Y + p.Y - RenderingSettings.PointSize, w, h);			
			g.endFill();			
			g.beginFill(0x808080);
			
			x = mGlobalShape[i].X;
			y = mGlobalShape[i].Y;
			w = RenderingSettings.PointSize * 2;
			h = RenderingSettings.PointSize * 2;
			
			g.drawRect(x * s.X + p.X - RenderingSettings.PointSize, y * s.Y + p.Y - RenderingSettings.PointSize, w, h);			
			g.endFill();			
			g.lineStyle(1, 0x808080);			
			g.moveTo(x * s.X + p.X, y * s.Y + p.Y);			
			g.lineTo(mPointMasses[i].PositionX * s.X + p.X, mPointMasses[i].PositionY * s.Y + p.Y);
		}
		
		for (i in 0...mSprings.length) {
			g.lineStyle(0, 0x7CFC00);
			
			g.moveTo(mPointMasses[mSprings[i].pointMassA].PositionX * s.X + p.X, mPointMasses[mSprings[i].pointMassA].PositionY * s.Y + p.Y);
			g.lineTo(mPointMasses[mSprings[i].pointMassB].PositionX * s.X + p.X, mPointMasses[mSprings[i].pointMassB].PositionY * s.Y + p.Y);
		}
		
		super.debugDrawMe(g);
	}
}
