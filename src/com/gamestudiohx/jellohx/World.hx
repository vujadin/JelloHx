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
import flash.utils.*;

import jellohx.*;	

/**
 * ...
 * @author Luiz
 */
class World {
	// PUBLIC VARIABLES
	/// <summary>
	/// Collision Filter type. return TRUE to allow collision, FALSE to ignore collision.
	/// </summary>
	/// <param name="bodyA">The colliding body</param>
	/// <param name="bodyApm">Point mass that has collided</param>
	/// <param name="bodyB">Body that bodyA collided with</param>
	/// <param name="bodyBpm1">PointMass 1 on the edge that was collided with</param>
	/// <param name="bodyBpm2">PointMass 2 on the edge that was collided with</param>
	/// <param name="hitPt">Location of collision in global space</param>
	/// <param name="normalVel">Velocity along normal of collision.</param>
	/// <returns>TRUE = accept collision, FALSE = ignore collision</returns>
	
	// public function collisionFilter( Body bodyA, int bodyApm, Body bodyB, int bodyBpm1, int bodyBpm2, Vector2 hitPt, float normalVel )
	
	public var collisionFilter:Dynamic;

	// PRIVATE VARIABLES
	private var mBodies:Array<Body>;
	private var mWorldLimits:AABB;
	private var mWorldSize:Vector2;
	private var mWorldGridStep:Vector2;

	private var mPenetrationThreshold:Float;
	private var mPenetrationCount:Int;

	// material chart.
	private var mMaterialPairs:Array<Array<MaterialPair>>;
	private var mDefaultMatPair:MaterialPair;
	private var mMaterialCount:Int;

	private var mCollisionList:Array<BodyCollisionInfo>;
	
	//// debug visualization variables
	// var mVertexDecl:VertexDeclaration = null;

	// CONSTRUCTOR
	/// <summary>
	/// Creates the World object, and sets world limits to default (-20,-20) to (20,20).
	/// </summary>
	public function new():Void {
		mBodies = new Array<Body>();
		mCollisionList = new Array<BodyCollisionInfo>();
		
		// initialize materials.
		mMaterialCount = 1;
		mMaterialPairs = new Array();
		mMaterialPairs.push(new Array());
		//mMaterialPairs[0].push(new Array());
		//mMaterialPairs[0].length = 1;
		
		mDefaultMatPair = new MaterialPair();
		mDefaultMatPair.Friction = 0.3;
		mDefaultMatPair.Elasticity = 0.2;
		mDefaultMatPair.Collide = true;
		mDefaultMatPair.CollisionFilter = this.defaultCollisionFilter;
		
		mMaterialPairs[0][0] = mDefaultMatPair.clone();

		var min:Vector2 = new Vector2(-20.0, -20.0);
		var max:Vector2 = new Vector2(20.0, 20.0);
		
		setWorldLimits(min, max);

		mPenetrationThreshold = 0.3;
	}

	// WORLD SIZE
	public function setWorldLimits(min:Vector2, max:Vector2):Void {
		mWorldLimits = new AABB(min, max);
		
		mWorldSize = new Vector2();
		mWorldSize.setToVec(max.minus(min));
		
		mWorldGridStep = new Vector2();
		mWorldGridStep.setToVec(mWorldSize.div(32));
	}
	

	// MATERIALS
	/// <summary>
	/// Add a new material to the world.  all previous material data is kept intact.
	/// </summary>
	/// <returns>int ID of the newly created material</returns>
	public function addMaterial():Int {
		var old = mMaterialPairs.copy();
		mMaterialCount++;
		
		mMaterialPairs = new Array();
		
		// replace old data.
		for (i in 0...mMaterialCount) {
			mMaterialPairs.push(new Array());
			
			for (j in 0...mMaterialCount)
			{
				if ((i < (mMaterialCount-1)) && (j < (mMaterialCount-1)))
					mMaterialPairs[i][j] = old[i][j];
				else
					mMaterialPairs[i][j] = mDefaultMatPair.clone();
			}
		}
		
		return mMaterialCount - 1;
	}

