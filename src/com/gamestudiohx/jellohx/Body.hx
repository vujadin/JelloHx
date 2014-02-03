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
class Body {
	
	// PRIVATE VARIABLES
	public var mBaseShape:ClosedShape;
	public var mGlobalShape:Array<Vector2>;
	public var mPointMasses:Array<PointMass>;
	public var mScale:Vector2;
	public var mDerivedPos:Vector2;
	public var mDerivedVel:Vector2;
	public var mDerivedAngle:Float;
	public var mDerivedOmega:Float;
	public var mLastAngle:Float;
	public var mAABB:AABB;
	public var mMaterial:Int;
	public var mIsStatic:Bool;
	public var mKinematic:Bool;
	public var mObjectTag:Dynamic;
	
	public var mIsPined:Bool = false;
	
	public var mVelDamping:Float = 0.999;
	
	//// debug visualization variables
	// VertexDeclaration mVertexDecl = null;
	
	
	// INTERNAL VARIABLES
	public var mBitMaskX:Bitmask;
	public var mBitMaskY:Bitmask;
	
	
	// CONSTRUCTORS
	
	/// <summary>
	/// create a body, and set its shape and position immediately - with individual masses for each PointMass.
	/// </summary>
	/// <param name="w">world to add this body to (done automatically)</param>
	/// <param name="shape">closed shape for this body</param>
	/// <param name="pointMasses">list of masses for each PointMass</param>
	/// <param name="position">global position of the body</param>
	/// <param name="angleInRadians">global angle of the body</param>
	/// <param name="scale">local scale of the body</param>
	/// <param name="kinematic">whether this body is kinematically controlled.</param>
	public function new(w:World, shape:ClosedShape, pointMasses:Array<Float>, position:Vector2, angleInRadians:Float, scale:Vector2, kinematic:Bool):Void {
		mAABB = new AABB();
		mDerivedPos = position;
		mDerivedAngle = angleInRadians;
		mLastAngle = mDerivedAngle;
		mScale = scale;
		mMaterial = 0;
		mIsStatic = false;
		mKinematic = kinematic;
		mVelDamping = 0.999;
		mIsPined = false;
		
		mBitMaskX = new Bitmask();
	    mBitMaskY = new Bitmask();
		
		mPointMasses = new Array<PointMass>();
		setShape(shape);
		
		for (i in 0...mPointMasses.length) {
			mPointMasses[i].Mass = pointMasses[i];
		}
			
		updateAABB(0, true);
		
		if(w != null) {
			w.addBody(this);
		}
	}
		
	
	// SETTING SHAPE
	/// <summary>
	/// set the shape of this body to a new ClosedShape object.  This function 
	/// will remove any existing PointMass objects, and replace them with new ones IF
	/// the new shape has a different vertex count than the previous one.  In this case
	/// the mass for each newly added point mass will be set zero.  Otherwise the shape is just
	/// updated, not affecting the existing PointMasses.
	/// </summary>
	/// <param name="shape">new closed shape</param>
	public function setShape(shape:ClosedShape):Void {
		mBaseShape = shape;
		
		if (mBaseShape.Vertices.length != mPointMasses.length) {
			mPointMasses = [];			
			mGlobalShape = mBaseShape.transformVertices(mDerivedPos, mDerivedAngle, mScale);
			
			for (i in 0...mBaseShape.Vertices.length) {
				mPointMasses.push(new PointMass(0.0, mGlobalShape[i]));    
			}
		}
	}
	
	
	// SETTING MASS
	/// <summary>
	/// set the mass for each PointMass in this body.
	/// </summary>
	/// <param name="mass">new mass</param>
	public function setMassAll(mass:Float):Void {
		for (i in 0...mPointMasses.length) {
			mPointMasses[i].Mass = mass;
		}
		
		if (Math.POSITIVE_INFINITY == mass) { 
			mIsStatic = true; 
		}
	}
	
	/// <summary>
	/// set the mass for each PointMass individually.
	/// </summary>
	/// <param name="index">index of the PointMass</param>
	/// <param name="mass">new mass</param>
	public function setMassIndividual(index:Int, mass:Float):Void {
		if ((index >= 0) && (index < mPointMasses.length))
			mPointMasses[index].Mass = mass;
	}
	
