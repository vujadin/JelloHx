package com.gamestudiohx.jellohx;

/**
 * The rendering settings for the engines. There are Scale and Offset vectors that should be multiplied and added to the
 * resulting vectors to position the bodies on screen. It works much like a camera!
 * 
 * @author Luiz
 */
class RenderingSettings {
	// The point size of points drawn on screen (this value is independent of the Scale vector)
	public static var PointSize:Float = 3;
	
	// Why is the Y vector negative? The engine is a port of an XNA engine (JelloPhysics).
	// XNA is basicly 3D, so the Y vector grows up instead of down, like in a 2D screen (Say, Flash)
	public static var Scale:Vector2 = new Vector2(25.8, -25.8);
	
	// The offset is independent of the scale, unlike Flash DisplayObject's x-y coordinates and scaleX-scaleY
	public static var Offset:Vector2 = new Vector2(300, -50);
}