	/// <summary>
	/// Enable or Disable collision between 2 materials.
	/// </summary>
	/// <param name="a">material ID A</param>
	/// <param name="b">material ID B</param>
	/// <param name="collide">true = collide, false = ignore collision</param>
	public function setMaterialPairCollide(a:Int, b:Int, collide:Bool):Void {
		if ((a >= 0) && (a < mMaterialCount) && (b >= 0) && (b < mMaterialCount)) {
			mMaterialPairs[a][b].Collide = collide;
			mMaterialPairs[b][a].Collide = collide;
		}
	}

	/// <summary>
	/// Set the collision response variables for a pair of materials.
	/// </summary>
	/// <param name="a">material ID A</param>
	/// <param name="b">material ID B</param>
	/// <param name="friction">friction.  [0,1] 0 = no friction, 1 = 100% friction</param>
	/// <param name="elasticity">"bounce" [0,1] 0 = no bounce (plastic), 1 = 100% bounce (super ball)</param>
	public function setMaterialPairData(a:Int, b:Int, friction:Float, elasticity:Float):Void {
		if ((a >= 0) && (a < mMaterialCount) && (b >= 0) && (b < mMaterialCount)) {
			mMaterialPairs[a][b].Friction = friction;
			mMaterialPairs[a][b].Elasticity = elasticity;
			
			mMaterialPairs[b][a].Friction = friction;
			mMaterialPairs[b][a].Elasticity = elasticity;
		}
	}

	/// <summary>
	/// Sets a user function to call when 2 bodies of the given materials collide.
	/// </summary>
	/// <param name="a">Material A</param>
	/// <param name="b">Material B</param>
	/// <param name="filter">User fuction (delegate)</param>
	public function setMaterialPairFilterCallback(a:Int, b:Int, filter:Dynamic):Void {
		if ((a >= 0) && (a < mMaterialCount) && (b >= 0) && (b < mMaterialCount)) {
			mMaterialPairs[a][b].CollisionFilter = filter;			
			mMaterialPairs[b][a].CollisionFilter = filter;
		}
	}
	

	// ADDING / REMOVING BODIES
	/// <summary>
	/// Add a Body to the world.  Bodies do this automatically, you should NOT need to call this.
	/// </summary>
	/// <param name="b">the body to add to the world</param>
	public function addBody(b:Body):Void {
		if (Lambda.indexOf(mBodies, b) == -1) {
			mBodies.push(b);
		}
	}

	/// <summary>
	/// Remove a body from the world.  call this outside of an update to remove the body.
	/// </summary>
	/// <param name="b">the body to remove</param>
	public function removeBody(b:Body):Void {
		if (Lambda.indexOf(mBodies, b) != -1) {
			mBodies.splice(Lambda.indexOf(mBodies, b), 1);
		}
	}

	/// <summary>
	/// Get a body at a specific index.
	/// </summary>
	/// <param name="index"></param>
	/// <returns></returns>
	public function getBody(index:Int):Body {
		if ((index >= 0) && (index < mBodies.length))
			return mBodies[index];

		return null;
	}
	

	// BODY HELPERS
	/// <summary>
	/// Find the closest PointMass in the world to a given point.
	/// </summary>
	/// <param name="pt">global point</param>
	/// <param name="bodyID">index of the body that contains the PointMass</param>
	/// <param name="pmID">index of the PointMass</param>
	inline public function getClosestPointMass(pt:Vector2, bodyID:Array<Int>, pmID:Array<Int>):Void {
		bodyID[0] = -1;
		pmID[0] = -1;
		
		var dist:Array<Float> = [];
		
		var closestD:Float = 1000.0;
		var pm:Int;
		for (i in 0...mBodies.length) {
			dist = [];
			
			pm = mBodies[i].getClosestPointMass(pt, dist);
			if (dist[0] < closestD) {
				closestD = dist[0];
				bodyID[0] = i;
				pmID[0] = pm;
			}
		}
	}