	/// <summary>
	/// set the mass for all point masses from a list.
	/// </summary>
	/// <param name="masses">list of masses (count MUSE equal PointMasses.length)</param>
	public function setMassFromList(masses:Array<Float>):Void {
		if (masses.length == mPointMasses.length) {
			for (i in 0...mPointMasses.length) {
				mPointMasses[i].Mass = masses[i];
			}
		}
	}
	
	
	// MATERIAL
	/// <summary>
	/// Material for this body.  Used for physical interaction and collision notification.
	/// </summary>
	public var Material(get, set):Int;
	public function get_Material():Int {
		return mMaterial;
	}	
	public function set_Material(value:Int):Int {
		mMaterial = value;
		return value;
	}
	
	
	// SETTING POSITION AND ANGLE MANUALLY
	/// <summary>
	/// Set the position and angle of the body manually.
	/// </summary>
	/// <param name="pos">global position</param>
	/// <param name="angleInRadians">global angle</param>
	public inline function setPositionAngle(pos:Vector2, angleInRadians:Float, scale:Vector2):Void {
		if(mGlobalShape == null) {
			mGlobalShape = new Array<Vector2>();
		}
		
		mGlobalShape = mBaseShape.transformVertices(pos == null ? mDerivedPos : pos, angleInRadians, scale == null ? new Vector2(1, 1) : scale);
		
		var p:PointMass;
		var v:Vector2;
		
		for (i in 0...mPointMasses.length) {
			p = mPointMasses[i];
			v = mGlobalShape[i];
			
			p.PositionX = v.X;
			p.PositionY = v.Y;
		}
		
		if(pos != null)	mDerivedPos = pos;
		mDerivedAngle = angleInRadians;
	}
	
	/// <summary>
	/// For moving a body kinematically.  sets the position in global space.  via shape-matching, the
	/// body will eventually move to this location.
	/// </summary>
	/// <param name="pos">position in global space.</param>
	public function setKinematicPosition(pos:Vector2):Void {
		mDerivedPos = pos;
	}
	
	/// <summary>
	/// For moving a body kinematically.  sets the angle in global space.  via shape-matching, the
	/// body will eventually rotate to this angle.
	/// </summary>
	/// <param name="angleInRadians"></param>
	public function setKinematicAngle(angleInRadians:Float):Void {
		mDerivedAngle = angleInRadians;
	}
	
	/// <summary>
	/// For changing a body kinematically.  via shape matching, the body will eventually
	/// change to the given scale.
	/// </summary>
	/// <param name="scale"></param>
	public function setKinematicScale(scale:Vector2):Void {
		mScale = scale;
	}
	
