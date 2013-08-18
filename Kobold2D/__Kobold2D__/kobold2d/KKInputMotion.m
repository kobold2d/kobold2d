/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKInputMotion.h"

@interface KKInputMotion (PrivateMethods)
@end

@implementation KKInputMotion

#if KK_PLATFORM_IOS

-(id) init
{
    if ((self = [super init]))
	{
		// Don't use the motionManager in Simulator builds because iSimulate doesn't work with motion manager.
		// By leaving motionManager uninitialized KKInputMotion falls back to using UIAccelerometer.
#if KK_PLATFORM_IOS_DEVICE
		// check if the motion manager class is available (available since iOS 4.0)
		Class motionManagerClass = NSClassFromString(@"CMMotionManager");
		if (motionManagerClass)
		{
			motionManager = [[motionManagerClass alloc] init];
		}
#endif
		
		deviceMotion = [[KKDeviceMotion alloc] init];
		
		if (motionManager)
		{
			[[CCDirector sharedDirector].scheduler scheduleUpdateForTarget:self priority:INT_MIN paused:NO];
		}
    }
    
    return self;
}

-(void) dealloc
{
	if (motionManager)
	{
		[[CCDirector sharedDirector].scheduler unscheduleAllForTarget:self];
	}

	[deviceMotion release];
	[motionManager release];
	
	[super dealloc];
}

-(void) resetInputStates
{
	[deviceMotion reset];
}

-(void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)accel
{
	[deviceMotion.acceleration setAccelerationWithTimestamp:accel.timestamp x:accel.x y:accel.y z:accel.z];
}

#endif // KK_PLATFORM_IOS



#pragma mark Accelerometer Private

-(void) updateAcceleration
{
#if KK_PLATFORM_IOS
	CMAccelerometerData* data = [motionManager accelerometerData];
	CMAcceleration accel = [data acceleration];
	[deviceMotion.acceleration setAccelerationWithTimestamp:[data timestamp] x:accel.x y:accel.y z:accel.z];
#endif
}

#pragma mark Accelerometer Facade

-(BOOL) accelerometerActive
{
	return accelerometerActive;
}
-(void) setAccelerometerActive:(BOOL)active
{
#if KK_PLATFORM_IOS
	if (accelerometerActive != active)
	{
		accelerometerActive = active;
		
		if (motionManager)
		{
			if (accelerometerActive)
			{
				// make sure we don't read accelerometer values twice
				[self setDeviceMotionActive:NO];

				[motionManager startAccelerometerUpdates];
				[self updateAcceleration];
			}
			else
			{
				[motionManager stopAccelerometerUpdates];
				[deviceMotion.acceleration reset];
			}
		}
	}
#else
	accelerometerActive = NO;
#endif // KK_PLATFORM_IOS
}
-(BOOL) accelerometerAvailable
{
#if KK_PLATFORM_IOS
	if (motionManager)
	{
		return (BOOL)[motionManager isAccelerometerAvailable];
	}
	return YES; // emulated via UIAcceleration and iSimulate on Simulator
#else
	return NO;
#endif
}
-(KKAcceleration*) acceleration
{
	return deviceMotion.acceleration;
}



#pragma mark Gyroscope Private

-(void) updateRotationRate
{
#if KK_PLATFORM_IOS
	CMGyroData* data = [motionManager gyroData];
	CMRotationRate rate = [data rotationRate];
	[deviceMotion.rotationRate setRotationRateWithTimestamp:[data timestamp] x:rate.x y:rate.y z:rate.z];
#endif
}

#pragma mark Gyroscope Facade

-(BOOL) gyroActive
{
	return gyroActive;
}
-(void) setGyroActive:(BOOL)active
{
#if KK_PLATFORM_IOS
	if (motionManager && gyroActive != active)
	{
		gyroActive = active;
		if (gyroActive)
		{
			// make sure we don't read gyro values twice
			[self setDeviceMotionActive:NO];

			[motionManager startGyroUpdates];
			[self updateRotationRate];
		}
		else
		{
			[motionManager stopGyroUpdates];
			[deviceMotion.rotationRate reset];
		}
	}
#endif // KK_PLATFORM_IOS
}
-(BOOL) gyroAvailable
{
#if KK_PLATFORM_IOS
	return (BOOL)[motionManager isGyroAvailable];
#else
	return NO;
#endif
}
-(KKRotationRate*) rotationRate
{
	return deviceMotion.rotationRate;
}



#pragma mark DeviceMotion Private

-(void) updateDeviceMotion
{
#if KK_PLATFORM_IOS
	CMDeviceMotion* data = [(CMMotionManager*)motionManager deviceMotion];
	NSTimeInterval ts = [data timestamp];
	
	CMAcceleration accel = [data userAcceleration];
	[deviceMotion.acceleration setAccelerationWithTimestamp:ts x:accel.x y:accel.y z:accel.z];

	CMAcceleration gravity = [data gravity];
	[deviceMotion.gravity setAccelerationWithTimestamp:ts x:gravity.x y:gravity.y z:gravity.z];

	CMRotationRate rate = [data rotationRate];
	[deviceMotion.rotationRate setRotationRateWithTimestamp:ts x:rate.x y:rate.y z:rate.z];

	deviceMotion.attitude = data.attitude;
#endif	
}

#pragma mark DeviceMotion Facade

-(BOOL) deviceMotionActive
{
	return deviceMotionActive;
}
-(void) setDeviceMotionActive:(BOOL)active
{
#if KK_PLATFORM_IOS
	if (motionManager && deviceMotionActive != active)
	{
		deviceMotionActive = active;
		if (deviceMotionActive)
		{
			// make sure we don't read accelerometer & gyro values twice
			[self setAccelerometerActive:NO];
			[self setGyroActive:NO];
			
			[motionManager startDeviceMotionUpdates];
			[self updateDeviceMotion];
		}
		else
		{
			[motionManager stopDeviceMotionUpdates];
			[deviceMotion reset];
		}
	}
#endif // KK_PLATFORM_IOS
}
-(BOOL) deviceMotionAvailable
{
#if KK_PLATFORM_IOS
	return (BOOL)[motionManager isDeviceMotionAvailable];
#else
	return NO;
#endif
}
-(KKDeviceMotion*) deviceMotion
{
	return deviceMotion;
}



#pragma mark update

-(void) update:(ccTime)delta
{
	if (deviceMotionActive)
	{
		[self updateDeviceMotion];
	}
	else
	{
		if (accelerometerActive)
		{
			[self updateAcceleration];
		}
		
		if (gyroActive)
		{
			[self updateRotationRate];
		}
	}
}

@end
