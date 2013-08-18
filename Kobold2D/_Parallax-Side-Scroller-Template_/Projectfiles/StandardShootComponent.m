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

#import "StandardShootComponent.h"
#import "BulletCache.h"
#import "GameLayer.h"

#import "SimpleAudioEngine.h"

@implementation StandardShootComponent

@synthesize shootFrequency;
@synthesize bulletFrameName, shootSoundFile;

-(id) init
{
	if ((self = [super init]))
	{
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[bulletFrameName release];
	[super dealloc];
#endif // KK_ARC_ENABLED
}

-(void) update:(ccTime)delta
{
	if (self.parent.visible)
	{
		updateCount += delta;
		
		if (updateCount >= shootFrequency)
		{
			//CCLOG(@"enemy %@ shoots!", self.parent);
			updateCount = 0;
			
			GameLayer* game = [GameLayer sharedGameLayer];
			CGPoint startPos = ccpSub(self.parent.position, CGPointMake(self.parent.contentSize.width * 0.5f, 0));
			[game.bulletCache shootBulletFrom:startPos velocity:CGPointMake(-200, 0) frameName:bulletFrameName isPlayerBullet:NO];
			
			if (shootSoundFile != nil)
			{
				float pitch = CCRANDOM_0_1() * 0.2f + 0.9f;
				[[SimpleAudioEngine sharedEngine] playEffect:shootSoundFile pitch:pitch pan:0.0f gain:1.0f];
			}
		}
	}
}

@end
