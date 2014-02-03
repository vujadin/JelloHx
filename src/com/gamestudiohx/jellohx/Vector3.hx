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
class Vector3 {
	
	public var X:Float;
	public var Y:Float;
	public var Z:Float;
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0):Void {
		X = x;
		Y = y;
		Z = z;
	}
	
	inline public static function Cross(vector1:Vector3, vector2:Vector3, result:Vector3):Void {
		var num3:Float = (vector1.Y * vector2.Z) - (vector1.Z * vector2.Y);
		var num2:Float = (vector1.Z * vector2.X) - (vector1.X * vector2.Z);
		var num:Float = (vector1.X * vector2.Y) - (vector1.Y * vector2.X);
		
		result.X = num3;
		result.Y = num2;
		result.Z = num;
	}
	
	inline public static function Cross2(vector1:Vector3, vector2:Vector3):Vector3 {
		var vector:Vector3 = new Vector3();
		
		vector.X = (vector1.Y * vector2.Z) - (vector1.Z * vector2.Y);
		vector.Y = (vector1.Z * vector2.X) - (vector1.X * vector2.Z);
		vector.Z = (vector1.X * vector2.Y) - (vector1.Y * vector2.X);
		
		return vector;
	}
	
	inline public static function Cross2Z(vector1:Vector3, vector2:Vector3):Float {
		var z:Float = (vector1.X * vector2.Y) - (vector1.Y * vector2.X);
		return z;
	}
	
	inline public function fromVector2(v:Vector2, z:Float = 0):Void {
		X = v.X;
		Y = v.Y;
		Z = z;
	}
}
