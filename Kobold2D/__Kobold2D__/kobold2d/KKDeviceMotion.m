/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKDeviceMotion.h"

@interface KKDeviceMotion (PrivateMethods)
@end

@implementation KKDeviceMotion

@synthesize acceleration, gravity, rotationRate, attitude, roll, pitch, yaw;

-(id) init
{
    if ((self = [super init]))
	{
		acceleration = [[KKAcceleration alloc] init];
		gravity = [[KKAcceleration alloc] init];
		rotationRate = [[KKRotationRate alloc] init];
		attitude = nil;
    }
    
    return self;
}

-(void) dealloc
{
	[acceleration release];
	[gravity release];
	[rotationRate release];
	[attitude release];
	[super dealloc];
}

-(void) reset
{
	[acceleration reset];
	[gravity reset];
	[rotationRate reset];
	
	[attitude release];
	attitude = nil;
}

-(double) roll
{
	return [attitude roll];
}
-(double) pitch
{
	return [attitude pitch];
}
-(double) yaw
{
	return [attitude yaw];
}

@end
