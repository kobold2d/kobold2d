/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import "EnemyEntity.h"
#import "GameLayer.h"
#import "StandardMoveComponent.h"
#import "StandardShootComponent.h"
#import "HealthbarComponent.h"

#import "SimpleAudioEngine.h"

@interface EnemyEntity (PrivateMethods)
-(void) initSpawnFrequency;
@end

@implementation EnemyEntity

@synthesize initialHitPoints, hitPoints;

-(id) initWithType:(EnemyTypes)enemyType
{
	type = enemyType;
	
	NSString* enemyFrameName;
	NSString* bulletFrameName;
	float shootFrequency = 6.0f;
	initialHitPoints = 1;
	
	switch (type)
	{
		case EnemyTypeUFO:
			enemyFrameName = @"monster-a.png";
			bulletFrameName = @"shot-a.png";
			break;
		case EnemyTypeCruiser:
			enemyFrameName = @"monster-b.png";
			bulletFrameName = @"shot-b.png";
			shootFrequency = 1.0f;
			initialHitPoints = 3;
			break;
		case EnemyTypeBoss:
			enemyFrameName = @"monster-c.png";
			bulletFrameName = @"shot-c.png";
			shootFrequency = 2.0f;
			initialHitPoints = 15;
			break;
			
		default:
			[NSException exceptionWithName:@"EnemyEntity Exception" reason:@"unhandled enemy type" userInfo:nil];
	}

	if ((self = [super initWithSpriteFrameName:enemyFrameName]))
	{
		// Create the game logic components
		[self addChild:[StandardMoveComponent node]];
		
		StandardShootComponent* shootComponent = [StandardShootComponent node];
		shootComponent.shootFrequency = shootFrequency;
		shootComponent.bulletFrameName = bulletFrameName;
		shootComponent.shootSoundFile = @"shoot2.wav";
		[self addChild:shootComponent];

		if (type == EnemyTypeBoss)
		{
			HealthbarComponent* healthbar = [HealthbarComponent spriteWithSpriteFrameName:@"healthbar.png"];
			[self addChild:healthbar];
		}
		else if (type == EnemyTypeUFO)
		{
			// create an animation object from all the sprite animation frames
			float delay = CCRANDOM_0_1() * 0.04f + 0.1f;
			CCAnimation* anim = [CCAnimation animationWithFrames:@"monster-a-anim" frameCount:3 delay:delay];
			
			// run the animation by using the CCAnimate action
			CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
			CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
			[self runAction:repeat];
		}

		// enemies start invisible
		self.visible = NO;

		[self initSpawnFrequency];
	}
	
	return self;
}

+(id) enemyWithType:(EnemyTypes)enemyType
{
	id enemy = [[self alloc] initWithType:enemyType];
#ifndef KK_ARC_ENABLED
	[enemy autorelease];
#endif // KK_ARC_ENABLED
	return enemy;
}

static CCArray* spawnFrequency;

-(void) initSpawnFrequency
{
	// initialize how frequent the enemies will spawn
	if (spawnFrequency == nil)
	{
		spawnFrequency = [[CCArray alloc] initWithCapacity:EnemyType_MAX];
		[spawnFrequency insertObject:[NSNumber numberWithInt:80] atIndex:EnemyTypeUFO];
		[spawnFrequency insertObject:[NSNumber numberWithInt:260] atIndex:EnemyTypeCruiser];
		[spawnFrequency insertObject:[NSNumber numberWithInt:1500] atIndex:EnemyTypeBoss];
		
		// spawn one enemy immediately
		[self spawn];
	}
}

+(int) getSpawnFrequencyForEnemyType:(EnemyTypes)enemyType
{
	NSAssert(enemyType < EnemyType_MAX, @"invalid enemy type");
	NSNumber* number = [spawnFrequency objectAtIndex:enemyType];
	return [number intValue];
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[spawnFrequency release];
	spawnFrequency = nil;
	
	[super dealloc];
#endif // KK_ARC_ENABLED
}


-(void) spawn
{
	//CCLOG(@"spawn enemy");
	
	// Select a spawn location just outside the right side of the screen, with random y position
	CGRect screenRect = [GameLayer screenRect];
	CGSize spriteSize = [self contentSize];
	float xPos = screenRect.size.width + spriteSize.width * 0.5f;
	float yPos = CCRANDOM_0_1() * (screenRect.size.height - spriteSize.height) + spriteSize.height * 0.5f;
	self.position = CGPointMake(xPos, yPos);
	
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
	
	// reset health
	hitPoints = initialHitPoints;
	
	// reset certain components
	CCNode* node;
	CCARRAY_FOREACH([self children], node)
	{
		if ([node isKindOfClass:[HealthbarComponent class]])
		{
			HealthbarComponent* healthbar = (HealthbarComponent*)node;
			[healthbar reset];
		}
	}
}

-(void) gotHit
{
	hitPoints--;
	if (hitPoints <= 0)
	{
		self.visible = NO;
		
		// Play a particle effect when the enemy was destroyed
		CCParticleSystem* system;
		if (type == EnemyTypeBoss)
		{
			system = [CCParticleSystemQuad particleWithFile:@"fx-explosion2.plist"];
			[[SimpleAudioEngine sharedEngine] playEffect:@"explo1.wav" pitch:1.0f pan:0.0f gain:1.0f];
		}
		else
		{
			system = [CCParticleSystemQuad particleWithFile:@"fx-explosion.plist"];
			[[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav" pitch:1.0f pan:0.0f gain:1.0f];
		}
		
		// Set some parameters that can't be set in Particle Designer
		system.positionType = kCCPositionTypeFree;
		system.autoRemoveOnFinish = YES;
		system.position = self.position;
		
		// Add the particle effect to the GameScene, for these reasons:
		// - self is a sprite added to a spritebatch and will only allow CCSprite nodes (it crashes if you try)
		// - self is now invisible which might affect rendering of the particle effect
		// - since the particle effects are short lived, there is no harm done by adding them directly to the GameScene
		[[GameLayer sharedGameLayer] addChild:system];
	}
	else
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"hit1.wav" pitch:1.0f pan:0.0f gain:1.0f];
	}
}

@end
