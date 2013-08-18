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

#import "cocos2d.h"
#import "GLES-Render.h"
#import "ContactListener.h"
#import "Box2D.h"

@interface PinballTable : CCLayer
{
	b2World* world;
	ContactListener* contactListener;
	
	GLESDebugDraw* debugDraw;
}

+(id) node;

@end