	//test
	var baseNorm:Vector2;
	var baseShapeVertice:Vector2;
	var curNorm:Vector2;	
	var dot:Float;
	var thisAngle:Float;
	var diff:Float;
	var thisSign:Int;
	// end test
	// DERIVING POSITION AND VELOCITY	
	inline public function derivePositionAndAngle(elaspsed:Float):Void {
		// no need if this is a static body, or kinematically controlled.
		if (!(mIsStatic || mKinematic)) {		
			// Temp variables
			var p:PointMass;
			
			// Precalculations
			var l:Int = mPointMasses.length;
			var reverse_length:Float = 1.0 / l;
			
			if(!mIsPined) {
				// find the geometric center.
				//var center:Vector2 = new Vector2();
				var centerX:Float = 0, centerY:Float = 0;
				
				//var vel:Vector2 = new Vector2();
				var velX:Float = 0, velY:Float = 0;
				
				for (i in 0...l) {
					p = mPointMasses[i];
					
					centerX += p.PositionX;
					centerY += p.PositionY;
					
					velX += p.VelocityX;
					velY += p.VelocityY;
				}
				
				centerX *= reverse_length;
				centerY *= reverse_length;
				
				velX *= reverse_length;
				velY *= reverse_length;
				
				mDerivedPos.setTo(centerX, centerY);
				mDerivedVel = new Vector2(velX, velY);
			}
			
			// find the average angle of all of the masses.
			var angle:Float = 0;
			
			var originalSign:Int = 1;
			var originalAngle:Float = 0;
			
			for (i in 0...l) {
				p = mPointMasses[i];
				
				baseNorm = new Vector2(); 
				baseShapeVertice = mBaseShape.Vertices[i];
				baseNorm.X = baseShapeVertice.X;
				baseNorm.Y = baseShapeVertice.Y;
				
				//Vector2.Normalize(baseNorm, baseNorm);
				baseNorm.normalizeThis();
				
				curNorm = new Vector2();
				
				curNorm.X = p.PositionX - mDerivedPos.X;
				curNorm.Y = p.PositionY - mDerivedPos.Y;
				
				// Vector2.Normalize(curNorm, curNorm);
				curNorm.normalizeThis();
				
				dot = Vector2.Dot(baseNorm, curNorm);
				
				if (dot > 1.0) { dot = 1.0; }
				if (dot < -1.0) { dot = -1.0; }
				
				thisAngle = Math.acos(dot);
				
				if (!VectorTools.isCCW(baseNorm, curNorm)) { 
					thisAngle = -thisAngle; 
				}
				
				if (i == 0) {
					originalSign = (thisAngle >= 0.0) ? 1 : -1;
					originalAngle = thisAngle;
				} else {
					diff = (thisAngle - originalAngle);
					thisSign = (thisAngle >= 0.0) ? 1 : -1;
					
					if (((diff < 0 ? -diff : diff) > Math.PI) && (thisSign != originalSign)) {
						thisAngle = (thisSign == -1) ? (Math.PI + (Math.PI + thisAngle)) : ((Math.PI - thisAngle) - Math.PI);
					}
				}
				
				angle += thisAngle;
			}
			
			angle /= l;		
			mDerivedAngle = angle;
			
			// now calculate the derived Omega, based on change in angle over time.
			var angleChange:Float = (mDerivedAngle - mLastAngle);		
			if ((angleChange < 0 ? -angleChange : angleChange) >= Math.PI) {
				angleChange < 0 ? angleChange = angleChange + (Math.PI * 2) : angleChange = angleChange - (Math.PI * 2);
			}
			
			mDerivedOmega = angleChange / elaspsed;		
			mLastAngle = mDerivedAngle;
		}
	}
	
	/// <summary>
	/// Derived position of the body in global space, based on location of all PointMasses.
	/// </summary>
	public var DerivedPosition(get, never):Vector2;
	public function get_DerivedPosition():Vector2 {
		return mDerivedPos;
	}
	
	/// <summary>
	/// Derived global angle of the body in global space, based on location of all PointMasses.
	/// </summary>
	public var DerivedAngle(get, never):Float;
	public function get_DerivedAngle():Float {
		return mDerivedAngle;
	}
	
	/// <summary>
	/// Derived global velocity of the body in global space, based on velocity of all PointMasses.
	/// </summary>
	public var DerivedVelocity(get, never):Vector2;
	public function get_DerivedVelocity():Vector2 {
		return mDerivedVel;
	}
	
	/// <summary>
	/// Derived rotational velocity of the body in global space, based on changes in DerivedAngle.
	/// </summary>
	public function DerivedOmega():Float {
		return mDerivedOmega;
	}
	
	// ACCUMULATING FORCES - TO BE INHERITED!
	/// <summary>
	/// this function should add all internal forces to the Force member variable of each PointMass in the body.
	/// these should be forces that try to maintain the shape of the body.
	/// </summary>
	public function accumulateInternalForces() : Void { }
	
	/// <summary>
	/// this function should add all external forces to the Force member variable of each PointMass in the body.
	/// these are external forces acting on the PointMasses, such as gravity, etc.
	/// </summary>
	public function accumulateExternalForces() : Void { } 
	
	// INTEGRATION
	public function integrate(elapsed:Float):Void {
		if (mIsStatic) { 
			return; 
		}
		
		for (i in 0...mPointMasses.length) {
			mPointMasses[i].integrateForce(elapsed);
		}
	}
	
	inline public function dampenVelocity():Void {
		if (!mIsStatic) { 
			var p:PointMass;
			for (i in 0...mPointMasses.length) {
				p = mPointMasses[i];			
				p.VelocityX *= mVelDamping;
				p.VelocityY *= mVelDamping;
			}
		}		
	}
	
