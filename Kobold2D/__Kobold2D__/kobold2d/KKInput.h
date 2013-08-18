/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import "KKInputEnums.h"
#import "KKAcceleration.h"
#import "KKRotationRate.h"
#import "KKDeviceMotion.h"
#import "KKTouches.h"
#import "KKInputGesture.h"

@class KKInputKeyboard;
@class KKInputMouse;
@class KKInputMotion;
@class KKInputTouch;
@class KKInputGesture;
@class KKTouch;

/** Kobold2D User Input handler that gives you both a polling API (eg isKeyDown) and an event-driven API configurable via config.lua.
 KKInput supports all input methods: keyboard, mouse, touch, motion (accelerometer and gyroscope) and gestures.
 
 The design of the KKInput API is meant to be as simple as possible, giving you many convenience functions. For example, mouse button
 double-clicks are treated as if they were separate buttons so you don't have to write your own code to test for double-clicks. You
 can also easily test mouse button states in combination with keyboard modifierFlags to detect Control-Clicks and the like.
 
 It is legal (no compile error) to call keyboard & mouse methods on iOS, as is calling touch, motion and gesture methods on Mac OS. 
 Of course you won't get meaningful results/values, the real benefit is that you can write #ifdef-less code.
 
 Note: all "ThisFrame" methods are only useful if you poll the state every frame (eg scheduled update method without an interval),
 otherwise you might "miss" the event because the state will only remain true for one frame.
 */
@interface KKInput : NSObject
{
@private
	KKInputKeyboard* keyboard;
	KKInputMouse* mouse;
	KKInputMotion* motion;
	KKInputTouch* touch;
	KKInputGesture* gesture;
}

/** returns the singleton instance */
+(KKInput*) sharedInput;

/** Resets the entire KKInput system, meaning all current touches, keypresses, etc. will be removed and state
 variables are reset. However gesture recognizers will remain enabled and so are other "enabled" states.
 Note: This method is called automatically when changing scenes (replaceScene, pushScene, popScene). */
-(void) resetInputStates;

#pragma mark General Input Helpers

/** Enable or disable user interaction events for the Cocos2D glView entirely. */
@property (nonatomic) BOOL userInteractionEnabled;

#pragma mark Keyboard Facade

/** returns true if any keyboard key is down */
@property (nonatomic, readonly) BOOL isAnyKeyDown;
/** returns true if any keyboard key changed from keyUp to keyDown state in the current frame */
@property (nonatomic, readonly) BOOL isAnyKeyDownThisFrame;
/** returns true if any keyboard key changed from keyDown to keyUp state in the current frame */
@property (nonatomic, readonly) BOOL isAnyKeyUpThisFrame;

/** returns true if the key with the given virtual keyCode is down */
-(BOOL) isKeyDown:(KKKeyCode)keyCode;
/** returns true if the key with the given virtual keyCode and the given modifierFlags are down */
-(BOOL) isKeyDown:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags;
/** returns true if the key with the given virtual keyCode just changed from keyUp to keyDown state in the current frame */
-(BOOL) isKeyDownThisFrame:(KKKeyCode)keyCode;
/** returns true if the key with the given virtual keyCode just changed from keyUp to keyDown state in the current frame, with modifiers. The modifiers must already be down, eg pressing modifier(s) followed by key will return true but pressing key first and modifier(s) second won't. */
-(BOOL) isKeyDownThisFrame:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags;

/** returns true if the key with the given virtual keyCode is up */
-(BOOL) isKeyUp:(KKKeyCode)keyCode;
/** returns true if the key with the given virtual keyCode and the given modifierFlags are up */
-(BOOL) isKeyUp:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags;
/** returns true if the key with the given virtual keyCode just changed from keyDown to keyUp state in the current frame */
-(BOOL) isKeyUpThisFrame:(KKKeyCode)keyCode;
/** returns true if the key with the given virtual keyCode just changed from keyDown to keyUp state in the current frame, with modifiers. The modifiers must already be down when the key is released. */
-(BOOL) isKeyUpThisFrame:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags;


#pragma mark Mouse Facade

/** returns true if any mouse button is down */
@property (nonatomic, readonly) BOOL isAnyMouseButtonDown;
/** returns true if any mouse button changed from up to down state in the current frame */
@property (nonatomic, readonly) BOOL isAnyMouseButtonDownThisFrame;
/** returns true if any mouse button changed from down to up state in the current frame */
@property (nonatomic, readonly) BOOL isAnyMouseButtonUpThisFrame;

