/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"

enum 
{
	kTagBatchNode = 1,
	kCollisionTypeBox = 2,
};

@interface PhysicsLayer : CCLayer <SpaceManagerSerializeDelegate>
{
	SpaceManagerCocos2d* spaceManager;
}

@end
