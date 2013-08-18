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

#import "GameLayer.h"
#import "Bullet.h"
#import "InputLayer.h"
#import "BulletCache.h"
#import "EnemyCache.h"

#import "SimpleAudioEngine.h"

@interface GameLayer (PrivateMethods)
-(void) countBullets:(ccTime)delta;
-(void) preloadParticleEffects:(NSString*)particleFile;
@end

@implementation GameLayer

static CGRect screenRect;

static GameLayer* instanceOfGameLayer;
+(GameLayer*) sharedGameLayer
{
	NSAssert(instanceOfGameLayer != nil, @"GameLayer instance not yet initialized!");
	return instanceOfGameLayer;
}

-(id) init
{
	if ((self = [super init]))
	{
		instanceOfGameLayer = self;

		// Enable pre multiplied alpha for PVR textures to avoid artifacts
		[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

		// Load all of the game's artwork up front.
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"game-art.plist"];

		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		screenRect = CGRectMake(0, 0, screenSize.width, screenSize.height);
		
		ShipEntity* ship = [ShipEntity ship];
		ship.position = CGPointMake([ship contentSize].width / 2, screenSize.height / 2);
		[self addChild:ship z:0 tag:GameSceneNodeTagShip];

		EnemyCache* enemyCache = [EnemyCache node];
		[self addChild:enemyCache z:0 tag:GameSceneNodeTagEnemyCache];

		BulletCache* bulletCache = [BulletCache node];
		[self addChild:bulletCache z:1 tag:GameSceneNodeTagBulletCache];
		
		
		// To preload the textures, play each effect once off-screen
		[self preloadParticleEffects:@"fx-explosion.plist"];
		[self preloadParticleEffects:@"fx-explosion2.plist"];
		
		// Preload sound effects
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"explo1.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"explo2.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"shoot1.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"shoot2.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"hit1.wav"];
		
		ParallaxBackground* background = [ParallaxBackground node];
		[self addChild:background z:-1];

		InputLayer* inputLayer = [InputLayer node];
		[self addChild:inputLayer z:1];
		
		if ([[CCDirector sharedDirector] currentDeviceIsIPad]) 
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Note: the background Images were not designed for iPad dimensions." fontName:@"Arial" fontSize:28];
			CGPoint labelPos = [[CCDirector sharedDirector] screenCenter];
			label.position = CGPointMake(labelPos.x, labelPos.y * 1.75f);
			label.color = ccYELLOW;
			[self addChild:label z:-10];
		}
	}
	return self;
}

-(void) dealloc
{
	instanceOfGameLayer = nil;
	
#ifndef KK_ARC_ENABLED
	// don't forget to call "super dealloc"
	[super dealloc];
#endif // KK_ARC_ENABLED
}

-(void) preloadParticleEffects:(NSString*)particleFile
{
	[CCParticleSystem particleWithFile:particleFile];
}

-(BulletCache*) bulletCache
{
	CCNode* node = [self getChildByTag:GameSceneNodeTagBulletCache];
	NSAssert([node isKindOfClass:[BulletCache class]], @"not a BulletCache");
	return (BulletCache*)node;
}

-(ShipEntity*) defaultShip
{
	CCNode* node = [self getChildByTag:GameSceneNodeTagShip];
	NSAssert([node isKindOfClass:[ShipEntity class]], @"node is not a ShipEntity!");
	return (ShipEntity*)node;
}

+(CGRect) screenRect
{
	return screenRect;
}

@end
