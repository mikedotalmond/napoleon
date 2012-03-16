/*
Copyright (c) 2012 Mike Almond - @mikedotalmond - https://github.com/mikedotalmond

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

package mikedotalmond.napoleon {

	/**
	 * ...
	 * @author Mike Almond - https://github.com/
	 * 
	 * Interface that all the classes with Nape physics need to implement. 
	 * Classes that implement this interface should also extend Node2D 
	 * e.g. [NapeSprite2D:INapeNode] > [Sprite2D] > [Node2D]
	 * 
	 * This allows NapeScene and it's descendants to target the Nape (phyiscs) bodies as required.
	 */
	
	import nape.phys.Body;
	import de.nulldesign.nd2d.display.Node2D;
	
	public interface INapeNode {
		
		function copyAsINapeNode():INapeNode;
		
		function get body():Body; // the Nape pyhsics body
		function setBodyNull():void; // clears the associated body - but does not remove it from the nape space
		
		// these are here to make sure the physics body properties get updated too - means you have to override these public functions of Node2D in your implementation
		function set visible(value:Boolean):void;
		function get visible():Boolean;
		function get x():Number;
		function get y():Number;
		function set x(value:Number):void;
		function set y(value:Number):void;
		function set rotation(value:Number):void;
		function scale(x:Number, y:Number):void; //scale the node and associated nape body (mulplicative)
		
		function get scaleX():Number;
		function get scaleY():Number;
		function set scaleX(value:Number):void;
		function set scaleY(value:Number):void;
		
		function dispose():void; // clean up
	}
}