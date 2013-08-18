/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKInputGesture.h"

@interface KKInputGesture (PrivateMethods)
-(void) determineGestureRecognizersAvailable;
-(void) update:(ccTime)delta;
#if KK_PLATFORM_IOS
-(void) removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer;
#endif
@end


@implementation KKInputGesture

#if KK_PLATFORM_IOS
-(UISwipeGestureRecognizer*) swipeGestureRecognizerForDirection:(KKSwipeGestureDirection)direction
{
	switch (direction)
	{
		case KKSwipeGestureDirectionRight:
			return swipeGestureRecognizers[0];
		case KKSwipeGestureDirectionLeft:
			return swipeGestureRecognizers[1];
		case KKSwipeGestureDirectionUp:
			return swipeGestureRecognizers[2];
		case KKSwipeGestureDirectionDown:
			return swipeGestureRecognizers[3];
			
		default:
			NSAssert1(nil, @"invalid KKSwipeGestureDirection/UISwipeGestureRecognizerDirection '%i'", direction);
			break;
	}
	
	return nil;
}

@synthesize tapGestureRecognizer, doubleTapGestureRecognizer, longPressGestureRecognizer;
@synthesize panGestureRecognizer, rotationGestureRecognizer, pinchGestureRecognizer;
#endif

@synthesize gesturesAvailable;

// tap & double tap
@dynamic gestureTapEnabled, gestureDoubleTapEnabled;
@synthesize gestureTapRecognizedThisFrame, gestureTapLocation, gestureDoubleTapRecognizedThisFrame, gestureDoubleTapLocation;

// swipe
@dynamic gestureSwipeEnabled;
@synthesize gestureSwipeRecognizedThisFrame, gestureSwipeLocation, gestureSwipeDirection;

// long press
@dynamic gestureLongPressEnabled;
@synthesize gestureLongPressBegan, gestureLongPressLocation;

// pan
@dynamic gesturePanEnabled;
@synthesize gesturePanBegan, gesturePanLocation, gesturePanTranslation, gesturePanVelocity;

// rotation
@dynamic gestureRotationEnabled;
@synthesize gestureRotationBegan, gestureRotationLocation, gestureRotationAngle, gestureRotationVelocity;

// pinch
@dynamic gesturePinchEnabled;
@synthesize gesturePinchBegan, gesturePinchLocation, gesturePinchScale, gesturePinchVelocity;

-(id) init
{
    if ((self = [super init]))
	{
		director = [CCDirector sharedDirector];
		
		[self determineGestureRecognizersAvailable];
    }
    
    return self;
}

-(void) dealloc
{
	if (gesturesAvailable)
	{
#if KK_PLATFORM_IOS
		[self removeGestureRecognizer:tapGestureRecognizer];
		[self removeGestureRecognizer:doubleTapGestureRecognizer];
		for (int i = 0; i < kNumSwipeGestureRecognizers; i++)
		{
			[self removeGestureRecognizer:swipeGestureRecognizers[i]];
		}
		[self removeGestureRecognizer:longPressGestureRecognizer];
		[self removeGestureRecognizer:panGestureRecognizer];
		[self removeGestureRecognizer:rotationGestureRecognizer];
		[self removeGestureRecognizer:pinchGestureRecognizer];
#endif
	}
	
	[super dealloc];
}


#if KK_PLATFORM_IOS

-(void) resetInputStates
{
	// turn recognizers off and on to stop them from recognizing a gesture until new touches occur
	tapGestureRecognizer.enabled = !tapGestureRecognizer.enabled;
	tapGestureRecognizer.enabled = !tapGestureRecognizer.enabled;
	
	doubleTapGestureRecognizer.enabled = !doubleTapGestureRecognizer.enabled;
	doubleTapGestureRecognizer.enabled = !doubleTapGestureRecognizer.enabled;
	
	for (int i = 0; i < kNumSwipeGestureRecognizers; i++)
	{
		swipeGestureRecognizers[i].enabled = !swipeGestureRecognizers[i].enabled;
		swipeGestureRecognizers[i].enabled = !swipeGestureRecognizers[i].enabled;
	}
	
	longPressGestureRecognizer.enabled = !longPressGestureRecognizer.enabled;
	longPressGestureRecognizer.enabled = !longPressGestureRecognizer.enabled;
	
	panGestureRecognizer.enabled = !panGestureRecognizer.enabled;
	panGestureRecognizer.enabled = !panGestureRecognizer.enabled;
	
	rotationGestureRecognizer.enabled = !rotationGestureRecognizer.enabled;
	rotationGestureRecognizer.enabled = !rotationGestureRecognizer.enabled;
	
	pinchGestureRecognizer.enabled = !pinchGestureRecognizer.enabled;
	pinchGestureRecognizer.enabled = !pinchGestureRecognizer.enabled;
	
	// this clears the states that need to be cleared every frame
	[self update:0];
}

