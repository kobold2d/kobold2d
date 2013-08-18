/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKInput.h"

#import "KKInputKeyboard.h"
#import "KKInputMouse.h"
#import "KKInputMotion.h"
#import "KKInputTouch.h"
#import "KKInputGesture.h"

@implementation KKInput
static KKInput *instanceOfInput;

-(id) init
{
    if ((self = [super init]))
	{
#if KK_PLATFORM_IOS
		touch = [[KKInputTouch alloc] init];
		motion = [[KKInputMotion alloc] init];
		gesture = [[KKInputGesture alloc] init];
		if ([gesture gesturesAvailable] == NO)
		{
			[gesture release];
			gesture = nil;
		}			
#elif KK_PLATFORM_MAC
		keyboard = [[KKInputKeyboard alloc] init];
		mouse = [[KKInputMouse alloc] init];
#endif
    }
    
    return self;
}

-(void) dealloc
{
	[keyboard release];
	[mouse release];
	[motion release];
	[touch release];
	[gesture release];
	
	[super dealloc];
}

-(void) resetInputStates
{
#if KK_PLATFORM_IOS
	[touch resetInputStates];
	[motion resetInputStates];
	[gesture resetInputStates];
#elif KK_PLATFORM_MAC
	[keyboard resetInputStates];
	[mouse resetInputStates];
#endif
}


-(BOOL) userInteractionEnabled
{
#if KK_PLATFORM_IOS
	return [[CCDirector sharedDirector].view isUserInteractionEnabled];
#else
	return NO;
#endif
}
-(void) setUserInteractionEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	[[CCDirector sharedDirector].view setUserInteractionEnabled:enabled];
#endif
}


#pragma mark KeyboardInput Private

-(BOOL) isKeyDown:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags onlyThisFrame:(BOOL)onlyThisFrame
{
	if (([keyboard modifiersDown] & modifierFlags) == modifierFlags)
	{
		return [[keyboard keyStates] isKeyDown:keyCode onlyThisFrame:onlyThisFrame];
	}
	return NO;
}

-(BOOL) isKeyUp:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags onlyThisFrame:(BOOL)onlyThisFrame
{
	if (([keyboard modifiersDown] & modifierFlags) == modifierFlags)
	{
		return [[keyboard keyStates] isKeyUp:keyCode onlyThisFrame:onlyThisFrame];
	}
	return NO;
}

-(BOOL) isKeyUp:(KKKeyCode)keyCode onlyThisFrame:(BOOL)onlyThisFrame
{
	return [[keyboard keyStates] isKeyUp:keyCode onlyThisFrame:onlyThisFrame];
}

#pragma mark KeyboardInput Facade
-(BOOL) isAnyKeyDown
{
	return [[keyboard keyStates] isAnyKeyDown];
}
-(BOOL) isAnyKeyDownThisFrame
{
	return [[keyboard keyStates] isAnyKeyDownThisFrame];
}
-(BOOL) isAnyKeyUpThisFrame
{
	return [[keyboard keyStates] isAnyKeyUpThisFrame];
}
-(BOOL) isKeyDown:(KKKeyCode)keyCode
{
	return [self isKeyDown:keyCode modifierFlags:0 onlyThisFrame:NO];
}
-(BOOL) isKeyDown:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags
{
	return [self isKeyDown:keyCode modifierFlags:modifierFlags onlyThisFrame:NO];
}
-(BOOL) isKeyUp:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags
{
	return [self isKeyUp:keyCode modifierFlags:modifierFlags onlyThisFrame:NO];
}
-(BOOL) isKeyDownThisFrame:(KKKeyCode)keyCode
{
	return [self isKeyDown:keyCode modifierFlags:0 onlyThisFrame:YES];
}
-(BOOL) isKeyDownThisFrame:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags
{
	return [self isKeyDown:keyCode modifierFlags:modifierFlags onlyThisFrame:YES];
}
-(BOOL) isKeyUpThisFrame:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags
{
	return [self isKeyUp:keyCode modifierFlags:modifierFlags onlyThisFrame:YES];
}
-(BOOL) isKeyUp:(KKKeyCode)keyCode
{
	return [self isKeyUp:keyCode onlyThisFrame:NO];
}
-(BOOL) isKeyUpThisFrame:(KKKeyCode)keyCode
{
	return [self isKeyUp:keyCode onlyThisFrame:YES];
}



