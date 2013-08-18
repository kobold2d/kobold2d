/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"

#import "KKKeyStates.h"

@interface KKInputMouse : NSObject
#if KK_PLATFORM_MAC
	<CCMouseEventDelegate>
#endif
{
@private
	KKKeyStates* keyStates;
	
	CGPoint locationInWindow;
	CGPoint previousLocationInWindow;
	CGPoint scrollWheelDelta;
	
	BOOL hasPreciseScrollingDeltas;
#if KK_PLATFORM_MAC // to prevent analyzer warning
	BOOL isDragging;
#endif
}

@property (nonatomic, readonly) KKKeyStates* keyStates;
@property (nonatomic, readonly) CGPoint locationInWindow;
@property (nonatomic, readonly) CGPoint previousLocationInWindow;
@property (nonatomic, readonly) CGPoint scrollWheelDelta;
@property (nonatomic, readonly) BOOL hasPreciseScrollingDeltas;

#if KK_PLATFORM_MAC
-(void) resetInputStates;
#endif

-(void) update:(ccTime)delta;

@end
