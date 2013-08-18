/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "TileMapLayer.h"
#import "SimpleAudioEngine.h"

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
		CCTMXTiledMap* tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"orthogonal.tmx"];
		tileMapHeightInPixels = tileMap.mapSize.height * tileMap.tileSize.height / CC_CONTENT_SCALE_FACTOR();
		[self addChild:tileMap z:-1 tag:TileMapNode];
		
		// Use a negative offset to set the tilemap's start position
		//tileMap.position = CGPointMake(-160, -120);

		// hide the event layer, we only need this information for code, not to display it
		CCTMXLayer* eventLayer = [tileMap layerNamed:@"GameEventLayer"];
		eventLayer.visible = NO;

		CCTMXLayer* winterLayer = [tileMap layerNamed:@"WinterLayer"];
		winterLayer.visible = NO;

#if KK_PLATFORM_IOS
		self.touchEnabled = YES;
#elif KK_PLATFORM_MAC
		self.mouseEnabled = YES;
#endif

		[[SimpleAudioEngine sharedEngine] preloadEffect:@"alien-sfx.caf"];
	}

	return self;
}

-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	// Tilemap position must be added as an offset, in case the tilemap position is not at 0,0 due to scrolling
	CGPoint pos = ccpSub(location, tileMap.position);
	
	// scaling tileSize to Retina display size if necessary
	float scaledWidth = tileMap.tileSize.width / CC_CONTENT_SCALE_FACTOR();
	float scaledHeight = tileMap.tileSize.height / CC_CONTENT_SCALE_FACTOR();
	// Cast to int makes sure that result is in whole numbers, tile coordinates will be used as array indices
	pos.x = (int)(pos.x / scaledWidth);
	pos.y = (int)((tileMap.mapSize.height * tileMap.tileSize.height - pos.y) / scaledHeight);
	
	CCLOG(@"touch at (%.0f, %.0f) is at tileCoord (%i, %i)", location.x, location.y, (int)pos.x, (int)pos.y);
	
	// make sure coordinates are within bounds
	pos.x = fminf(fmaxf(pos.x, 0), tileMap.mapSize.width - 1);
	pos.y = fminf(fmaxf(pos.y, 0), tileMap.mapSize.height - 1);
	
	return pos;
}

-(void) centerTileMapOnTileCoord:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	// center tilemap on the given tile pos
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CGPoint screenCenter = CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
	
	// tile coordinates are counted from upper left corner, this maps coordinates to lower left corner
	tilePos.y = (tileMap.mapSize.height - 1) - tilePos.y;
	
	// point is now at lower left corner of the screen
	CGPoint scrollPosition = CGPointMake(-(tilePos.x * tileMap.tileSize.width), 
										  -(tilePos.y * tileMap.tileSize.height));
	
	// offset point to center of screen and center of tile
	scrollPosition.x += screenCenter.x - tileMap.tileSize.width * 0.5f;
	scrollPosition.y += screenCenter.y - tileMap.tileSize.height * 0.5f;

	// make sure tilemap scrolling stops at the tilemap borders
	scrollPosition.x = MIN(scrollPosition.x, 0);
	scrollPosition.x = MAX(scrollPosition.x, -screenSize.width);
	scrollPosition.y = MIN(scrollPosition.y, 0);
	scrollPosition.y = MAX(scrollPosition.y, -screenSize.height);
	
	CCLOG(@"tilePos: (%i, %i) moveTo: (%.0f, %.0f)", (int)tilePos.x, (int)tilePos.y, scrollPosition.x, scrollPosition.y);
	
	CCAction* move = [CCMoveTo actionWithDuration:0.2f position:scrollPosition];
	[tileMap stopAllActions];
	[tileMap runAction:move];
}

-(CGRect) getRectFromObjectProperties:(NSDictionary*)dict tileMap:(CCTMXTiledMap*)tileMap
{
	float x, y, width, height;
	x = [[dict valueForKey:@"x"] floatValue] + tileMap.position.x;
	y = [[dict valueForKey:@"y"] floatValue] + tileMap.position.y;
	width = [[dict valueForKey:@"width"] floatValue];
	height = [[dict valueForKey:@"height"] floatValue];
	
	return CGRectMake(x, y, width, height);
}