	/// <summary>
	/// Given a global point, get a body (if any) that contains this point.
	/// Useful for picking objects with a cursor, etc.
	/// </summary>
	/// <param name="pt">global point</param>
	/// <returns>Body (or null)</returns>
	inline public function getBodyContaining(pt:Vector2):Body {
		for (i in 0...mBodies.length) {
			if (mBodies[i].containsVec(pt))
				return mBodies[i];
		}
		
		return null;
	}
	
	
	// UPDATE
	/// <summary>
	/// Update the world by a specific timestep.
	/// </summary>
	/// <param name="elapsed">elapsed time in seconds</param>
	public function update(elapsed:Float):Void {
		mPenetrationCount = 0;
		
		var body_count:Int = mBodies.length;
		var body1:Body = null;
		var body2:Body = null;
		
		// update all bounding boxes, and then bitmasks.
		for (i in 0...body_count) {
			// Everything's in one single loop, now:
			
			body1 = mBodies[i];
			
			body1.derivePositionAndAngle(elapsed);
			body1.accumulateExternalForces();
			body1.accumulateInternalForces();
			
			body1.integrate(elapsed);
			
			body1.updateAABB(elapsed, false);
			updateBodyBitmask(body1);
		}
		
		// now check for collision.
		// inter-body collision!
		for (i in 0...body_count) {
			body1 = mBodies[i];
			
			for (j in i+1...body_count)
			{
				body2 = mBodies[j];
				
				// another early-out - both bodies are static.
				if ((body1.IsStatic) && (body2.IsStatic))
					continue;
				
				// grid-based early out.
				if (((body1.mBitMaskX.mask & body2.mBitMaskX.mask) == 0) && 
					((body1.mBitMaskY.mask & body2.mBitMaskY.mask) == 0))
					continue;
				
				// early out - these bodies materials are set NOT to collide
				if (!mMaterialPairs[body1.Material][body2.Material].Collide)
					continue;
				
				// broad-phase collision via AABB.
				// early out
				if(!body1.mAABB.intersects(body2.mAABB))
					continue;
				
				// okay, the AABB's of these 2 are intersecting.  now check for collision of A against B.
				bodyCollide(body1, body2, mCollisionList);
				
				// and the opposite case, B colliding with A
				bodyCollide(body2, body1, mCollisionList);
			}
		}
		
		// now handle all collisions found during the update at once.
		_handleCollisions();

		// now dampen velocities.
		for (i in 0...body_count) {
			mBodies[i].dampenVelocity();
		}
	}

	inline private function updateBodyBitmask(body:Body):Void {
		var box:AABB = body.mAABB;
		
		var rev_DividerX:Float = 1.0 / mWorldGridStep.X;
		var rev_DividerY:Float = 1.0 / mWorldGridStep.Y;
		
		var minX:Int = cast Math.floor((box.Min.X - mWorldLimits.Min.X) * rev_DividerX);
		var maxX:Int = cast Math.floor((box.Max.X - mWorldLimits.Min.X) * rev_DividerX);
		
		if (minX < 0) { minX = 0; } else if (minX > 32) { minX = 32; }
		if (maxX < 0) { maxX = 0; } else if (maxX > 32) { maxX = 32; }
		
		var minY:Int = cast Math.floor((box.Min.Y - mWorldLimits.Min.Y) * rev_DividerY);
		var maxY:Int = cast Math.floor((box.Max.Y - mWorldLimits.Min.Y) * rev_DividerY);
		
		if (minY < 0) { minY = 0; } else if (minY > 32) { minY = 32; }
		if (maxY < 0) { maxY = 0; } else if (maxY > 32) { maxY = 32; }
		
		body.mBitMaskX.clear();
		var i : Int = minX;
		while(i <= maxX) {
			body.mBitMaskX.setOn(i);
			i++;
		}
		body.mBitMaskY.clear();
		i = minY;
		while(i <= maxY) {
			body.mBitMaskY.setOn(i);
			i++;
		}
			
		//Console.WriteLine("Body bitmask: minX{0} maxX{1} minY{2} maxY{3}", minX, maxX, minY, minY, maxY);
	}
	
