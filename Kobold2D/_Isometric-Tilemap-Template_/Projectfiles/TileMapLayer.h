/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"

#import "Player.h"

enum
{
	TileMapNode = 0,
};

typedef enum
{
	MoveDirectionNone = 0,
	MoveDirectionUpperLeft,
	MoveDirectionLowerLeft,
	MoveDirectionUpperRight,
	MoveDirectionLowerRight,
	
	MAX_MoveDirections,
} EMoveDirection;

@interface TileMapLayer : CCLayer
{
	CGPoint playableAreaMin, playableAreaMax;

	Player* player;

	CGPoint screenCenter;
	CGRect upperLeft, lowerLeft, upperRight, lowerRight;
	CGPoint moveOffsets[MAX_MoveDirections];
	EMoveDirection currentMoveDirection;
}

+(id) node;

@end
