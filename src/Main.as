﻿package  {		import flash.display.MovieClip;	import flash.display.Shape;	import flash.events.Event;	import flash.events.KeyboardEvent;	import flash.events.MouseEvent;	import flash.filters.GlowFilter;	import flash.geom.Rectangle;	import flash.net.URLRequest;	import flash.net.URLRequestMethod;	import flash.net.navigateToURL;	import flash.ui.Keyboard;		import editor.ModeChanger;	import editor.commonData.DrawingType;	import editor.commonData.Restrictions;	import editor.drawingObject.BaseObject;	import editor.drawingObject.JointObject;	import editor.events.CommonEvent;	import editor.modes.BaseMode;	import editor.modes.BoxMode;	import editor.modes.CircleMode;	import editor.modes.DragMode;	import editor.modes.IDrawMode;	import editor.modes.JointMode;	import editor.modes.LoadMode;	import editor.modes.PolyMode;	import editor.modes.RotateMode;	import editor.modes.SaveMode;	import editor.ui.Grid;	import editor.ui.PropertiesPanel;	import editor.utils.Keys;
		public class Main extends MovieClip {		private var _modeChanger:ModeChanger;				private var _mode:IDrawMode;				public function get mode():String { return _modeChanger.mode.toString();}					private var _drawingObject:BaseObject;		public function get drawingObject():BaseObject{ return _drawingObject;}					private var _propPanel:PropertiesPanel;				private var _mousePoint:Shape;				public function Main(){						init();			createChildren();			initListener();		}		private function init():void{			_modeChanger = new ModeChanger();			Restrictions._isGridSnapping = true;		}		private function createChildren():void{			var grid:Grid = new Grid();			this.addChild(grid);						_mousePoint = new Shape();			_mousePoint.graphics.beginFill(0xFF0000);			_mousePoint.graphics.drawCircle(0,0,2);			this.addChild(_mousePoint);						_propPanel = new PropertiesPanel();			_propPanel.visible = false;							this.addChild(_propPanel);		}		private function initListener():void{			_propPanel.addEventListener(CommonEvent.CHANGE_NAME, onShapeNameChange);			_propPanel.addEventListener(CommonEvent.CHANGE_DENSITY, onShapeNameChange);									this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);			this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);			this.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);						this.addEventListener(CommonEvent.START_CREATE, onCreated);			this.addEventListener(Event.ENTER_FRAME, onMoveLoc);		}		//=============Event Listener======================		private function onMoveLoc(evt:Event):void{			if (Restrictions._isGridSnapping){				_mousePoint.x = int(this.mouseX / 10) * 10;				_mousePoint.y = int(this.mouseY / 10) * 10;				_mousePoint.visible = true;			}else{				_mousePoint.visible = false;			}		}		private function onShapeNameChange(evt:Event):void {						if (_drawingObject){				_drawingObject.name =  _propPanel.shapeName;				_drawingObject.shapeData.density = _propPanel.density;			}		}		private function onCreated(evt:Event):void{			setCurrentShape(evt.target);		}								private function onMouseDown(evt:MouseEvent):void{			if (evt.target is BaseObject){ 				setCurrentShape(evt.target);			}else{				//this is for drawing item,the target is stage.				//the current shape will be indicate by onCreated()			} 						if (_modeChanger.mode.toString() == DrawingType.DRAG){				if (_drawingObject){					if (_drawingObject.hitTestPoint(this.mouseX, this.mouseY, true)){												_drawingObject.startDrag();					}				}			}else if (_modeChanger.mode.toString() == DrawingType.ROTATE){				if (_drawingObject){					_modeChanger.mode.start(this);					this.addEventListener(Event.ENTER_FRAME, onDrawing);				} 			}else{				_modeChanger.mode.start(this);				this.addEventListener(Event.ENTER_FRAME, onDrawing);			}		}		private function onDrawing(evt:Event):void {			_modeChanger.mode.run();		}		private function onMouseUp(evt:MouseEvent):void {			_modeChanger.mode.end();			this.removeEventListener(Event.ENTER_FRAME, onDrawing);			this.stopDrag();						if (_modeChanger.mode.toString() == DrawingType.DRAG){				if (_drawingObject){					if (Restrictions._isGridSnapping){						var b:Rectangle = _drawingObject.getRect(this);						// check rotation						while(int(b.left) % 10 != 0){							_drawingObject.x -= 1;							b = _drawingObject.getRect(this);						}						while(int(b.top) % 10 != 0){							_drawingObject.y -= 1;							b = _drawingObject.getRect(this);						}						// _drawingObject.x = int(_drawingObject.x / 10) * 10;						//_drawingObject.y = int(_drawingObject.y / 10) * 10;					}				}			}		}		private function setCurrentShape(sp:Object):void{			if(_drawingObject){				_drawingObject.filters=[]			}			_drawingObject = sp as BaseObject;						if (_drawingObject){				_drawingObject.filters = [new GlowFilter()];				_propPanel.enabled = true;				_propPanel.density = _drawingObject.shapeData.density;				_propPanel.shapeName = _drawingObject.name;							}		}				private var req:URLRequest;				private function onKeyPressed(evt:KeyboardEvent):void{			var code:int = evt.keyCode;			if (code == Keys.I){				_propPanel.visible = !_propPanel.visible;  				this.addChild(_propPanel);			}else if (code == Keys.ONE){				_modeChanger.change(new SaveMode(this, getCommandFromObjects()));			}else if (code == Keys.TWO){				_modeChanger.change(new LoadMode(this));			}else if (code == Keys.THREE){				req = new URLRequest();				req.url="preview.swf";								req.data = "data=" + getCommandFromObjects();				req.method = URLRequestMethod.GET;				navigateToURL(req); 			}else if (code == Keys.FOUR){				req = new URLRequest();				req.url="preview.swf";								req.data = "debug=true&data=" + getCommandFromObjects();				req.method = URLRequestMethod.GET;				navigateToURL(req); 			}						if (_propPanel.visible == true) {				_modeChanger.change(new BaseMode());				return			}						if (code == Keys.A){				_modeChanger.change(new BaseMode());			}else if (code == Keys.B){				_modeChanger.change(new BoxMode());			}else if (code == Keys.C){				_modeChanger.change(new CircleMode()); 			}else if (code == Keys.P){				_modeChanger.change(new PolyMode()); 			}else if (code == Keys.D){				_modeChanger.change(new DragMode());			}else if (code == Keys.R){				_modeChanger.change(new RotateMode());			}else if (code == Keys.J){				_modeChanger.change(new JointMode());			}else if (code == Keyboard.SHIFT){				Restrictions._isConstrainSquare = true;			}else if (code == Keys.G){				Restrictions._isGridSnapping = !Restrictions._isGridSnapping;			}else if (code == Keyboard.DOWN){				moveAll(0,1);			}else if (code == Keyboard.UP){				moveAll(0,-1);			}else if (code == Keyboard.LEFT){				moveAll(-1,0);			}else if (code == Keyboard.RIGHT){				moveAll(1,0);			}else if (code == Keys.X){				if (_drawingObject){					_drawingObject.parent.removeChild(_drawingObject); 				}			}									if (_modeChanger.mode.toString() == DrawingType.PLOY){				if (code == Keyboard.SPACE){					_modeChanger.mode.reset();				}			}					}		private function moveAll(offX:Number, offY:Number):void{			for (var i:int = 0; i<this.numChildren; i++){				var e:BaseObject = this.getChildAt(i) as BaseObject;				if (e){					e.x += offX;					e.y += offY				}			}		}		private function getCommandFromObjects():String{			var str:String = "";			for (var i:int = 0; i<this.numChildren; i++){				var e:BaseObject = this.getChildAt(i) as BaseObject;				if (e){					if (!(e is JointObject)){						str += e.objectDef + "\n";					}				}			}			str += "// joints:\n";			for (i = 0; i<this.numChildren; i++){				e = this.getChildAt(i) as BaseObject;				if (e){					if ((e is JointObject)){						str += e.objectDef + "\n";					}				}			}						trace(str);			return str;		}				private function onKeyReleased(evt:KeyboardEvent):void{			var code:int = evt.keyCode;			if (code == Keyboard.SHIFT){				Restrictions._isConstrainSquare = false;			}					}	}}