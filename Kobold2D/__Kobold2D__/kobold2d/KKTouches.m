/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKTouches.h"

@interface KKTouches (PrivateMethods)
-(void) updateTouches;
@end

@implementation KKTouches

// surplus touches because there may be overlap by a touch that ends or is cancelled while in the same frame
// new touches may begin
const NSUInteger kTouchesPoolSize = 10;

-(id) init
{
    if ((self = [super init]))
	{
		touchesPool = [[CCArray alloc] initWithCapacity:kTouchesPoolSize];
		for (NSUInteger i = 0; i < kTouchesPoolSize; i++)
		{
			KKTouch* touch = [[[KKTouch alloc] init] autorelease];
			[touchesPool addObject:touch];
		}
		
		touches = [[CCArray alloc] initWithCapacity:kTouchesPoolSize];
		uiTouches = [[CCArray alloc] initWithCapacity:kTouchesPoolSize];
		touchesToBeRemoved = [[CCArray alloc] initWithCapacity:kTouchesPoolSize];

		[[CCDirector sharedDirector].scheduler scheduleUpdateForTarget:self priority:INT_MAX paused:NO];
    }
    
    return self;
}

-(void) dealloc
{
	[[CCDirector sharedDirector].scheduler unscheduleAllForTarget:self];
	
	[touches release];
	[touchesPool release];
	[touchesToBeRemoved release];
	[uiTouches release];
	
	[super dealloc];
}

-(KKTouch*) getInactiveTouchFromPool
{
	KKTouch* touch;
	CCARRAY_FOREACH(touchesPool, touch)
	{
		if (touch && touch->isInvalid)
		{
			return touch;
		}
	}
	
	return nil;
}

-(KKTouch*) getTouchByID:(NSUInteger)touchID
{
	KKTouch* touch;
	CCARRAY_FOREACH(touches, touch)
	{
		if (touch.touchID == touchID)
		{
			return touch;
		}
	}
	
	return nil;
}

#ifdef KK_PLATFORM_IOS

-(void) addTouches:(NSSet*)touchesSet
{
	for (UITouch* uiTouch in touchesSet)
	{
		[uiTouches addObject:uiTouch];
		
		KKTouch* touch = [self getInactiveTouchFromPool];
		[touch setValidWithID:(NSUInteger)uiTouch];
		[touches addObject:touch];
	}
	
	[self updateTouches];
}

-(void) updateMovedTouches:(NSSet*)touchesSet
{
	for (UITouch* uiTouch in touchesSet)
	{
		KKTouch* touch = [self getTouchByID:(NSUInteger)uiTouch];
		[touch setTouchPhase:KKTouchPhaseMoved];
	}
}

-(void) removeTouch:(KKTouch*)touch invalidate:(BOOL)invalidate
{
	if (touch)
	{
		if (invalidate)
		{
			[touch invalidate];
		}
		[touchesToBeRemoved addObject:touch];
	}
}

-(void) removeTouches:(NSSet*)touchesSet
{
	for (UITouch* uiTouch in touchesSet) 
	{
		// must delay removal of the touch from list because player needs to be able to check for
		// touches that ended or were cancelled in this frame
		KKTouch* touch = [self getTouchByID:(NSUInteger)uiTouch];
		[self removeTouch:touch invalidate:NO];
	}

	[self updateTouches];
}

-(void) removeAllTouches
{
	KKTouch* touch;
	CCARRAY_FOREACH(touches, touch)
	{
		UITouch* uiTouch = (UITouch*)(touch.touchID);
		[uiTouches removeObject:uiTouch];
		[touches removeObject:touch];
		[touch invalidate];
	}
}

#endif

-(void) update:(ccTime)delta
{
#if KK_PLATFORM_IOS
	// remove any touches that are no longer valid after this frame
	if ([touchesToBeRemoved count] > 0)
	{
		KKTouch* touch;
		CCARRAY_FOREACH(touchesToBeRemoved, touch)
		{
			UITouch* uiTouch = (UITouch*)(touch.touchID);
			[uiTouches removeObject:uiTouch];
			[touches removeObject:touch];
			[touch invalidate];
		}
		[touchesToBeRemoved removeAllObjects];
	}

	touchesNeedUpdate = YES;
#endif
}

-(void) updateTouches
{
#if KK_PLATFORM_IOS
	touchesNeedUpdate = NO;

	CCDirector* director = [CCDirector sharedDirector];
	UIView* glView = [director view];
	
	KKTouch* touch;
	CCARRAY_FOREACH(touches, touch)
	{
		if (touch)
		{
			UITouch* uiTouch = (UITouch*)(touch.touchID);
			if (uiTouch)
			{
				[touch setTouchWithLocation:[director convertToGL:[uiTouch locationInView:glView]]
						   previousLocation:[director convertToGL:[uiTouch previousLocationInView:glView]]
								   tapCount:[uiTouch tapCount]
								  timestamp:[uiTouch timestamp]
									  phase:(KKTouchPhase)[uiTouch phase]];
			}
		}
	}
#endif
}

-(CCArray*) touches
{
	if (touchesNeedUpdate)
	{
		[self updateTouches];
	}
	
	return touches;
}

@end