	private var fromPrev:Vector2;
	private var toNext:Vector2;
	private var ptNorm:Vector2;
	private var hitPt:Vector2;
	private var norm:Vector2;
	
	// test
	var ptX:Float;
	var ptY:Float;
	var prevPt:Int;
	var nextPt:Int;
	var prevX:Float;
	var prevY:Float;
	var nextX:Float;
	var nextY:Float;
	var closestAway:Float;
	var closestSame:Float;
	var found:Bool;
	var b1:Int;
	var b2:Int;
	var edgeD:Float;
	var e:Array<Float>;
	var dist:Float;
	var dot:Float;
	// end test
	// COLLISION CHECKS / RESPONSE
	inline private function bodyCollide(bA:Body, bB:Body, infoList:Array<BodyCollisionInfo>):Void {
		fromPrev = new Vector2();
		toNext = new Vector2();
		ptNorm = new Vector2();
		hitPt = new Vector2();
		norm = new Vector2();
	
		var bApCount:Int = bA.mPointMasses.length;
		var bBpCount:Int = bB.mPointMasses.length;
		
		var boxB:AABB = bB.getAABB();
		
		// check all PointMasses on bodyA for collision against bodyB.  if there is a collision, return detailed info.
		var infoAway:BodyCollisionInfo = new BodyCollisionInfo();
		var infoSame:BodyCollisionInfo = new BodyCollisionInfo();
		
		for (i in 0...bApCount) {			
			ptX = bA.mPointMasses[i].PositionX;
			ptY = bA.mPointMasses[i].PositionY;
			
			// early out - if this point is outside the bounding box for bodyB, skip it!
			if (!boxB.contains(ptX, ptY))
				continue;
				
			// early out - if this point is not inside bodyB, skip it!
			if (!bB.contains(ptX, ptY))
				continue;
				
			prevPt = (i > 0) ? i - 1 : bApCount - 1;
			nextPt = (i < bApCount - 1) ? i + 1 : 0;
			
			// var prev:Vector2 = bA.getPointMass(prevPt).Position.clone();
			prevX = bA.mPointMasses[prevPt].PositionX;
			prevY = bA.mPointMasses[prevPt].PositionY;
			
			// var next:Vector2 = bA.getPointMass(nextPt).Position.clone();
			nextX = bA.mPointMasses[nextPt].PositionX;
			nextY = bA.mPointMasses[nextPt].PositionY;
			
			// now get the normal for this point. (NOT A UNIT VECTOR)
			fromPrev.X = ptX - prevX;
			fromPrev.Y = ptY - prevY;
			
			toNext.X = nextX - ptX;
			toNext.Y = nextY - ptY;
			
			ptNorm.X = fromPrev.X + toNext.X;
			ptNorm.Y = fromPrev.Y + toNext.Y;
			
			// VectorTools.makePerpendicular(ptNorm);
			ptNorm = ptNorm.perpendicular();
			
			// this point is inside the other body.  now check if the edges on either side intersect with and edges on bodyB.          
			closestAway = Math.POSITIVE_INFINITY;
			closestSame = Math.POSITIVE_INFINITY;
			
			infoAway.Clear();
			infoAway.bodyA = bA;
			infoAway.bodyApm = i;
			infoAway.bodyB = bB;
			
			infoSame.Clear();
			infoSame.bodyA = bA;
			infoSame.bodyApm = i;
			infoSame.bodyB = bB;
			
			found = false;
			
			b1 = 0;
			b2 = 1;
			
			for (j in 0...bBpCount) {
				edgeD = 0;
				
				b1 = j;
				b2 = (j + 1) % (bBpCount);
								
				e = [];
				
				// test against this edge.
				dist = bB.getClosestPointOnEdgeSquared(ptX, ptY, j, hitPt, norm, e);
				edgeD = e[0];
				
				// only perform the check if the normal for this edge is facing AWAY from the point normal.
				dot = Vector2.Dot(ptNorm, norm);
								
				if (dot <= 0.0) {
					if (dist < closestAway) {
						closestAway = dist;
						
						infoAway.bodyBpmA = b1;
						infoAway.bodyBpmB = b2;
						infoAway.edgeD = edgeD;
						infoAway.hitPt.setToVec(hitPt);
						infoAway.normal.setToVec(norm);
						infoAway.penetration = dist;
						
						found = true;
					}
				} else {
					if (dist < closestSame) {
						closestSame = dist;
						
						infoSame.bodyBpmA = b1;
						infoSame.bodyBpmB = b2;
						infoSame.edgeD = edgeD;
						infoSame.hitPt.setToVec(hitPt);
						infoSame.normal.setToVec(norm);
						infoSame.penetration = dist;
					}
				}
			}
			
			// we've checked all edges on BodyB.  add the collision info to the stack.
			if ((found) && (closestAway > mPenetrationThreshold) && (closestSame < closestAway)) {
				infoSame.penetration = Math.sqrt(infoSame.penetration);
				infoList.push(infoSame.clone());
			} else {
				infoAway.penetration = Math.sqrt(infoAway.penetration);
				infoList.push(infoAway.clone());
			}
		}
	}
	