	// HELPER FUNCTIONS
	/// <summary>
	/// update the AABB for this body, including padding for velocity given a timestep.
	/// This function is called by the World object on Update(), so the user should not need this in most cases.
	/// </summary>
	/// <param name="elapsed">elapsed time in seconds</param>
	inline public function updateAABB(elapsed:Float, forceUpdate:Bool):Void {
		if ((!IsStatic) || (forceUpdate)) {
			mAABB.clear();
			
			var p:PointMass;
			for (i in 0...mPointMasses.length) {
				p = mPointMasses[i];				
				mAABB.expandToIncludePos(p.PositionX, p.PositionY);
				
				// expanding for velocity only makes sense for dynamic objects.
				if (!IsStatic) {
					mAABB.expandToIncludePos(p.PositionX + (p.VelocityX * elapsed), p.PositionY + (p.VelocityY * elapsed));
				}
			}
		}
	}
	
	/// <summary>
	/// get the Axis-aligned bounding box for this body.  used for broad-phase collision checks.
	/// </summary>
	/// <returns>AABB for this body</returns>
	public function getAABB():AABB {
		return mAABB;
	}
	
	/// <summary>
	/// collision detection.  detect if a global point is inside this body.
	/// </summary>
	/// <param name="pt">point in global space</param>
	/// <returns>true = point is inside body, false = it is not.</returns>
	inline public function contains(ptX:Float, ptY:Float):Bool {
		// basic idea: draw a line from the point to a point known to be outside the body.  count the number of
		// lines in the polygon it intersects.  if that number is odd, we are inside.  if it's even, we are outside.
		// in this implementation we will always use a line that moves off in the positive X direction from the point
		// to simplify things.
		var endPtX:Float = mAABB.Max.X + 0.1;
		var endPtY:Float = ptY;
		
		// line we are testing against goes from pt -> endPt.
		var inside:Bool = false;
				
		var edgeStX:Float = mPointMasses[0].PositionX;
		var edgeStY:Float = mPointMasses[0].PositionY;
		
		var edgeEndX:Float = 0;
		var edgeEndY:Float = 0;
		
		var c:Int = mPointMasses.length;
		var slope:Float;
		var hitX:Float;
		
		for (i in 0...c) {
			// the current edge is defined as the line from edgeSt -> edgeEnd.
			if (i < (c - 1)) {
				edgeEndX = mPointMasses[i + 1].PositionX;
				edgeEndY = mPointMasses[i + 1].PositionY;
			} else {
				edgeEndX = mPointMasses[0].PositionX;
				edgeEndY = mPointMasses[0].PositionY;
			}
			
			// perform check now...
			if (((edgeStY <= ptY) && (edgeEndY > ptY)) || ((edgeStY > ptY) && (edgeEndY <= ptY))) {
				// this line crosses the test line at some point... does it do so within our test range?
				slope = (edgeEndX - edgeStX) / (edgeEndY - edgeStY);
				hitX = edgeStX + ((ptY - edgeStY) * slope);
				
				if ((hitX >= ptX) && (hitX <= endPtX))
					inside = !inside;
			}
			edgeStX = edgeEndX;
			edgeStY = edgeEndY;
		}
		
		return inside;
	}
	
	inline public function containsVec(pt:Vector2):Bool {
		// basic idea: draw a line from the point to a point known to be outside the body.  count the number of
		// lines in the polygon it intersects.  if that number is odd, we are inside.  if it's even, we are outside.
		// in this implementation we will always use a line that moves off in the positive X direction from the point
		// to simplify things.
		var endPtX:Float = mAABB.Max.X + 0.1;
		var endPtY:Float = pt.Y;
		
		// line we are testing against goes from pt -> endPt.
		var inside:Bool = false;
				
		var edgeStX:Float = mPointMasses[0].PositionX;
		var edgeStY:Float = mPointMasses[0].PositionY;
		
		var edgeEndX:Float = 0;
		var edgeEndY:Float = 0;
		
		var c:Int = mPointMasses.length;
		var slope:Float;
		var hitX:Float;
		
		for (i in 0...c) {
			// the current edge is defined as the line from edgeSt -> edgeEnd.
			if (i < (c - 1)) {
				edgeEndX = mPointMasses[i + 1].PositionX;
				edgeEndY = mPointMasses[i + 1].PositionY;
			} else {
				edgeEndX = mPointMasses[0].PositionX;
				edgeEndY = mPointMasses[0].PositionY;
			}
			
			// perform check now...
			if (((edgeStY <= pt.Y) && (edgeEndY > pt.Y)) || ((edgeStY > pt.Y) && (edgeEndY <= pt.Y))) {
				// this line crosses the test line at some point... does it do so within our test range?
				slope = (edgeEndX - edgeStX) / (edgeEndY - edgeStY);
				hitX = edgeStX + ((pt.Y - edgeStY) * slope);
				
				if ((hitX >= pt.X) && (hitX <= endPtX))
					inside = !inside;
			}
			edgeStX = edgeEndX;
			edgeStY = edgeEndY;
		}
		
		return inside;
	}
	
