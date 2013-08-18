/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import "Bumper.h"

@implementation Bumper

-(id) initWithWorld:(b2World*)world position:(CGPoint)pos
{
	if ((self = [super initWithShape:@"bumper" inWord:world]))
	{
        // set the body position
        body->SetTransform([Helper toMeters:pos], 0.0f);
	}
	return self;
}

+(id) bumperWithWorld:(b2World*)world position:(CGPoint)pos
{
	id bumper = [[self alloc] initWithWorld:world position:pos];
#ifndef KK_ARC_ENABLED
	[bumper autorelease];
#endif // KK_ARC_ENABLED
	return bumper;
}

@end
