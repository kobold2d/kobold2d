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

#import "TableSetup.h"
#import "Flipper.h"
#import "TablePart.h"
#import "Bumper.h"
#import "Ball.h"
#import "Plunger.h"

@implementation TableSetup

-(void) addBumperAt:(CGPoint)pos inWorld:(b2World*)world
{
	Bumper* bumper = [Bumper bumperWithWorld:world position:pos];
	[self addChild:bumper];
}

-(id) initTableWithWorld:(b2World*)world
{
	if ((self = [super initWithFile:@"pinball.pvr.ccz" capacity:5]))
	{		
        // add the table blocks
        [self addChild:[TablePart tablePartInWorld:world
										  position:ccp(0, 480)
											  name:@"table-top"]];
		
        [self addChild:[TablePart tablePartInWorld:world
										  position:ccp(0, 0)
											  name:@"table-bottom"]];
		
        [self addChild:[TablePart tablePartInWorld:world
										  position:ccp(0, 263)
											  name:@"table-left"]];

        // Add some bumpers
		// upper center bumpers
		[self addBumperAt:ccp(150, 280) inWorld:world];
		[self addBumperAt:ccp(100, 320) inWorld:world];
		[self addBumperAt:ccp(200, 320) inWorld:world];
		[self addBumperAt:ccp(50, 360) inWorld:world];
		[self addBumperAt:ccp(250, 360) inWorld:world];
		[self addBumperAt:ccp(150, 410) inWorld:world];

		// side lane protection bumpers
		[self addBumperAt:ccp(0, 125) inWorld:world];
		[self addBumperAt:ccp(265, 150) inWorld:world];
		[self addBumperAt:ccp(27, 244) inWorld:world];

        // Add ball object
		Ball* ball = [Ball ballWithWorld:world];
		[self addChild:ball z:-1];
		
        // Add flippers
        Flipper *left = [Flipper flipperWithWorld:world flipperType:kFlipperLeft];
        [self addChild:left];
        
        Flipper *right = [Flipper flipperWithWorld:world flipperType:kFlipperRight];
        [self addChild:right];
        
        // Add plunger
        Plunger *plunger = [Plunger plungerWithWorld:world];
        [self addChild:plunger z:-1];
        
    }
	
	return self;
}

+(id) setupTableWithWorld:(b2World*)world
{
	id table = [[self alloc] initTableWithWorld:world];
#ifndef KK_ARC_ENABLED
	[table autorelease];
#endif // KK_ARC_ENABLED
	return table;
}

@end