	private var tangent:Vector2;
	private var numV:Vector2;
	
	// test
	var info:BodyCollisionInfo;
	var A:PointMass;
	var B1:PointMass;
	var B2:PointMass;
	var bVelX:Float;
	var bVelY:Float;
	var relVel:Vector2;
	var relDot:Float;
	var b1inf:Float;
	var b2inf:Float;
	var b2MassSum:Float;
	var massSum:Float;
	var Amove:Float;
	var Bmove:Float;
	var rev_massSum:Float;
	var B1move:Float;
	var B2move:Float;
	var AinvMass:Float;
	var BinvMass:Float;
	var jDenom:Float;
	var elas:Float;
	var rev_jDenom:Float;
	var infoNormal:Vector2;
	var jMult:Float = 0;
	var fMult:Float = 0;
	var rev_AMass:Float;
	static var infinity:Float = Math.POSITIVE_INFINITY;
	var collisions_count:Int;
	var friction:Float;
	var jj:Float;
	var ff:Float;
	// end test
	inline private function _handleCollisions():Void {
		tangent = new Vector2();
	    numV = new Vector2();
		
		// handle all collisions!
		collisions_count = mCollisionList.length;
				
		for (i in 0...collisions_count) {
			info = mCollisionList[i];
			
			A = info.bodyA.getPointMass(info.bodyApm);
			B1 = info.bodyB.getPointMass(info.bodyBpmA);
			B2 = info.bodyB.getPointMass(info.bodyBpmB);

			// velocity changes as a result of collision.			
			bVelX = (B1.VelocityX + B2.VelocityX) * 0.5;
			bVelY = (B1.VelocityY + B2.VelocityY) * 0.5;

			relVel = new Vector2(A.VelocityX - bVelX, A.VelocityY - bVelY);			
			
			relDot = Vector2.Dot(relVel, info.normal);
			   
			if (!mMaterialPairs[info.bodyA.Material][info.bodyB.Material].CollisionFilter(info.bodyA, info.bodyApm, info.bodyB, info.bodyBpmA, info.bodyBpmB, info.hitPt, relDot))
				 continue;
			
			if (info.penetration > mPenetrationThreshold) {
				mPenetrationCount++;				
				continue;
			}

			b1inf = 1.0 - info.edgeD;
			b2inf = info.edgeD;

			b2MassSum = ((infinity == (B1.Mass)) || (infinity == (B2.Mass))) ? infinity : (B1.Mass + B2.Mass);

			massSum = A.Mass + b2MassSum;			
			
			if (infinity == A.Mass) {
				Amove = 0.0;
				Bmove = (info.penetration) + 0.001;
			} else if (infinity == b2MassSum) {
				Amove = (info.penetration) + 0.001;
				Bmove = 0.0;
			} else {
				rev_massSum = 1.0 / massSum;
				Amove = (info.penetration * (b2MassSum * rev_massSum));
				Bmove = (info.penetration * (A.Mass * rev_massSum));
			}

			B1move = Bmove * b1inf;
			B2move = Bmove * b2inf;

			AinvMass = (infinity == A.Mass) ? 0 : 1.0 / A.Mass;
			BinvMass = (infinity == b2MassSum) ? 0 : 1.0 / b2MassSum;

			jDenom = AinvMass + BinvMass;
			elas = 1 + mMaterialPairs[info.bodyA.Material][info.bodyB.Material].Elasticity;
			numV.setTo(relVel.X * elas, relVel.Y * elas);
			
			rev_jDenom = 1 / jDenom;
			jj = -Vector2.Dot(numV, info.normal) * rev_jDenom;
			infoNormal = info.normal;

			if (infinity != A.Mass && b2MassSum == infinity) {
				A.PositionX += infoNormal.X * Amove;
				A.PositionY += infoNormal.Y * Amove;
			}

			if (infinity != B1.Mass) {
				B1.PositionX -= infoNormal.X * B1move;
				B1.PositionY -= infoNormal.Y * B1move;
			}

			if (infinity != B2.Mass) {
				B2.PositionX -= infoNormal.X * B2move;
				B2.PositionY -= infoNormal.Y * B2move;
			}
			
			VectorTools.getPerpendicular(info.normal, tangent);
			
			friction = mMaterialPairs[info.bodyA.Material][info.bodyB.Material].Friction;
			ff = (Vector2.Dot(relVel, tangent) * friction) * rev_jDenom;
									
			// adjust velocity if relative velocity is moving toward each other.
			if (relDot <= 0.0001) {
				if (infinity != A.Mass) {
					rev_AMass = 1 / A.Mass;
					jMult = jj * rev_AMass;
					fMult = ff * rev_AMass;
					
					A.VelocityX += (info.normal.X * jMult) - (tangent.X * fMult);
					A.VelocityY += (info.normal.Y * jMult) - (tangent.Y * fMult);					
				}

				if (infinity != b2MassSum) {
					jMult = jj / b2MassSum;
					fMult = ff / b2MassSum;
					
					B1.VelocityX -= (info.normal.X * jMult * b1inf) - (tangent.X * fMult * b1inf);
					B1.VelocityY -= (info.normal.Y * jMult * b1inf) - (tangent.Y * fMult * b1inf);
					
					B2.VelocityX -= (info.normal.X * jMult * b2inf) - (tangent.X * fMult * b2inf);
					B2.VelocityY -= (info.normal.Y * jMult * b2inf) - (tangent.Y * fMult * b2inf);
				}
			}
		}
		
		while(mCollisionList.length > 0) {
			mCollisionList.pop();
		}
	}
	
