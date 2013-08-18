/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"

typedef enum
{
	kSpriteBatchModeNoSpriteBatch = 0,
	kSpriteBatchModeOneSpriteBatch,
	
	kSpriteBatchModes_Count,
} ESpriteBatchModes;

@interface HelloWorldLayer : CCLayer
{
	CCNode* spriteContainer;
	
	NSUInteger currentImageName;
	NSMutableArray* imageNames;
	
	CCLabelTTF* modeLabel;
	CCLabelTTF* numSpritesLabel;

	ESpriteBatchModes currentMode;
	
	int numberOfSprites;
	int increaseSpritesCounter;
	
	int numberOfSpritesToStartWith;
	float increaseNumberOfSpritesByFactor;
	int increaseNumberOfSpritesThisManyTimes;
	
	int deltaTooHighCounter;
}

@property (nonatomic) int numberOfSpritesToStartWith;
@property (nonatomic) float increaseNumberOfSpritesByFactor;
@property (nonatomic) int increaseNumberOfSpritesThisManyTimes;

@end
