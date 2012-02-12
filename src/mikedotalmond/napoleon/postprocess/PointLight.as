/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package mikedotalmond.napoleon.postprocess {

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.Sprite2DMaterial;
	import de.nulldesign.nd2d.materials.shader.Shader2D;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;

	public class PointLight extends Sprite2DMaterial {

        private const POINTLIGHT_VERTEX_SHADER:String =
			"m44 op, va0, vc0   \n" + // vertex * clipspace
			"mov v0, va1		\n"; // copy uv
			
			/** 
			.pbk (2d) pixelshader for simple pointLight effect...
			{
				float2 outcoord     = outCoord();
				dst                 = sampleNearest(src, outcoord);
				
				float dist          = distance(outcoord, float2(pX, pY));
				float attn          = bgLevel + (1.0 / dist) * size;
				
				dst.rgb             *= attn;
			}
			
			// converting to AGAL...
			
			// program constants
			position.xy		--> fc2.xy
			size			--> fc2.z
			bgLevel			--> fc2.w
			
			// calc distance between input XY and the current pixel... in PB2D - dist = distance(outcoord, float2(pX, pY));
			// So, dist = sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
			// Break steps for AGAL...
			diff	= pos0.xy - pos1.xy		--> sub ft0.xy ft0.xy fc2.xy
			sq 		= diff.xy * diff.xy		--> mul ft0.xy ft0.xy ft0.xy
			sqadd	= diff.x  + diff.y		--> add ft0.x ft0.x ft0.y
			1/dist  = 1/sqrt(sqadd)			--> rsq ft0.x ft0.x
			
			So now ft0.x is 1.0 / distance
			
			attn 	= bgLevel + ft0.x * size;
			ft0.y	= fc2.w + ft0.x * fc2.z
				--> mul ft0.y ft0.x fc2.z
				-->	add ft0.y ft0.y fc2.w
			
			So now, ft0.y == attn
			and if ft0.y == 0 we can exit without drawing
				--> kil ft0.y
			
			dst.rgb	*= attn;
			ft1		*= ft0.y
				--> mul ft1 ft1 ft0.y
			
		 */
        private const POINTLIGHT_FRAGMENT_SHADER:String =
			"mov ft0.xyzw, v0.xy                        \n" + // get interpolated uv coords
			"tex ft1, ft0, fs0 <2d,clamp,linear,nomip>  \n" + // sample texture		
			
			"sub ft0.xy ft0.xy fc2.xy 					\n" + // calc distance - xy delta
			"mul ft0.x ft0.x fc3.x	 					\n" + // scale x distance by scene aspect ratio
			"mul ft0.xy ft0.xy ft0.xy 					\n" + // square the xy pair
			"add ft0.x ft0.x ft0.y 						\n" + // add squared x,y components together
			"rsq ft0.x ft0.x 							\n" + // calc distane - 1.0/sqrt(value)
			"mul ft0.y ft0.x fc2.z 						\n" + // calc attenuation - distance*size
			"add ft0.y ft0.y fc2.w 						\n" + // add bg level
			"kil ft0.y 									\n" + // attenuation level == 0 ? exit			
			"mul ft1.xyz ft1.xyz ft0.y 					\n" + // mult sampled texture by attenuation
			
			"mul ft1, ft1, fc0                          \n" + // mult with colorMultiplier
			"add ft1, ft1, fc1                          \n" + // add colorOffset
			"mov oc, ft1                                \n";  // set output
		
		
		private static var pointLightProgramData	:Shader2D;
		
		private var textureWidth					:uint;
		private var textureHeight					:uint;
		private var stageWidth						:uint;
		private var stageHeight						:uint;
		
		private var xRatio							:Number;
		private var yRatio							:Number;
		private var sizeRatio						:Number;
		
		private const aspectRatioConst				:Vector.<Number> = Vector.<Number>([0, 0, 0, 0]);
		
		public var pctX								:Number = 0.5;
		public var pctY								:Number = 0.5;
		public var size								:Number = 32;
		public var bgLevel							:Number = -0.015;
		
        public function PointLight(stageWidth:uint, stageHeight:uint, textureWidth:uint, textureHeight:uint) {
			
			aspectRatioConst.fixed 	= true;
			
			this.textureWidth  		= textureWidth;
			this.textureHeight 		= textureHeight;
			
			stageResize(stageWidth, stageHeight);
			
            super();
        }
		
		/**
		 * Centre the effect on an x,y stage position
		 * @param	x
		 * @param	y
		 */
		public function setPosition(x:Number, y:Number):void {
			pctX = x / stageWidth;
			pctY = y / stageHeight;
		}
		
		/**
		 * Stage resized? call this with new stageWidth,stageHeight
		 * @param	w
		 * @param	h
		 */
		public function stageResize(w:uint, h:uint):void {
			stageWidth  		= w;
			stageHeight 		= h;
			xRatio 				= w / textureWidth;
			yRatio 				= h / textureHeight;
			sizeRatio			= 1.0 / h;
			aspectRatioConst[0]	= w / h;
		}
		
        override protected function prepareForRender(context:Context3D):void {
			
            super.prepareForRender(context);
			
			programConstVector[0] = pctX * xRatio;
			programConstVector[1] = pctY * yRatio;
			programConstVector[2] = size * sizeRatio;
			programConstVector[3] = bgLevel;
			
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, programConstVector);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, aspectRatioConst);
        }
		
        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            pointLightProgramData = null;
        }
		
        override protected function initProgram(context:Context3D):void {
            if(!pointLightProgramData) pointLightProgramData = new Shader2D(context, POINTLIGHT_VERTEX_SHADER, POINTLIGHT_FRAGMENT_SHADER, 4, texture.textureOptions);
            shaderData = pointLightProgramData;
        }
		
		override public function dispose():void {
			super.dispose();
		}
    }
}
