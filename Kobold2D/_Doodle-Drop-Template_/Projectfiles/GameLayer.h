/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameLayer : CCLayer
{
	CCSprite* player;
	CGPoint playerVelocity;
	
	// CCArray is cocos2d's undocumented array class optimized to perform better than NSArray.
	// You can find the class' implementation in the cocos2d/support folder.
	CCArray* spiders;
	
	float spiderMoveDuration;
	int numSpidersMoved;
	
	// Used for Scores
	ccTime totalTime;
	int score;
	CCLabelBMFont* scoreLabel;
	
	// Mac variables
	BOOL isGameOver;
	float currentKeyAcceleration;
}

@end
