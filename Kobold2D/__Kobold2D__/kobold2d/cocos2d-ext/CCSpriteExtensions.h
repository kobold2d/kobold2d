/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"


/** extends CCSprite */
@interface CCSprite (KoboldExtensions)

/** Plays an anim once with the given file format (eg @"playeranim%i.png") with the given number of frames and a starting index. 
 The animateTag parameter is the tag given to the action playing the animation, so that you can stop it by tag. */
-(void) playAnimWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag;
/** Plays an anim looped with the given file format (eg @"playeranim%i.png") with the given number of frames and a starting index. 
 The animateTag parameter is the tag given to the action playing the animation, so that you can stop it by tag. */
-(void) playAnimLoopedWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag;

/** Plays an anim once with the given file format (eg @"playeranim%i.png") with the given number of frames and a starting index. 
 The animateTag parameter is the tag given to the action playing the animation, so that you can stop it by tag. When the anim
 has cycled through all frames, the node running the animation will be removed from its parent. Useful for one-off animations, like
 an explosion, smoke-puff, blood splat, etc. */
-(void) playAnimAndRemoveWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag;


/** Variant that allows to set the restoreOriginalFrame property. */
-(void) playAnimWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag restoreOriginalFrame:(BOOL)restoreOriginalFrame;
/** Variant that allows to set the restoreOriginalFrame property. */
-(void) playAnimLoopedWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag restoreOriginalFrame:(BOOL)restoreOriginalFrame;
/** Variant that allows to set the restoreOriginalFrame property. */
-(void) playAnimAndRemoveWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag restoreOriginalFrame:(BOOL)restoreOriginalFrame;


/** First, checks if the string can be found in the spriteFrameCache, if not it will try to load the string assuming its a file name. */
+(id) spriteWithSpriteFrameNameOrFile:(NSString*)nameOrFile;

/** Creates an autoreleased sprite from a CCRenderTexture */
+(id) spriteWithRenderTexture:(CCRenderTexture*)rtx;

@end
