/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "HelloWorldLayer.h"

@interface HelloWorldLayer (PrivateMethods)
-(void) addLabels;
-(void) changeInputType:(ccTime)delta;
-(void) postUpdateInputTests:(ccTime)delta;
@end

@implementation HelloWorldLayer

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@ init", NSStringFromClass([self class]));
		
		glClearColor(0.2f, 0.1f, 0.15f, 1.0f);

		CCDirector* director = [CCDirector sharedDirector];
		CGPoint screenCenter = director.screenCenter;

		particleFX = [CCParticleMeteor node];
		particleFX.position = screenCenter;
		[self addChild:particleFX z:-2];

		[self addLabels];

		ship = [CCSprite spriteWithFile:@"ship.png"];
		ship.position = screenCenter;
		[self addChild:ship];

		CCSprite* touchSprite = [CCSprite spriteWithFile:@"touchsprite.png"];
		touchSprite.position = screenCenter;
		touchSprite.scale = 0.1f;
		[self addChild:touchSprite z:-1 tag:99];
		{
			id rotate = [CCRotateBy actionWithDuration:60 angle:360];
			id repeat = [CCRepeatForever actionWithAction:rotate];
			[touchSprite runAction:repeat];
		}
		{
			id scaleUp = [CCScaleTo actionWithDuration:20 scale:3];
			id scaleDn = [CCScaleTo actionWithDuration:20 scale:0.1f];
			id sequence = [CCSequence actions:scaleUp, scaleDn, nil];
			id repeat = [CCRepeatForever actionWithAction:sequence];
			[touchSprite runAction:repeat];
		}

		[self scheduleUpdate];
		[self schedule:@selector(changeInputType:) interval:8.0f];
		[self schedule:@selector(postUpdateInputTests:)];
		
		// initialize KKInput
		KKInput* input = [KKInput sharedInput];
		input.accelerometerActive = input.accelerometerAvailable;
		input.gyroActive = input.gyroAvailable;
		input.multipleTouchEnabled = YES;
		input.gestureTapEnabled = input.gesturesAvailable;
		input.gestureDoubleTapEnabled = input.gesturesAvailable;
		input.gestureSwipeEnabled = input.gesturesAvailable;
		input.gestureLongPressEnabled = input.gesturesAvailable;
		input.gesturePanEnabled = input.gesturesAvailable;
		input.gestureRotationEnabled = input.gesturesAvailable;
		input.gesturePinchEnabled = input.gesturesAvailable;
	}

	return self;
}

-(void) addLabels
{
	CCDirector* director = [CCDirector sharedDirector];
	CGPoint screenCenter = director.screenCenter;

#if KK_PLATFORM_IOS
	
	CCLabelTTF* label1 = [CCLabelTTF labelWithString:@"Move ship by tilting device" fontName:@"Arial" fontSize:14];
	label1.position = CGPointMake(screenCenter.x, screenCenter.y + 140);
	label1.color = ccYELLOW;
	[self addChild:label1];

	CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Using RAW accelerometer values" fontName:@"Arial" fontSize:14];
	label2.position = CGPointMake(screenCenter.x, screenCenter.y - 100);
	label2.color = ccYELLOW;
	[self addChild:label2 z:0 tag:2];
	
#elif KK_PLATFORM_MAC
	
	CCLabelTTF* label1 = [CCLabelTTF labelWithString:@"Move ship with arrow keys or WASD" fontName:@"Arial" fontSize:14];
	label1.position = CGPointMake(screenCenter.x, screenCenter.y + 140);
	label1.color = ccYELLOW;
	[self addChild:label1];
	
	CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Rotate ship with mouse buttons & modifier keys" fontName:@"Arial" fontSize:14];
	label2.position = CGPointMake(screenCenter.x, screenCenter.y + 120);
	label2.color = ccYELLOW;
	[self addChild:label2];
	
	CCLabelTTF* label3 = [CCLabelTTF labelWithString:@"(try double-clicking & scroll wheel too!)" fontName:@"Arial" fontSize:14];
	label3.position = CGPointMake(screenCenter.x, screenCenter.y + 100);
	label3.color = ccYELLOW;
	[self addChild:label3];
	
#endif
}

