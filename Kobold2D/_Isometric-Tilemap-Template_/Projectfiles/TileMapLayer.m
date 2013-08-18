/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "TileMapLayer.h"
#import "Player.h"

// Why include Carbon? Because it defines the Mac's virtual key constants in HIToolbox/Events.h
// See here for the full virtual keyboard constants list: http://forums.macrumors.com/showthread.php?t=780577
// Will including Carbon.h increase your App size? No, because the Carbon framework isn't linked with the App and
// we're only using the keycodes enumeration (in other words: readable names for constant values).
#if KK_PLATFORM_MAC
#import <Carbon/Carbon.h>
#endif

@interface TileMapLayer (PrivateMethods)
-(void) startAutoMove:(ccTime)delta;
@end

@implementation TileMapLayer

+(id) node
{
	CCScene *scene = [CCScene node];
	TileMapLayer *layer = [TileMapLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCTMXTiledMap* tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"isometric-with-border.tmx"];
		[self addChild:tileMap z:-1 tag:TileMapNode];
		
		CCTMXLayer* layer = [tileMap layerNamed:@"Collisions"];
		layer.visible = NO;
		
		// Use a negative offset to set the tilemap's start position
		tileMap.position = CGPointMake(-500, -500);
		
		// define the extents of the playable area in tile coordinates
		const int borderSize = 10;
		playableAreaMin = CGPointMake(borderSize, borderSize);
		playableAreaMax = CGPointMake(tileMap.mapSize.width - 1 - borderSize, tileMap.mapSize.height - 1 - borderSize);
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		// Create the player and add it
		player = [Player player];
		player.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		// approximately position player's texture to best match the tile center position
		player.anchorPoint = CGPointMake(0.3f, 0.1f);
		[self addChild:player];

		// divide the screen into 4 areas
		screenCenter = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		upperLeft = CGRectMake(0, screenCenter.y, screenCenter.x, screenCenter.y);
		lowerLeft = CGRectMake(0, 0, screenCenter.x, screenCenter.y);
		upperRight = CGRectMake(screenCenter.x, screenCenter.y, screenCenter.x, screenCenter.y);
		lowerRight = CGRectMake(screenCenter.x, 0, screenCenter.x, screenCenter.y);

		// to move in any of these directions means to add/subtract 1 to/from the current tile coordinate
		moveOffsets[MoveDirectionNone] = CGPointZero;
		moveOffsets[MoveDirectionUpperLeft] = CGPointMake(-1, 0);
		moveOffsets[MoveDirectionLowerLeft] = CGPointMake(0, 1);
		moveOffsets[MoveDirectionUpperRight] = CGPointMake(0, -1);
		moveOffsets[MoveDirectionLowerRight] = CGPointMake(1, 0);

		[self schedule:@selector(startAutoMove:) interval:0.4f];
		currentMoveDirection = MoveDirectionLowerLeft;
		
		// continuously check for walking
		[self scheduleUpdate];

#if KK_PLATFORM_IOS
		self.touchEnabled = YES;
#elif KK_PLATFORM_MAC
		self.keyboardEnabled = YES;
#endif
	}

	return self;
}

-(void) startAutoMove:(ccTime)delta
{
	[self unschedule:_cmd];
	currentMoveDirection = MoveDirectionLowerRight;
}

-(bool) isTilePosBlocked:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	CCTMXLayer* layer = [tileMap layerNamed:@"Collisions"];
	NSAssert(layer != nil, @"Collisions layer not found!");
	
	bool isBlocked = NO;
	unsigned int tileGID = [layer tileGIDAt:tilePos];
	if (tileGID > 0)
	{
		NSDictionary* tileProperties = [tileMap propertiesForGID:tileGID];
		id blocks_movement = [tileProperties objectForKey:@"blocks_movement"];
		isBlocked = (blocks_movement != nil);
	}

	return isBlocked;
}

-(CGPoint) ensureTilePosIsWithinBounds:(CGPoint)tilePos
{
	// make sure coordinates are within bounds of the playable area
	tilePos.x = MAX(playableAreaMin.x, tilePos.x);
	tilePos.x = MIN(playableAreaMax.x, tilePos.x);
	tilePos.y = MAX(playableAreaMin.y, tilePos.y);
	tilePos.y = MIN(playableAreaMax.y, tilePos.y);

	return tilePos;
}

