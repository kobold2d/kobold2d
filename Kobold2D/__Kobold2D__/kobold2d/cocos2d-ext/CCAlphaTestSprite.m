/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCAlphaTestSprite.h"


@interface CCAlphaTestSprite (Private)
@end

@implementation CCAlphaTestSprite

-(void) draw
{
	CCLOG(@"%@: %@ method not converted to OpenGL ES 2.0", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

	/*
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER, 0.0f);

	[super draw];
	
	glDisable(GL_ALPHA_TEST);
	 */
}

@end