	// DEBUG VISUALIZATION
	/// <summary>
	/// draw the world extents on-screen.
	/// </summary>
	/// <param name="device">Graphics Device</param>
	/// <param name="effect">An Effect to draw the lines with (should implement vertex color diffuse)</param>
	public function debugDrawMe(g:Graphics) : Void
	{
		/*if (mVertexDecl == null)
		{
			mVertexDecl = new VertexDeclaration(device, VertexPositionColor.VertexElements);
		}
		
		// draw the world limits.
		VertexPositionColor[] limits = new VertexPositionColor[5];
		
		limits[0].Position = new Vector3(mWorldLimits.Min.X, mWorldLimits.Max.Y, 0);
		limits[0].Color = Color.SlateGray;
		
		limits[1].Position = new Vector3(mWorldLimits.Max.X, mWorldLimits.Max.Y, 0);
		limits[1].Color = Color.SlateGray;
		
		limits[2].Position = new Vector3(mWorldLimits.Max.X, mWorldLimits.Min.Y, 0);
		limits[2].Color = Color.SlateGray;
		
		limits[3].Position = new Vector3(mWorldLimits.Min.X, mWorldLimits.Min.Y, 0);
		limits[3].Color = Color.SlateGray;
		
		limits[4].Position = new Vector3(mWorldLimits.Min.X, mWorldLimits.Max.Y, 0);
		limits[4].Color = Color.SlateGray;
		
		device.VertexDeclaration = mVertexDecl;
		effect.Begin();
		foreach (EffectPass pass in effect.CurrentTechnique.Passes)
		{
			pass.Begin();
			device.DrawUserPrimitives<VertexPositionColor>(PrimitiveType.LineStrip, limits, 0, 4);
			pass.End();
		}
		effect.End();*/
	}
	
