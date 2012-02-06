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
	
	import com.furusystems.dconsole2.DConsole;
	import com.furusystems.dconsole2.plugins.StatsOutputUtil;
	import com.furusystems.dconsole2.plugins.SystemInfoUtil;
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.World2D;
	
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.getTimer;
	
	import mikedotalmond.input.KeyboardPlus;
	import mikedotalmond.napoleon.NapeScene2D;
	
	import org.osflash.signals.Signal;
	
	/**
	 * Gives World2D, among other things, control of NapeScene2D scenes and the delta-time calculations needed for Nape in the mainLoop
	 * @see de.nulldesign.nd2d.display.World2D
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	public class NapeWorld2D extends World2D {
		
		static public const Logger			:ILogger	= Logging.getLogger(NapeWorld2D);		
		static public const VERSION			:String 	= Version.Major + "." + Version.Minor + "." + Version.Build + "." + Version.Revision;
		
		protected var inputPollInterval		:Number 	= 1 / 25;
		protected var lastDelta				:Number 	= 1 / 60;
		
		protected var GameControllerClass	:Class 		= null;
		
		protected var inputInterval			:Number 	= 0;
		protected var inputUpdateSignal		:Signal 	= new Signal();
		
		protected var currentSceneIndex		:int = -1;
		protected var sceneClassList		:Vector.<Class> = new Vector.<Class>();
		protected var sceneClassNameList	:Vector.<String> = new Vector.<String>();
		protected var napeScene				:NapeScene2D;
		
		/**
		 * 
		 * @param	renderMode
		 * @param	frameRate
		 * @param	bounds
		 * @param	stageID
		 */
		public function NapeWorld2D(renderMode:String, frameRate:uint = 60, bounds:Rectangle = null, stageID:uint = 0) {
			super(renderMode, frameRate, bounds, stageID);
		}
		
		/**
		 * 
		 * @param	event
		 */
		override protected function addedToStage(event:Event):void {
			super.addedToStage(event);
			
			stage.align 	= StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality 	= StageQuality.LOW; // NOTE: turn this up if you're drawing shapes into bitmap data at any point...
			stage.showDefaultContextMenu = false;
			
			const m:ContextMenu = new ContextMenu();
			m.customItems 		= [new ContextMenuItem("napoleon " + VERSION, false, false)];
			contextMenu 		= m;
			
			KeyboardPlus.keyboardPlus.init(stage);
			
			setupScenes();
			setupDConsole();
		}
		
		/**
		 * @throws IllegalOperationError (if not overriden)
		 */
		protected function setupScenes():void {
			throw new IllegalOperationError("setupScenes requires implementation");
		}
		
		
		/**
		 * Add to the world scene-list
		 * @param	scene
		 * @param	name
		 * @return	The new length of the scene list
		 */
		protected function addScene(scene:Class, name:String):int {
			if (sceneClassNameList.indexOf(name) == -1) {
				sceneClassList.push(scene);
				sceneClassNameList.push(name);
			} else {
				Logger.info("Scene '" + name + "' already exists");
			}
			
			return sceneClassNameList.length;
		}
		
		
		/**
		 * Remove a scene from the scene-list, either by class, or name
		 * (doesn't deactivate / destroy the scene if it's the current scene, just removes it from the list of available scenes)
		 * @param	scene
		 * @param	name
		 * @return	The new length of the scene list
		 */
		protected function removeScene(clss:Class = null, name:String = null):int {
			
			var i:int = -1;
			if (name != null) {
				i = sceneClassNameList.indexOf(name) ;
			} else if (scene != null) {
				i = sceneClassList.indexOf(scene) ;
			} 
			
			if (i != -1) {
					sceneClassList.splice(i, 1);
					sceneClassNameList.splice(i, 1);
			} else {
				Logger.info("Scene '" + name + "' does not exist");
			}
			
			return sceneClassNameList.length;
		}
		
		 /**
		 * select the next scene from the list
		  * @param	direction	-1/1
		  */
		protected function nextScene(direction:int=1):void {
			if (sceneClassList.length == 0) {
				Logger.warn("Nothing to select! Use addScene to add your scenes to the list...");
				return;
			}
			currentSceneIndex += direction;
			if (currentSceneIndex == sceneClassList.length) currentSceneIndex -= sceneClassList.length;
			else if(currentSceneIndex < 0) currentSceneIndex += sceneClassList.length;
			setActiveScene(new sceneClassList[currentSceneIndex]());
		}
		
		
		/**
		 * Create some commands, print some messages...
		 */
		protected function setupDConsole():void {
			
			addChild(DConsole.view);
			DConsole.view.alpha = 0.8;
			DConsole.console.createCommand("step", mainLoop, "NapeWorld2D");
			DConsole.console.createCommand("resume", resume, "NapeWorld2D");
			DConsole.console.createCommand("sleep", sleep, "NapeWorld2D");
			DConsole.console.createCommand("wakeUp", wakeUp, "NapeWorld2D");
			DConsole.console.createCommand("fullscreen", function():void { 
				stage.displayState = StageDisplayState.FULL_SCREEN; DConsole.hide(); 
			}, "NapeWorld2D");
			
			DConsole.console.createCommand("sceneList", getSceneList, "NapeWorld2D");
			DConsole.console.createCommand("setActiveScene", setActiveSceneByName, "NapeWorld2D");
			DConsole.registerPlugins(StatsOutputUtil, SystemInfoUtil);
			
			Logger.info("napoleon", VERSION);
			Logger.info("-------------------");
			Logger.info("Ctrl+Shift+Enter to show/hide this console");
			Logger.info("Some commands: sceneList, setActiveScene, fullscreen, pause, resume, sleep, wakeUp");
			Logger.info("Available scenes:", getSceneList());
		}
		
		/**
		 * 
		 * @return A String of comma sperated names of scenes in the sceneClassList
		 */
		protected function getSceneList():String {
			return sceneClassNameList.toString();
		}
		
		/**
		 * 
		 * @param	scene - Name of the scene to activate
		 */
		protected function setActiveSceneByName(scene:String):void {
			
			const i	:int = sceneClassNameList.indexOf(scene);
			
			if (i != -1) {
				setActiveScene(new sceneClassList[i]() as Scene2D);
			} else{
				Logger.info("scene '" + scene + "' does not exist");
				Logger.info("Available scenes: " + getSceneList());
			}
		}
		
		/**
		 * 
		 * @param	e
		 */
		protected function toggleFullscreen(e:Event = null):void {
			try {
				stage.displayState = (stage.displayState == StageDisplayState.FULL_SCREEN) ? StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN;
			} catch (err:Error) {
				Logger.error(err); // allowFullscreen not set?
			}
		}
		
		/**
		 * 
		 * @param	e
		 */
		override protected function context3DError(e:ErrorEvent):void {
			super.context3DError(e);
		}
		
		/**
		 * 
		 * @param	e
		 */
		override protected function context3DCreated(e:Event):void {
			super.context3DCreated(e);
			DConsole.show();
			start();
		}
		
		/**
		 * 
		 * @param	value
		 */
		override public function setActiveScene(value:Scene2D):void {
			if(scene) scene.dispose();
			
			super.setActiveScene(value);
			
			napeScene = scene as NapeScene2D; // will be null if not a NapeScene2D
			if (napeScene) {
				antialiasing = scene.preferredAntialiasing;
				if(GameControllerClass) { // create and assign the game controller in the NapeScene2D
					napeScene.gameController = new GameControllerClass(inputUpdateSignal);
				}
			}
			
			System.pauseForGCIfCollectionImminent();
		}
		
		/**
		 * 
		 * @param	e
		 */
		override protected function mainLoop(e:Event):void {
			
			if (scene && context3D) {
				
				var time	:Number = getTimer() * 0.001;
				var delta:Number = time - lastFramesTime;
				
				lastFramesTime = time;
				
				delta 	-= (delta - lastDelta) * 0.9; // ease changes to the delta time for smoother physics
				lastDelta = delta;
				
				if ((inputInterval += delta) >= inputPollInterval) { // update inputs
					inputUpdateSignal.dispatch();
					inputInterval = 0;
				}
				
				draw(delta, time); // update scene space and draw
			}
		}
		
		/**
		 * 
		 * @param	e
		 */
		override protected function resizeStage(e:Event = null):void {
			super.resizeStage(e);
			if(napeScene) napeScene.resize(stage.stageWidth, stage.stageHeight);
		}
	}
}