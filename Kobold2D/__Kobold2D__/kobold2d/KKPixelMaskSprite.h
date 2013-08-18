/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "bitarray.h"
#import "kkUserConfig.h"

/** KKPixelMaskSprite is a CCSprite that has a pixelMask for pixel-perfect collision detection.
 
 Notable behavior of this class:
 - Each instance creates its own pixelMask, even though the same texture may already be loaded.
 - Can only compare HD vs HD or SD vs SD images, but not HD vs SD images.
 - Can not be created from spriteframe or spriteframe name.
 .
 
 These may be fixed at a later time given enough interest.
 */
@interface KKPixelMaskSprite : CCSprite
{
	// Some useful improvements to this implementation would be:
	// cache pixelMasks for the same filename, to avoid wasting memory (much like CCTextureCache)
	// allow pixel mask to be created from a sprite frame
	// allow collisions between SD and HD assets (atm pixelMasks must be either both SD or both HD, collision tests return wrong results otherwise)
	// allow collisions if one or both sprites are rotated by exactly 90, 180 or 270 degrees
	
	// Possible optimizations:
	// reduce pixelMask size by combining the result of 2x2, 3x3, 4x4, etc pixel blocks into a single collision bit
	//	such a downscaled pixelMask would still be accurate enough for most use cases but require considerably less memory and is faster to iterate
	//	however picking a good algorithm that determines if a bit is set or not can be tricky
	// optimizing rectangle test: read multiple bits at once (byte or int), only compare individual bits if value > 0
	
	// Non-trivial improvement:
	// move the pixelMask array to CCTexture2D, to avoid loading the same image twice and take advantage of CCTextureCache
	// allow pixel perfect collisions if one or both nodes are rotated and/or scaled
	//		suggest using the render texture approach instead, as described here: http://www.cocos2d-iphone.org/forum/topic/18522
	// for purely "walking over landscape" type of games (think Tiny Wings but with an arbitrarily complex and rugged terrain),
	//	the pixelMask could be changed to contain only the pixel height (first pixel from top that's not alpha)
	//	That modification should be a separate class, labelled something like KKSpriteWithHeightMask.
	
#if KK_PIXELMASKSPRITE_USE_BITARRAY
	bit_array_t* pixelMask;
#else
	BOOL* pixelMask;
#endif
	NSUInteger pixelMaskWidth;
	NSUInteger pixelMaskHeight;
	NSUInteger pixelMaskSize;
	float pixelMaskResolutionFactor;
}

#if KK_PIXELMASKSPRITE_USE_BITARRAY
@property (nonatomic, readonly) bit_array_t* pixelMask;
#else
@property (nonatomic, readonly) BOOL* pixelMask;
#endif

@property (nonatomic, readonly) NSUInteger pixelMaskWidth;
@property (nonatomic, readonly) NSUInteger pixelMaskHeight;
@property (nonatomic, readonly) NSUInteger pixelMaskSize;

/** Initializer with filename and alphaThreshold (range 0-255). The alpha value of a pixel must be > alphaThreshold to be
 added as a collision bit to the pixelMask. Ie alphaThreshold = 255 ensures that only fully opaque pixels are colliding,
 and alphaThreshold == 0 ensures that all but completely transparent pixels are considered for collision bits. */
-(id) initWithFile:(NSString *)filename alphaThreshold:(UInt8)alphaThreshold;
/** Same as initWithFile but returns an autoreleased instance with alphaThreshold defaulting to 255 (only fully opaque pixels are collision bits). */
+(id) spriteWithFile:(NSString *)filename;
/** Same as initWithFile but returns an autoreleased instance. */
+(id) spriteWithFile:(NSString *)filename alphaThreshold:(UInt8)alphaThreshold;

/** Returns YES if the given point (in world/screen coordinates) is on a collision bit that is set to YES in the pixelMask.
 Returns NO if the point in the pixelMask is not colliding, or if the point lies outside the bounds of the pixelMask.
 
 Note: The KKPixelMaskSprite may be rotated and/or scaled. */
-(BOOL) pixelMaskContainsPoint:(CGPoint)point;
/** Returns YES if the given node intersection contains a pixelMask collision bit. If the node is a non-KKPixelMaskSprite node
 then the intersection rectangle (if any) will be tested for containing any collision bits and return YES if the other node's
 boundingBox intersection contains a pixelMask collision. Returns NO if the nodes aren't colliding or if there is no pixelMask collision.
 
 If the other node is of class KKPixelMaskSprite an accurate pixelMask vs. pixelMask comparison is performed. If the intersection of
 the two nodes contains a pixelMask collision bit set at the same coordinates, then the two nodes are colliding and YES is returned.
 
 Note: both nodes may NOT be rotated or scaled. This test only works with non-rotated, non-scaled nodes! */
-(BOOL) pixelMaskIntersectsNode:(CCNode*)other;

@end