	/// <summary>
	/// collision detection - given a global point, find the point on this body that is closest to the global point,
	/// and if it is an edge, information about the edge it resides on.
	/// </summary>
	/// <param name="pt">global point</param>
	/// <param name="hitPt">returned point on the body in global space</param>
	/// <param name="normal">returned normal on the body in global space</param>
	/// <param name="pointA">returned ptA on the edge</param>
	/// <param name="pointB">returned ptB on the edge</param>
	/// <param name="edgeD">scalar distance between ptA and ptB [0,1]</param>
	/// <returns>distance</returns>
	inline public function getClosestPoint(pt:Vector2, hitPt:Vector2, normal:Vector2, pointA:Array<Float>, pointB:Array<Float>, edgeD:Array<Float>):Float {
		pointA[0] = -1;
		pointB[0] = -1;
		edgeD[0] = 0;
		
		var closestD:Float = 1000.0;
		
		var tempHit:Vector2;
		var tempNorm:Vector2;
		var tempEdgeD:Array<Float>;
		var dist:Float;
		
		for (i in 0...mPointMasses.length) {
			tempHit = new Vector2();
			tempNorm = new Vector2();
			tempEdgeD = [];
			
			dist = getClosestPointOnEdge(pt, i, tempHit, tempNorm, tempEdgeD);
			
			if (dist < closestD) {
				closestD = dist;
				pointA[0] = i;
				
				i < (mPointMasses.length - 1) ? pointB[0] = i + 1 : pointB[0] = 0;
				
				edgeD[0] = tempEdgeD[0];
				normal.setToVec(tempNorm);
				hitPt.setToVec(tempHit);
			}
		}
		
		// return.
		return closestD;
	}
	
	/// <summary>
	/// find the distance from a global point in space, to the closest point on a given edge of the body.
	/// </summary>
	/// <param name="pt">global point</param>
	/// <param name="edgeNum">edge to check against.  0 = edge from pt[0] to pt[1], etc.</param>
	/// <param name="hitPt">returned point on edge in global space</param>
	/// <param name="normal">returned normal on edge in global space</param>
	/// <param name="edgeD">returned distance along edge from ptA to ptB [0,1]</param>
	/// <returns>distance</returns>
	private var toP3:Vector3;
	private var E3:Vector3;
	private var toP:Vector2;
	private var E:Vector2;
	private var n:Vector2;
	inline public function getClosestPointOnEdge(pt:Vector2, edgeNum:Int, hitPt:Vector2, normal:Vector2, edgeD:Array<Float>):Float {		
		toP3 = new Vector3();
		E3 = new Vector3();
		toP = new Vector2(0, 0);
		E = new Vector2();
		n = new Vector2();
		
		edgeD[0] = 0.0;
		var dist:Float = 0.0;
				
		var ptAX:Float = mPointMasses[edgeNum].PositionX;
		var ptAY:Float = mPointMasses[edgeNum].PositionY;
		
		var ptBX:Float = 0;
		var ptBY:Float = 0;
		
		if (edgeNum < (mPointMasses.length - 1)) {
			ptBX = mPointMasses[edgeNum + 1].PositionX;
			ptBY = mPointMasses[edgeNum + 1].PositionY;
		} else {
			ptBX = mPointMasses[0].PositionX;
			ptBY = mPointMasses[0].PositionY;
		}
		
		toP.X = pt.X - ptAX;
		toP.Y = pt.Y - ptAY;
		
		E.X = ptBX - ptAX;
		E.Y = ptBY - ptAY;
		
		// get the length of the edge, and use that to normalize the vector.
		var edgeLength:Float = Math.sqrt((E.X * E.X) + (E.Y * E.Y));
		
		if (edgeLength > 0.00001) {
			E.X /= edgeLength;
			E.Y /= edgeLength;
		}
		
		// normal
		n.setTo(0, 0);
		VectorTools.getPerpendicular(E, n);
		
		// calculate the distance!
		var x = Vector2.Dot(toP, E);
		
		if (x <= 0.0) {
			// x is outside the line segment, distance is from pt to ptA.
			dist = Vector2.Distance(pt, new Vector2(ptAX, ptAY));
			
			hitPt.setTo(ptAX, ptAY);
			edgeD[0] = 0.0;
			normal.setToVec(n);
		} else if (x >= edgeLength) {
			// x is outside of the line segment, distance is from pt to ptB.
			dist = Vector2.Distance(pt, new Vector2(ptBX, ptBY));
			
			hitPt.setTo(ptBX, ptBY);
			edgeD[0] = 1.0;
			normal.X = n.X;
			normal.Y = n.Y;
		} else {
			// point lies somewhere on the line segment.
			toP3.X = toP.X;
			toP3.Y = toP.Y;
			
			E3.X = E.X;
			E3.Y = E.Y;
			
			Vector3.Cross(toP3, E3, E3);
			
			dist = E3.Z;
			
			hitPt.X = ptAX + (E.X * x);
			hitPt.Y = ptAY + (E.Y * x);
			edgeD[0] = x / edgeLength;
			
			normal.setToVec(n);
		}
		
		return dist;
	}
	