/** returns true if the mouse button with the given button code is down */
-(BOOL) isMouseButtonDown:(KKMouseButtonCode)buttonCode;
/** returns true if the mouse button with the given button code and the given modifierFlags are down */
-(BOOL) isMouseButtonDown:(KKMouseButtonCode)buttonCode modifierFlags:(KKModifierFlag)modifierFlags;
/** returns true if the mouse button with the given button code just changed from up to down state in the current frame */
-(BOOL) isMouseButtonDownThisFrame:(KKMouseButtonCode)buttonCode;
/** returns true if the mouse button with the given button code just changed from up to down state in the current frame, with modifiers. The modifiers must already be down, eg pressing modifier(s) followed by mouse button will return true but pressing mouse button first and modifier(s) second won't. */
-(BOOL) isMouseButtonDownThisFrame:(KKMouseButtonCode)buttonCode modifierFlags:(KKModifierFlag)modifierFlags;

/** returns true if the mouse button with the given button code is up */
-(BOOL) isMouseButtonUp:(KKMouseButtonCode)buttonCode;
/** returns true if the mouse button with the given button code just changed from down to up state in the current frame */
-(BOOL) isMouseButtonUpThisFrame:(KKMouseButtonCode)buttonCode;

/** Determines if mouse moved events are accepted or not. Unless you need to track all mouse movements it is recommended to set this to NO. This is the same setting as: AcceptsMouseMovedEvents in config.lua. */
@property (nonatomic) BOOL acceptsMouseMovedEvents;
/** returns the mouse cursor location in window coordinates. If you want to track ALL mouse movements you'll have to turn on trackMouseMovedEvents (AcceptsMouseMovedEvents in config.lua). */
@property (nonatomic, readonly) CGPoint mouseLocation;
/** returns the previous mouse cursor location in window coordinates. With trackMouseMovedEvents (AcceptsMouseMovedEvents in config.lua) turned OFF (NO) the previous location will be the location of the previous mouse down, mouse up, or mouse dragged event and could be quite far away from the current mouseLocation. If you need to track previous locations accurately you need to turn on trackMouseMovedEvents. */
@property (nonatomic, readonly) CGPoint previousMouseLocation;
/** returns the delta of the current and previous mouse cursor location in window coordinates. With trackMouseMovedEvents (AcceptsMouseMovedEvents in config.lua) turned OFF (NO) the delta location will be the location of the previous mouse down, mouse up, or mouse dragged event and could be quite far away from the current mouseLocation. If you need to track delta locations accurately you need to turn on trackMouseMovedEvents. */
@property (nonatomic, readonly) CGPoint mouseLocationDelta;

/** returns the current scroll wheel delta position. Will be (0,0) if the user hasn't scrolled the wheel in the current frame. */
@property (nonatomic, readonly) CGPoint scrollWheelDelta;


#pragma mark MotionInput Facade

/** Set to YES to enable accelerometer input. When enabled, the acceleration values are updated every frame. On devices that support it (running iOS 4.0) the CMMotionManager is used to obtain acceleration data, otherwise UIAcceleration is used. If deviceMotion is set to YES, acceleration will be taken from userAcceleration property of the <a href="http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMDeviceMotion_Class/Reference/Reference.html#//apple_ref/doc/c_ref/CMDeviceMotion">CMDeviceMotion</a> class. */
@property (nonatomic) BOOL accelerometerActive;
/** Is YES if the current device has an accelerometer, and accelerometer input can be activated and used. */
@property (nonatomic, readonly) BOOL accelerometerAvailable;
/** Returns the KKAcceleration object used by KKInput internally. The acceleration object is valid during the entire lifetime of your application and its acceleration values will continue to be updated (depending on the accelerometerActive property). */
@property (nonatomic, readonly) KKAcceleration* acceleration;

/** Set to YES to enable gyroscope input. When enabled, the gyro values are updated every frame. Only available on devices that have a gyroscope (4th generation, iPad 2, and newer). Use gyroAvailable property to check for gyroscope availability on the current device. If deviceMotion is set to YES, rotationRate will be taken from rotationRate property of the <a href="http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMDeviceMotion_Class/Reference/Reference.html#//apple_ref/doc/c_ref/CMDeviceMotion">CMDeviceMotion</a> class. */
@property (nonatomic) BOOL gyroActive;
/** Is YES if the current device has a gyroscope, and gyroscope input can be activated and used. */
@property (nonatomic, readonly) BOOL gyroAvailable;
/** Returns the KKRotationRate object used by KKInput internally. The rotationRate object is valid during the entire lifetime of your application and its rotation values will continue to be updated (depending on the gyroActive property). */
@property (nonatomic, readonly) KKRotationRate* rotationRate;

