/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "BodyNode.h"

@interface Plunger : BodyNode
{
	b2PrismaticJoint* joint;
}

+(id) plungerWithWorld:(b2World*)world;

@end