#pragma mark MouseInput Private

-(BOOL) isMouseButtonDown:(KKMouseButtonCode)buttonCode modifierFlags:(KKModifierFlag)modifierFlags onlyThisFrame:(BOOL)onlyThisFrame
{
	if (([keyboard modifiersDown] & modifierFlags) == modifierFlags)
	{
		KKKeyStates* keyStates = [mouse keyStates];
		return ([keyStates isKeyDown:buttonCode onlyThisFrame:onlyThisFrame] ||
				((buttonCode < KKMouseButtonDoubleClickOffset) && // check for button double-click as well:
				 [keyStates isKeyDown:buttonCode + KKMouseButtonDoubleClickOffset onlyThisFrame:onlyThisFrame]));
	}
	return NO;
}

-(BOOL) isMouseButtonUp:(KKMouseButtonCode)buttonCode onlyThisFrame:(BOOL)onlyThisFrame
{
	return [[mouse keyStates] isKeyUp:buttonCode onlyThisFrame:onlyThisFrame];
}

#pragma mark MouseInput Facade

-(BOOL) isAnyMouseButtonDown
{
	return [[mouse keyStates] isAnyKeyDown];
}
-(BOOL) isAnyMouseButtonDownThisFrame
{
	return [[mouse keyStates] isAnyKeyDownThisFrame];
}
-(BOOL) isAnyMouseButtonUpThisFrame
{
	return [[mouse keyStates] isAnyKeyUpThisFrame];
}
-(BOOL) isMouseButtonDown:(KKMouseButtonCode)buttonCode
{
	return [self isMouseButtonDown:buttonCode modifierFlags:0 onlyThisFrame:NO];
}
-(BOOL) isMouseButtonDown:(KKMouseButtonCode)buttonCode modifierFlags:(KKModifierFlag)modifierFlags
{
	return [self isMouseButtonDown:buttonCode modifierFlags:modifierFlags onlyThisFrame:NO];
}
-(BOOL) isMouseButtonDownThisFrame:(KKMouseButtonCode)buttonCode
{
	return [self isMouseButtonDown:buttonCode modifierFlags:0 onlyThisFrame:YES];
}
-(BOOL) isMouseButtonDownThisFrame:(KKMouseButtonCode)buttonCode modifierFlags:(KKModifierFlag)modifierFlags
{
	return [self isMouseButtonDown:buttonCode modifierFlags:modifierFlags onlyThisFrame:YES];
}
-(BOOL) isMouseButtonUp:(KKMouseButtonCode)buttonCode
{
	return [self isMouseButtonUp:buttonCode onlyThisFrame:NO];
}
-(BOOL) isMouseButtonUpThisFrame:(KKMouseButtonCode)buttonCode
{
	return [self isMouseButtonUp:buttonCode onlyThisFrame:YES];
}
-(CGPoint) mouseLocation
{
	return [mouse locationInWindow];
}
-(CGPoint) previousMouseLocation
{
	return [mouse previousLocationInWindow];
}
-(CGPoint) mouseLocationDelta
{
	return ccpSub([mouse locationInWindow], [mouse previousLocationInWindow]);
}
-(BOOL) acceptsMouseMovedEvents
{
#if KK_PLATFORM_IOS
	return NO;
#elif KK_PLATFORM_MAC
	NSWindow* window = [[NSApplication sharedApplication] mainWindow];
	return [window acceptsMouseMovedEvents];
#endif
}
-(void) setAcceptsMouseMovedEvents:(BOOL)acceptsMouseMovedEvents
{
#if KK_PLATFORM_MAC
	NSWindow* window = [[NSApplication sharedApplication] mainWindow];
	[window setAcceptsMouseMovedEvents:acceptsMouseMovedEvents];
#endif
}
-(CGPoint) scrollWheelDelta
{
	return [mouse scrollWheelDelta];
}



#pragma mark MotionInput Facade

-(BOOL) accelerometerActive
{
	return [motion accelerometerActive];
}
-(void) setAccelerometerActive:(BOOL)active
{
	[motion setAccelerometerActive:active];
}
-(BOOL) accelerometerAvailable
{
	return [motion accelerometerAvailable];
}
-(KKAcceleration*) acceleration
{
	return [motion acceleration];
}