-(void) handleGestureDummy:(UIGestureRecognizer*)gestureRecognizer {}
-(void) determineGestureRecognizersAvailable
{
	// gestures are not available if gestureRecognizer is nil, or does not support the locationInView selector added in iOS 3.2
	UIGestureRecognizer* gestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureDummy:)];
	gesturesAvailable = [gestureRecognizer respondsToSelector:@selector(locationInView:)];
	[gestureRecognizer release];
}


-(void) removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
	if (gestureRecognizer)
	{
		[director.view removeGestureRecognizer:gestureRecognizer];
		gestureRecognizer.delegate = nil;
		[gestureRecognizer release];
		gestureRecognizer = nil;
	}
}


#pragma mark Gesture properties

-(void) setGesturePanTranslation:(CGPoint)translation
{
	[panGestureRecognizer setTranslation:translation inView:director.view];
}

-(void) setGestureRotationAngle:(float)angle
{
	[rotationGestureRecognizer setRotation:CC_DEGREES_TO_RADIANS(angle)];
}

-(void) setGesturePinchScale:(float)scale
{
	[pinchGestureRecognizer setScale:scale];
}


#pragma mark Gesture delegate methods

-(BOOL) gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
	Class recognizerClass = [gestureRecognizer class];
	Class otherClass = [otherGestureRecognizer class];
	Class panClass = [UIPanGestureRecognizer class];
	Class swipeClass = [UISwipeGestureRecognizer class];
	Class rotationClass = [UIRotationGestureRecognizer class];
	Class pinchClass = [UIPinchGestureRecognizer class];
	
	return ((recognizerClass == panClass && otherClass == swipeClass) || (recognizerClass == swipeClass && otherClass == panClass) ||
			(recognizerClass == rotationClass && otherClass == pinchClass) || (recognizerClass == pinchClass && otherClass == rotationClass));
}


#pragma mark Gesture Handlers

-(KKSwipeGestureDirection) convertSwipeDirection:(UISwipeGestureRecognizerDirection)uiDirection
{
	// portrait mode direction remains unchanged
	KKSwipeGestureDirection direction = (KKSwipeGestureDirection)uiDirection;
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	switch (uiDirection)
	{
		case UISwipeGestureRecognizerDirectionRight:
		{
			switch (orientation)
			{
				case UIDeviceOrientationPortraitUpsideDown:
					direction = KKSwipeGestureDirectionLeft;
					break;
				case UIDeviceOrientationLandscapeLeft:
					direction = KKSwipeGestureDirectionUp;
					break;
				case UIDeviceOrientationLandscapeRight:
					direction = KKSwipeGestureDirectionDown;
					break;
				default:
					break;
			}
			break;
		}
			
		case UISwipeGestureRecognizerDirectionLeft:
		{
			switch (orientation)
			{
				case UIDeviceOrientationPortraitUpsideDown:
					direction = KKSwipeGestureDirectionRight;
					break;
				case UIDeviceOrientationLandscapeLeft:
					direction = KKSwipeGestureDirectionDown;
					break;
				case UIDeviceOrientationLandscapeRight:
					direction = KKSwipeGestureDirectionUp;
					break;
				default:
					break;
			}
			break;
		}
			
		case UISwipeGestureRecognizerDirectionUp:
		{
			switch (orientation)
			{
				case UIDeviceOrientationPortraitUpsideDown:
					direction = KKSwipeGestureDirectionDown;
					break;
				case UIDeviceOrientationLandscapeLeft:
					direction = KKSwipeGestureDirectionLeft;
					break;
				case UIDeviceOrientationLandscapeRight:
					direction = KKSwipeGestureDirectionRight;
					break;
				default:
					break;
			}
			break;
		}
			
		case UISwipeGestureRecognizerDirectionDown:
		{
			switch (orientation)
			{
				case UIDeviceOrientationPortraitUpsideDown:
					direction = KKSwipeGestureDirectionUp;
					break;
				case UIDeviceOrientationLandscapeLeft:
					direction = KKSwipeGestureDirectionRight;
					break;
				case UIDeviceOrientationLandscapeRight:
					direction = KKSwipeGestureDirectionLeft;
					break;
				default:
					break;
			}
			break;
		}
	}
	
	return direction;
}