	/// <summary>
	/// find the squared distance from a global point in space, to the closest point on a given edge of the body.
	/// </summary>
	/// <param name="pt">global point</param>
	/// <param name="edgeNum">edge to check against.  0 = edge from pt[0] to pt[1], etc.</param>
	/// <param name="hitPt">returned point on edge in global space</param>
	/// <param name="normal">returned normal on edge in global space</param>
	/// <param name="edgeD">returned distance along edge from ptA to ptB [0,1]</param>
	/// <returns>distance</returns>
	inline public function getClosestPointOnEdgeSquared(ptX:Float, ptY:Float, edgeNum:Int, hitPt:Vector2, normal:Vector2, edgeD:Array<Float>):Float {
		toP3 = new Vector3();
		E3 = new Vector3();
		toP = new Vector2(0, 0);
		E = new Vector2();
		n = new Vector2();
		
		edgeD[0] = 0;
		var dist:Float = 0;
		
		var p:PointMass = mPointMasses[edgeNum];
		
		var ptAX:Float = p.PositionX;
		var ptAY:Float = p.PositionY;
		
		var ptBX:Float = 0;
		var ptBY:Float = 0;
		
		if (edgeNum < (mPointMasses.length - 1)) {
			p = mPointMasses[edgeNum + 1];
			
			ptBX = p.PositionX;
			ptBY = p.PositionY;
		} else {
			p = mPointMasses[0];
			
			ptBX = p.PositionX;
			ptBY = p.PositionY;
		}
		
		toP.X = ptX - ptAX;
		toP.Y = ptY - ptAY;
		
		E.X = ptBX - ptAX;
		E.Y = ptBY - ptAY;
		
		// get the length of the edge, and use that to normalize the vector.
		var edgeLength:Float = Math.sqrt((E.X * E.X) + (E.Y * E.Y));
		
		if (edgeLength > 0.0000001) {
			E.X /= edgeLength;
			E.Y /= edgeLength;
		}		
		
		var nX:Float = -E.Y;
		var nY:Float = E.X;
		
		// calculate the distance!
		var x = Vector2.Dot(toP, E);
		
		if (x <= 0.0) {
			// x is outside the line segment, distance is from pt to ptA.
			dist = (ptX - ptAX) * (ptX - ptAX) + (ptY - ptAY) * (ptY - ptAY);
			
			hitPt.X = ptAX;
			hitPt.Y = ptAY;
			
			edgeD[0] = 0;
			
			normal.X = nX;
			normal.Y = nY;
		} else if (x >= edgeLength) {
			// x is outside of the line segment, distance is from pt to ptB.
			dist = Vector2.DistanceSquared(new Vector2(ptX, ptY), new Vector2(ptBX, ptBY));
			
			hitPt.X = ptBX;
			hitPt.Y = ptBY;
			
			edgeD[0] = 1;
			
			normal.X = nX;
			normal.Y = nY;
		} else {
			// point lies somewhere on the line segment.
			toP3.X = toP.X;
			toP3.Y = toP.Y;
			
			E3.X = E.X;
			E3.Y = E.Y;
			
			Vector3.Cross(toP3, E3, E3);
			
			dist = E3.Z * E3.Z;
			
			hitPt.X = ptAX + (E.X * x);
			hitPt.Y = ptAY + (E.Y * x);
			edgeD[0] = x / edgeLength;
			
			normal.X = nX;
			normal.Y = nY;
		}
				
		return dist;
	}
	