-(void) moveShipByPollingKeyboard
{
	const float kShipSpeed = 3.0f;

	KKInput* input = [KKInput sharedInput];
	CGPoint shipPosition = ship.position;
	
	if ([input isKeyDown:KKKeyCode_UpArrow] ||
		[input isKeyDown:KKKeyCode_W])
	{
		shipPosition.y += kShipSpeed;
	}
	if ([input isKeyDown:KKKeyCode_LeftArrow] || 
		[input isKeyDown:KKKeyCode_A])
	{
		shipPosition.x -= kShipSpeed;
	}
	if ([input isKeyDown:KKKeyCode_DownArrow] ||
		[input isKeyDown:KKKeyCode_S])
	{
		shipPosition.y -= kShipSpeed;
	}
	if ([input isKeyDown:KKKeyCode_RightArrow] || 
		[input isKeyDown:KKKeyCode_D])
	{
		shipPosition.x += kShipSpeed;
	}

	if (([input isKeyDown:KKKeyCode_Command] ||
		 [input isKeyDown:KKKeyCode_Control]))
	{
		shipPosition = [input mouseLocation];
	}	

	ship.position = shipPosition;

	if ([input isKeyDown:KKKeyCode_Slash])
	{
		ship.scale += 0.03f;
	}
	else if ([input isKeyDown:KKKeyCode_Semicolon])
	{
		ship.scale -= 0.03f;
	}
	
	if ([input isKeyDownThisFrame:KKKeyCode_Quote])
	{
		ship.scale = 1.0f;
	}
}

-(void) changeInputType:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];

	inputType++;
	if ((inputType == kInputTypes_End) || (inputType == kGyroscopeRotationRate && input.gyroAvailable == NO))
	{
		inputType = 0;
	}
	
	NSString* labelString = nil;
	switch (inputType)
	{
		case kAccelerometerValuesRaw:
			// reset back to non-deviceMotion input
			input.accelerometerActive = input.accelerometerAvailable;
			input.gyroActive = input.gyroAvailable;
			labelString = @"Using RAW accelerometer values";
			break;
		case kAccelerometerValuesSmoothed:
			labelString = @"Using SMOOTHED accelerometer values";
			break;
		case kAccelerometerValuesInstantaneous:
			labelString = @"Using INSTANTANEOUS accelerometer values";
			break;
		case kGyroscopeRotationRate:
			labelString = @"Using GYROSCOPE rotation values";
			break;
		case kDeviceMotion:
			// use deviceMotion input for this test
			input.deviceMotionActive = input.deviceMotionAvailable;
			labelString = @"Using DEVICE MOTION values";
			break;
			
		default:
			break;
	}
	
	CCLabelTTF* label = (CCLabelTTF*)[self getChildByTag:2];
	[label setString:labelString];
}

-(void) moveShipWithMotionSensors
{
	const float kShipSpeed = 25.0f;
	
	KKInput* input = [KKInput sharedInput];
	CGPoint shipPosition = ship.position;
	
	switch (inputType) 
	{
		case kAccelerometerValuesRaw:
			shipPosition.x += input.acceleration.rawX * kShipSpeed;
			shipPosition.y += input.acceleration.rawY * kShipSpeed;
			break;
		case kAccelerometerValuesSmoothed:
			shipPosition.x += input.acceleration.smoothedX * kShipSpeed;
			shipPosition.y += input.acceleration.smoothedY * kShipSpeed;
			break;
		case kAccelerometerValuesInstantaneous:
			shipPosition.x += input.acceleration.instantaneousX * kShipSpeed;
			shipPosition.y += input.acceleration.instantaneousY * kShipSpeed;
			break;
		case kGyroscopeRotationRate:
			shipPosition.x += input.rotationRate.x * kShipSpeed;
			shipPosition.y += input.rotationRate.y * kShipSpeed;
			break;
		case kDeviceMotion:
			shipPosition.x += input.deviceMotion.pitch * kShipSpeed;
			shipPosition.y += input.deviceMotion.roll * kShipSpeed;
			break;
			
		default:
			break;
	}

	ship.position = shipPosition;
}

-(void) moveParticleFXToTouch
{
	KKInput* input = [KKInput sharedInput];
	
	if (input.touchesAvailable)
	{
		particleFX.position = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
	}
}

-(void) detectSpriteTouched
{
	KKInput* input = [KKInput sharedInput];

	CCSprite* touchSprite = (CCSprite*)[self getChildByTag:99];
	if ([input isAnyTouchOnNode:touchSprite touchPhase:KKTouchPhaseAny])
	{
		touchSprite.color = ccGREEN;
	}
	else
	{
		touchSprite.color = ccWHITE;
	}
}

