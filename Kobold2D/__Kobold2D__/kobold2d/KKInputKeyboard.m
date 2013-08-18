/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKInputKeyboard.h"
#import "KKInput.h"

@implementation KKInputKeyboard

@synthesize keyStates, modifiersDown;

#if KK_PLATFORM_MAC

-(id) init
{
    if ((self = [super init]))
	{
		keyStates = [[KKKeyStates alloc] init];

		[[CCDirector sharedDirector].eventDispatcher addKeyboardDelegate:self priority:0];
    }
    
    return self;
}

-(void) dealloc
{
	[[CCDirector sharedDirector].eventDispatcher removeKeyboardDelegate:self];

	[keyStates release];
	
	[super dealloc];
}

-(void) resetInputStates
{
	// don't reset keyboard states because they're always repeating
	// resetting them would cause a continued key press to be registered as "key down this frame"
	// in the next scene, which is undesirable
	//[keyStates reset];
}

-(BOOL) ccKeyDown:(NSEvent*)event
{
	//CCLOG(@"key down: %@", event);
	[keyStates addKeyDown:[event keyCode]];
	return NO;
}

-(BOOL) ccKeyUp:(NSEvent*)event
{
	//CCLOG(@"key up: %@", event);
	[keyStates removeKeyDown:[event keyCode]];
	return NO;
}

-(BOOL) ccFlagsChanged:(NSEvent*)event
{
	//CCLOG(@"flags changed  : %@", event);

	modifiersDown = ([event modifierFlags] & KKDeviceIndependentModifierFlagsMask);

	UInt16 keyCode = [event keyCode];
	if ([keyStates isKeyDown:keyCode onlyThisFrame:NO])
	{
		[keyStates removeKeyDown:keyCode];
	}
	else
	{
		[keyStates addKeyDown:keyCode];
	}
	
	return NO;
}

#endif // KK_PLATFORM_MAC

-(void) update:(ccTime)delta
{
	[keyStates update:delta];
}



@end