	/// <summary>
	/// Find the closest PointMass in this body, givena global point.
	/// </summary>
	/// <param name="pos">global point</param>
	/// <param name="dist">returned dist</param>
	/// <returns>index of the PointMass</returns>
	inline public function getClosestPointMass(pos:Vector2, dist:Array<Float>):Int {
		var closestSQD:Float = 100000.0;
		var closest:Int = -1;

		var points_count:Int = mPointMasses.length;
		var p:PointMass;
		var dx:Float = 0;
		var dy:Float = 0;
		var thisD:Float = 0;
		for (i in 0...points_count) {
			p = mPointMasses[i];
			
			dx = pos.X - p.PositionX;
			dy = pos.Y - p.PositionY;
			
			thisD = dx * dx + dy * dy;
			
			if (thisD < closestSQD) {
				closestSQD = thisD;
				closest = i;
			}
		}
		
		dist[0] = Math.sqrt(closestSQD);
		
		return closest;
	}
	
	/// <summary>
	/// Number of PointMasses in the body
	/// </summary>
	public var PointMassCount(get, never):Int;
	public function get_PointMassCount():Int {
		return mPointMasses.length;
	}
	
	/// <summary>
	/// Get a specific PointMass from this body.
	/// </summary>
	/// <param name="index">index</param>
	/// <returns>PointMass</returns>
	public function getPointMass(index:Int):PointMass {
		return mPointMasses[index];
	}
	
	/// <summary>
	/// Helper function to add a global force acting on this body as a whole.
	/// </summary>
	/// <param name="pt">location of force, in global space</param>
	/// <param name="force">direction and intensity of force, in global space</param>
	private static var tempR:Vector2 = new Vector2();
	private static var tempV1:Vector3 = new Vector3();
	private static var tempV2:Vector3 = new Vector3();
	inline public function addGlobalForce(pt:Vector2, force:Vector2):Void {
		tempR = (mDerivedPos.minus(pt));
		
		tempV1.fromVector2(tempR);
		tempV2.fromVector2(force);
		var torqueF = Vector3.Cross2Z(tempV1, tempV2);
		
		var m:PointMass;
		var toPt:Vector2;
		var torque:Vector2;
		
		for (i in 0...mPointMasses.length) {
			m = mPointMasses[i];			
			toPt = new Vector2(m.PositionX - mDerivedPos.X, m.PositionY - mDerivedPos.Y);			
			torque = VectorTools.rotateVector(toPt, -(Math.PI) * 0.5);			
			m.ForceX += torque.X * torqueF;
			m.ForceY += torque.Y * torqueF;				
			m.ForceX += force.X;
			m.ForceY += force.Y;
		}
	}
	