-(void) createSmallExplosionAt:(CGPoint)location
{
	CCParticleExplosion* explosion = [[CCParticleExplosion alloc] initWithTotalParticles:50];
#ifndef KK_ARC_ENABLED
	[explosion autorelease];
#endif
	explosion.autoRemoveOnFinish = YES;
	explosion.blendAdditive = YES;
	explosion.position = location;
	explosion.speed *= 4;
	[self addChild:explosion];
}

-(void) createLargeExplosionAt:(CGPoint)location
{
	CCParticleExplosion* explosion = [[CCParticleExplosion alloc] initWithTotalParticles:100];
#ifndef KK_ARC_ENABLED
	[explosion autorelease];
#endif
	explosion.autoRemoveOnFinish = YES;
	explosion.blendAdditive = NO;
	explosion.position = location;
	explosion.speed *= 8;
	[self addChild:explosion];
}

-(void) gestureRecognition
{
	KKInput* input = [KKInput sharedInput];
	if (input.gestureTapRecognizedThisFrame)
	{
		[self createSmallExplosionAt:input.gestureTapLocation];
	}
	
	if (input.gestureDoubleTapRecognizedThisFrame)
	{
		[self createLargeExplosionAt:input.gestureDoubleTapLocation];
	}
	
	if (input.gestureSwipeRecognizedThisFrame) 
	{
		CCSprite* swipeSprite = [CCSprite spriteWithFile:@"ship.png"];
		swipeSprite.position = input.gestureSwipeLocation;
		swipeSprite.scale = 0.5f;
		[self addChild:swipeSprite];
		
		// move faster the faster start and end point are apart
		CGPoint swipeEndPoint = [input locationOfAnyTouchInPhase:KKTouchPhaseCancelled];
		float kMoveDistance = fabsf(ccpLength(ccpSub(swipeEndPoint, input.gestureSwipeLocation))) * 4;
		CGPoint moveDirection = CGPointZero;
		
		switch (input.gestureSwipeDirection) 
		{
			case KKSwipeGestureDirectionLeft:
				moveDirection.x = -kMoveDistance;
				break;
			case KKSwipeGestureDirectionRight:
				moveDirection.x = kMoveDistance;
				break;
			case KKSwipeGestureDirectionUp:
				moveDirection.y = kMoveDistance;
				break;
			case KKSwipeGestureDirectionDown:
				moveDirection.y = -kMoveDistance;
				break;
		}
		
		id move = [CCMoveBy actionWithDuration:10 position:moveDirection];
		id remove = [CCRemoveFromParentAction action];
		id sequence = [CCSequence actions: move, remove, nil];
		[swipeSprite runAction:sequence];
	}
	
	// drag & drop ship initiated by long-press gesture
	ship.color = ccWHITE;
	ship.scale = 1.0f;
	if (input.gestureLongPressBegan)
	{
		ship.position = input.gestureLongPressLocation;
		ship.color = ccGREEN;
		ship.scale = 1.25f;
	}
	
	if (input.gesturePanBegan) 
	{
		CCLOG(@"translation: %.0f, %.0f, velocity: %.1f, %.1f", input.gesturePanTranslation.x, input.gesturePanTranslation.y, input.gesturePanVelocity.x, input.gesturePanVelocity.y);
		ship.position = input.gesturePanLocation;
		
		// center particle on position where pan started, then move it according to velocity in the direction the ship was dragged
		particleFX.position = ccpSub(input.gesturePanLocation, input.gesturePanTranslation);
		particleFX.position = ccpAdd(particleFX.position, ccpMult(input.gesturePanVelocity, 5));
	}
	
	if (input.gestureRotationBegan) 
	{
		ship.position = input.gestureRotationLocation;
		ship.rotation = input.gestureRotationAngle;
		ship.scale = fminf(fabsf(input.gestureRotationVelocity) + 1.0f, 3.0f);
	}
	
	self.scale = 1.0f;
	particleFX.scale = 1.0f;
	if (input.gesturePinchBegan)
	{
		self.scale = input.gesturePinchScale;
		particleFX.scale = fminf(fabsf(input.gesturePinchVelocity) * 100.0f + 1.0f, 5.0f);
	}
}

-(void) detectMouseOverTouchSprite
{
	KKInput* input = [KKInput sharedInput];
	
	CCSprite* touchSprite = (CCSprite*)[self getChildByTag:99];
	if ([touchSprite containsPoint:input.mouseLocation])
	{
		touchSprite.color = ccGREEN;
	}
	else
	{
		touchSprite.color = ccWHITE;
	}
}

