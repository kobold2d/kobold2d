/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import "KKInput.h"

#define kNumSwipeGestureRecognizers 4

@interface KKInputGesture : NSObject 
#if KK_PLATFORM_IOS
	<UIGestureRecognizerDelegate>
#endif
{
@private
	CCDirector* director;

#if KK_PLATFORM_IOS
	UITapGestureRecognizer* tapGestureRecognizer;
	UITapGestureRecognizer* doubleTapGestureRecognizer;
	UISwipeGestureRecognizer* swipeGestureRecognizers[kNumSwipeGestureRecognizers];
	UILongPressGestureRecognizer* longPressGestureRecognizer;
	UIPanGestureRecognizer* panGestureRecognizer;
	UIRotationGestureRecognizer* rotationGestureRecognizer;
	UIPinchGestureRecognizer* pinchGestureRecognizer;
#endif

	// enabled states
	BOOL gesturesAvailable;
	BOOL gestureTapEnabled;
	BOOL gestureDoubleTapEnabled;
	BOOL gestureSwipeEnabled;
	BOOL gestureLongPressEnabled;
	BOOL gesturePanEnabled;
	BOOL gestureRotationEnabled;
	BOOL gesturePinchEnabled;
	
	// tap
	BOOL gestureTapRecognizedThisFrame;
	CGPoint gestureTapLocation;

	// double tap
	BOOL gestureDoubleTapRecognizedThisFrame;
	CGPoint gestureDoubleTapLocation;

	// swipe
	BOOL gestureSwipeRecognizedThisFrame;
	CGPoint gestureSwipeLocation;
	KKSwipeGestureDirection gestureSwipeDirection;
	
	// long-press
	BOOL gestureLongPressBegan;
	CGPoint gestureLongPressLocation;

	// pan
	BOOL gesturePanBegan;
	CGPoint gesturePanLocation;
	CGPoint gesturePanTranslation;
	CGPoint gesturePanVelocity;

	// rotation
	BOOL gestureRotationBegan;
	CGPoint gestureRotationLocation;
	float gestureRotationAngle;
	float gestureRotationVelocity;
	
	// pinch
	BOOL gesturePinchBegan;
	CGPoint gesturePinchLocation;
	float gesturePinchScale;
	float gesturePinchVelocity;
}

#if KK_PLATFORM_IOS
-(void) resetInputStates;

-(UISwipeGestureRecognizer*) swipeGestureRecognizerForDirection:(KKSwipeGestureDirection)direction;
@property (nonatomic, readonly) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic, readonly) UITapGestureRecognizer* doubleTapGestureRecognizer;
@property (nonatomic, readonly) UILongPressGestureRecognizer* longPressGestureRecognizer;
@property (nonatomic, readonly) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, readonly) UIRotationGestureRecognizer* rotationGestureRecognizer;
@property (nonatomic, readonly) UIPinchGestureRecognizer* pinchGestureRecognizer;
#endif

@property (nonatomic, readonly) BOOL gesturesAvailable;

// tap
@property (nonatomic) BOOL gestureTapEnabled;
@property (nonatomic, readonly) BOOL gestureTapRecognizedThisFrame;
@property (nonatomic, readonly) CGPoint gestureTapLocation;

// double tap
@property (nonatomic) BOOL gestureDoubleTapEnabled;
@property (nonatomic, readonly) BOOL gestureDoubleTapRecognizedThisFrame;
@property (nonatomic, readonly) CGPoint gestureDoubleTapLocation;

// swipe
@property (nonatomic) BOOL gestureSwipeEnabled;
@property (nonatomic, readonly) BOOL gestureSwipeRecognizedThisFrame;
@property (nonatomic, readonly) CGPoint gestureSwipeLocation;
@property (nonatomic, readonly) KKSwipeGestureDirection gestureSwipeDirection;

// long-press
@property (nonatomic) BOOL gestureLongPressEnabled;
@property (nonatomic, readonly) BOOL gestureLongPressBegan;
@property (nonatomic, readonly) CGPoint gestureLongPressLocation;

// pan
@property (nonatomic) BOOL gesturePanEnabled;
@property (nonatomic, readonly) BOOL gesturePanBegan;
@property (nonatomic, readonly) CGPoint gesturePanLocation;
@property (nonatomic) CGPoint gesturePanTranslation;
@property (nonatomic, readonly) CGPoint gesturePanVelocity;

// rotation
@property (nonatomic) BOOL gestureRotationEnabled;
@property (nonatomic, readonly) BOOL gestureRotationBegan;
@property (nonatomic, readonly) CGPoint gestureRotationLocation;
@property (nonatomic) float gestureRotationAngle;
@property (nonatomic, readonly) float gestureRotationVelocity;

// pinch
@property (nonatomic) BOOL gesturePinchEnabled;
@property (nonatomic, readonly) BOOL gesturePinchBegan;
@property (nonatomic, readonly) CGPoint gesturePinchLocation;
@property (nonatomic) float gesturePinchScale;
@property (nonatomic, readonly) float gesturePinchVelocity;

-(void) update:(ccTime)delta;

@end
