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

#import "BodyNode.h"
#import "TablePart.h"

@implementation TablePart

-(id) initWithWorld:(b2World*)world position:(CGPoint)pos name:(NSString *)name
{
	if ((self = [super initWithShape:name inWord:world]))
	{
        // set the body position
        body->SetTransform([Helper toMeters:pos], 0.0f);

        // make the body static
        body->SetType(b2_staticBody);
	}
	return self;
}

+(id) tablePartInWorld:(b2World*)world position:(CGPoint)pos name:(NSString *)name
{
	id tablePart = [[self alloc] initWithWorld:world position:pos name:name];
#ifndef KK_ARC_ENABLED
	[tablePart autorelease];
#endif // KK_ARC_ENABLED
	return tablePart;
}

@end
