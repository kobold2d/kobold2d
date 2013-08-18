/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCSpriteExtensions.h"
#import "CCAnimationExtensions.h"
#import "CCRemoveFromParentAction.h"

@implementation CCSprite (KoboldExtensions)

-(void) privatePlayAnimWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag looped:(BOOL)looped remove:(BOOL)remove restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	CCAnimation* anim = [CCAnimation animationWithName:format format:format numFrames:numFrames firstIndex:firstIndex delay:delay];
	anim.restoreOriginalFrame = restoreOriginalFrame;
	CCAnimate* animate = [CCAnimate actionWithAnimation:anim];

	id action = nil;
	if (looped)
	{
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		repeat.tag = animateTag;
		action = repeat;
	}
	else
	{
		animate.tag = animateTag;
		action = animate;
		
		if (remove)
		{
			CCRemoveFromParentAction* removeAction = [CCRemoveFromParentAction action];
			CCSequence* sequence = [CCSequence actions:animate, removeAction, nil];
			action = sequence;
		}
	}

	[self runAction:action];
}

-(void) playAnimWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag
{
	[self privatePlayAnimWithFormat:format numFrames:numFrames firstIndex:firstIndex delay:delay animateTag:animateTag looped:NO remove:NO restoreOriginalFrame:NO];
}

-(void) playAnimLoopedWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag
{
	[self privatePlayAnimWithFormat:format numFrames:numFrames firstIndex:firstIndex delay:delay animateTag:animateTag looped:YES remove:NO restoreOriginalFrame:NO];
}

-(void) playAnimAndRemoveWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag
{
	[self privatePlayAnimWithFormat:format numFrames:numFrames firstIndex:firstIndex delay:delay animateTag:animateTag looped:NO remove:YES restoreOriginalFrame:NO];
}


-(void) playAnimWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	[self privatePlayAnimWithFormat:format numFrames:numFrames firstIndex:firstIndex delay:delay animateTag:animateTag looped:NO remove:NO restoreOriginalFrame:restoreOriginalFrame];
}

-(void) playAnimLoopedWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	[self privatePlayAnimWithFormat:format numFrames:numFrames firstIndex:firstIndex delay:delay animateTag:animateTag looped:YES remove:NO restoreOriginalFrame:restoreOriginalFrame];
}

-(void) playAnimAndRemoveWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	[self privatePlayAnimWithFormat:format numFrames:numFrames firstIndex:firstIndex delay:delay animateTag:animateTag looped:NO remove:YES restoreOriginalFrame:restoreOriginalFrame];
}

+(id) spriteWithSpriteFrameNameOrFile:(NSString*)nameOrFile
{
	CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:nameOrFile];
	if (spriteFrame)
	{
		return [CCSprite spriteWithSpriteFrame:spriteFrame];
	}

	return [CCSprite spriteWithFile:nameOrFile];
}

+(id) spriteWithRenderTexture:(CCRenderTexture*)rtx
{
    CCSprite* sprite = [CCSprite spriteWithTexture:rtx.sprite.texture];
    sprite.scaleY = -1;
    return sprite;
}

@end
