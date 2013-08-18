/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import <Foundation/Foundation.h>
#import "Entity.h"

typedef enum
{
	EnemyTypeUFO = 0,
	EnemyTypeCruiser,
	EnemyTypeBoss,
	
	EnemyType_MAX,
} EnemyTypes;


@interface EnemyEntity : Entity
{
	EnemyTypes type;
	int initialHitPoints;
	int hitPoints;
}

@property (readonly, nonatomic) int initialHitPoints;
@property (readonly, nonatomic) int hitPoints;

+(id) enemyWithType:(EnemyTypes)enemyType;

+(int) getSpawnFrequencyForEnemyType:(EnemyTypes)enemyType;

-(void) spawn;

-(void) gotHit;

@end
