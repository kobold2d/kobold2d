/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import "KKInput.h"

/** The Kobold2D equivalent of the UITouch class contains the same information as a UITouch. The locations are already converted
 to the Cocos2D view coordinate space, you should *not* call convertToGL on the KKTouch locations. Touches are pooled to avoid frequent alloc/dealloc cycles as fingers
 touch the screen and are lifted back up again.
 
 The touchID property is a unique identifier for a particular finger that touches the screen. 
 The touchID is simply the UITouch* pointer cast to NSUInteger, so you can get to the UITouch* if needed by casting touchID to UITouch*: UITouch* uiTouch = (UITouch*)(kkTouch.touchID);
 */
@interface KKTouch : NSObject
{
@private
	CGPoint location;
	CGPoint previousLocation;
	NSUInteger tapCount;
	NSUInteger touchID;
	NSTimeInterval timestamp;
	KKTouchPhase phase;

@public
	NSUInteger touchBeganFrame;
	BOOL isInvalid;
	BOOL didPhaseChange;
}

/** An identifier that uniquely identifies one particular finger while it is touching. Used to track fingers over several frames. */
@property (nonatomic, readonly) NSUInteger touchID;
/** The current location of the touch, already converted to Cocos2D view coordinates and device orientation. */
@property (nonatomic, readonly) CGPoint location;
/** The previous (frame's) location of the touch, already converted to Cocos2D view coordinates and device orientation. */
@property (nonatomic, readonly) CGPoint previousLocation;
/** How often the finger was tapped for this touch. */
@property (nonatomic, readonly) NSUInteger tapCount;
/** The timestamp when the UITouch was last updated. */
@property (nonatomic, readonly) NSTimeInterval timestamp;
/** The KKTouchPhase the touch is currently in. */
@property (nonatomic, readonly) KKTouchPhase phase;


-(void) setTouchWithLocation:(CGPoint)location 
			previousLocation:(CGPoint)previousLocation 
					tapCount:(NSUInteger)tapCount 
				   timestamp:(NSTimeInterval)timestamp
					   phase:(KKTouchPhase)phase;

-(void) invalidate;
-(void) setValidWithID:(NSUInteger)touchID;

-(void) setTouchPhase:(KKTouchPhase)phase_;

@end
