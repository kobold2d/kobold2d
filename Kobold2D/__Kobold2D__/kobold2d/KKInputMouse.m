/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Availability.h>
#import "KKInputMouse.h"
#import "KKInput.h"
#import "kobold2d_version.h"

@implementation KKInputMouse

@synthesize keyStates, locationInWindow, previousLocationInWindow, scrollWheelDelta, hasPreciseScrollingDeltas;

#if KK_PLATFORM_MAC

-(id) init
{
    if ((self = [super init]))
	{
		keyStates = [[KKKeyStates alloc] init];
		
		[[CCDirector sharedDirector].eventDispatcher addMouseDelegate:self priority:0];
    }
    
    return self;
}

-(void) dealloc
{
	[[CCDirector sharedDirector].eventDispatcher removeMouseDelegate:self];
	
	[keyStates release];
	
	[super dealloc];
}

-(void) resetInputStates
{
	[keyStates reset];
	isDragging = NO;
	scrollWheelDelta = CGPointZero;
}

#pragma mark Helper methods

-(UInt16) buttonCodeFromEvent:(NSEvent*)event
{
	return (UInt16)([event buttonNumber] + (([event clickCount] > 1) ? KKMouseButtonDoubleClickOffset : 0));
}

-(void) updateMouseLocationFromEvent:(NSEvent*)event
{
	previousLocationInWindow = locationInWindow;
	// separate assignments prevent build error in Mac 32-bit builds (CGPoint != NSPoint)
	locationInWindow.x = [event locationInWindow].x;
	locationInWindow.y = [event locationInWindow].y;
}

#pragma mark Mouse Down events

-(void) mouseButtonDownEvent:(NSEvent*)event
{
	//CCLOG(@"mouse down: %@ --- button number: %li --- clickCount: %li", event, [event buttonNumber], [event clickCount]);
	[keyStates addKeyDown:[self buttonCodeFromEvent:event]];
	[self updateMouseLocationFromEvent:event];
}

-(BOOL) ccMouseDown:(NSEvent*)event
{
	[self mouseButtonDownEvent:event];
	return NO;
}

-(BOOL) ccRightMouseDown:(NSEvent*)event
{
	[self mouseButtonDownEvent:event];
	return NO;
}

-(BOOL) ccOtherMouseDown:(NSEvent*)event
{
	[self mouseButtonDownEvent:event];
	return NO;
}


#pragma mark Mouse Up events

-(void) mouseButtonUpEvent:(NSEvent*)event
{
	//CCLOG(@"mouse up: %@ --- button number: %li --- clickCount: %li", event, [event buttonNumber], [event clickCount]);
	UInt16 buttonCode = [event buttonNumber];
	[keyStates removeKeyDown:buttonCode];
	[keyStates removeKeyDown:buttonCode + KKMouseButtonDoubleClickOffset];
	[self updateMouseLocationFromEvent:event];
}

-(BOOL) ccMouseUp:(NSEvent*)event
{
	isDragging = NO;
	[self mouseButtonUpEvent:event];
	return NO;
}

-(BOOL) ccRightMouseUp:(NSEvent*)event
{
	isDragging = NO;
	[self mouseButtonUpEvent:event];
	return NO;
}

-(BOOL) ccOtherMouseUp:(NSEvent*)event
{
	isDragging = NO;
	[self mouseButtonUpEvent:event];
	return NO;
}


#pragma mark Mouse Dragged events

-(BOOL) ccMouseDragged:(NSEvent*)event
{
	isDragging = YES;
	[self updateMouseLocationFromEvent:event];
	return NO;
}

-(BOOL) ccRightMouseDragged:(NSEvent*)event
{
	isDragging = YES;
	[self updateMouseLocationFromEvent:event];
	return NO;
}

-(BOOL) ccOtherMouseDragged:(NSEvent*)event
{
	isDragging = YES;
	[self updateMouseLocationFromEvent:event];
	return NO;
}


#pragma mark Various other Mouse events

-(BOOL) ccScrollWheel:(NSEvent*)event
{
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_6
	hasPreciseScrollingDeltas = [event hasPreciseScrollingDeltas];
	scrollWheelDelta.x = [event scrollingDeltaX];
	scrollWheelDelta.y = [event scrollingDeltaY];
#else
	scrollWheelDelta.x = [event deltaX];
	scrollWheelDelta.y = [event deltaY];
#endif
	
	[self updateMouseLocationFromEvent:event];
	return NO;
}

-(BOOL) ccMouseMoved:(NSEvent*)event
{
	[self updateMouseLocationFromEvent:event];
	return NO;
}

/*
-(void) ccMouseEntered:(NSEvent*)event
{
}

-(void) ccMouseExited:(NSEvent*)event
{
}
 */

#endif

-(void) update:(ccTime)delta
{
	scrollWheelDelta = CGPointZero;
	[keyStates update:delta];
}

@end
