/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKApplicationMac.h"

#if __MAC_OS_X_VERSION_MAX_ALLOWED

@implementation KKApplicationMac

-(void) sendEvent:(NSEvent*)anEvent
{
	// This works around an AppKit bug, where key up events while holding
	// down the command key don't get sent to the key window.
	// Taken from: http://www.cocoadev.com/index.pl?GameKeyboardHandlingAlmost
	
	if ([anEvent type] == NSKeyUp && ([anEvent modifierFlags] & NSCommandKeyMask))
	{
		[[self keyWindow] sendEvent:anEvent];
	}
	else
	{
		[super sendEvent:anEvent];
	}
}

@end

#endif