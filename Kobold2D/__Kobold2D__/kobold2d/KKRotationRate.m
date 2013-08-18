/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKRotationRate.h"

@interface KKRotationRate (PrivateMethods)
@end

@implementation KKRotationRate

@synthesize timestamp, x, y, z;

-(void) reset
{
	timestamp = 0;
	x = y = z = 0;
}

-(void) setRotationRateWithTimestamp:(NSTimeInterval)ts x:(double)x_ y:(double)y_ z:(double)z_
{
	timestamp = ts;
	x = x_;
	y = y_;
	z = z_;
}


@end
