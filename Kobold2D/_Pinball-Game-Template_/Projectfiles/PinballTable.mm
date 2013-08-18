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

#import "PinballTable.h"
#import "Constants.h"
#import "Helper.h"
#import "TableSetup.h"
#import "GB2ShapeCache.h"
#import "BodyNode.h"
#import "SimpleAudioEngine.h"

@interface PinballTable (PrivateMethods)
-(void) initBox2dWorld;
-(void) enableBox2dDebugDrawing;
@end

@implementation PinballTable

+(id) node
{
	CCScene* scene = [CCScene node];
	PinballTable* layer = [PinballTable node];
	[scene addChild:layer];
	return scene;
}


-(id) init
{
	if ((self = [super init]))
	{
		// pre load the sprite frames from the texture atlas
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pinball.plist"];

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"pinball-shapes.plist"];

		// pre load audio effects
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"bumper.wav"];
		
        // init the box2d world
		[self initBox2dWorld];

		// uncomment this line to draw debug info
		//[self enableBox2dDebugDrawing];

		// load the background from the texture atlas
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background"];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
		[self addChild:background z:-3];

		// Set up table elements
		TableSetup* tableSetup = [TableSetup setupTableWithWorld:world];
		[self addChild:tableSetup z:-1];
		
		if ([CCDirector sharedDirector].currentDeviceIsIPad) 
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Note: the pinball table is not designed for iPad dimensions." fontName:@"Arial" fontSize:28];
			CGPoint labelPos = [[CCDirector sharedDirector] screenCenter];
			label.position = CGPointMake(labelPos.x, labelPos.y * 1.2f);
			label.color = ccYELLOW;
			[self addChild:label z:-10];
		}
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete contactListener;
	contactListener = NULL;
	
	delete debugDraw;
	debugDraw = NULL;

#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif // KK_ARC_ENABLED
}

-(void) initBox2dWorld
{
	// Construct a world object, which will hold and simulate the rigid bodies.
	b2Vec2 gravity = b2Vec2(0.0f, -5.0f);
	world = new b2World(gravity);
	world->SetAllowSleeping(YES);
	world->SetContinuousPhysics(YES);
	
	contactListener = new ContactListener();
	world->SetContactListener(contactListener);
	
	// for the screenBorder body we'll need these values
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	float widthInMeters = screenSize.width / PTM_RATIO;
	float heightInMeters = screenSize.height / PTM_RATIO;
	b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
	b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
	b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
	b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
	
	// Define the static container body, which will provide the collisions at screen borders.
	b2BodyDef screenBorderDef;
	screenBorderDef.position.Set(0, 0);
	b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
	b2EdgeShape screenBorderShape;
	
	// We only need the sides for the table:
	screenBorderShape.Set(lowerRightCorner, upperRightCorner);
	b2Fixture* leftBorderFixture = screenBorderBody->CreateFixture(&screenBorderShape, 0);
	screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
	b2Fixture* rightBorderFixture = screenBorderBody->CreateFixture(&screenBorderShape, 0);
	
    // set the collision flags: category and mask
    b2Filter collisonFilter;
    collisonFilter.groupIndex = 0;
    collisonFilter.categoryBits = 0x0010; // category = Wall
    collisonFilter.maskBits = 0x0001;     // mask = Ball

    leftBorderFixture->SetFilterData(collisonFilter);
    rightBorderFixture->SetFilterData(collisonFilter);
}

-(void) enableBox2dDebugDrawing
{
	float debugDrawScaleFactor = 1.0f;
#if KK_PLATFORM_IOS
	debugDrawScaleFactor = [[CCDirector sharedDirector] contentScaleFactor];
#endif
	debugDrawScaleFactor *= PTM_RATIO;

	debugDraw = new GLESDebugDraw(debugDrawScaleFactor);
	
	if (debugDraw)
	{
		UInt32 debugDrawFlags = 0;
		debugDrawFlags += b2Draw::e_shapeBit;
		debugDrawFlags += b2Draw::e_jointBit;
		//debugDrawFlags += b2Draw::e_aabbBit;
		//debugDrawFlags += b2Draw::e_pairBit;
		//debugDrawFlags += b2Draw::e_centerOfMassBit;
		
		debugDraw->SetFlags(debugDrawFlags);
		world->SetDebugDraw(debugDraw);
	}
}

-(void) update:(ccTime)delta
{
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(delta, velocityIterations, positionIterations);

	// for each body, get its assigned BodyNode and update the sprite's position
	for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
	{
		BodyNode* bodyNode = (__bridge BodyNode*)body->GetUserData();
		if (bodyNode != nil)
		{
			// update the sprite's position to where their physics bodies are
			bodyNode.position = [Helper toPixels:body->GetPosition()];
			float angle = body->GetAngle();
			bodyNode.rotation = -(CC_RADIANS_TO_DEGREES(angle));
		}
	}
}


#if DEBUG
-(void) draw
{
	[super draw];
	
	if (debugDraw)
	{
		ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
		kmGLPushMatrix();
		world->DrawDebugData();	
		kmGLPopMatrix();
	}
}
#endif

@end
