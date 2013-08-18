/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "BodyNode.h"

@interface Ball : BodyNode
#if KK_PLATFORM_IOS
	<CCTouchOneByOneDelegate>
#elif KK_PLATFORM_MAC
	<CCMouseEventDelegate>
#endif
{
	bool moveToFinger;
	CGPoint fingerLocation;
}

/**
 * Creates a new ball
 * @param world world to add the ball to
 */
+(id) ballWithWorld:(b2World*)world;

@end
