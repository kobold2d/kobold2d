/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "BodyNode.h"

typedef enum
{
	kFlipperLeft,
	kFlipperRight,
} EFlipperType;

@interface Flipper : BodyNode
#if KK_PLATFORM_IOS
	<CCTouchOneByOneDelegate>
#elif KK_PLATFORM_MAC
	<CCMouseEventDelegate>
#endif
{
	EFlipperType type;
	b2RevoluteJoint* joint;
	float totalTime;
}

+(id) flipperWithWorld:(b2World*)world flipperType:(EFlipperType)flipperType;

@end