/** Set to YES to enable device motion input (combined accelerometer & gyroscope -> attitude). DeviceMotion relies on the CoreMotion.framework which is only available on devices running iOS 4.0 and later, and only available on devices that have both accelerometer and gyroscope (4th generation devices and iPad 2). Use deviceMotionAvailable property to check for availability on the current device. You can get acceleration, rotation plus attitude and gravity via the deviceMotion property (KKDeviceMotion). The rotationRate and acceleration can also be obtained via the regular rotationRate and acceleration properties. */
@property (nonatomic) BOOL deviceMotionActive;
/** Is YES if the current device has both a gyroscope and accelerometer, and device motion (sensor fusion) input can be activated and used. */
@property (nonatomic, readonly) BOOL deviceMotionAvailable;
/** Returns the KKDeviceMotion object used by KKInput internally. The deviceMotion object is valid during the entire lifetime of your application and its properties will continue to be updated (depending on the deviceMotionActive property). Gives you access to acceleration, rotationRate, gravity and attitude as <a href="http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMDeviceMotion_Class/Reference/Reference.html#//apple_ref/doc/c_ref/CMDeviceMotion">CMDeviceMotion</a> object. */
@property (nonatomic, readonly) KKDeviceMotion* deviceMotion;


#pragma mark TouchInput Facade

/** Returns a CCArray of five KKTouch objects. Each object either represents a finger currently touching the screen, or it is set to be invalid.
 Note: do not rely on the array indexes for tracking individual touches/fingers. Compare the KKTouch touchID property if you need to track specific fingers. */
@property (nonatomic, readonly) CCArray* touches;
/** Returns YES if there are touches available this frame, ie if the uiTouches array contains UITouch objects. NO if uiTouches is currently empty. */
@property (nonatomic, readonly) BOOL touchesAvailable;
/** Set to YES to allow multi touch events. If NO, only the first touch will be tracked. Same as config.lua setting EnableMultiTouch. */
@property (nonatomic) BOOL multipleTouchEnabled;

/** Returns YES if any touch began this frame. */
@property (nonatomic, readonly) BOOL anyTouchBeganThisFrame;
/** Returns YES if any touch ended this frame. */
@property (nonatomic, readonly) BOOL anyTouchEndedThisFrame;
/** Returns the location of any touch, or CGPointZero if there's no touch. Useful mostly when not using multi touch and you just want to get the touch location easily. */
@property (nonatomic, readonly) CGPoint anyTouchLocation;
/** Returns the location (in cocos2d coordinates) of any touch in the given phase. If there is no finger touching the screen, CGPointZero is returned. */
-(CGPoint) locationOfAnyTouchInPhase:(KKTouchPhase)touchPhase;
/** Tests if a touch in the given touchPhase was on a node. The test is correct even if the node was rotated and/or scaled. */
-(BOOL) isAnyTouchOnNode:(CCNode*)node touchPhase:(KKTouchPhase)touchPhase;

/** The given touch will be invalidated, its touch phase is set to KKTouchPhaseLifted and all information in the KKTouch class is reset.
 However the KKTouch remains in the CCArray* touches list for the remainder of the frame, it is removed after the current frame ends.
 This allows calling the removeTouch method while iterating over the touches array. */
-(void) removeTouch:(KKTouch*)touchToBeRemoved;

#pragma mark GestureInput Facade

/** Returns YES if gesture recognizers are available. Gesture Recognizers are available on devices running iOS 3.2 or newer. */
@property (nonatomic, readonly) BOOL gesturesAvailable;

/** Enables the (one finger) tap gesture recognizer. Note that the tap recognition may be delayed if double-tap is also active. 
 See the explanation in gestureDoubleTapEnabled. */
@property (nonatomic) BOOL gestureTapEnabled;
/** Is YES if a tap gesture was recognized in this frame. */
@property (nonatomic, readonly) BOOL gestureTapRecognizedThisFrame;
/** The location of the last tap. Is updated every time a tap gesture is recognized. */
@property (nonatomic, readonly) CGPoint gestureTapLocation;