-(CGPoint) floatingTilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	// Tilemap position must be added as an offset, in case the tilemap position is not at 0,0 due to scrolling
	CGPoint pos = ccpSub(location, tileMap.position);
	
	float halfMapWidth = tileMap.mapSize.width * 0.5f;
	float mapHeight = tileMap.mapSize.height;
	float tileWidth = tileMap.tileSize.width / CC_CONTENT_SCALE_FACTOR();
	float tileHeight = tileMap.tileSize.height / CC_CONTENT_SCALE_FACTOR();
	
	CGPoint tilePosDiv = CGPointMake(pos.x / tileWidth, pos.y / tileHeight);
	float mapHeightDiff = mapHeight - tilePosDiv.y;
	
	// Cast to int makes sure that result is in whole numbers, tile coordinates will be used as array indices
	float posX = (mapHeightDiff + tilePosDiv.x - halfMapWidth);
	float posY = (mapHeightDiff - tilePosDiv.x + halfMapWidth);

	return CGPointMake(posX, posY);
}

-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	CGPoint pos = [self floatingTilePosFromLocation:location tileMap:tileMap];

	// make sure coordinates are within bounds of the playable area, and cast to int
	pos = [self ensureTilePosIsWithinBounds:CGPointMake((int)pos.x, (int)pos.y)];
	
	//CCLOG(@"touch at (%.0f, %.0f) is at tileCoord (%i, %i)", location.x, location.y, (int)pos.x, (int)pos.y);
	
	return pos;
}

-(void) centerTileMapOnTileCoord:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	// get the ground layer
	CCTMXLayer* layer = [tileMap layerNamed:@"Ground"];
	NSAssert(layer != nil, @"Ground layer not found!");
	
	// internally tile Y coordinates seem to be off by 1, this fixes the returned pixel coordinates
	tilePos.y -= 1;
	
	// get the pixel coordinates for a tile at these coordinates
	CGPoint scrollPosition = [layer positionAt:tilePos];
	// negate the position for scrolling
	scrollPosition = ccpMult(scrollPosition, -1);
	// add offset to screen center
	scrollPosition = ccpAdd(scrollPosition, screenCenter);
	
	CCLOG(@"tilePos: (%i, %i) moveTo: (%.0f, %.0f)", (int)tilePos.x, (int)tilePos.y, scrollPosition.x, scrollPosition.y);
	
	CCAction* move = [CCMoveTo actionWithDuration:0.2f position:scrollPosition];
	[tileMap stopAllActions];
	[tileMap runAction:move];
}


#if KK_PLATFORM_IOS

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:[touches anyObject]];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// get the position in tile coordinates from the touch location
	CGPoint touchLocation = [self locationFromTouches:touches];

	// check on which screen quadrant the touch was and set the move direction accordingly
	if (CGRectContainsPoint(upperLeft, touchLocation))
	{
		currentMoveDirection = MoveDirectionUpperLeft;
	}
	else if (CGRectContainsPoint(lowerLeft, touchLocation))
	{
		currentMoveDirection = MoveDirectionLowerLeft;
	}
	else if (CGRectContainsPoint(upperRight, touchLocation))
	{
		currentMoveDirection = MoveDirectionUpperRight;
	}
	else if (CGRectContainsPoint(lowerRight, touchLocation))
	{
		currentMoveDirection = MoveDirectionLowerRight;
	}
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	currentMoveDirection = MoveDirectionNone;
}

#elif KK_PLATFORM_MAC

// Mac keyboard event processing uses the Carbon keycodes.
// See here for the full list: http://forums.macrumors.com/showthread.php?t=780577
// Nice visual key mapping: http://boredzo.org/blog/archives/2007-05-22/virtual-key-codes

// NOTE: unlike Windows apps your Mac app won't "miss" key events if the app's window loses focus.

-(BOOL) ccKeyDown:(NSEvent*)keyDownEvent
{
	UInt16 keyCode = [keyDownEvent keyCode];
	
	switch (keyCode)
	{
		case kVK_UpArrow:
			currentMoveDirection = MoveDirectionUpperRight;
			break;
		case kVK_DownArrow:
			currentMoveDirection = MoveDirectionLowerLeft;
			break;
		case kVK_LeftArrow:
			currentMoveDirection = MoveDirectionUpperLeft;
			break;
		case kVK_RightArrow:
			currentMoveDirection = MoveDirectionLowerRight;
			break;
			
		default:
			// ignore unhandled keypresses
			break;
	}
	
	return YES;
}

