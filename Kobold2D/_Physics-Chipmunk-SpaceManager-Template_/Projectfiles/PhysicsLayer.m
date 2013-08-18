/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "PhysicsLayer.h"

const int TILESIZE = 32;
const int TILESET_COLUMNS = 9;
const int TILESET_ROWS = 19;


@interface PhysicsLayer (PrivateMethods)
-(BOOL) boxCollision:(CollisionMoment)moment arbiter:(cpArbiter*)arb space:(cpSpace*)space;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)pos;
@end

@implementation PhysicsLayer

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@ init", NSStringFromClass([self class]));

		CGSize screenSize = [CCDirector sharedDirector].winSize;

		spaceManager = [[SpaceManagerCocos2d alloc] init];
		spaceManager.constantDt = 0.01f;
		spaceManager.gravity = CGPointMake(0, -100);
		spaceManager.space->iterations = 8;
		
		[spaceManager addWindowContainmentWithFriction:1.0 elasticity:1.0 inset:cpvzero];
		[spaceManager start];
		
		// Note: SpaceManager collision handling adds some overhead. You can always switch back to
		// Chipmunk C-style collision handling if you are experiencing slowdowns during mass collision events.
		[spaceManager addCollisionCallbackBetweenType:kCollisionTypeBox 
											otherType:kCollisionTypeBox
											   target:self
											 selector:@selector(boxCollision:arbiter:space:)
											  moments:COLLISION_BEGIN, COLLISION_SEPARATE, nil];

		NSString* message = @"Tap Screen For More Awesome!";
		if ([CCDirector sharedDirector].currentPlatformIsMac)
		{
			message = @"Click Window For More Awesome!";
		}
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:32];
		[self addChild:label];
		[label setColor:ccc3(222, 222, 255)];
		label.position = CGPointMake(screenSize.width / 2, screenSize.height - 50);
		
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"dg_grounds32.png" capacity:150];
		[self addChild:batch z:0 tag:kTagBatchNode];
		
		// Add a few objects initially
		for (int i = 0; i < 11; i++)
		{
			[self addNewSpriteAt:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
		}
		
		[self addSomeJoinedBodies:CGPointMake(screenSize.width / 3, screenSize.height -50)];

		[self scheduleUpdate];
		
		[KKInput sharedInput].accelerometerActive = YES;
	}

	return self;
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[spaceManager release];
	spaceManager = nil;

	[super dealloc];
#endif // KK_ARC_ENABLED
}

-(void) onExit
{
	[spaceManager stop];
}

-(BOOL) boxCollision:(CollisionMoment)moment arbiter:(cpArbiter*)arbiter space:(cpSpace*)space
{
	BOOL processCollision = YES;

	if (moment == COLLISION_BEGIN || moment == COLLISION_SEPARATE)
	{
		cpShape* shapeA;
		cpShape* shapeB;
		cpArbiterGetShapes(arbiter, &shapeA, &shapeB);

		cpCCSprite* spriteA = (__bridge cpCCSprite*)shapeA->data;
		cpCCSprite* spriteB = (__bridge cpCCSprite*)shapeB->data;
		if (spriteA != nil && spriteB != nil)
		{
			if (moment == COLLISION_BEGIN)
			{
				//spriteA.color = ccMAGENTA;
				//spriteB.color = ccMAGENTA;
			}
			else
			{
				spriteA.color = ccWHITE;
				spriteB.color = ccWHITE;
			}
		}
	}
	
	return processCollision;
}

-(cpCCSprite*) addRandomSpriteAt:(CGPoint)pos shape:(cpShape*)shape
{
	CCSpriteBatchNode* batch = (CCSpriteBatchNode*)[self getChildByTag:kTagBatchNode];

	int idx = CCRANDOM_0_1() * TILESET_COLUMNS;
	int idy = CCRANDOM_0_1() * TILESET_ROWS;
	CGRect tileRect = CGRectMake(TILESIZE * idx, TILESIZE * idy, TILESIZE, TILESIZE);
	
	cpCCSprite* sprite = [cpCCSprite spriteWithTexture:batch.texture rect:tileRect];
	sprite.shape = shape;
	sprite.position = pos;
	[batch addChild:sprite];
	
	return sprite;
}

-(void) addSomeJoinedBodies:(CGPoint)pos
{
	const float mass = 1.0f;
	const float posOffset = 1.4f;
	
	cpShape* staticBox = [spaceManager addRectAt:pos mass:STATIC_MASS width:TILESIZE height:TILESIZE rotation:0];
	staticBox->collision_type = kCollisionTypeBox;
	cpCCSprite* sprite = [self addRandomSpriteAt:pos shape:staticBox];
	sprite.opacity = 100;
	staticBox->data = (__bridge void*)sprite;

	pos.x += TILESIZE * posOffset;
	cpShape* boxA = [spaceManager addRectAt:pos mass:mass width:TILESIZE height:TILESIZE rotation:0];
	boxA->collision_type = kCollisionTypeBox;
	boxA->data = (__bridge void*)[self addRandomSpriteAt:pos shape:boxA];

	pos.x += TILESIZE * posOffset;
	cpShape* boxB = [spaceManager addRectAt:pos mass:mass width:TILESIZE height:TILESIZE rotation:0];
	boxB->collision_type = kCollisionTypeBox;
	boxB->data = (__bridge void*)[self addRandomSpriteAt:pos shape:boxB];

	pos.x += TILESIZE * posOffset;
	cpShape* boxC = [spaceManager addRectAt:pos mass:mass width:TILESIZE height:TILESIZE rotation:0];
	boxC->collision_type = kCollisionTypeBox;
	boxC->data = (__bridge void*)[self addRandomSpriteAt:pos shape:boxC];
	
	[spaceManager addPivotToBody:staticBox->body fromBody:boxA->body worldAnchor:staticBox->body->p];
	[spaceManager addPivotToBody:boxA->body fromBody:boxB->body worldAnchor:boxA->body->p];
	[spaceManager addPivotToBody:boxB->body fromBody:boxC->body worldAnchor:boxB->body->p];
}

-(void) addNewSpriteAt:(CGPoint)pos
{
	const float elasticity = 0.3f;
	const float friction = 0.7f;

	cpShape* box = [spaceManager addRectAt:pos mass:0.5f width:TILESIZE height:TILESIZE rotation:0];
	box->e = elasticity;
	box->u = friction;
	box->collision_type = kCollisionTypeBox;
	box->data = (__bridge void*)[self addRandomSpriteAt:pos shape:box];
}

-(void) update:(ccTime)delta
{
	CCDirector* director = [CCDirector sharedDirector];
	if (director.currentPlatformIsIOS)
	{
		KKInput* input = [KKInput sharedInput];
		if (director.currentDeviceIsSimulator == NO)
		{
			KKAcceleration* acceleration = input.acceleration;
			spaceManager.space->gravity = cpv(500.0f * acceleration.rawX, 500.0f * acceleration.rawY);
		}
		
		if (input.anyTouchEndedThisFrame)
		{
			[self addNewSpriteAt:[input locationOfAnyTouchInPhase:KKTouchPhaseEnded]];
		}
	}
	else if (director.currentPlatformIsMac)
	{
		KKInput* input = [KKInput sharedInput];
		if (input.isAnyMouseButtonUpThisFrame || CGPointEqualToPoint(input.scrollWheelDelta, CGPointZero) == NO)
		{
			[self addNewSpriteAt:input.mouseLocation];
		}
	}
}

@end