-(CGPoint) convertRelativePointToGL:(CGPoint)relativePoint
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	switch (orientation)
	{
		case UIDeviceOrientationPortrait:
			relativePoint.y *= -1.0f;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			relativePoint.x *= -1.0f;
			break;
		case UIDeviceOrientationLandscapeLeft:
			relativePoint = CGPointMake(relativePoint.y, relativePoint.x);
			break;
		case UIDeviceOrientationLandscapeRight:
			relativePoint = CGPointMake(-relativePoint.y, -relativePoint.x);
			break;
		default:
			break;
	}
	
	return relativePoint;
}

-(void) handleTapGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		gestureTapRecognizedThisFrame = YES;
		gestureTapLocation = [director convertToGL:[recognizer locationInView:director.view]];
	}
}

-(void) handleDoubleTapGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		gestureDoubleTapRecognizedThisFrame = YES;
		gestureDoubleTapLocation = [director convertToGL:[recognizer locationInView:director.view]];
	}
}

-(void) handleSwipeGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		gestureSwipeRecognizedThisFrame = YES;
		gestureSwipeLocation = [director convertToGL:[recognizer locationInView:director.view]];
		gestureSwipeDirection = [self convertSwipeDirection:[(UISwipeGestureRecognizer*)recognizer direction]];
	}
}

-(void) handleLongPressGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded || 
		recognizer.state == UIGestureRecognizerStateCancelled ||
		recognizer.state == UIGestureRecognizerStateFailed)
	{
		gestureLongPressBegan = NO;
	}
	else
	{
		gestureLongPressBegan = YES;
		gestureLongPressLocation = [director convertToGL:[recognizer locationInView:director.view]];
	}
}

-(void) handlePanGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded || 
		recognizer.state == UIGestureRecognizerStateCancelled ||
		recognizer.state == UIGestureRecognizerStateFailed)
	{
		gesturePanBegan = NO;
	}
	else
	{
		UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)recognizer;
		UIView* glView = director.view;
		
		gesturePanBegan = YES;
		gesturePanLocation = [director convertToGL:[recognizer locationInView:glView]];
		gesturePanTranslation = [panRecognizer translationInView:glView];
		gesturePanTranslation = [self convertRelativePointToGL:gesturePanTranslation];
		gesturePanVelocity = [panRecognizer velocityInView:glView];
		gesturePanVelocity = [self convertRelativePointToGL:gesturePanVelocity];
		gesturePanVelocity = ccpMult(gesturePanVelocity, director.animationInterval);
	}
}

-(void) handleRotationGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded || 
		recognizer.state == UIGestureRecognizerStateCancelled ||
		recognizer.state == UIGestureRecognizerStateFailed)
	{
		gestureRotationBegan = NO;
	}
	else
	{
		UIRotationGestureRecognizer* rotationRecognizer = (UIRotationGestureRecognizer*)recognizer;
		UIView* glView = director.view;
		
		gestureRotationBegan = YES;
		gestureRotationLocation = [director convertToGL:[recognizer locationInView:glView]];
		gestureRotationAngle = CC_RADIANS_TO_DEGREES([rotationRecognizer rotation]);
		gestureRotationVelocity = CC_RADIANS_TO_DEGREES([rotationRecognizer velocity]) * director.animationInterval;
	}
}

-(void) handlePinchGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded || 
		recognizer.state == UIGestureRecognizerStateCancelled ||
		recognizer.state == UIGestureRecognizerStateFailed)
	{
		gesturePinchBegan = NO;
	}
	else
	{
		UIPinchGestureRecognizer* pinchRecognizer = (UIPinchGestureRecognizer*)recognizer;
		UIView* glView = director.view;
		
		gesturePinchBegan = YES;
		gesturePinchLocation = [director convertToGL:[recognizer locationInView:glView]];
		gesturePinchScale = [pinchRecognizer scale];
		gesturePinchVelocity = [pinchRecognizer velocity] * director.animationInterval;
	}
}

#endif // KK_PLATFORM_IOS


