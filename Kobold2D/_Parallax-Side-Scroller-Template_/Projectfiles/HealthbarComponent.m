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

#import "HealthbarComponent.h"
#import "EnemyEntity.h"

@implementation HealthbarComponent

-(void) onEnter
{
	[super onEnter];
	self.visible = NO;
}

-(void) reset
{
	float parentHeight = self.parent.contentSize.height;
	float selfHeight = self.contentSize.height;
	self.position = CGPointMake(self.parent.contentSize.width * 0.5f, parentHeight + selfHeight);
	self.scaleX = 1;
	self.visible = YES;
	[self scheduleUpdate];
}

-(void) update:(ccTime)delta
{
	if (self.parent.visible)
	{
		NSAssert([self.parent isKindOfClass:[EnemyEntity class]], @"not a EnemyEntity");
		EnemyEntity* parentEntity = (EnemyEntity*)self.parent;
		self.scaleX = parentEntity.hitPoints / (float)parentEntity.initialHitPoints;
	}
	else if (self.visible)
	{
		self.visible = NO;
		[self unscheduleUpdate];
	}
}

@end