-(BOOL) ccKeyUp:(NSEvent*)keyUpEvent
{
	UInt16 keyCode = [keyUpEvent keyCode];
	
	switch (keyCode)
	{
		case kVK_UpArrow:
		case kVK_DownArrow:
		case kVK_LeftArrow:
		case kVK_RightArrow:
			currentMoveDirection = MoveDirectionNone;
			break;
			
		default:
			// ignore unhandled keypresses
			break;
	}
	
	return YES;
}

-(BOOL) ccFlagsChanged:(NSEvent*)event
{
	// Not used, can be used to keep track of Command, Option, etc key states
	CCLOG(@"flags changes: %@", event);
	return NO;
}

#endif

-(void) update:(ccTime)delta
{
	CCNode* node = [self getChildByTag:TileMapNode];
	NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
	CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;

	// if the tilemap is currently being moved, wait until it's done moving
	if ([tileMap numberOfRunningActions] == 0)
	{
		if (currentMoveDirection != MoveDirectionNone)
		{
			// player is always standing on the tile which is centered on the screen
			CGPoint tilePos = [self tilePosFromLocation:screenCenter tileMap:tileMap];
			
			// get the tile coordinate offset for the direction we're moving to
			NSAssert(currentMoveDirection < MAX_MoveDirections, @"invalid move direction!");
			CGPoint offset = moveOffsets[currentMoveDirection];
			
			// offset the tile position and then make sure it's within bounds of the playable area
			tilePos = CGPointMake(tilePos.x + offset.x, tilePos.y + offset.y);
			tilePos = [self ensureTilePosIsWithinBounds:tilePos];
			
			if ([self isTilePosBlocked:tilePos tileMap:tileMap] == NO)
			{
				// move tilemap so that touched tiles is at center of screen
				[self centerTileMapOnTileCoord:tilePos tileMap:tileMap];
			}
		}
	}

	// continuously fix the player's Z position
	CGPoint tilePos = [self floatingTilePosFromLocation:screenCenter tileMap:tileMap];
	[player updateVertexZ:tilePos tileMap:tileMap];
}

#ifdef DEBUG
// Draw the object rectangles for debugging and illustration purposes.
-(void) draw
{
	[super draw];
	
	/*
	CCNode* node = [self getChildByTag:TileMapNode];
	NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
	CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;

	// draw each tile's center point as crosshair
	CCTMXLayer* layer1 = [tileMap layerNamed:@"Ground"];
	int width = layer1.layerSize.width;
	int height = layer1.layerSize.height;
	
	for (int x = 0; x < width; x++)
	{
		for (int y = 0; y < height; y++)
		{
			CGPoint tileCoord = CGPointMake(x, y);
			CGPoint tilePos = [layer1 positionAt:tileCoord];
			
			CGPoint center = ccpAdd(tilePos, tileMap.position);
			center = ccpAdd(center, CGPointMake(54 * 0.5f, 49 * 0.25f + 1));
			
			float lineLength = 4;
			CGPoint point1, point2;
			point1 = CGPointMake(center.x - lineLength, center.y);
			point2 = CGPointMake(center.x + lineLength, center.y);
			ccDrawLine(point1, point2);
			point1 = CGPointMake(center.x, center.y - lineLength);
			point2 = CGPointMake(center.x, center.y + lineLength);
			ccDrawLine(point1, point2);
		}
	}
	*/
	
	/*
	// show center screen position
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CGPoint center = CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
	ccDrawCircle(center, 10, 0, 8, NO);
	 */
	
	/*
	for (int w = 0; w < screenSize.width; w++)
	{
		for (int h = 0; h < screenSize.height; h++)
		{
			CGPoint location = CGPointMake(w, h);
			CGPoint tilePos = [self tilePosFromLocation:location tileMap:tileMap];
			if (tilePos.x < 0 || tilePos.x >= 30 || tilePos.y < 0 || tilePos.y >= 30)
				continue;
			
			glColor4f((int)tilePos.x % 2, (int)tilePos.y % 2, 0.5f, 1);
			ccDrawPoint(location);
		}
	}
	*/
}
#endif

@end
