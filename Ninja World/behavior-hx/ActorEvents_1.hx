package scripts;

import com.stencyl.graphics.G;
import com.stencyl.graphics.BitmapWrapper;

import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.Scene;
import com.stencyl.models.Sound;
import com.stencyl.models.Region;
import com.stencyl.models.Font;
import com.stencyl.models.Joystick;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;
import com.stencyl.utils.Utils;

import openfl.ui.Mouse;
import openfl.display.Graphics;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.net.URLLoader;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.joints.B2Joint;

import motion.Actuate;
import motion.easing.Back;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;

import com.stencyl.graphics.shaders.BasicShader;
import com.stencyl.graphics.shaders.GrayscaleShader;
import com.stencyl.graphics.shaders.SepiaShader;
import com.stencyl.graphics.shaders.InvertShader;
import com.stencyl.graphics.shaders.GrainShader;
import com.stencyl.graphics.shaders.ExternalShader;
import com.stencyl.graphics.shaders.InlineShader;
import com.stencyl.graphics.shaders.BlurShader;
import com.stencyl.graphics.shaders.SharpenShader;
import com.stencyl.graphics.shaders.ScanlineShader;
import com.stencyl.graphics.shaders.CSBShader;
import com.stencyl.graphics.shaders.HueShader;
import com.stencyl.graphics.shaders.TintShader;
import com.stencyl.graphics.shaders.BloomShader;



class ActorEvents_1 extends ActorScript
{
	public var _SceneTransitioning:Bool;
	public var _IsInvencible:Bool;
	
	/* ========================= Custom Event ========================= */
	public function _customEvent_Damage():Void
	{
		if(((Engine.engine.getGameAttribute("Sushi lives") >= 2) && (_IsInvencible == false)))
		{
			_IsInvencible = true;
			propertyChanged("_IsInvencible", _IsInvencible);
			Engine.engine.setGameAttribute("Sushi lives", (Engine.engine.getGameAttribute("Sushi lives") - 1));
			runLater(1000 * 1, function(timeTask:TimedTask):Void
			{
				_IsInvencible = false;
				propertyChanged("_IsInvencible", _IsInvencible);
			}, actor);
		}
		else if(((Engine.engine.getGameAttribute("Sushi lives") <= 1) && (_IsInvencible == false)))
		{
			actor.shout("_customEvent_" + "Death");
		}
	}
	
	/* ========================= Custom Event ========================= */
	public function _customEvent_GongAnimation():Void
	{
		Engine.engine.setGameAttribute("sceneTransitioning", true);
		actor.setAnimation("" + "GongAnimation");
		playSound(getSound(13));
		actor.setAnimation("" + "Idle right");
		runLater(1000 * 3, function(timeTask:TimedTask):Void
		{
			switchScene(GameModel.get().scenes.get(1).getID(), null, createCrossfadeTransition(1));
		}, actor);
	}
	
	/* ========================= Custom Event ========================= */
	public function _customEvent_Death():Void
	{
		if((Engine.engine.getGameAttribute("Sushi lives") < 1))
		{
			switchScene(GameModel.get().scenes.get(0).getID(), createFadeOut(.5, Utils.getColorRGB(0,0,0)), createFadeIn(.5, Utils.getColorRGB(0,0,0)));
			Engine.engine.setGameAttribute("Sushi lives", 1);
		}
		else
		{
			reloadCurrentScene(null, createCrossfadeTransition(1));
		}
	}
	
	
	public function new(dummy:Int, actor:Actor, dummy2:Engine)
	{
		super(actor);
		nameMap.set("SceneTransitioning", "_SceneTransitioning");
		_SceneTransitioning = false;
		nameMap.set("Is Invencible", "_IsInvencible");
		_IsInvencible = false;
		
	}
	
	override public function init()
	{
		
		/* ======================== When Creating ========================= */
		engine.cameraFollow(actor);
		Engine.engine.setGameAttribute("sceneTransitioning", false);
		
		/* ======================== When Updating ========================= */
		addWhenUpdatedListener(null, function(elapsedTime:Float, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled)
			{
				Engine.engine.setGameAttribute("Hero Y", actor.getY());
			}
		});
		
		/* =========================== Keyboard =========================== */
		addKeyStateListener("Sword", function(pressed:Bool, released:Bool, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled && pressed)
			{
				Engine.engine.setGameAttribute("Is swinging sword", true);
				if(Engine.engine.getGameAttribute("Face Right"))
				{
					actor.setAnimation("" + "Sword Animation right");
				}
				else
				{
					actor.setAnimation("" + "Sword Animation left");
				}
				runLater(1000 * .69, function(timeTask:TimedTask):Void
				{
					Engine.engine.setGameAttribute("Is swinging sword", false);
				}, actor);
			}
		});
		
		/* ======================== When Updating ========================= */
		addWhenUpdatedListener(null, function(elapsedTime:Float, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled)
			{
				Engine.engine.setGameAttribute("Hero X", actor.getX());
			}
		});
		
		/* ======================== Actor of Type ========================= */
		addCollisionListener(actor, function(event:Collision, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled && sameAsAny(getActorType(8), event.otherActor.getType(),event.otherActor.getGroup()))
			{
				Engine.engine.setGameAttribute("Sushi lives", (Engine.engine.getGameAttribute("Sushi lives") + 1));
				recycleActor(event.otherActor);
			}
		});
		
		/* ======================== When Updating ========================= */
		addWhenUpdatedListener(null, function(elapsedTime:Float, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled)
			{
				if((actor.getY() > getScreenHeight()))
				{
					Engine.engine.setGameAttribute("Sushi lives", (Engine.engine.getGameAttribute("Sushi lives") - 1));
					actor.shout("_customEvent_" + "Death");
				}
			}
		});
		
	}
	
	override public function forwardMessage(msg:String)
	{
		
	}
}