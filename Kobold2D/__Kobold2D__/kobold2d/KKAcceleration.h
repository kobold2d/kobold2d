/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"

#if KK_PLATFORM_IOS
#import <CoreMotion/CoreMotion.h>
#endif

/** Contains the current accelerometer values. You can access the raw values as reported by the accelerometer, 
 the smoothed values which have a low-pass filter applied to them (reacts slowly to sudden acceleration, averages the continous acceleration),
 or the instantaneous values which have a high-pass filter applied to them (reacts mostly to sudden acceleration, little to continuous acceleration).
 The filtering algorithm for smoothed and instantaneous values is only run once per frame, and only when you access one of the smoothed or instantaneous properties.

 See the Event Handling Guide for iOS for more information about high and low pass filtering applied to the smoothed and instantaneous values: 
 http://developer.apple.com/library/ios/#documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/MotionEvents/MotionEvents.html#//apple_ref/doc/uid/TP40009541-CH4-SW1

 Acceleration along the axis' is in G's (gravitational force). According to Apple: "A G is a unit of gravitation force equal to that exerted by the earth’s gravitational field (9.81 m s−2)."
 */
@interface KKAcceleration : NSObject
{
@private
	NSTimeInterval timestamp;
	double rawX, rawY, rawZ;
	double smoothedX, smoothedY, smoothedZ;
	double instantaneousX, instantaneousY, instantaneousZ;
	double filteringFactor;
	
	//double calibrationX, calibrationY, calibrationZ;
	
	BOOL lowPassFilterApplied;
	BOOL highPassFilterApplied;
}

/** The timeStamp when the accelerometer was last sampled. */
@property (nonatomic, readonly) NSTimeInterval timestamp;
/** Raw acceleration in G's along the x axis. Value is already transformed to current device orientation. */
@property (nonatomic, readonly) double rawX;
/** Raw acceleration in G's along the y axis. Value is already transformed to current device orientation. */
@property (nonatomic, readonly) double rawY;
/** Raw acceleration in G's along the z axis. */
@property (nonatomic, readonly) double rawZ;
/** Same as rawX. */
@property (nonatomic, readonly) double x;
/** Same as rawY. */
@property (nonatomic, readonly) double y;
/** Same as rawZ. */
@property (nonatomic, readonly) double z;

/** Smoothed value using a low-pass filter influenced by the filteringFactor property. Smoothed values are averaged over several frames and responds barely to sudden changes of motion (eg shaking or dropping the device). Value is already transformed to current device orientation. */
@property (nonatomic, readonly) double smoothedX;
/** Smoothed value using a low-pass filter influenced by the filteringFactor property. Smoothed values are averaged over several frames and responds barely to sudden changes of motion (eg shaking or dropping the device). Value is already transformed to current device orientation. */
@property (nonatomic, readonly) double smoothedY;
/** Smoothed value using a low-pass filter influenced by the filteringFactor property. Smoothed values are averaged over several frames and responds barely to sudden changes of motion (eg shaking or dropping the device). */
@property (nonatomic, readonly) double smoothedZ;

/** Instantaneous acceleration value obtained from a high-pass filter. This value approximates the instant motion of the device with the constant effect of gravity filtered out, and reacts strongy to sudden changes of motion (eg shaking or dropping the device). Value is already transformed to current device orientation. */
@property (nonatomic, readonly) double instantaneousX;
/** Instantaneous acceleration value obtained from a high-pass filter. This value approximates the instant motion of the device with the constant effect of gravity filtered out, and reacts strongy to sudden changes of motion (eg shaking or dropping the device). Value is already transformed to current device orientation. */
@property (nonatomic, readonly) double instantaneousY;
/** Instantaneous acceleration value obtained from a high-pass filter. This value approximates the instant motion of the device with the constant effect of gravity filtered out, and reacts strongy to sudden changes of motion (eg shaking or dropping the device). */
@property (nonatomic, readonly) double instantaneousZ;


/** The filtering factor used for high & low pass filtering. Determines how strongly raw values affect the filtered acceleration values. A filteringFactor of 0.1f means that only 10% of the raw values per update will be added to the running acceleration values. In other words the values are smoothed out over 10 updates (frames). */
@property (nonatomic) double filteringFactor;


/** Sets all acceleration values to 0, including internal states. Call this method after an interruption in your application, for example the pause menu or starting a new level. */
-(void) reset;

//-(void) calibrate;

-(void) setAccelerationWithTimestamp:(NSTimeInterval)ts x:(double)x y:(double)y z:(double)z;

@end
