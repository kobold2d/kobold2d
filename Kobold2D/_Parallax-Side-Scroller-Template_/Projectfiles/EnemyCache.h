/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface EnemyCache : CCNode 
{
	CCSpriteBatchNode* batch;
	CCArray* enemies;
	
	int updateCount;
}

@end
