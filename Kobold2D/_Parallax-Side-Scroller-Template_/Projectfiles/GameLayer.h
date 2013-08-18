/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim, Andreas Loew 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "BulletCache.h"
#import "ParallaxBackground.h"
#import "ShipEntity.h"

typedef enum
{
	GameSceneNodeTagBullet = 1,
	GameSceneNodeTagBulletSpriteBatch,
	GameSceneNodeTagBulletCache,
	GameSceneNodeTagEnemyCache,
	GameSceneNodeTagShip,
	
} GameSceneNodeTags;


@interface GameLayer : CCLayer 
{

}

+(GameLayer*) sharedGameLayer;

-(ShipEntity*) defaultShip;

@property (readonly, nonatomic) BulletCache* bulletCache;

+(CGRect) screenRect;

@end