-(void) tilemapTouchedAt:(CGPoint)location
{
	CCNode* node = [self getChildByTag:TileMapNode];
	NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
	CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
	
	// get the position in tile coordinates from the touch location
	CGPoint tilePos = [self tilePosFromLocation:location tileMap:tileMap];
	
	// move tilemap so that touched tiles is at center of screen
	[self centerTileMapOnTileCoord:tilePos tileMap:tileMap];
	
	// Check if the touch was on water (eg. tiles with isWater property drawn in GameEventLayer)
	bool isTouchOnWater = NO;
	CCTMXLayer* eventLayer = [tileMap layerNamed:@"GameEventLayer"];
	int tileGID = [eventLayer tileGIDAt:tilePos];
	
	if (tileGID != 0)
	{
		NSDictionary* properties = [tileMap propertiesForGID:tileGID];
		if (properties)
		{
			NSString* isWaterProperty = [properties valueForKey:@"isWater"];
			isTouchOnWater = ([isWaterProperty boolValue] == YES);
		}
	}
	
	// Check if the touch was within one of the rectangle objects
	CCTMXObjectGroup* objectLayer = [tileMap objectGroupNamed:@"ObjectLayer"];
	NSAssert([objectLayer isKindOfClass:[CCTMXObjectGroup class]], @"ObjectLayer not found or not a CCTMXObjectGroup");
	
	bool isTouchInRectangle = NO;
	NSUInteger numObjects = [[objectLayer objects] count];
	for (NSUInteger i = 0; i < numObjects; i++)
	{
		NSDictionary* properties = [[objectLayer objects] objectAtIndex:i];
		CGRect rect = [self getRectFromObjectProperties:properties tileMap:tileMap];
		
		if (CGRectContainsPoint(rect, location))
		{
			isTouchInRectangle = YES;
			break;
		}
	}
	
	// decide what to do depending on where the touch was ...
	if (isTouchOnWater)
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];
	}
	else if (isTouchInRectangle)
	{
		CCParticleSystem* system = [CCParticleSystemQuad particleWithFile:@"fx-explosion.plist"];
		system.autoRemoveOnFinish = YES;
		system.position = location;
		[self addChild:system z:1];
	}
	else
	{
		/*
		// get the winter layer and toggle its visibility
		CCTMXLayer* winterLayer = [tileMap layerNamed:@"WinterLayer"];
		winterLayer.visible = !winterLayer.visible;
		
		// remove the touched tile
		[winterLayer removeTileAt:tilePos];
		
		// adds a given tile
		tileGID = [winterLayer tileGIDAt:CGPointMake(0, 19)];
		[winterLayer setTileGID:tileGID at:tilePos];
		*/
	}
}


#if KK_PLATFORM_IOS

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView:[touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// get the position in tile coordinates from the touch location
	CGPoint location = [self locationFromTouch:[touches anyObject]];
	[self tilemapTouchedAt:location];
}

#elif KK_PLATFORM_MAC

-(BOOL) ccMouseDown:(NSEvent*)event
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	[self tilemapTouchedAt:location];
	return YES;
}

#endif



#ifdef DEBUG
-(void) drawRect:(CGRect)rect
{
	// Because there is no specialized rect drawing method the rect is drawn using 4 lines
	CGPoint pos1, pos2, pos3, pos4;
	pos1 = CGPointMake(rect.origin.x, rect.origin.y);
	pos2 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
	pos3 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
	pos4 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
	
	ccDrawLine(pos1, pos2);
	ccDrawLine(pos2, pos3);
	ccDrawLine(pos3, pos4);
	ccDrawLine(pos4, pos1);
}

// Draw the object rectangles for debugging and illustration purposes.
-(void) draw
{
	CCNode* node = [self getChildByTag:TileMapNode];
	NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
	CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
	
	// get the object layer
	CCTMXObjectGroup* objectLayer = [tileMap objectGroupNamed:@"ObjectLayer"];
	NSAssert([objectLayer isKindOfClass:[CCTMXObjectGroup class]], @"ObjectLayer not found or not a CCTMXObjectGroup");
	
	NSUInteger numObjects = [[objectLayer objects] count];
	for (NSUInteger i = 0; i < numObjects; i++)
	{
		NSDictionary* properties = [[objectLayer objects] objectAtIndex:i];
		CGRect rect = [self getRectFromObjectProperties:properties tileMap:tileMap];
		[self drawRect:rect];
	}

	// show center screen position
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CGPoint center = CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
	ccDrawCircle(center, 10, 0, 8, NO);
}
#endif

@end
