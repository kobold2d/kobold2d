/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#if __MAC_OS_X_VERSION_MAX_ALLOWED

#import <AppKit/AppKit.h>

/** The principal application class of all Kobold2D Mac targets. Used to override application-specific behavior. 
 Provides a workaround for an AppKit bug: if the Command key is held down, no key up events are
 received for other keys (see: http://www.cocoadev.com/index.pl?GameKeyboardHandlingAlmost). */
@interface KKApplicationMac : NSApplication
{
@private

}

@end

#endif
