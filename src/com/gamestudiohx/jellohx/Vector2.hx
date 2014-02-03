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

// Vector2 class
class Vector2 {
	
	public static var Zero:Vector2 = new Vector2(0,0);
	public static var One:Vector2 = new Vector2(1,1);

	public var X:Float;
	public var Y:Float;

	public function new(px:Float = 0, py:Float = 0):Void {
		X = px;
		Y = py;
	}

	public function setTo(px:Float, py:Float):Void {
		X = px;
		Y = py;
	}

	public function setToVec(v:Vector2):Void {
		X = v.X;
		Y = v.Y;
	}

	public function copy(v:Vector2):Void {
		X = v.X;
		Y = v.Y;
	}

	public function clone():Vector2 {
		return new Vector2(X, Y);
	}

	inline public function dot(v:Vector2):Float {
		return X * v.X + Y * v.Y;
	}

	inline public static function Dot(v1:Vector2, v2:Vector2):Float {
		return v1.dot(v2);
	}

	inline public function cross(v:Vector2):Float {
		return X * v.Y - Y * v.X;
	}

	inline public function plus(v:Vector2):Vector2 {
		return new Vector2(X + v.X, Y + v.Y);
	}

	inline public function plusEquals(v:Vector2):Vector2 {
		X += v.X;
		Y += v.Y;

		return this;
	}

	inline public function minus(v:Vector2):Vector2 {
		return new Vector2(X - v.X, Y - v.Y);
	}

	inline public function minusEquals(v:Vector2):Vector2 {
		X -= v.X;
		Y -= v.Y;

		return this;
	}

	inline public function mult(s:Float):Vector2 {
		return new Vector2(X * s, Y * s);
	}

	inline public function multVec(v:Vector2):Vector2 {
		return new Vector2(X * v.X, Y * v.Y);
	}

	inline public function perpendicular():Vector2 {
		var t:Float = X;

		X = -Y;
		Y = t;

		return this;
	}

	inline public function div(s:Float):Vector2 {
		var revS:Float = 1 / s;
		
		return new Vector2(X * revS, Y * revS);
	}

	inline public function multEquals(s:Float):Vector2 {
		X *= s;
		Y *= s;

		return this;
	}
	
	inline public function multEqualsVec(v:Vector2):Vector2 {
		X *= v.X;
		Y *= v.Y;

		return this;
	}

	inline public function times(v:Vector2):Vector2 {
		return new Vector2(X * v.X, Y * v.Y);
	}

	inline public function divEquals(s:Float):Vector2 {
		if (s == 0) {
			s = 0.0001;
		}
		
		var revS = 1 / s;
		
		X *= revS;
		Y *= revS;

		return this;
	}

	inline public function magnitude():Float {
		return Math.sqrt(X * X + Y * Y);
	}

	inline public function length():Float {
		return (X * X) + (Y * Y);
	}

	inline public function distance(v:Vector2):Float {
		var delta:Vector2 = this.minus(v);

		return delta.magnitude();
	}

	inline public static function Distance(value1:Vector2, value2:Vector2):Float {
		var num2:Float = value1.X - value2.X;
		var num:Float = value1.Y - value2.Y;

		return Math.sqrt((num2 * num2) + (num * num));
	}

	inline public static function DistanceSquared(value1:Vector2, value2:Vector2):Float {
		var num2:Float = value1.X - value2.X;
		var num:Float = value1.Y - value2.Y;

		return (num2 * num2) + (num * num);
	}

	inline public static function Normalize(value:Vector2, result:Vector2):Void {
		var num2:Float = (value.X * value.X) + (value.Y * value.Y);
		var num:Float = 1 / Math.sqrt(num2);

		result.X = value.X * num;
		result.Y = value.Y * num;
	}

	inline public function getDifference(v:Vector2):Vector2 {
		return new Vector2(v.X - X, v.Y - Y);
	}
	
	inline public function normalize():Vector2 {
		var m:Float = magnitude();

		if (m == 0) {
			m = 0.0001;
		}

		return div(m);
	}

	inline public function normalizeThis():Vector2 {
		var m:Float = magnitude();

		if (m == 0) {
			m = 0.0001;
		}

		divEquals(m);		

		return this;
	}

	inline public function negate():Vector2 {
		X =  -  X;
		Y =  -  Y;

		return this;
	}

	inline public function toString():String {
		return ('{X:' + X + " Y:" + Y + '}');
	}
}