-(void) wrapShipAtScreenBorders
{
	CCDirector* director = [CCDirector sharedDirector];
	CGSize screenSize = director.screenSize;
	
	CGPoint shipPosition = ship.position;

	if (shipPosition.x < 0)
	{
		shipPosition.x += screenSize.width;
	}
	else if (shipPosition.x >= screenSize.width)
	{
		shipPosition.x -= screenSize.width;
	}
	
	if (shipPosition.y < 0)
	{
		shipPosition.y += screenSize.height;
	}
	else if (shipPosition.y >= screenSize.height)
	{
		shipPosition.y -= screenSize.height;
	}
	
	ship.position = shipPosition;
	//LOG_EXPR(ship.texture);
	//LOG_EXPR([ship boundingBox]);
}

-(void) rotateShipWithMouseButtons
{
	KKInput* input = [KKInput sharedInput];

	if ([input isMouseButtonDown:KKMouseButtonLeft])
	{
		ship.rotation -= 2;
	}
	if ([input isMouseButtonDown:KKMouseButtonRight])
	{
		ship.rotation += 2;
	}

	if ([input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierCommandKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierControlKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierShiftKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierAlternateKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonLeft modifierFlags:KKModifierAlphaShiftKeyMask])
	{
		ship.rotation -= 10;
	}
	if ([input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierCommandKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierControlKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierShiftKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierAlternateKeyMask] ||
		[input isMouseButtonDown:KKMouseButtonRight modifierFlags:KKModifierAlphaShiftKeyMask])
	{
		ship.rotation += 10;
	}
	
	if ([input isMouseButtonDownThisFrame:KKMouseButtonDoubleClickLeft])
	{
		[self createSmallExplosionAt:input.mouseLocation];
	}
	if ([input isMouseButtonDownThisFrame:KKMouseButtonDoubleClickRight])
	{
		[self createLargeExplosionAt:input.mouseLocation];
	}
	
	ship.scale += (float)[input scrollWheelDelta].y * 0.1f;
}

-(void) particleFXFollowsMouse
{
	KKInput* input = [KKInput sharedInput];
	
	particleFX.position = [input mouseLocation];
	particleFX.gravity = ccpMult([input mouseLocationDelta], 50.0f);
}

-(void) update:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];
	if ([input isAnyTouchOnNode:self touchPhase:KKTouchPhaseAny])
	{
		CCLOG(@"Touch: beg=%d mov=%d sta=%d end=%d can=%d",
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseBegan], 
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseMoved], 
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseStationary],
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseEnded],
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseCancelled]);
	}
	
	CCDirector* director = [CCDirector sharedDirector];
	
	if (director.currentPlatformIsIOS)
	{
		[self moveShipWithMotionSensors];
		[self moveParticleFXToTouch];
		[self detectSpriteTouched];
		[self gestureRecognition];
		
		if ([KKInput sharedInput].anyTouchEndedThisFrame)
		{
			CCLOG(@"anyTouchEndedThisFrame");
		}
	}
	else
	{
		[self moveShipByPollingKeyboard];
		[self rotateShipWithMouseButtons];
		[self particleFXFollowsMouse];
		[self detectMouseOverTouchSprite];
	}
	
	[self wrapShipAtScreenBorders];
}

-(void) postUpdateInputTests:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];
	if ([input anyTouchEndedThisFrame] || [input isAnyKeyUpThisFrame])
	{
		//CCLOG(@"touch ended / key up this frame");
	}
}

-(void) draw
{
	KKInput* input = [KKInput sharedInput];
	if (input.touchesAvailable)
	{
		NSUInteger color = 0;
		KKTouch* touch;
		CCARRAY_FOREACH(input.touches, touch)		
		{
			switch (color)
			{
				case 0:
					ccDrawColor4F(0.2f, 1, 0.2f, 0.5f);
					break;
				case 1:
					ccDrawColor4F(0.2f, 0.2f, 1, 0.5f);
					break;
				case 2:
					ccDrawColor4F(1, 1, 0.2f, 0.5f);
					break;
				case 3:
					ccDrawColor4F(1, 0.2f, 0.2f, 0.5f);
					break;
				case 4:
					ccDrawColor4F(0.2f, 1, 1, 0.5f);
					break;
					
				default:
					break;
			}
			color++;
			
			ccDrawCircle(touch.location, 60, 0, 16, NO);
			ccDrawCircle(touch.previousLocation, 30, 0, 16, NO);
			ccDrawColor4F(1, 1, 1, 1);
			ccDrawLine(touch.location, touch.previousLocation);
			
			if (CCRANDOM_0_1() > 0.98f)
			{
				//[input removeTouch:touch];
			}
		}
	}
}

@end