	/// <summary>
	/// draw the velocities of all PointMasses in the simulation on-screen in an orange/yellow color.
	/// </summary>
	/// <param name="device">GraphicsDevice</param>
	/// <param name="effect">An Effect to draw the lines with</param>
	public function debugDrawPointVelocities(g:Graphics):Void {		
		g.clear();
		
		var s:Vector2 = RenderingSettings.Scale;
		var p:Vector2 = RenderingSettings.Offset;
		
		g.lineStyle(1, 0xFFFF00);
		
		for(i in 0...mBodies.length) {
			for(pm in 0...mBodies[i].mPointMasses.length) {
				g.moveTo(mBodies[i].mPointMasses[pm].PositionX * s.X + p.X, mBodies[i].mPointMasses[pm].PositionY * s.Y + p.Y);
				g.lineTo((mBodies[i].mPointMasses[pm].PositionX + mBodies[i].mPointMasses[pm].VelocityX * 0.25) * s.X + p.X, (mBodies[i].mPointMasses[pm].PositionY + mBodies[i].mPointMasses[pm].VelocityY * 0.25) * s.Y + p.Y);
			}
		}
	}
	
	private function defaultCollisionFilter(A:Body, Apm:Int, B:Body, Bpm1:Int, Bpm2:Int, hitPt:Vector2, normSpeed:Float):Bool {
		return true;
	}
	
	/// <summary>
	/// Draw all of the bodies in the world in debug mode, for quick visualization of the entire scene.
	/// </summary>
	/// <param name="device">GraphicsDevice</param>
	/// <param name="effect">An Effect to draw the lines with</param>
	/// <param name="drawAABBs"></param>
	public function debugDrawAllBodies(g:Graphics, drawAABBs:Bool):Void {
		debugDrawPointVelocities(g);
		
		for (i in 0...mBodies.length) {
			if (drawAABBs)
				mBodies[i].debugDrawAABB(g);
			
			mBodies[i].debugDrawMe(g);
		}
	}
	
	// PUBLIC PROPERTIES	
	/// <summary>
	/// number of materials created.
	/// </summary>
	public var MaterialCount(get, never):Int;
	public function get_MaterialCount():Int {
		return mMaterialCount;
	}
	
		
	/// <summary>
	/// This threshold allows objects to be crushed completely flat without snapping through to the other side of objects.
	/// It should be set to a value that is slightly over half the average depth of an object for best results.  Defaults to 0.5.
	/// </summary>
	public var PenetrationThreshold(get, set):Float;
	public function get_PenetrationThreshold():Float {
		return mPenetrationThreshold;
	}
	public function set_PenetrationThreshold(value : Float):Float {
		mPenetrationThreshold = value;
		return value;
	}

	/// <summary>
	/// How many collisions exceeded the Penetration Threshold last update.  if this is a high number, you can assume that
	/// the simulation has "broken" (one or more objects have penetrated inside each other).
	/// </summary>
	public var PenetrationCount(get, never):Int;
	public function get_PenetrationCount():Int {
		return mPenetrationCount;
	}
}