	// DEBUG VISUALIZATION
	/// <summary>
	/// This function draws the points to the screen as lines, showing several things:
	/// WHITE - actual PointMasses, connected by lines
	/// GREY - baseshape, at the derived position and angle.
	/// </summary>
	/// <param name="device">graphics device</param>
	/// <param name="effect">effect to use (MUST implement VertexColors)</param>
	public function debugDrawMe(g:Graphics):Void {
		// Temp vars
		var gs_count = mGlobalShape.length;
		var pm_count = mPointMasses.length;
		
		var s:Vector2 = RenderingSettings.Scale;
		var p:Vector2 = RenderingSettings.Offset;
		
		mGlobalShape = mBaseShape.transformVertices(mDerivedPos, mDerivedAngle, mScale);
		
		for (i in 0...gs_count) {
			mGlobalShape[i].X = mGlobalShape[i].X * s.X + p.X;
			mGlobalShape[i].Y = mGlobalShape[i].Y * s.Y + p.Y;
		}
		
		// Draw body original shape
		
		g.lineStyle(0, 0x808080);
		g.moveTo(mGlobalShape[0].X, mGlobalShape[0].Y);
		
		for (i in 0...gs_count) {
			g.lineTo(mGlobalShape[i].X, mGlobalShape[i].Y);
		}
		
		g.lineTo(mGlobalShape[0].X, mGlobalShape[0].Y);
		
		
		// Draw body outline
		
		g.lineStyle(0, 0xFFFFFF);
		g.moveTo(mPointMasses[0].PositionX * s.X + p.X, mPointMasses[0].PositionY * s.Y + p.Y);
		
		for (i in 0...pm_count) {
			g.lineTo(mPointMasses[i].PositionX * s.X + p.X, mPointMasses[i].PositionY * s.Y + p.Y);
		}
		g.lineTo(mPointMasses[0].PositionX * s.X + p.X, mPointMasses[0].PositionY * s.Y + p.Y);
		
		for (i in 0...pm_count) {
			g.lineStyle(0, 0, 0);			
			g.beginFill(0xFFFFFF);			
			g.drawRect(mPointMasses[i].PositionX * s.X + p.X - RenderingSettings.PointSize, mPointMasses[i].PositionY * s.Y + p.Y - RenderingSettings.PointSize, RenderingSettings.PointSize * 2, RenderingSettings.PointSize * 2);			
			g.endFill();
		}
		
		
		// UP and LEFT vectors.
		
		g.lineStyle(0, 0xFF4500);
		
		g.moveTo(mDerivedPos.X * s.X + p.X, mDerivedPos.Y * s.Y + p.Y);
		var v:Vector2 = mDerivedPos.plus(VectorTools.rotateVector(new Vector2(0, 1), mDerivedAngle));
		g.lineTo(v.X * s.X + p.X, v.Y * s.Y + p.Y);
		
		
		g.lineStyle(0, 0x9ACD32);
		
		g.moveTo(mDerivedPos.X * s.X + p.X, mDerivedPos.Y * s.Y + p.Y);
		v = mDerivedPos.plus(VectorTools.rotateVector(new Vector2(1, 0), mDerivedAngle));
		g.lineTo(v.X * s.X + p.X, v.Y * s.Y + p.Y);
		
		// Center vector
		g.lineStyle(0, 0, 0);
		g.beginFill(0xCD5C5C, 1);
		
		g.drawRect(mDerivedPos.X * s.X + p.X - RenderingSettings.PointSize, mDerivedPos.Y * s.Y + p.Y - RenderingSettings.PointSize,
				   RenderingSettings.PointSize * 2,  RenderingSettings.PointSize * 2);
		
		g.endFill();
	}
	
	/// <summary>
	/// Draw the AABB for this body, for debug purposes.
	/// </summary>
	/// <param name="device">graphics device</param>
	/// <param name="effect">effect to use (MUST implement VertexColors)</param>
	public function debugDrawAABB(g:Graphics):Void {
		var box:AABB = getAABB();
		
		g.lineStyle(0, 0x708090);
		
		var s:Vector2 = RenderingSettings.Scale;
		var p:Vector2 = RenderingSettings.Offset;
		
		g.drawRect(box.Min.X * s.X + p.X, box.Min.Y * s.Y + p.Y, (box.Max.X - (box.Min.X)) * s.X, (box.Max.Y - box.Min.Y) * s.Y);
	}
	
	// PUBLIC PROPERTIES
	/// <summary>
	/// Gets / Sets whether this is a static body.  setting static greatly improves performance on static bodies.
	/// </summary>
	public var IsStatic(get, set):Bool;
	public function get_IsStatic():Bool {
		return mIsStatic;
	}	
	public function set_IsStatic(value:Bool):Bool {
		mIsStatic = value;	
		return value;
	}
	
	/// <summary>
	/// Sets whether this body is kinematically controlled.  kinematic control requires shape-matching forces to work properly.
	/// </summary>
	public var IsKinematic(get, set):Bool;
	public function get_IsKinematic():Bool {
		return mKinematic;
	}
	public function set_IsKinematic(value:Bool):Bool {
		mKinematic = value;
		return value;
	}
	
	public var VelocityDamping(get, set):Float;
	public function get_VelocityDamping():Float {
		return mVelDamping;
	}
	public function set_VelocityDamping(value:Float):Float {
		mVelDamping = value;
		return value;
	}
	
	public var ObjectTag(get, set):Dynamic;
	public function get_ObjectTag():Dynamic {
		return mObjectTag;
	}
	public function set_ObjectTag(value:Dynamic):Dynamic {
		mObjectTag = value;
		return value;
	}
}
