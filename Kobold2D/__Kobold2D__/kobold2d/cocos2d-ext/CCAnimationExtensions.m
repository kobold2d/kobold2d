/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCAnimationExtensions.h"

@implementation CCAnimation (KoboldExtensions)

+(id) animationWithName:(NSString*)name format:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay
{
	CCAnimation* anim = [self animation];
	anim.delayPerUnit = delay;
	
	int maxIndex = firstIndex + numFrames;
	for (int i = firstIndex; i < maxIndex; i++)
	{
		NSString* frameName = [NSString stringWithFormat:format, i];
		CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
		NSAssert(frame != nil, @"there's no sprite frame with name '%@' in CCSpriteFrameCache!", frameName);
		[anim addSpriteFrame:frame];
	}
	
	return anim;
}

// Creates an animation from single files.
+(CCAnimation*) animationWithFiles:(NSString*)name frameCount:(int)frameCount delay:(float)delay
{
	CCTextureCache* textureCache = [CCTextureCache sharedTextureCache];
	
	// load the animation frames as textures and create the sprite frames
	NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameCount];
	for (int i = 0; i < frameCount; i++)
	{
		// Assuming all animation files are named "nameX.png" with X being a consecutive number starting with 0.
		NSString* file = [NSString stringWithFormat:@"%@%i.png", name, i];
		CCTexture2D* texture = [textureCache addImage:file];
		
		// Assuming that image file animations always use the whole image for each animation frame.
		CGSize texSize = [texture contentSize];
		CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
		CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:texture rect:texRect];
		
		[frames addObject:frame];
	}
	
	// create an animation object from all the sprite animation frames
	return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}

// Creates an animation from sprite frames.
+(CCAnimation*) animationWithFrames:(NSString*)frame frameCount:(int)frameCount delay:(float)delay
{
	CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];

	// load the animation frames as textures and create the sprite frames
	NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameCount];
	for (int i = 0; i < frameCount; i++)
	{
		NSString* file = [NSString stringWithFormat:@"%@%i.png", frame, i];
		CCSpriteFrame* frame = [frameCache spriteFrameByName:file];
		[frames addObject:frame];
	}
	
	// return an animation object from all the sprite animation frames
	return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}

@end