-(BOOL) gyroActive
{
	return [motion gyroActive];
}
-(void) setGyroActive:(BOOL)active
{
	[motion setGyroActive:active];
}
-(BOOL) gyroAvailable
{
	return [motion gyroAvailable];
}
-(KKRotationRate*) rotationRate
{
	return [motion rotationRate];
}

-(BOOL) deviceMotionActive
{
	return [motion deviceMotionActive];
}
-(void) setDeviceMotionActive:(BOOL)active
{
	[motion setDeviceMotionActive:active];
}
-(BOOL) deviceMotionAvailable
{
	return [motion deviceMotionAvailable];
}
-(KKDeviceMotion*) deviceMotion
{
	return [motion deviceMotion];
}


#pragma mark TouchInput Facade

-(CCArray*) touches
{
	return [touch touches];
}
-(BOOL) touchesAvailable
{
	return ([[touch touches] count] > 0);
}
-(BOOL) anyTouchBeganThisFrame
{
	return [touch anyTouchBeganThisFrame];
}
-(BOOL) anyTouchEndedThisFrame
{
	return [touch anyTouchEndedThisFrame];
}
-(CGPoint) locationOfAnyTouchInPhase:(KKTouchPhase)touchPhase
{
	return [touch locationOfAnyTouchInPhase:touchPhase];
}
@dynamic anyTouchLocation;
-(CGPoint) anyTouchLocation
{
	return [touch locationOfAnyTouchInPhase:KKTouchPhaseAny];
}
-(BOOL) isAnyTouchOnNode:(CCNode*)node touchPhase:(KKTouchPhase)touchPhase
{
	return [touch isAnyTouchOnNode:node touchPhase:touchPhase];
}
-(BOOL) multipleTouchEnabled
{
#if KK_PLATFORM_IOS
	return [CCDirector sharedDirector].view.multipleTouchEnabled;
#else
	return NO;
#endif
}
-(void) setMultipleTouchEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	[CCDirector sharedDirector].view.multipleTouchEnabled = enabled;
#endif
}

-(void) removeTouch:(KKTouch*)touchToBeRemoved
{
	[touch removeTouch:touchToBeRemoved];
}

#pragma mark GestureInput Facade
-(BOOL) gesturesAvailable
{
	return [gesture gesturesAvailable];
}

// tap
-(BOOL) gestureTapEnabled
{
	return [gesture gestureTapEnabled];
}
-(void) setGestureTapEnabled:(BOOL)enabled
{
	return [gesture setGestureTapEnabled:enabled];
}
-(BOOL) gestureTapRecognizedThisFrame
{
	return [gesture gestureTapRecognizedThisFrame];
}
-(CGPoint) gestureTapLocation
{
	return [gesture gestureTapLocation];
}

// double tap
-(BOOL) gestureDoubleTapEnabled
{
	return [gesture gestureDoubleTapEnabled];
}
-(void) setGestureDoubleTapEnabled:(BOOL)enabled
{
	return [gesture setGestureDoubleTapEnabled:enabled];
}
-(BOOL) gestureDoubleTapRecognizedThisFrame
{
	return [gesture gestureDoubleTapRecognizedThisFrame];
}
-(CGPoint) gestureDoubleTapLocation
{
	return [gesture gestureDoubleTapLocation];
}

// swipe
-(BOOL) gestureSwipeEnabled
{
	return [gesture gestureSwipeEnabled];
}
-(void) setGestureSwipeEnabled:(BOOL)enabled
{
	return [gesture setGestureSwipeEnabled:enabled];
}
-(BOOL) gestureSwipeRecognizedThisFrame
{
	return [gesture gestureSwipeRecognizedThisFrame];
}
-(CGPoint) gestureSwipeLocation
{
	return [gesture gestureSwipeLocation];
}
-(KKSwipeGestureDirection) gestureSwipeDirection
{
	return [gesture gestureSwipeDirection];
}

// long press
-(BOOL) gestureLongPressEnabled
{
	return [gesture gestureLongPressEnabled];
}
-(void) setGestureLongPressEnabled:(BOOL)enabled
{
	return [gesture setGestureLongPressEnabled:enabled];
}
-(BOOL) gestureLongPressBegan
{
	return [gesture gestureLongPressBegan];
}
-(CGPoint) gestureLongPressLocation
{
	return [gesture gestureLongPressLocation];
}

