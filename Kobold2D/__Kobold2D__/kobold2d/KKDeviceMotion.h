/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"

#import "KKAcceleration.h"
#import "KKRotationRate.h"
#if KK_PLATFORM_IOS
#import <CoreMotion/CoreMotion.h>
#endif

/** Contains the deviceMotion data. DeviceMotion is only available on devices running iOS 4.0 or newer. The rotationRate and attitude are only available on 4th generation
 iPhone & iPod touch devices and newer, and iPad 2 and newer.
 
 See the CMDeviceMotion class reference: http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMDeviceMotion_Class/Reference/Reference.html#//apple_ref/doc/c_ref/CMDeviceMotion */
@interface KKDeviceMotion : NSObject
{
@private
	KKAcceleration* acceleration;
	KKAcceleration* gravity;
	KKRotationRate* rotationRate;
#if KK_PLATFORM_IOS
	CMAttitude* attitude;
#else
	id attitude;
#endif
	
	double roll, pitch, yaw;
}

/** The KKAcceleration object used by KKDeviceMotion to store user acceleration. */
@property (nonatomic, readonly) KKAcceleration* acceleration;
/** The KKAcceleration object used by KKDeviceMotion to store the gravity acceleration vector. */
@property (nonatomic, readonly) KKAcceleration* gravity;
/** The KKRotationRate object used by KKDeviceMotion to store the rotation rate reported by gyroscope. */
@property (nonatomic, readonly) KKRotationRate* rotationRate;

/** Returns the CMAttitude object used by KKDeviceMotion. Is only non-nil when KKInput deviceMotionActive=YES. Contains the attitude as euler angles (roll, pitch, yaw), rotation matrix (CMRotationMatrix), or quaternion (CMQuaternion). On Mac attitude is of type id. */
#if KK_PLATFORM_IOS
@property (nonatomic, copy) CMAttitude* attitude;
#else
@property (nonatomic, copy) id attitude;
#endif

/** The roll euler angle of CMAttitude. */
@property (nonatomic, readonly) double roll;
/** The pitch euler angle of CMAttitude. */
@property (nonatomic, readonly) double pitch;
/** The yaw euler angle of CMAttitude. */
@property (nonatomic, readonly) double yaw;

/** Sets all internal values to 0. Call this method after an interruption in your application, for example the pause menu or starting a new level. */
-(void) reset;

@end
