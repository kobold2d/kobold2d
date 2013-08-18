/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "EnemyCache.h"
#import "EnemyEntity.h"
#import "GameLayer.h"
#import "BulletCache.h"


@interface EnemyCache (PrivateMethods)
-(void) initEnemies;
@end


@implementation EnemyCache

+(id) cache
{
	id cache = [[self alloc] init];
#ifndef KK_ARC_ENABLED
	[cache autorelease];
#endif // KK_ARC_ENABLED
	return cache;
}

-(id) init
{
	if ((self = [super init]))
	{
		// get any image from the Texture Atlas we're using
		CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"monster-a.png"];
		batch = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];
		[self addChild:batch];
		
		[self initEnemies];
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) initEnemies
{
	// create the enemies array containing further arrays for each type
	enemies = [[CCArray alloc] initWithCapacity:EnemyType_MAX];
	
	// create the arrays for each type
	for (int i = 0; i < EnemyType_MAX; i++)
	{
		// depending on enemy type the array capacity is set to hold the desired number of enemies
		int capacity;
		switch (i)
		{
			case EnemyTypeUFO:
				capacity = 6;
				break;
			case EnemyTypeCruiser:
				capacity = 3;
				break;
			case EnemyTypeBoss:
				capacity = 1;
				break;
				
			default:
				[NSException exceptionWithName:@"EnemyCache Exception" reason:@"unhandled enemy type" userInfo:nil];
				break;
		}
		
		// no alloc needed since the enemies array will retain anything added to it
		CCArray* enemiesOfType = [CCArray arrayWithCapacity:capacity];
		[enemies addObject:enemiesOfType];
	}
	
	for (int i = 0; i < EnemyType_MAX; i++)
	{
		CCArray* enemiesOfType = [enemies objectAtIndex:i];
		int numEnemiesOfType = [enemiesOfType capacity];
		
		for (int j = 0; j < numEnemiesOfType; j++)
		{
			EnemyEntity* enemy = [EnemyEntity enemyWithType:i];
			[batch addChild:enemy z:0 tag:i];
			[enemiesOfType addObject:enemy];
		}
	}
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[enemies release];
	[super dealloc];
#endif // KK_ARC_ENABLED
}


-(void) spawnEnemyOfType:(EnemyTypes)enemyType
{
	CCArray* enemiesOfType = [enemies objectAtIndex:enemyType];
	
	EnemyEntity* enemy;
	CCARRAY_FOREACH(enemiesOfType, enemy)
	{
		// find the first free enemy and respawn it
		if (enemy.visible == NO)
		{
			//CCLOG(@"spawn enemy type %i", enemyType);
			[enemy spawn];
			break;
		}
	}
}

-(void) checkForBulletCollisions
{
	EnemyEntity* enemy;
	CCARRAY_FOREACH([batch children], enemy)
	{
		if (enemy.visible)
		{
			BulletCache* bulletCache = [[GameLayer sharedGameLayer] bulletCache];
			CGRect bbox = [enemy boundingBox];
			if ([bulletCache isPlayerBulletCollidingWithRect:bbox])
			{
				// This enemy got hit ...
				[enemy gotHit];
			}
		}
	}
}

-(void) update:(ccTime)delta
{
	updateCount++;

	for (int i = EnemyType_MAX - 1; i >= 0; i--)
	{
		int spawnFrequency = [EnemyEntity getSpawnFrequencyForEnemyType:i];
		
		if (updateCount % spawnFrequency == 0)
		{
			[self spawnEnemyOfType:i];
			break;
		}
	}
	
	[self checkForBulletCollisions];
}

@end
