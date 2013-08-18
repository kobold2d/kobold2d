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
#import "KKDeviceMotion.h"

#if KK_PLATFORM_IOS
#import <CoreMotion/CoreMotion.h>
#endif


@interface KKInputMotion : NSObject
#if KK_PLATFORM_IOS
	<UIAccelerometerDelegate>
#endif
{
@private
	id motionManager;
	KKDeviceMotion* deviceMotion;
	BOOL accelerometerActive;
	BOOL gyroActive;
	BOOL deviceMotionActive;
}

#if KK_PLATFORM_IOS
-(void) resetInputStates;
#endif

// accelerometer
@property (nonatomic) BOOL accelerometerActive;
@property (nonatomic, readonly) BOOL accelerometerAvailable;
@property (nonatomic, readonly) KKAcceleration* acceleration;

// gyroscope
@property (nonatomic) BOOL gyroActive;
@property (nonatomic, readonly) BOOL gyroAvailable;
@property (nonatomic, readonly) KKRotationRate* rotationRate;

// device motion
@property (nonatomic) BOOL deviceMotionActive;
@property (nonatomic, readonly) BOOL deviceMotionAvailable;
@property (nonatomic, readonly) KKDeviceMotion* deviceMotion;

@end
