/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKTouch.h"

@interface KKTouch (PrivateMethods)
@end

@implementation KKTouch

@synthesize location, previousLocation, tapCount, timestamp, phase, touchID;

-(id) init
{
    if ((self = [super init]))
	{
		phase = KKTouchPhaseLifted;
		didPhaseChange = NO;
		isInvalid = YES;
		touchBeganFrame = INT_MAX;
    }
    
    return self;
}

-(void) setTouchWithLocation:(CGPoint)loc previousLocation:(CGPoint)prevLoc tapCount:(NSUInteger)taps timestamp:(NSTimeInterval)ts phase:(KKTouchPhase)ph
{
	location = loc;
	previousLocation = prevLoc;
	tapCount = taps;
	timestamp = ts;
	didPhaseChange = (phase != ph);
	phase = ph;
	isInvalid = NO;

	if (didPhaseChange)
	{
		if (phase == KKTouchPhaseBegan)
		{
			touchBeganFrame = [CCDirector sharedDirector].frameCount;
		}
	}
}

-(void) setValidWithID:(NSUInteger)ID
{
	isInvalid = NO;
	touchID = ID;
}

-(void) invalidate
{
	isInvalid = YES;
	touchID = 0;
	touchBeganFrame = INT_MAX;
	phase = KKTouchPhaseLifted;
	didPhaseChange = NO;
	location = CGPointZero;
	previousLocation = CGPointZero;
	tapCount = 0;
	timestamp = 0;
}

-(void) setTouchPhase:(KKTouchPhase)phase_
{
	phase = phase_;
}

@end