#pragma mark Gesture Enablers

-(void) setGestureTapEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureTapEnabled = enabled;
		
		if (enabled && tapGestureRecognizer == nil)
		{
			tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
			[director.view addGestureRecognizer:tapGestureRecognizer];
			
			if (doubleTapGestureRecognizer)
			{
				[tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
			}
		}
		else if (enabled == NO && tapGestureRecognizer)
		{
			[self removeGestureRecognizer:tapGestureRecognizer];
			tapGestureRecognizer = nil;
		}
	}
#endif
}

-(void) setGestureDoubleTapEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureDoubleTapEnabled = enabled;
		
		if (enabled && doubleTapGestureRecognizer == nil)
		{
			doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
			doubleTapGestureRecognizer.numberOfTapsRequired = 2;
			[director.view addGestureRecognizer:doubleTapGestureRecognizer];
			
			[tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
		}
		else if (enabled == NO && doubleTapGestureRecognizer)
		{
			[tapGestureRecognizer requireGestureRecognizerToFail:nil];
			[self removeGestureRecognizer:doubleTapGestureRecognizer];
			doubleTapGestureRecognizer = nil;
		}
	}
#endif
}

-(void) setGestureSwipeEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureSwipeEnabled = enabled;
		
		if (enabled && swipeGestureRecognizers[0] == nil)
		{
			for (int i = 0; i < kNumSwipeGestureRecognizers; i++)
			{
				swipeGestureRecognizers[i] = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
				swipeGestureRecognizers[i].direction = (UISwipeGestureRecognizerDirection)(1 << i);
				swipeGestureRecognizers[i].delegate = self;
				[director.view addGestureRecognizer:swipeGestureRecognizers[i]];
			}
		}
		else if (enabled == NO && swipeGestureRecognizers[0])
		{
			for (int i = 0; i < kNumSwipeGestureRecognizers; i++)
			{
				[self removeGestureRecognizer:swipeGestureRecognizers[i]];
				swipeGestureRecognizers[i] = nil;
			}
		}
	}
#endif
}

-(void) setGestureLongPressEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureLongPressEnabled = enabled;
		
		if (enabled && longPressGestureRecognizer == nil)
		{
			longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
			[director.view addGestureRecognizer:longPressGestureRecognizer];
		}
		else if (enabled == NO && longPressGestureRecognizer)
		{
			[self removeGestureRecognizer:longPressGestureRecognizer];
			longPressGestureRecognizer = nil;
		}
	}
#endif
}

-(void) setGesturePanEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gesturePanEnabled = enabled;
		
		if (enabled && panGestureRecognizer == nil)
		{
			panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
			panGestureRecognizer.delegate = self;
			[director.view addGestureRecognizer:panGestureRecognizer];
		}
		else if (enabled == NO && panGestureRecognizer)
		{
			[self removeGestureRecognizer:panGestureRecognizer];
			panGestureRecognizer = nil;
		}
	}
#endif
}

-(void) setGestureRotationEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureRotationEnabled = enabled;
		
		if (enabled && rotationGestureRecognizer == nil)
		{
			rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
			rotationGestureRecognizer.delegate = self;
			[director.view addGestureRecognizer:rotationGestureRecognizer];
		}
		else if (enabled == NO && rotationGestureRecognizer)
		{
			[self removeGestureRecognizer:rotationGestureRecognizer];
			rotationGestureRecognizer = nil;
		}
	}
#endif
}

-(void) setGesturePinchEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gesturePinchEnabled = enabled;
		
		if (enabled && pinchGestureRecognizer == nil)
		{
			pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
			pinchGestureRecognizer.delegate = self;
			[director.view addGestureRecognizer:pinchGestureRecognizer];
		}
		else if (enabled == NO && pinchGestureRecognizer)
		{
			[self removeGestureRecognizer:pinchGestureRecognizer];
			pinchGestureRecognizer = nil;
		}
	}
#endif
}


#pragma mark update

-(void) update:(ccTime)delta
{
	if (gesturesAvailable)
	{
		gestureTapRecognizedThisFrame = NO;
		gestureDoubleTapRecognizedThisFrame = NO;
		gestureSwipeRecognizedThisFrame = NO;
		gesturePanVelocity = CGPointZero;
		gestureRotationVelocity = 0.0f;
		gesturePinchVelocity = 0.0f;
	}
}

@end
