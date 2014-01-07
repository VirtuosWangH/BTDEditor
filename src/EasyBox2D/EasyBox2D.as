﻿package EasyBox2D{		import flash.utils.*;	import flash.display.*	import flash.events.*;	import EasyBox2D.objects.*;		import Box2D.Dynamics.*;	import Box2D.Collision.*;	import Box2D.Collision.Shapes.*;	import Box2D.Common.Math.*;	import Box2D.Dynamics.Joints.*;	import EasyBox2D.contact.EasyContacts;
		/**        In order to make use of this library you'll need to instantiate a EasyBox2D instance.				What does the EasyBox2D class do?		It instantiates the main classes that Box2D needs to run (b2World and b2AABB).		It manages the Box2D simulation via <code>start()</code> and <code>stop()</code> methods.		It contains methods for creating rigid bodies and joints - such as addCircle(), addBox() and addPoly()		It contains a few additional methods for debugging and mouse interaction.	*/	public class EasyBox2D extends EventDispatcher{				/** Constant value for use with the EasyBox2D step event */		public static var STEP:String = "step";				/** Constant value "distance" joint type */		public static var DISTANCE:String = "distance";				/** Constant value "revolute" joint type */		public static var REVOLUTE:String = "revolute";				/** Constant value "prismatic" joint type */		public static var PRISMATIC:String = "prismatic";				/** Constant value "gear" joint type */		public static var GEAR:String = "gear";				/** Constant value "pulley" joint type */		public static var PULLEY:String = "pulley";						/** The Box2D b2AABB instance. */		public var worldAABB:b2AABB;				private var  _gravity:b2Vec2;		/** The world gravity vector. This can be changed during runtime. */		public function set gravity(v:b2Vec2):void{			_gravity = v;			w.SetGravity(_gravity);		}		public function get gravity():b2Vec2{			return _gravity;		}				/** The Box2D b2World instance. */		public var w:b2World;				/** The Box2D iterations. This effects the accuracy of the simulation, lower values will be less CPU intensive and less accurate, higher values will be more CPU intensive and more accurate. */		public var iterations:int = 20;				/** The Box2D time step. The default is 1 / 60.0 - for simplicity it is not recommended that you change this value*/        public var timeStep:Number = 1 / 60.0;				/** The MovieClip containing the Box2D world. */		public var main:MovieClip;				/** Toggles FRIM (frame rate independent movement). By default this is set to true. Turning it off will cause the stage.frameRate (the frame rate of the swf) to effect the speed of the Box2D simulation.*/		public var frim:Boolean;				private var contactListener:b2ContactListener;				public var debug:Boolean;		private var _simpleRender:Boolean = true;		private var _renderJoints:Boolean = true;		private var _defaults:Object = new Object();				private var _customMouse:Boolean = false;				private var _mouseJoint:b2MouseJoint;		private var _mousePVec:b2Vec2 = new b2Vec2();				private var _quickObjects:Dictionary = new Dictionary(true);				public var destroyable:Array =[];				private var render:Event=new Event("render");				/**		 * Creates a new EasyBox2D instance.		 *		 * @param main  The MovieClip to render the Box2D world into.		 * @param params An Object containing settings for EasyBox2D and the Box2D world. <i>See below for details</i>.		 *		 * <i>All <code>params</code> Object Properties:</i>		  <blockquote>		  <code>debug: </code>: <span class="codeIdentifier">false</span> - If set to true, EasyBox2D will use the Box2D debug renderer to draw the world.		  <code>gravityX :</code> 0 - The x component of the gravity vector for the Box2D world.		  <code>gravityY:</code> 20 - The y component of the gravity vector for the Box2D world.		  <code>timeStep:</code> 1 / 60 - The Box2D time step.		  <code>iterations:</code> 20 - The Box2D iterations.		  <code>frim:</code> <span class="codeIdentifier">true</span> -  Toggles FRIM (frame rate independent movement).		  <code>bounds:</code> [-100, -100, 100, 100] - Defines the bounding box for the Box2D world.		  <code>renderJoints:</code> <span class="codeIdentifier">true</span> - Toggles the rendering of joints for the simple renderer.		  <code>simpleRender:</code> <span class="codeIdentifier">true</span> - Toggles the EasyBox2D simple renderer. Set this to false if you don’t want to utilize any of the EasyBox2D rigid body skinning.		  <code>customMouse</code> <span class="codeIdentifier">false</span> - Toggles the ability for custom mouse coordinates to be passed in via the {@link #setMouse()}. This can be useful if your using EasyBox2D with a 3D engine.		  </blockquote>		 */		public function EasyBox2D(main:MovieClip, params:Object=null){			this.main = main;			init(params);		}				private function init(p:Object=null):void{			var defaults:Object = {gravityX:0.0, gravityY:20.0, iterations: iterations, timeStep: timeStep, bounds: [-100, -100, 100, 100], debug:false, simpleRender:_simpleRender, renderJoints:true, frim:true, customMouse:false};			 			 if (p == null){				 p = new Object();			 }			 				for (var key:String in defaults){					if (p[key] == null){					  p[key] = defaults[key];					}				}			 _customMouse = p.customMouse;			 frim = p.frim;			 _simpleRender = p.simpleRender;			 _renderJoints = p.renderJoints;			 iterations = p.iterations;			 timeStep = p.timeStep			 debug = p.debug;			 			 var bg:Sprite = new Sprite();			 main.addChild(bg);			 if (debug){				bg.graphics.beginFill(0x333333);				bg.graphics.drawRect(0,0, main.stage.stageWidth, main.stage.stageHeight);			 }						worldAABB  = new b2AABB();			worldAABB.lowerBound.Set(p.bounds[0], p.bounds[1])			worldAABB.upperBound.Set(p.bounds[2], p.bounds[3]);						_gravity = new b2Vec2(p.gravityX, p.gravityY);						w=new b2World(worldAABB, _gravity, true);						if (debug){				var dbgDraw:b2DebugDraw = new b2DebugDraw();				var dbgSprite:Sprite = new Sprite();				main.addChild(dbgSprite);				dbgDraw.m_sprite = dbgSprite;				dbgDraw.m_drawScale = 30.0;				dbgDraw.m_fillAlpha = .5;				dbgDraw.m_alpha = .5;				dbgDraw.m_lineThickness = 1.0;				dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit;//0xFFFFFFFF;				w.SetDebugDraw(dbgDraw);			}					}				/**		   Draws a grid for testing/debugging purposes only. 		  @param size The width and height of the grid squares. The default size is 30 because with EasyBox2D default settings 30 pixels = 1 meter.		  		  @param lineColor The line color.		  @param lineAlpha The line alpha.		*/		public function grid(size:int=30, lineColor:uint=0xFFFF00, lineAlpha:Number=1):void{			//main.graphics.clear();			var g:Sprite = new Sprite();			main.addChild(g);			g.graphics.lineStyle(0, lineColor, lineAlpha);			for (var i:int = 0; i<main.stage.stageWidth; i+=size){				g.graphics.moveTo(i, 0);				g.graphics.lineTo(i, main.stage.stageHeight);			}			for (i = 0; i<main.stage.stageHeight; i+=size){				g.graphics.moveTo(0, i);				g.graphics.lineTo(main.stage.stageWidth, i);			}		}				/**		Draws boxes on each side of the stage.		@params The params Object for all four boxes. See the {@link #addBox()} method for list of valid Object properties.		*/		public function createStageWalls(params:Object=null):void{			 			var p:Object = params;			 if (p == null){				 p = new Object();			 }			 			for (var key:String in _defaults){			      if (p[key] == null){				     p[key] = _defaults[key];				  }			 }									var sw:Number = main.stage.stageWidth / 30;			var sh:Number = main.stage.stageHeight / 30;						if (p.bottom == true || p.bottom == null){			 addBox({x:sw / 2, y:sh, width:sw - 1, height:1,  density:.0, lineThickness:p.lineThickness, lineColor: p.lineColor, lineAlpha: p.lineAlpha, fillColor: p.fillColor, fillAlpha: p.fillAllpha});			}			 if (p.top == true || p.top == null){			 addBox({x:sw / 2, y:0, width:sw - 1, height:1,  density:.0, lineThickness:p.lineThickness,lineColor: p.lineColor, lineAlpha: p.lineAlpha, fillColor: p.fillColor, fillAlpha: p.fillAllpha});			 }			 			 if (p.left == true || p.left == null){			 addBox({x:0, y:sh / 2, width:1, height:sh ,  density:.0, lineThickness:p.lineThickness,lineColor: p.lineColor, lineAlpha: p.lineAlpha, fillColor: p.fillColor, fillAlpha: p.fillAllpha});			 }			 			 if (p.right == true || p.right == null){			 addBox({x:sw, y:sh / 2, width:1, height:sh,  density:.0, lineThickness:p.lineThickness,lineColor: p.lineColor, lineAlpha: p.lineAlpha, fillColor: p.fillColor, fillAlpha: p.fillAllpha});			 }				}				/**		Causes the mouse location (in meters) to be traced to the output window when the stage is clicked.		*/		public function traceMouse():void{			main.stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);			main.stage.addEventListener(MouseEvent.MOUSE_UP, onUp);		}				private function onDown(evt:MouseEvent):void {			main.addEventListener(Event.ENTER_FRAME, onTraceMouse);		}		private function onTraceMouse(evt:Event):void{			trace("Mouse: ", (main.mouseX / 30).toFixed(2), (main.mouseY/30).toFixed(2));		}		private function onUp(evt:MouseEvent):void{			main.removeEventListener(Event.ENTER_FRAME, onTraceMouse);		}						internal var dragging:Boolean = false;		/**		Turns on mouse dragging for all non-static (dynamic) rigid bodies.		*/		public function mouseDrag():void{			dragging = true;			for each(var obj:BaseObject in _quickObjects) {                obj.handCursor();             }			main.stage.addEventListener(MouseEvent.MOUSE_DOWN, createMouse);			main.stage.addEventListener(MouseEvent.MOUSE_UP, destroyMouse);			main.stage.addEventListener(Event.MOUSE_LEAVE, destroyMouse);		}				/**		Removes all event listeners within the EasyBox2D instance. This should only be called if you know your application will not be using this instance again.		*/		public function destroy():void{			// additional clean up			main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, createMouse);			main.stage.removeEventListener(MouseEvent.MOUSE_UP, destroyMouse);			main.removeEventListener(Event.ENTER_FRAME, onRender);			main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);			main.stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);		}				/**		Starts the Box2D simulation.		*/		public function start():void{			_prevTime = getTimer();			main.addEventListener(Event.ENTER_FRAME, onRender);		}		/**		Stops the Box2D simulation.		*/		public function stop():void{			main.removeEventListener(Event.ENTER_FRAME, onRender);		}				/**		Enables all contact listener events. This is used for advanced collision. Returns an instance of {@link com.actionsnippet.qbox.QuickContacts} (EasyBox2D's b2ContactListener). You should store a reference to this, add desired listeners, read desired properties and call desired methods. For more info see {@link com.actionsnippet.qbox.QuickContacts}.		*/		public function addContactListener():EasyContacts{		  contactListener = new EasyContacts();		  w.SetContactListener(contactListener);		  return EasyContacts(contactListener);		}				/**		Main description text.		@sends Event#STEP - dispatched whenever a world timeStep occurs. This can be more than once per frame if framerate independent motion is on (frim).		@sends Event#render - dispatched at the end of EasyBox2D's internal <code>enterframe</code> event.		*/		private var _prevTime:Number = 0; 		private var _currTime:Number;		private var _elapsedTime:Number;		private var _accumulator:Number = 0;				/** This value is incremented every time a time step occurs. This is very useful for having event occur in your simulation at a specific time. If frim is on this value will be framerate independent. For more info see {@link #addTimeStepSequence()}*/		public var totalTimeSteps:int = 0;						private var step:Event = new Event("step");				protected function onRender(evt:Event):void{									var i:int, leng:int, ts:TimeStepCallback			if (frim  == true){				//from here https://developer.playfirst.com/node/860				_currTime = getTimer();				_elapsedTime = (_currTime - _prevTime) * 0.001;				_prevTime = _currTime;								if (_elapsedTime > 0.25){					_elapsedTime = 0.25;				}				_accumulator += _elapsedTime;								while(_accumulator >= timeStep){					w.Step(timeStep, iterations);					dispatchEvent(step);					_accumulator -= timeStep;					totalTimeSteps++;					leng = timeStepCallbacks.length;					for (i = 0; i<leng; i++){						ts = timeStepCallbacks[i];						if (ts.time == totalTimeSteps){							ts.callback.apply(null, ts.args);						}					}				}			}else{				w.Step(timeStep, iterations);				dispatchEvent(step);				totalTimeSteps++;				for (i = 0; i<leng; i++){						ts = timeStepCallbacks[i];						if (ts.time == totalTimeSteps){							ts.callback.apply(null, ts.args);						}				}			}						leng = destroyable.length;			for (i = 0; i<leng; i++){				destroyable[i].fullDestroy();				_quickObjects[destroyable[i].body] = null;				destroyable[i] = null;							}			destroyable = [];						if (!_customMouse){				setMouse(main.mouseX, main.mouseY);			}			updateMouse();			if (_simpleRender){			   updateBodies();			}			dispatchEvent(render);		}						private var timeStepCallbacks:Array = [];				/**		This method is used for creating a sequence of function calls based on the EasyBox2D <code>totalTimeSteps</code> value. If frim is on, totalTimeSteps is framerate independent.		This method takes a variable number of Objects as its arguments. Each Object should be set up as follows:<br>		 <code>time: </code> - When to call the callback function. 		 <code>callback: </code> - The function to call when totalTimeSteps is equal to this Object's time property.		 <code>args: </code> - An optional array of arguments to pass to the callback function.		*/		public function addTimeStepSequence(...sequence:Array):void{			var time:int, callback:Function, args:Array;			var count:int = 0;			for (var i:int = 0; i<sequence.length; i++){				count = 0;				args = [];				for (var key:String in sequence[i]){										if (key == "time"){						time = sequence[i][key];						count++					}else if (key == "callback"){						 						callback = sequence[i][key];						count++					}else if (key == "args"){						 						args = sequence[i][key];						count++					}					if (count == 3 || (sequence[i].args == undefined && count == 2) ){						//trace(time, callback, args);												timeStepCallbacks.push(new TimeStepCallback(time, callback, args));					}				}			}		}				public function updateBodies():void{			//var inc = 0;			 for (var bb:b2Body = w.m_bodyList; bb; bb = bb.m_next) {								//trace(_quickObjects[bb], bb.m_userData, inc);				if (bb.m_userData is Sprite) {									 					bb.m_userData.x=bb.GetPosition().x * 30;					bb.m_userData.y=bb.GetPosition().y * 30;															bb.m_userData.rotation = (bb.GetAngle() * (180 / Math.PI)) % 360;										//trace(bb.GetAngle() * (180 / Math.PI), bb.m_userData.rotation);				}	         } 			 			 			 if (_renderJoints){				 main.graphics.clear();				 for (var joint:b2Joint = w.m_jointList; joint; joint = joint.m_next) {					 					 var b1:b2Body = joint.m_body1;					var b2:b2Body = joint.m_body2;					var xf1:b2XForm = b1.m_xf;					var xf2:b2XForm = b2.m_xf;					var x1:b2Vec2 = xf1.position;					var x2:b2Vec2 = xf2.position;					 var p1:b2Vec2 = joint.GetAnchor1();					 var p2:b2Vec2 = joint.GetAnchor2();					 var userData:*  = joint.GetUserData();					 					 					 if (!(joint is b2MouseJoint)){						 if (userData.skin != "none"){							 if (joint is b2PulleyJoint){								 main.graphics.lineStyle(userData.lineThickness, userData.lineColor, userData.lineAlpha);								 var pulley:b2PulleyJoint = (joint as b2PulleyJoint);									var s1:b2Vec2 = pulley.GetGroundAnchor1();									var s2:b2Vec2 = pulley.GetGroundAnchor2();																		  main.graphics.moveTo(s1.x * 30, s1.y * 30);									  main.graphics.lineTo(p1.x * 30, p1.y * 30);									  main.graphics.moveTo(s2.x * 30, s2.y * 30);									  main.graphics.lineTo(p2.x * 30, p2.y * 30);									  main.graphics.moveTo(s1.x * 30, s1.y * 30);									  main.graphics.lineTo(s2.x * 30, s2.y * 30);									  									 							 }else if (joint is b2DistanceJoint){										// skinned joint								if (userData is MovieClip){									userData.x = p1.x * 30;									userData.y = p1.y * 30;									userData.scaleX = (p2.x * 30 - userData.x) / userData.startWidth;									userData.scaleY = (p2.y * 30 - userData.y) / userData.startHeight;								}else{																		// simpleRender joint									main.graphics.lineStyle(userData.lineThickness, userData.lineColor, userData.lineAlpha);									main.graphics.moveTo(p1.x * 30, p1.y * 30);									main.graphics.lineTo(p2.x * 30, p2.y * 30);								}							 }else{						  								main.graphics.lineStyle(userData.lineThickness, userData.lineColor, userData.lineAlpha);							    if (b1 != w.m_groundBody){								  main.graphics.moveTo(x1.x * 30, x1.y * 30);								  main.graphics.lineTo(p1.x * 30, p1.y * 30);						        }								   main.graphics.moveTo(p1.x * 30, p1.y * 30);								   main.graphics.lineTo(p2.x * 30, p2.y * 30);								if (b2 != w.m_groundBody){								  main.graphics.moveTo(x2.x * 30, x2.y * 30);								  main.graphics.lineTo(p2.x * 30, p2.y * 30);								}									 							  }						  }					  }				  }		     }		}				/**		Adds a polygon to the world.		@param params An Object containing properties that describe all aspects of the polygon. <i>See below for a full list of valid properties</i>.		  <blockquote>		  <i>Nearly all of these properties come straight from the Box2D b2ShapeDef and b2BodyDef (and subclasses). EasyBox2D puts them all in one place for easy rigid body instantiation.</i>		  		  <b>Common Properties:</b>		  <code>x: </code> 3.0 - The x location in meters.		  <code>y: </code> 3.0 - The y location in meters.		  <code>points: </code> <span class="codeIdentifier">null</span> - An array describing the contour of the polygon. EasyBox2D will triangulate the <code>verts</code> array automatically if this property is set.		  <code>verts: </code> [[-.5, -1, 1, -1, 1, 1, -1, 1]] - A two dimensional array of vertices describing the polygon.		  		  <code>angle: </code> 0.0 - The angle in radians.		  <code>draggable: </code> <span class="codeIdentifier">true</span> - Enable or disable dragging if the {@link #mouseDrag()} method has been called.		  		  <b>Rendering Properties:</b> (These are used with EasyBox2D's simpleRenderer)		  <code>skin: </code> <span class="codeIdentifier">null</span> - Set this to the name of a linkage class from your library if you'd like to use a graphics created in flash for your rigid body skin.		  		 <i>The following properties will not do anything if you have set the skin property or if you have set simpleRender to false.</i>		  <code>lineColor:</code> 0x000000 - Line color.		  <code>lineAlpha:</code> 1.0 - Line alpha.		  <code>lineThickness:</code> 0.0 - Line thickness.		  <code>fillColor:</code> 0xCCCCCC - Fill color.		  <code>fillAlpha:</code> 1.0 - Fill alpha.		  		  <b>Additional Properties:</b>		  <code>density: </code> 1.0 - The density in kg/m^2.		  <code>friction: </code> 0.5 - The friction coefficient. Normally ranges from 0 - 1.		  <code>restitution: </code> 0.2 - The restitution of the rigid body. This is like elasticity or bounciness. Normally ranges from 0 - 1.		  <code>linearDamping:</code> 0.0 - Linear damping.		  <code>angularDamping:</code>  0.0 - Angular damping.		  <code>isBullet: </code> false - uses CCD (continuous collision detection) to prevent fast moving object from moving through other objects.		  <code>fixedRotation: </code> <span class="codeIdentifier">false</span> - If set to true the rigid body will not rotate.		  <code>allowSleep: </code> <span class="codeIdentifier">true</span> - If set to false the rigid body will never sleep.		  <code>isSleeping: </code> <span class="codeIdentifier">false</span> - If set to true the rigid body will start off sleeping. This can be useful for creating breakable objects.		  <code>mass: </code> - The mass of the rigid body. This is usually set automatically - setting it on polygons may cause unexpected results.		  <code>maskBits:</code> - 0xFFFF - Collision mask bits. See Box2D manual for a description of this http://www.box2d.org/manual.html#d0e845		  <code>categoryBits:</code> 1 - Category bits. See Box2D manual for a description of this http://www.box2d.org/manual.html#d0e845		  <code>groupIndex: </code> 0 - Group index.See Box2D manual for a description of this http://www.box2d.org/manual.html#d0e845		  </blockquote>		  		  @return {@link com.actionsnippet.qbox.QuickObject} 		*/		public function addPoly(params:Object):BaseObject{			return create("poly", params);		}		/**		Adds a box to the world.		@param params An Object containing properties that describe all aspects of the box. <i>See below for a full list of valid properties</i>.		  <blockquote>		  <i>Nearly all of these properties come straight from the Box2D b2ShapeDef and b2BodyDef (and subclasses). EasyBox2D puts them all in one place for easy rigid body instantiation.</i>		  		  <b>Common Properties:</b>		  <code>x: </code> 3.0 - The x location in meters.		  <code>y: </code> 3.0 - The y location in meters.		  <code>width: </code> 1.0 - The width in meters.		  <code>height: </code> 1.0 - The height in meters.		  <code>angle: </code> 0.0 - The angle in radians.		  <code>draggable: </code> <span class="codeIdentifier">true</span> - Enable or disable dragging if the {@link #mouseDrag()} method has been called.		  		 <b>Rendering Properties: (These are used with EasyBox2D's simpleRenderer)</b>		  <code>skin: </code> <span class="codeIdentifier">null</span> - Set this to the name of a linkage class from your library if you'd like to use a graphics created in flash for your rigid body skin.		  		  <i>The following properties will not do anything if you have set the skin property or if you have set simpleRender to false.</i>		  <code>lineColor:</code> 0x000000 - Line color.		  <code>lineAlpha:</code> 1.0 - Line alpha.		  <code>lineThickness:</code> 0.0 - Line thickness.		  <code>fillColor:</code> 0xCCCCCC - Fill color.		  <code>fillAlpha:</code> 1.0 - Fill alpha.		  		 <b>Additional Properties:</b>		  <code>density: </code> 1.0 - The density in kg/m^2.		  <code>friction: </code> 0.5 - The friction coefficient. Normally ranges from 0 - 1.		  <code>restitution: </code> 0.2 - The restitution of the rigid body. This is like elasticity or bounciness. Normally ranges from 0 - 1.		  <code>linearDamping:</code> 0.0 - Linear damping.		  <code>angularDamping:</code>  0.0 - Angular damping.		  <code>isBullet: </code> false - uses CCD (continuous collision detection) to prevent fast moving object from moving through other objects.		  <code>fixedRotation: </code> <span class="codeIdentifier">false</span> - If set to true the rigid body will not rotate.		  <code>allowSleep: </code> <span class="codeIdentifier">true</span> - If set to false the rigid body will never sleep.		  <code>isSleeping: </code> <span class="codeIdentifier">false</span> - If set to true the rigid body will start off sleeping. This can be useful for creating breakable objects.		  <code>mass: </code> - The mass of the rigid body. This is usually set automatically - setting it on polygons may cause unexpected results.		  <code>maskBits:</code> - 0xFFFF - Collision mask bits. See Box2D manual for a description of this http://www.box2d.org/manual.html#d0e845		  <code>categoryBits:</code> 1 - Category bits. See Box2D manual for a description of this http://www.box2d.org/manual.html#d0e845		  <code>groupIndex: </code> 0 - Group index.See Box2D manual for a description of this http://www.box2d.org/manual.html#d0e845		  </blockquote>		  		  @return {@link com.actionsnippet.qbox.QuickObject} 		*/		public function addBox(params:Object):BaseObject{			return create("box", params);		}		/**		Adds a circle to the world.		@param params An Object containing properties that describe all aspects of the circle. <i>See below for a full list of valid properties</i>.		 		  <blockquote>		  <i>Nearly all of these properties come straight from the Box2D b2ShapeDef and b2BodyDef (and subclasses). EasyBox2D puts them all in one place for easy rigid body instantiation.</i>		  		 <b> Common Properties:</b>		  <code>x: </code> 3.0 - The x location in meters.		  <code>y: </code> 3.0 - The x location in meters.		  <code>radius: </code> 1.0 - The radius in meters.		  <code>angle: </code> 0.0 - The angle in radians.		  <code>draggable: </code> <span class="codeIdentifier">true</span> - Enable or disable dragging if the {@link #mouseDrag()} method has been called.		  		  <b>Rendering Properties: (These are used with EasyBox2D's simpleRenderer)</b>		  <code>skin: </code> <span class="codeIdentifier">null</span> - Set this to the name of a linkage class from your library if you'd like to use a graphics created in flash for your rigid body skin.		  		 <i>The following properties will not do anything if you have set the skin property or if you have set simpleRender to false.</i>		  <code>lineColor:</code> 0x000000 - Line color.		  <code>lineAlpha:</code> 1.0 - Line alpha.		  <code>lineThickness:</code> 0.0 - Line thickness.		  <code>fillColor:</code> 0xCCCCCC - Fill color.		  <code>fillAlpha:</code> 1.0 - Fill alpha.		  		 <b> Additional Properties:</b>		  <code>density: </code> 1.0 - The density in kg/m^2.		  <code>friction: </code> 0.5 - The friction coefficient. Normally ranges from 0 - 1.		  <code>restitution: </code> 0.2 - The restitution of the rigid body. This is like elasticity or bounciness. Normally ranges from 0 - 1.		  <code>linearDamping:</code> 0.0 - Linear damping.		  <code>angularDamping:</code>  0.0 - Angular damping.          <code>isBullet: </code> false - uses CCD (continuous collision detection) to prevent fast moving object from moving through other objects.		  <code>fixedRotation: </code> <span class="codeIdentifier">false</span> - If set to true the rigid body will not rotate.		  <code>allowSleep: </code> <span class="codeIdentifier">true</span> - If set to false the rigid body will never sleep.		  <code>isSleeping: </code> <span class="codeIdentifier">false</span> - If set to true the rigid body will start off sleeping. This can be useful for creating breakable objects.		  <code>mass: </code> - The mass of the rigid body. This is usually set automatically - setting it on polygons may cause unexpected results.		  <code>maskBits:</code> - 0xFFFF - Collision mask bits. See Box2D manual for a description of this http://www.box2d.org/manual.html#d0e845		  <code>categoryBits:</code> 1 - Category bits. See Box2D manual for a description of this http://www.box2d.org/manual.html#d0e845		  <code>groupIndex: </code> 0 - Group index.See Box2D manual for a description of this http://www.box2d.org/manual.html#d0e845		  </blockquote>		  		  @return {@link com.actionsnippet.qbox.QuickObject} 		*/		public function addCircle(params:Object):BaseObject {			return create("circle", params);		}				/**		Adds a joint to the world.		@param params An Object containing properties that describe all aspects of the joint. <i>See below for a full list of valid properties</i>				  <blockquote>		 		 <b> Common Properties:</b>		 <code>a: </code> <span class="codeIdentifier">null</span> - A {@link com.actionsnippet.qbox.QuickObject#body} property to attach one end of the joint to.		 <code>b: </code> <span class="codeIdentifier">null</span>  - A {@link com.actionsnippet.qbox.QuickObject#body} property to attach the other end of the joint to.		 <i>if the below propertyes (x1, y1, x2, y2) are not set they will be calculated based on the center points of <code>a</code> and <code>b</code>.</i>		 <code>x1: </code> <span class="codeIdentifier">null</span> - The x location for the end of the joint anchored to body <code>a</code>.		 <code>y1: </code> <span class="codeIdentifier">null</span>  - The y location for the end of the joint anchored to body <code>a</code>.		 <code>x2: </code> <span class="codeIdentifier">null</span> - The x location for the end of the joint anchored to body <code>b</code>.		 <code>y2: </code> <span class="codeIdentifier">null</span>  - The y location for the end of the joint anchored to body <code>b</code>.		 		   <b>Rendering Properties: (These are used with EasyBox2D's simpleRenderer)</b>		  <code>skin: </code> <span class="codeIdentifier">null</span> - Set this to the name of a 		  linkage class from your library if you'd like to use a graphics created in flash for your joint. This class must be dynamic. 		  If you are trying to use a Sprite here, just use a MovieClip instead. Currently DisplayObject/Class skins only work for b2DistanceJoints.		  		  <i>The following properties will not do anything if you have set the skin property or if you have set simpleRender to false.</i>		  <code>lineColor:</code> 0x000000 - Line color.		  <code>lineAlpha:</code> 1.0 - Line alpha.		  <code>lineThickness:</code> 0.0 - Line thickness.		 		 <b>Properties for all joints:</b>		 <code>type:</code> - The type of joint, either distance, prismatic, revolute, pulley or gear.		 <code>collideConnected:</code> <span class="codeIdentifier">true</span>  - If set to false, the two bodies attached to this joint will not collide.		 		 <b>Properties for distance joints:</b>		 <code>frequencyHz:</code> 0 - The response speed. Using numbers above zero will cause the joint to act more like a rubber band.		 <code>dampingRatio:</code> 0 - The damping ratio. 0 = no damping, 1 = critical damping. 		 <code>length:</code> 0 - The equilibrium length between the anchor points. If not set, this will automatically be calculated based on the distance between (x1, y1) and (x2, y2). 		 		 <b>Properties for some joints (revolute, prismatic)</b>		  <code>enableLimit</code> false - Enable joint limits (constraints on angle and translation).		  <code>enableMotor:</code> false - Toggle joint motor.		  <code>motorSpeed:</code> 0 - Set motor speed		  <code>referenceAngle</code> 0 - p.referenceAngle;		  		 <b>Properties for revolute joints:</b>		  		  <code>upperAngle:</code> 0 - p.upperAngle;		  <code>lowerAngle:</code> 0 - p.lowerAngle;  		  <code>maxMotorTorque:</code> 0 - p.maxMotorTorque;		 		 <b>Properties for prismatic joints:</b>	        <code>axis:</code> null - Axis b2Vec2, must be set.			<code>anchor:</code> null - Anchor b2Vec2, must be set.			<code>upperTranslation:</code> 0 - Upper limit b2Vec2 in local coordinates.			<code>lowerTranslation:</code> 0 - Upper limit b2Vec2 in local coordinates.		    <code>maxMotorForce:</code> 0 - Max force for motor.					 <b>Properties for pulley joints:</b>		    <code>groundAnchor1:</code> (0,a.x) - Ground anchor for body a b2Vec2;			<code>groundAnchor2:</code> (0,b.x) - Ground anchor for body b b2Vec2;			<code>anchor1:</code> (a.x, b.x) - Anchor for body a;			<code>anchor2:</code> (a.x, b.x) - Anchor for body b;			<code>ratio:</code> 1 - This causes one side of the pulley to extend faster than the other when not set to 1.		 		 <b>Properties for gear joints:</b>			<code>joint1:</code> null - Either revolute or prismatic joint tied to the groundBody and a, must be set.			<code>joint2:</code> null - Either revolute or prismatic joint tied to the groundBody and b, must be set.			<code>ratio:</code> 1 - This causes one of the gears to move more/less than the other when not set to 1.					@return {@link com.actionsnippet.qbox.QuickObject} 		*/		public function addJoint(params:Object):BaseObject {			return create("joint", params);		}				/**		Creates a group out of  existing QuickObject instances. This is usually reffered to as a compound shape.		@param params An Object containing properties that describe all aspects of the group. <i>See below for a full list of valid properties</i>.		  <blockquote>		  <i>Nearly all of these properties come straight from the Box2D b2ShapeDef and b2BodyDef (and subclasses). EasyBox2D puts them all in one place for easy rigid body instantiation.</i>		  		  <b>Common Properties:</b>		  <code>x: </code> 3.0 - The x location in meters.		  <code>y: </code> 3.0 - The y location in meters.		  <code>objects: </code> <span class="codeIdentifier">null</span> - An array of {@link com.actionsnippet.qbox.QuickObject} instances to group together.		  <code>angle: </code> 0.0 - The angle in radians.		  <code>draggable: </code> <span class="codeIdentifier">true</span> - Enable or disable dragging if the {@link #mouseDrag()} method has been called.		  		  <b>Rendering Properties:</b> (These are used with EasyBox2D's simpleRenderer)		  <code>skin: </code> <span class="codeIdentifier">null</span> - Set this to the name of a linkage class from your library if you'd like to use a graphics created in flash for your rigid body skin. This can also be set to a DisplayObject instance on the stage - currently boxes and circles x,y and angle values are reset based on the DisplayObject instance's x,y and rotation properties.		  		  <b>Additional Properties:</b>		  <code>linearDamping:</code> 0.0 - Linear damping.		  <code>angularDamping:</code>  0.0 - Angular damping.		  <code>isBullet: </code> false - uses CCD (continuous collision detection) to prevent fast moving object from moving through other objects.		  <code>fixedRotation: </code> <span class="codeIdentifier">false</span> - If set to true the rigid body will not rotate.		  <code>allowSleep: </code> <span class="codeIdentifier">true</span> - If set to false the rigid body will never sleep.		  <code>isSleeping: </code> <span class="codeIdentifier">false</span> - If set to true the rigid body will start off sleeping. This can be useful for creating breakable objects.		  </blockquote>		  		  @return {@link com.actionsnippet.qbox.QuickObject} 		*/		public function addGroup(params:Object):BaseObject {			return create("group", params);		}				/**		Can create any type of QuickObject.		@param type The type of QuickObject to create, either "box", "circle", "poly" or "joint".		<i>For a list of possible params see any of the below methods:</i>		{@link #addBox()}		{@link #addCircle()}		{@link #addPoly()}		{@link #addJoint()}				@return {@link com.actionsnippet.qbox.QuickObject} 		*/		public function create(type:String, params:Object):BaseObject{			var quickObject:BaseObject;			if (type == "box"){				quickObject = new BoxObject(this, params);				 _quickObjects[quickObject.body] = quickObject;			}else if (type == "circle"){				quickObject = new CircleObject(this, params);				 _quickObjects[quickObject.body] = quickObject;			}else if (type == "poly"){				quickObject = new PolyObject(this, params);				 _quickObjects[quickObject.body] = quickObject;			}else  if (type == "joint"){				quickObject = new JointObject(this, params);				 _quickObjects[quickObject.joint] = quickObject;			}else  if (type == "group"){				quickObject = new GroupObject(this, params);				 _quickObjects[quickObject.body] = quickObject;			}else{				throw new Error("EasyBox2D: Sorry, there is no QuickObject subclass for " + type + " types.");			}			return quickObject;		}				/**		Sets some default params for all QuickObjects. This can be useful for setting default rendering styles - but can contain any default properties for		any type of object - box, circle, poly or joint.		@param params		<i>For a full list of possible params see any of the below methods:</i>		{@link #addBox()}		{@link #addCircle()}		{@link #addPoly()}		{@link #addJoint()}		*/		public function setDefault(params:Object=null):void{			_defaults = params;		}		/*		Traces the properties of the EasyBox2D internal default Object. 				public function traceDefault():void{			trace("DEFAULTS:");			for (var k:String in _defaults){				if (k == "lineColor" || k == "fillColor"){					trace("- ",k, " = ", "0x"+_defaults[k].toString(16));				}else{				    trace("- ",k, " = ", _defaults[k], " = ");				}			}		}*/				/**		@exclude		*/	    public function defaultParams(params:Object):void{			if (params==null) {				params = new Object();			}			for (var key:String in _defaults) {				if (params[key]==null) {					params[key]=_defaults[key];				}			}		}						private var _mouseX:Number;		private var _mouseY:Number;		/**		Use this method for passing in custom mouse coordinates for {@link #mouseDrag()}. This can be useful if your using EasyBox2D with a 3D engine. You must call this method every time you wish to update the position of the mouse joint.		*/		public function setMouse(xp:Number, yp:Number):void{			_mouseX = xp;			_mouseY = yp;		}		//		// -- mouse drag stuff (from the testbed code)		//		public function updateMouse():void{			if (_mouseJoint) {				 				var p2:b2Vec2=new b2Vec2(_mouseX/30 ,_mouseY/30);				_mouseJoint.SetTarget(p2);			}		}		public function createMouse(evt:MouseEvent):void {			var body:b2Body=GetBodyAtMouse();			var _mouseJointDef:b2MouseJointDef			if (_quickObjects[body]){				if (body && _quickObjects[body].params.draggable == true) {					_mouseJointDef=new b2MouseJointDef();					_mouseJointDef.body1=w.GetGroundBody();					_mouseJointDef.body2=body;					_mouseJointDef.target.Set(_mouseX/30, _mouseY/30);					_mouseJointDef.maxForce=3000;					_mouseJointDef.timeStep=timeStep;					_mouseJoint=w.CreateJoint(_mouseJointDef) as b2MouseJoint;				}			}else{				if (body){				_mouseJointDef=new b2MouseJointDef();				_mouseJointDef.body1=w.GetGroundBody();			    _mouseJointDef.body2=body;				_mouseJointDef.target.Set(_mouseX/30, _mouseY/30);				_mouseJointDef.maxForce=3000;				_mouseJointDef.timeStep=timeStep;				_mouseJoint=w.CreateJoint(_mouseJointDef) as b2MouseJoint;				}			}		}		private function destroyMouse(evt:*):void {			if (_mouseJoint) {				w.DestroyJoint(_mouseJoint);				_mouseJoint=null;			}		}		private function GetBodyAtMouse(includeStatic:Boolean=false):b2Body {			var mouseXWorldPhys:Number = (_mouseX)/30;			var mouseYWorldPhys:Number = (_mouseY)/30;			_mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);			var aabb:b2AABB = new b2AABB();			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);			var k_maxCount:int=10;			var shapes:Array = new Array();			var count:int=w.Query(aabb,shapes,k_maxCount);			var body:b2Body=null;			for (var i:int = 0; i < count; ++i) {				if (shapes[i].GetBody().IsStatic()==false||includeStatic) {					var tShape:b2Shape=shapes[i] as b2Shape;					var inside:Boolean=tShape.TestPoint(tShape.GetBody().GetXForm(),_mousePVec);					if (inside) {						body=tShape.GetBody();						break;					}				}			}			return body;		}	}}class TimeStepCallback{	public var time:int;	public var callback:Function;	public var args:Array;	public function TimeStepCallback(t:int, f:Function, ar:Array){		time = t ;		callback = f;		args = ar;	}}