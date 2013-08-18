/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCRemoveFromParentAction.h"


@interface CCRemoveFromParentAction (Private)
@end

@implementation CCRemoveFromParentAction

-(void) startWithTarget:(id)target
{
	[super startWithTarget:target];
	[target removeFromParentAndCleanup:YES];
}

@end
