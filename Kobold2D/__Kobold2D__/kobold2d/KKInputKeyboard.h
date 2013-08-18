/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"

#import "KKKeyStates.h"


@interface KKInputKeyboard : NSObject
#if KK_PLATFORM_MAC
	<CCKeyboardEventDelegate>
#endif
{
@private
	KKKeyStates* keyStates;
	
	NSUInteger modifiersDown;
}

@property (nonatomic, readonly) KKKeyStates* keyStates;
@property (nonatomic, readonly) NSUInteger modifiersDown;

#if KK_PLATFORM_MAC
-(void) resetInputStates;
#endif

-(void) update:(ccTime)delta;

@end
