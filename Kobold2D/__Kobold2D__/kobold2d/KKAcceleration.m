/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKAcceleration.h"
#import "KKAppDelegate.h"
#import "cocos2d.h"

@interface KKAcceleration (PrivateMethods)
@end

@implementation KKAcceleration

@synthesize timestamp, rawX, rawY, rawZ, filteringFactor;
@dynamic x, y, z;

-(id) init
{
	if ((self = [super init]))
	{
		filteringFactor = 0.1;
	}
	return self;
}

-(void) reset
{
	timestamp = 0;
	rawX = rawY = rawZ = 0;
	smoothedX = smoothedY = smoothedZ = 0;
	instantaneousX = instantaneousY = instantaneousZ = 0;
	//[self calibrate];
	lowPassFilterApplied = NO;
	highPassFilterApplied = NO;
}

-(void) applyLowPassFilter
{
	// only filter once per update
	lowPassFilterApplied = YES;
	smoothedX = (rawX * filteringFactor) + (smoothedX * (1.0 - filteringFactor));
	smoothedY = (rawY * filteringFactor) + (smoothedY * (1.0 - filteringFactor));
	smoothedZ = (rawZ * filteringFactor) + (smoothedZ * (1.0 - filteringFactor));
}

-(void) applyHighPassFilter
{
	// only filter once per update
	highPassFilterApplied = YES;
	instantaneousX = rawX - ((rawX * filteringFactor) + (instantaneousX * (1.0 - filteringFactor)));
	instantaneousY = rawY - ((rawY * filteringFactor) + (instantaneousY * (1.0 - filteringFactor)));
	instantaneousZ = rawZ - ((rawZ * filteringFactor) + (instantaneousZ * (1.0 - filteringFactor)));
}

-(double) x
{
	return rawX;
}
-(double) y
{
	return rawY;
}
-(double) z
{
	return rawZ;
}

-(double) smoothedX
{
	if (lowPassFilterApplied == NO)
	{
		[self applyLowPassFilter];
	}
	return smoothedX;
}
-(double) smoothedY
{
	if (lowPassFilterApplied == NO)
	{
		[self applyLowPassFilter];
	}
	return smoothedY;
}
-(double) smoothedZ
{
	if (lowPassFilterApplied == NO)
	{
		[self applyLowPassFilter];
	}
	return smoothedZ;
}

-(double) instantaneousX
{
	if (highPassFilterApplied == NO)
	{
		[self applyHighPassFilter];
	}
	return instantaneousX;	
}
-(double) instantaneousY
{
	if (highPassFilterApplied == NO)
	{
		[self applyHighPassFilter];
	}
	return instantaneousY;	
}
-(double) instantaneousZ
{
	if (highPassFilterApplied == NO)
	{
		[self applyHighPassFilter];
	}
	return instantaneousZ;	
}

-(void) setAccelerationWithTimestamp:(NSTimeInterval)ts x:(double)x y:(double)y z:(double)z
{
#if KK_PLATFORM_IOS
	lowPassFilterApplied = NO;
	highPassFilterApplied = NO;
	timestamp = ts;
	rawZ = z;
	
	// transform X/Y to current device orientation
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
	switch (appDelegate.rootViewController.interfaceOrientation)
	{
		case UIInterfaceOrientationPortrait:
			rawX = x;
			rawY = y;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			rawX = -x;
			rawY = -y;
			break;
		case UIInterfaceOrientationLandscapeRight:
			rawX = -y;
			rawY = x;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			rawX = y;
			rawY = -x;
			break;
			
		default:
			break;
	}
	
#endif
}

@end