// pan
-(BOOL) gesturePanEnabled
{
	return [gesture gesturePanEnabled];
}
-(void) setGesturePanEnabled:(BOOL)enabled
{
	return [gesture setGesturePanEnabled:enabled];
}
-(BOOL) gesturePanBegan
{
	return [gesture gesturePanBegan];
}
-(CGPoint) gesturePanLocation
{
	return [gesture gesturePanLocation];
}
-(CGPoint) gesturePanTranslation
{
	return [gesture gesturePanTranslation];
}
-(void) setGesturePanTranslation:(CGPoint)translation
{
	return [gesture setGesturePanTranslation:translation];
}
-(CGPoint) gesturePanVelocity
{
	return [gesture gesturePanVelocity];
}

// rotation
-(BOOL) gestureRotationEnabled
{
	return [gesture gestureRotationEnabled];
}
-(void) setGestureRotationEnabled:(BOOL)enabled
{
	return [gesture setGestureRotationEnabled:enabled];
}
-(BOOL) gestureRotationBegan
{
	return [gesture gestureRotationBegan];
}
-(CGPoint) gestureRotationLocation
{
	return [gesture gestureRotationLocation];
}
-(float) gestureRotationAngle
{
	return [gesture gestureRotationAngle];
}
-(void) setGestureRotationAngle:(float)angle
{
	return [gesture setGestureRotationAngle:angle];
}
-(float) gestureRotationVelocity
{
	return [gesture gestureRotationVelocity];
}

// pinch
-(BOOL) gesturePinchEnabled
{
	return [gesture gesturePinchEnabled];
}
-(void) setGesturePinchEnabled:(BOOL)enabled
{
	return [gesture setGesturePinchEnabled:enabled];
}
-(BOOL) gesturePinchBegan
{
	return [gesture gesturePinchBegan];
}
-(CGPoint) gesturePinchLocation
{
	return [gesture gesturePinchLocation];
}
-(float) gesturePinchScale
{
	return [gesture gesturePinchScale];
}
-(void) setGesturePinchScale:(float)angle
{
	return [gesture setGesturePinchScale:angle];
}
-(float) gesturePinchVelocity
{
	return [gesture gesturePinchVelocity];
}


// Gesture Recognizers
#if KK_PLATFORM_IOS
-(UISwipeGestureRecognizer*) swipeGestureRecognizerForDirection:(KKSwipeGestureDirection)direction
{
	return [gesture swipeGestureRecognizerForDirection:direction];
}
-(UITapGestureRecognizer*) tapGestureRecognizer
{
	return [gesture tapGestureRecognizer];
}
-(UITapGestureRecognizer*) doubleTapGestureRecognizer
{
	return [gesture doubleTapGestureRecognizer];
}
-(UILongPressGestureRecognizer*) longPressGestureRecognizer
{
	return [gesture longPressGestureRecognizer];
}
-(UIPanGestureRecognizer*) panGestureRecognizer
{
	return [gesture panGestureRecognizer];
}
-(UIRotationGestureRecognizer*) rotationGestureRecognizer
{
	return [gesture rotationGestureRecognizer];
}
-(UIPinchGestureRecognizer*) pinchGestureRecognizer
{
	return [gesture pinchGestureRecognizer];
}
#elif KK_PLATFORM_MAC
-(id) swipeGestureRecognizerForDirection:(int)direction {return nil;}
-(id) tapGestureRecognizer {return nil;}
-(id) doubleTapGestureRecognizer {return nil;}
-(id) longPressGestureRecognizer {return nil;}
-(id) panGestureRecognizer {return nil;}
-(id) rotationGestureRecognizer {return nil;}
-(id) pinchGestureRecognizer {return nil;}
#endif

// runs after all CCScheduler update & scheduled selectors have run
-(void) tick:(ccTime)delta
{
	[keyboard update:delta];
	[mouse update:delta];
	[touch update:delta];
	[gesture update:delta];
}

#pragma mark Singleton stuff
+(id) alloc
{
	@synchronized(self)	
	{
		NSAssert(instanceOfInput == nil, @"Attempted to allocate a second instance of the singleton: KKInput");
		instanceOfInput = [[super alloc] retain];
		return instanceOfInput;
	}
	// to avoid compiler warning
	return nil;
}

+(KKInput*) sharedInput
{
	@synchronized(self)
	{
		if (instanceOfInput == nil)
		{
			instanceOfInput = [[KKInput alloc] init];
		}
		
		return instanceOfInput;
	}
	// to avoid compiler warning
	return nil;
}

@end