/** Enables the (one finger) double tap gesture recognizer. Note that single tap gesture will be delayed if it is active.
 This is because the single tap gesture recognizer has to wait for the double-tap recognizer to fail before it is being recognized.
 See this question for a more detailed explanation: http://stackoverflow.com/questions/3081215/ipad-gesture-recognizer-delayed-response
 */
@property (nonatomic) BOOL gestureDoubleTapEnabled;
/** Is YES if a double-tap gesture was recognized in this frame. */
@property (nonatomic, readonly) BOOL gestureDoubleTapRecognizedThisFrame;
/** The location of the last double-tap. Is updated every time a double-tap gesture is recognized. */
@property (nonatomic, readonly) CGPoint gestureDoubleTapLocation;

/** Enables the (one finger) long-press gesture recognizer. A long-press occurs when the finger stays almost stationary (default: 10 pixels)
 on the screen for a minimum time period (0.5 seconds). If these conditions are true, the long-press gesture remains active until the finger is lifted.
 That means you have to long-press an object, and when the long-press gesture is recognized the user can move the finger freely. This makes long-press
 gestures ideal for initiating a drag & drop operation. */
@property (nonatomic) BOOL gestureLongPressEnabled;
/** Is YES when the long-press gesture has began and stays true until the finger moves too far or is lifted. */
@property (nonatomic, readonly) BOOL gestureLongPressBegan;
/** Returns the location of the long-press gesture. */
@property (nonatomic, readonly) CGPoint gestureLongPressLocation;

/** Enables the (one finger) swipe gesture recognizer. A swipe occurs when moving the finger mostly in one direction. 
 The swipe can be slow over a short distance or fast over a long distance. Since the pan gesture is similar to the swipe
 gesture, both will be recognized simulataneously if swipe and pan gestures are enabled at the same time. */
@property (nonatomic) BOOL gestureSwipeEnabled;
/** Is YES if a swipe gesture was recognized in this frame. */
@property (nonatomic, readonly) BOOL gestureSwipeRecognizedThisFrame;
/** The start location of the swipe. Use locationOfAnyTouchInPhase method with phase of KKTouchPhaseCancelled to get the end location of the swipe. */
@property (nonatomic, readonly) CGPoint gestureSwipeLocation;
/** The direction of the swipe. The direction is already converted to the current device orientation, so that left/right/up/down are relative
 to how the user is holding the device and up is always up, left is always to the left, and so on. */
@property (nonatomic, readonly) KKSwipeGestureDirection gestureSwipeDirection;

/** Enables the (one finger) pan gesture recognizer. A pan occurs when the finger touches the screen and starts moving within a short amount
 of time (otherwise it may be recognized as a long press gesture instead). Since the pan gesture is similar to the swipe gesture, the swipe and pan gestures
 will be recognized simultaneously if both are enabled at the same time. */
@property (nonatomic) BOOL gesturePanEnabled;
/** Is YES when the pan gesture has began and stays true until the finger is lifted. */
@property (nonatomic, readonly) BOOL gesturePanBegan;
/** Returns the location of the pan gesture. */
@property (nonatomic, readonly) CGPoint gesturePanLocation;
/** Returns the translation of the pan gesture, ie how far (in points) the finger has moved from the point where the pan gesture began. For example,
 if translation is -50, 20 then the finger has moved 50 points to the left and 20 points upwards from its initial position.
 You can set the translation at any time, for example to reset it to (0,0). Note that setting the translation resets the gesturePanVelocity. */
@property (nonatomic) CGPoint gesturePanTranslation;
/** Returns the velocity of the pan gesture in points per frame. If you need points per second (like UIPanGestureRecognizer returns), 
 simply multiply the x and y coordinates with the MaxFrameRate setting (ie 60). */
@property (nonatomic, readonly) CGPoint gesturePanVelocity;

/** Enables the (two finger) rotation gesture recognizer. A rotation occurs when two fingers touch the screen and the fingers move in opposing directions in a circular motion.
 The rotation gesture ends when both fingers are lifted. Can be used simultaneously with the pinch gesture recognizer for a rotate & scale action.
 
 It is recommended to not enable the pan or long press gestures simultaneously with the rotation gesture,
 since the pan and long press gestures will make it difficult for the user to correctly initiate the rotation gesture. 
 If the pan gesture is enabled with rotation, the user must place both fingers on the screen before moving either one more than 10 pixels. This is tricky to achieve.
 If the long press gesture is enabled, the user must place both fingers on the screen within the time it takes to initiate a long press (0.5 seconds). 
 This is feasible but can still be confusing. */
