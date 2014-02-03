package com.gamestudiohx;

/**

 * ...

 * @author Luiz

 */
import flash.display.*;
import flash.events.*;
import com.gamestudiohx.jellohx.*;
import openfl.Assets;
import openfl.display.FPS;

class Main extends MovieClip {

	public var mWorld : World;
	public var RenderCanvas : Sprite;
	public var mSpringBodies : Array<DraggableSpringBody>;
	public var mPressureBodies : Array<DraggablePressureBody>;
	public var mStaticBodies : Array<Body>;
	public var tId : Int;
	public function new() {
		super();
		mWorld = new World();
		mSpringBodies = new Array<DraggableSpringBody>();
		mPressureBodies = new Array<DraggablePressureBody>();
		mStaticBodies = new Array<Body>();
		tId = 0;
		go = true;
		showDebug = false;
		mouseDown = false;
		dragPoint = 0;
		
		if(stage != null) init()
		else addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(e : Event = null) : Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		// entry point
		addEventListener(Event.ENTER_FRAME, loop);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseClick);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseup);
		RenderCanvas = new Sprite();
		addChild(RenderCanvas);
		showDebug = false;
		
		loadTest(1);
		
		addChild(new FPS(10, 10, 0xffffff));
	}

	function loadTest(t : Int) : Void {
		tId = t;
		// Temp vars:
		var shape : ClosedShape;
		var pb : DraggablePressureBody;
		var groundShape : ClosedShape = new ClosedShape();
		groundShape.begin();
		groundShape.addVertex(new Vector2(-20, 1));
		groundShape.addVertex(new Vector2(20, 1));
		groundShape.addVertex(new Vector2(20, -1));
		groundShape.addVertex(new Vector2(-20, -1));
		groundShape.finish();

		var groundBody : Body = new Body(mWorld, groundShape, cast Utils.fillArray(Math.POSITIVE_INFINITY, groundShape.Vertices.length), new Vector2(0, -19), 0, Vector2.One.clone(), false);
		mStaticBodies.push(groundBody);
		if(t == 0)  {
			shape = new ClosedShape();
			shape.begin();
			shape.addVertexPos(0, 0);
			shape.addVertexPos(0, 1);
			shape.addVertexPos(0, 2);
			shape.addVertexPos(1, 2);
			shape.addVertexPos(2, 2);
			shape.addVertexPos(2, 1);
			shape.addVertexPos(2, 0);
			shape.addVertexPos(1, 0);
			shape.finish();
			x = -16;
			while(x <= -10) {
				var body1 : DraggablePressureBody = new DraggablePressureBody(mWorld, shape, 1, 40.0, 150.0, 5.0, 300.0, 15.0, new Vector2(0, x), 0.0, Vector2.One.clone());
				body1.addTriangle(7, 0, 1);
				body1.addTriangle(7, 1, 2);
				body1.addTriangle(7, 2, 3);
				body1.addTriangle(7, 3, 4);
				body1.addTriangle(7, 4, 5);
				body1.addTriangle(7, 5, 6);
				mPressureBodies.push(body1);
				body1.finalizeTriangles(0x00FF7F, 0x00FF7F);
				x += 3;
			}
		}
		if(t == 1)  {
			shape = new ClosedShape();
			shape.begin();
			shape.addVertex(new Vector2(-1.5, 2.0));
			shape.addVertex(new Vector2(-0.5, 2.0));
			shape.addVertex(new Vector2(0.5, 2.0));
			shape.addVertex(new Vector2(1.5, 2.0));
			shape.addVertex(new Vector2(1.5, 1.0));
			shape.addVertex(new Vector2(0.5, 1.0));
			shape.addVertex(new Vector2(0.5, -1.0));
			shape.addVertex(new Vector2(1.5, -1.0));
			shape.addVertex(new Vector2(1.5, -2.0));
			shape.addVertex(new Vector2(0.5, -2.0));
			shape.addVertex(new Vector2(-0.5, -2.0));
			shape.addVertex(new Vector2(-1.5, -2.0));
			shape.addVertex(new Vector2(-1.5, -1.0));
			shape.addVertex(new Vector2(-0.5, -1.0));
			shape.addVertex(new Vector2(-0.5, 1.0));
			shape.addVertex(new Vector2(-1.5, 1.0));
			shape.finish();
			shape.transformOwn(0, new Vector2(1.0, 1.0));
			var x : Int = -8;
			while(x <= 8) {
				var body : DraggableSpringBody = new DraggableSpringBody(mWorld, shape, 1, 150.0, 5.0, 300.0, 20.0, new Vector2(x, 0), 0.0, Vector2.One.clone());
				body.addInternalSpring(0, 14, 300.0, 10.0);
				body.addInternalSpring(1, 14, 300.0, 10.0);
				body.addInternalSpring(1, 15, 300.0, 10.0);
				body.addInternalSpring(1, 5, 300.0, 10.0);
				body.addInternalSpring(2, 14, 300.0, 10.0);
				body.addInternalSpring(2, 5, 300.0, 10.0);
				body.addInternalSpring(1, 5, 300.0, 10.0);
				body.addInternalSpring(14, 5, 300.0, 10.0);
				body.addInternalSpring(2, 4, 300.0, 10.0);
				body.addInternalSpring(3, 5, 300.0, 10.0);
				body.addInternalSpring(14, 6, 300.0, 10.0);
				body.addInternalSpring(5, 13, 300.0, 10.0);
				body.addInternalSpring(13, 6, 300.0, 10.0);
				body.addInternalSpring(12, 10, 300.0, 10.0);
				body.addInternalSpring(13, 11, 300.0, 10.0);
				body.addInternalSpring(13, 10, 300.0, 10.0);
				body.addInternalSpring(13, 9, 300.0, 10.0);
				body.addInternalSpring(6, 10, 300.0, 10.0);
				body.addInternalSpring(6, 9, 300.0, 10.0);
				body.addInternalSpring(6, 8, 300.0, 10.0);
				body.addInternalSpring(7, 9, 300.0, 10.0);
				// polygons!
				body.addTriangle(0, 15, 1);
				body.addTriangle(1, 15, 14);
				body.addTriangle(1, 14, 5);
				body.addTriangle(1, 5, 2);
				body.addTriangle(2, 5, 4);
				body.addTriangle(2, 4, 3);
				body.addTriangle(14, 13, 6);
				body.addTriangle(14, 6, 5);
				body.addTriangle(12, 11, 10);
				body.addTriangle(12, 10, 13);
				body.addTriangle(13, 10, 9);
				body.addTriangle(13, 9, 6);
				body.addTriangle(6, 9, 8);
				body.addTriangle(6, 8, 7);
				body.finalizeTriangles(0x00FF7F, 0xFF0080);
				mSpringBodies.push(body);
				x += 4;
			}
			var ball : ClosedShape = new ClosedShape();
			ball.begin();
			var i : Int = 0;
			while(i < 360) {
				ball.addVertexPos(Math.cos(-i * (Math.PI / 180)), Math.sin(-i * (Math.PI / 180)));
				i += 20;
			}
			ball.finish();
			x = -10;
			while(x <= 10) {
				pb = new DraggablePressureBody(mWorld, ball, 1.0, 40.0, 10.0, 1.0, 300.0, 20.0, new Vector2(x, -12), 0, Vector2.One.clone());
				pb.addTriangle(0, 10, 9);
				pb.addTriangle(0, 9, 1);
				pb.addTriangle(1, 9, 8);
				pb.addTriangle(1, 8, 2);
				pb.addTriangle(2, 8, 7);
				pb.addTriangle(2, 7, 3);
				pb.addTriangle(3, 7, 6);
				pb.addTriangle(3, 6, 4);
				pb.addTriangle(4, 6, 5);
				pb.addTriangle(17, 10, 0);
				pb.addTriangle(17, 11, 10);
				pb.addTriangle(16, 11, 17);
				pb.addTriangle(16, 12, 11);
				pb.addTriangle(15, 12, 16);
				pb.addTriangle(15, 13, 12);
				pb.addTriangle(14, 12, 15);
				pb.addTriangle(14, 13, 12);
				pb.finalizeTriangles(0x008080, 0xFFFFFF);
				mPressureBodies.push(pb);
				if(x == -10) pb.GasPressure = 0;
				x += 5;
			}
		}
		if(t == 2)  {
			var def : Int = 20;
			var ball = new ClosedShape();
			ball.begin();
			var i:Int = 0;
			while(i < 360) {
				ball.addVertexPos(Math.cos(-i * (Math.PI / 180)), Math.sin(-i * (Math.PI / 180)));
				i += def;
			}
			ball.transformOwn(0, new Vector2(0.3, 0.3));
			ball.finish();
			pb = new DraggablePressureBody(mWorld, ball, 0.6, 30.0, 10.0, 1.0, 600.0, 20.0, new Vector2(x, -15), 0, Vector2.One.clone());
			pb.finalizeTriangles(0x008080, 0x000000);
			mPressureBodies.push(pb);
			createBox(5, -17, 2, 2, 0);
			createBox(5, -14, 2, 2, 0);
			createBox(5, -11, 2, 2, 0);
			createBox(5, -8, 2, 2, 0);
			createBox(0, -17, 2, 2, 1);
			createBox(-5, -10, 3, 3, 2);
		}

		else if(tId == 3)  {
			mWorld.removeBody(groundBody);
			mStaticBodies.splice(Lambda.indexOf(mStaticBodies, groundBody), 1);
			var def = 20;
			var ball = new ClosedShape();
			ball.begin();
			var i = 0;
			while(i < 360) {
				ball.addVertexPos(Math.cos(-i * (Math.PI / 180)), Math.sin(-i * (Math.PI / 180)));
				i += def;
			}
			ball.transformOwn(0, new Vector2(0.3, 0.3));
			ball.finish();
			pb = new DraggablePressureBody(mWorld, ball, 0.6, 90.0, 10.0, 1.0, 1000.0, 25.0, new Vector2(0, -3), 0, Vector2.One.clone());
			// Equalize the size by the pressure by extending the soft body a bit so it won't wobble right off:
			pb.setPositionAngle(null, 0, new Vector2(4.33, 4.33));
			pb.finalizeTriangles(0x996633, 0x996633);
			mPressureBodies.push(pb);
			mWorld.setMaterialPairData(0, 0, 0.0, 0.9);
			var bs : Float = 1.3;
			fix(createBox(0, -18, bs, bs, 0));
			fix(createBox(2, -15, bs, bs, 0));
			fix(createBox(-2, -15, bs, bs, 0));
			fix(createBox(4, -12, bs, bs, 0));
			fix(createBox(0, -12, bs, bs, 0));
			fix(createBox(-4, -12, bs, bs, 0));
			fix(createBox(6, -9, bs, bs, 0));
			fix(createBox(2, -9, bs, bs, 0));
			fix(createBox(-2, -9, bs, bs, 0));
			fix(createBox(-6, -9, bs, bs, 0));
			createBox(-9, -12, 2, 27, 3).setPositionAngle(null, Math.PI / 5, null);
			createBox(9, -12, 2, 27, 3).setPositionAngle(null, -Math.PI / 5, null);
		}
	}

	public function fix(b : Body) : Void {
		b.mIsPined = true;
		b.VelocityDamping = 0.97;
		cast(b, SpringBody).setEdgeSpringConstants(100, 10);
	}

	public function createBox(x : Float, y : Float, w : Float, h : Float, t : Int = 0) : Body {
		var shape = new ClosedShape();
		if(t == 0)  {
			shape.begin();
			shape.addVertexPos(0, 0);
			shape.addVertexPos(0, h);
			shape.addVertexPos(w, h);
			shape.addVertexPos(w, 0);
			shape.finish();
			var body : DraggableSpringBody = new DraggableSpringBody(mWorld, shape, 1, 150.0, 5.0, 300.0, 15.0, new Vector2(x, y), 0.0, Vector2.One.clone());
			body.addInternalSpring(0, 2, 300, 10);
			body.addInternalSpring(1, 3, 300, 10);
			body.addTriangle(0, 1, 2);
			body.addTriangle(1, 2, 3);
			body.finalizeTriangles(0xDDDD00, 0xDDDD00);
			mSpringBodies.push(body);
			return body;
		}

		else if(t == 1)  {
			shape.begin();
			shape.addVertexPos(0, 0);
			shape.addVertexPos(0, h / 2);
			shape.addVertexPos(0, h);
			shape.addVertexPos(w / 2, h);
			shape.addVertexPos(w, h);
			shape.addVertexPos(w, h / 2);
			shape.addVertexPos(w, 0);
			shape.addVertexPos(w / 2, 0);
			shape.finish();
			var body1 : DraggablePressureBody = new DraggablePressureBody(mWorld, shape, 1, 40.0, 150.0, 5.0, 300.0, 15.0, new Vector2(x, y), 0.0, new Vector2(0.5, 0.5));
			body1.addTriangle(7, 0, 1);
			body1.addTriangle(7, 1, 2);
			body1.addTriangle(7, 2, 3);
			body1.addTriangle(7, 3, 4);
			body1.addTriangle(7, 4, 5);
			body1.addTriangle(7, 5, 6);
			mPressureBodies.push(body1);
			body1.finalizeTriangles(0x00FF7F, 0x00FF7F);
			return body1;
		}

		else if(t == 2)  {
			shape.begin();
			shape.addVertexPos(0, 0);
			shape.addVertexPos(0, h / 2);
			shape.addVertexPos(0, h);
			shape.addVertexPos(w / 2, h);
			shape.addVertexPos(w, h);
			shape.addVertexPos(w, h / 2);
			shape.addVertexPos(w, 0);
			shape.addVertexPos(w / 2, 0);
			shape.finish();
			var body2 : SpringBody = new SpringBody(mWorld, shape, 5, 900, 50, 30, 15, new Vector2(x, y), 0, Vector2.One.clone(), true);
			mStaticBodies.push(body2);
			return body2;
		}

		else if(t == 3)  {
			shape.begin();
			shape.addVertexPos(0, 0);
			shape.addVertexPos(0, h);
			shape.addVertexPos(w, h);
			shape.addVertexPos(w, 0);
			shape.finish();
			var body3 : Body = new Body(mWorld, shape, cast Utils.fillArray(Math.POSITIVE_INFINITY, shape.Vertices.length), new Vector2(x, y), 0, Vector2.One.clone(), false);
			mStaticBodies.push(body3);
			return body3;
		}
		return null;
	}

	public function mouseClick(e : Event) : Void {
		var s : Vector2 = RenderingSettings.Scale;
		var p : Vector2 = RenderingSettings.Offset;
		var cursorPos = new Vector2((mouseX - p.X) / s.X, (mouseY - p.Y) / s.Y);
		if(dragBody == null)  {
			var body : Array<Int> = [];
			var dragp : Array<Int> = [];
			mWorld.getClosestPointMass(cursorPos, body, dragp);
			dragPoint = dragp[0];
			dragBody = mWorld.getBody(body[0]);
		}
		mouseDown = true;
	}

	public function mouseup(e : Event) : Void {
		mouseDown = false;
		dragBody = null;
	}

	public function numbOfPairs(numb : Int, wholeNumb : Int) : Int {
		var i : Int = 0;
		while(wholeNumb > numb) {
			wholeNumb -= numb;
			i++;
		}

		return i;
	}

	public var go : Bool;
	public function loop(e : Event) : Void {
		var s : Vector2 = RenderingSettings.Scale;
		var p : Vector2 = RenderingSettings.Offset;
		var cursorPos : Vector2 = new Vector2((mouseX - p.X) / s.X, (mouseY - p.Y) / s.Y);
		var pm : PointMass;
		var i : Int = 0;
		while(i < 5) {
			mWorld.update(1.0 / 200.0);
			if(dragBody != null)  {
				pm = dragBody.getPointMass(dragPoint);
				if(Std.is(dragBody, DraggableSpringBody)) cast((dragBody), DraggableSpringBody).setDragForce(VectorTools.calculateSpringForceRetPos(pm.PositionX, pm.PositionY, pm.VelocityX, pm.VelocityY, cursorPos.X, cursorPos.Y, 0, 0, 0.0, 100.0, 10.0), dragPoint)
				else if(Std.is(dragBody, DraggablePressureBody)) cast((dragBody), DraggablePressureBody).setDragForce(VectorTools.calculateSpringForceRetPos(pm.PositionX, pm.PositionY, pm.VelocityX, pm.VelocityY, cursorPos.X, cursorPos.Y, 0, 0, 0.0, 100.0, 10.0), dragPoint);
			}
			i++;
		}

		RenderCanvas.graphics.clear();
		
		if(!showDebug)  {
			i = 0;
			while(i < mSpringBodies.length) {
				mSpringBodies[i].drawMe(RenderCanvas.graphics);
				i++;
			}
			i = 0;
			while(i < mPressureBodies.length) {
				mPressureBodies[i].drawMe(RenderCanvas.graphics);
				i++;
			}
			i = 0;
			while(i < mStaticBodies.length) {
				mStaticBodies[i].debugDrawMe(RenderCanvas.graphics);
				i++;
			}
		}

		else  {
			// draw all the bodies in debug mode, to confirm physics.
			mWorld.debugDrawMe(RenderCanvas.graphics);
			mWorld.debugDrawAllBodies(RenderCanvas.graphics, false);
		}

		if(dragBody != null)  {
			s = RenderingSettings.Scale;
			p = RenderingSettings.Offset;
			pm = dragBody.mPointMasses[dragPoint];
			RenderCanvas.graphics.lineStyle(1, 0xD2B48C);
			RenderCanvas.graphics.moveTo(pm.PositionX * s.X + p.X, pm.PositionY * s.Y + p.Y);
			RenderCanvas.graphics.lineTo(mouseX, mouseY);
		}

		else  {
			dragBody = null;
			dragPoint = -1;
		}

	}

	public var showDebug : Bool;
	public var dragBody : Body;
	public var mouseDown : Bool;
	public var dragPoint : Int;
}

