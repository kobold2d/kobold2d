/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"

/** Contains the current gyroscope values. The gyroscope is only available on 4th generation iPhone & iPod touch devices and newer, and iPad 2 and newer.
 
 See Apple's Event Handling Guide for more info:
 http://developer.apple.com/library/ios/#documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/MotionEvents/MotionEvents.html#//apple_ref/doc/uid/TP40009541-CH4-SW1
 */
@interface KKRotationRate : NSObject
{
@private
	NSTimeInterval timestamp;
	double x, y, z;
}

/** The timeStamp when the gyroscope was last sampled. */
@property (nonatomic, readonly) NSTimeInterval timestamp;

/** Rotation rate in radians per second. */
@property (nonatomic, readonly) double x;
/** Rotation rate in radians per second. */
@property (nonatomic, readonly) double y;
/** Rotation rate in radians per second. */
@property (nonatomic, readonly) double z;

/** Sets all rotationRate values to 0, including internal states. Call this method after an interruption in your application, for example the pause menu or starting a new level. */
-(void) reset;

-(void) setRotationRateWithTimestamp:(NSTimeInterval)ts x:(double)x y:(double)y z:(double)z;

@end