@property (nonatomic) BOOL gestureRotationEnabled;
/** Is YES when the rotation gesture has began and stays true until both fingers are lifted. */
@property (nonatomic, readonly) BOOL gestureRotationBegan;
/** Returns the location of the rotation gesture, which is the middle point between the two fingers. */
@property (nonatomic, readonly) CGPoint gestureRotationLocation;
/** Returns the rotation angle in Cocos2D direction values (an angle in the range 0 to 360 degrees). 
 If you change the rotation angle the rotation velocity will be reset. */
@property (nonatomic) float gestureRotationAngle;
/** Returns the velocity of the rotation gesture in degrees per frame. */
@property (nonatomic, readonly) float gestureRotationVelocity;

/** Enables the (two finger) pinch gesture recognizer. A pinch occurs when two fingers touch the screen and move either towards or away from each other.
 The rotation gesture ends when both fingers are lifted. Can be used simultaneously with the rotation gesture recognizer for a rotate & scale action.
 
 It is recommended to not enable the pan or long press gestures simultaneously with the pinch gesture,
 since the pan and long press gestures will make it difficult for the user to correctly initiate the pinch gesture. 
 If the pan gesture is enabled, the user must place both fingers on the screen before moving either one more than 10 pixels. This is tricky to achieve.
 If the long press gesture is enabled, the user must place both fingers on the screen within the time it takes to initiate a long press (0.5 seconds). 
 This is feasible but can still be confusing. */
@property (nonatomic) BOOL gesturePinchEnabled;
/** Is YES when the pinch gesture has began and stays true until both fingers are lifted. */
@property (nonatomic, readonly) BOOL gesturePinchBegan;
/** Returns the location of the pinch gesture, which is the middle point between the two fingers. */
@property (nonatomic, readonly) CGPoint gesturePinchLocation;
/** Returns the scale factor relative to the two fingers. 
 If you change the scale factor the pinch velocity will be reset. */
@property (nonatomic) float gesturePinchScale;
/** Returns the velocity of the pinch gesture in scale factor per frame. */
@property (nonatomic, readonly) float gesturePinchVelocity;


#if KK_PLATFORM_IOS
/** Returns the UISwipeGestureRecognizer for the given direction if enabled, otherwise returns nil. */
-(UISwipeGestureRecognizer*) swipeGestureRecognizerForDirection:(KKSwipeGestureDirection)direction;
/** Returns the UITapGestureRecognizer if enabled, otherwise returns nil. */
@property (nonatomic, readonly) UITapGestureRecognizer* tapGestureRecognizer;
/** Returns the UITapGestureRecognizer for double-taps if enabled, otherwise returns nil. */
@property (nonatomic, readonly) UITapGestureRecognizer* doubleTapGestureRecognizer;
/** Returns the UILongPressGestureRecognizer if enabled, otherwise returns nil. */
@property (nonatomic, readonly) UILongPressGestureRecognizer* longPressGestureRecognizer;
/** Returns the UIPanGestureRecognizer if enabled, otherwise returns nil. */
@property (nonatomic, readonly) UIPanGestureRecognizer* panGestureRecognizer;
/** Returns the UIRotationGestureRecognizer if enabled, otherwise returns nil. */
@property (nonatomic, readonly) UIRotationGestureRecognizer* rotationGestureRecognizer;
/** Returns the UIPinchGestureRecognizer if enabled, otherwise returns nil. */
@property (nonatomic, readonly) UIPinchGestureRecognizer* pinchGestureRecognizer;
#elif KK_PLATFORM_MAC
-(id) swipeGestureRecognizerForDirection:(int)direction;
@property (nonatomic, readonly) id tapGestureRecognizer;
@property (nonatomic, readonly) id doubleTapGestureRecognizer;
@property (nonatomic, readonly) id longPressGestureRecognizer;
@property (nonatomic, readonly) id panGestureRecognizer;
@property (nonatomic, readonly) id rotationGestureRecognizer;
@property (nonatomic, readonly) id pinchGestureRecognizer;
#endif

-(void) tick:(ccTime)delta;

@end
