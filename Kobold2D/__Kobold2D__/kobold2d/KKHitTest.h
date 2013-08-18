/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import "ccMoreMacros.h"

@interface KKHitTest : NSObject
{
@private
	BOOL isHitTesting;
}

/** Enables hit testing for the Cocos2D OpenGL view. If enabled, all nodes in the scene hierarchy are tested for
 a hit every time a touch began or mouse down event is received. The hit test is performed via [node containsPoint:location].
 If a node is "hit", then the touch/click is processed by the Cocos2D OpenGL view. Otherwise it is passed on to underlying views. */
@property (nonatomic) BOOL isHitTesting;

/** returns the singleton instance */
+(KKHitTest*) sharedHitTest;

@end


#if KK_PLATFORM_IOS
/*
@interface EAGLView (KoboldExtensions)
//-(UIView*) hitTest:(CGPoint)aPoint withEvent:(UIEvent*)event;
@end
*/
#endif


#if KK_PLATFORM_MAC
#endif