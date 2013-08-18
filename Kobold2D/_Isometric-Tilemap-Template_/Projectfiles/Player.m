/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "Player.h"


@implementation Player

+(id) player
{
	id player = [[self alloc] initWithFile:@"ninja.png"];
#ifndef KK_ARC_ENABLED
	[player autorelease];
#endif // KK_ARC_ENABLED
	return player;
}

-(void) updateVertexZ:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	// Lowest Z value is at the origin point and its value is equal to map width + height.
	// This is because automatic vertexZ values are not counted along rows or columns of tilemap coordinates,
	// but horizontally (diagonally in tilemap coordinates). Eg the tiles at coordinates:
	// 0,4 / 1,3 / 2,2 / 3,1 / 4,0 all have the same vertexZ value.
	float lowestZ = -(tileMap.mapSize.width + tileMap.mapSize.height);
	
	// Current Z value is simply the sum of the current tile coordinates.
	float currentZ = tilePos.x + tilePos.y;
	
	// Subtract 1.5f to always make the player appear behind the objects he is positioned at.
	// It's now 1.5f because the tilePos is no longer integer-based
	self.vertexZ = lowestZ + currentZ - 1.5f;
	
	//CCLOG(@"vertexZ: %.3f at tile pos: (%.1f, %.1f) -- lowestZ: %.0f, currentZ: %.1f", self.vertexZ, tilePos.x, tilePos.y, lowestZ, currentZ);
}

@end
