/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"

/** extends CCAnimation */
@interface CCAnimation (KoboldExtensions)

/** Creates a CCAnimation with name, a format string for the consecutively numbered files (eg @"frames_%i.png"), the number of frames, 
 the first index (from where to count numFrames), and delay between frames. */
+(id) animationWithName:(NSString*)name format:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay;

/** Creates a CCAnimation from individual files. The name is the base name of the files which must be suffixed with consecutive numbers.
 For example: ship0.png, ship1.png, ship2.png ... (name:@"ship" frameCount:3) */
+(CCAnimation*) animationWithFiles:(NSString*)name frameCount:(int)frameCount delay:(float)delay;

/** Creates a CCAnimation from individual sprite frames. Assumes the sprite frames have already been loaded. The name is the base name of the files which must be suffixed with consecutive numbers.
 For example: ship0.png, ship1.png, ship2.png ... (name:@"ship" frameCount:3) */
+(CCAnimation*) animationWithFrames:(NSString*)frame frameCount:(int)frameCount delay:(float)delay;

@end
