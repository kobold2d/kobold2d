/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "HelloWorldLayer.h"

@interface HelloWorldLayer (PrivateMethods)
-(void) startOver;
-(void) nextMode;
-(void) turnOnUpdate:(ccTime)delta;
@end

@implementation HelloWorldLayer

@synthesize numberOfSpritesToStartWith, increaseNumberOfSpritesByFactor, increaseNumberOfSpritesThisManyTimes;

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@ init", NSStringFromClass([self class]));

		glClearColor(0.3f, 0.2f, 0.1f, 1.0f);

		// get the hello world string from the config.lua file
		[KKConfig injectPropertiesFromKeyPath:@"SpriteBatchSettings" target:self];
		
		[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game-art.plist"];
		
		// Comment out some of the image names to test with a smaller variety of images.
		// The greater variety of images the more performance increase you'll see
		// when you are using a texture atlas and sprite batching.
		imageNames = [[NSMutableArray alloc] initWithObjects:
					  /*
					  @"bg1.png",
					  @"bg2.png",
					  @"bg3.png",
					  @"bg4.png",
					   */
					  @"bg5.png",
					  @"bg6.png",

					  @"ship.png", 
					  @"monster-a.png", 
					  @"monster-b.png",
					  @"monster-c.png", 
					  @"ship-anim0.png", 
					  @"ship-anim1.png", 
					  @"ship-anim2.png", 
					  @"ship-anim3.png",
					  @"ship-anim4.png",
					  @"monster-a-anim0.png",
					  @"monster-a-anim1.png",
					  @"monster-a-anim2.png",
					  nil];
		
		// start from the beginning
		[self startOver];
		[self nextMode];
		
		CCDirector* director = [CCDirector sharedDirector];
		
		// Disable the FPS display in iOS Simulator because this test is *only* meaningful when run on a device.
		// The performance of the iOS Simulator is completely irrelevant, misleading, and should not be referred.
		// The Simulator does software rendering on your Mac's CPU. The devices use hardware graphics acceleration.
		// Depending on your code and Mac's CPU, the Simulator performance may be radically faster OR slower than a particular iOS device.
		if (director.currentDeviceIsSimulator)
		{
			director.displayStats = NO;
			
			int fontSize = (director.currentDeviceIsIPad) ? 40 : 20;
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Run this test on an iOS Device to see the Framerate." fontName:@"Arial" fontSize:fontSize];
			label.position = director.screenCenter;
			label.color = ccMAGENTA;
			[self addChild:label z:111];
		}

#if KK_PLATFORM_IOS
		self.touchEnabled = YES;
#elif KK_PLATFORM_MAC
		self.mouseEnabled = YES;
#endif
	}

	return self;
}

#ifndef KK_ARC_ENABLED
-(void) dealloc
{
	[imageNames release];
	[super dealloc];
}
#endif // KK_ARC_ENABLED

-(void) updateModeLabelString
{
	switch (currentMode)
	{
		case kSpriteBatchModeNoSpriteBatch:
			[modeLabel setString:@"No Sprite Batching"];
			break;
		case kSpriteBatchModeOneSpriteBatch:
			[modeLabel setString:@"With Sprite Batching & PVR"];
			break;
			
		default:
			[modeLabel setString:@"<undefined mode>"];
			break;
	}
}

-(void) startOver
{
	[self removeAllChildrenWithCleanup:YES];
	
	CCDirector* director = [CCDirector sharedDirector];

	spriteContainer = [CCNode node];
	[self addChild:spriteContainer z:0 tag:111111];

	modeLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:30];
	CGPoint labelPos = [director screenCenter];
	labelPos.y = [[CCDirector sharedDirector] screenSize].height;
	modeLabel.position = labelPos;
	modeLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
	[self addChild:modeLabel z:101];
	
	int fontSize = (director.currentDeviceIsIPad || director.currentPlatformIsMac) ? 36 : 24;
	numSpritesLabel = [CCLabelTTF labelWithString:@"" fontName:@"Courier" fontSize:fontSize];
	numSpritesLabel.position = CGPointMake([director screenSize].width, 0);
	numSpritesLabel.anchorPoint = CGPointMake(1.0f, 0.0f);
	numSpritesLabel.color = ccYELLOW;
	[self addChild:numSpritesLabel z:101];
	
	currentMode = -1;
	numberOfSprites = numberOfSpritesToStartWith;
	increaseSpritesCounter = 0;
}

-(CCSpriteBatchNode*) addSpriteBatchNode
{
	// get any frame from the texture atlas to get the texture atlas' texture
	CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ship.png"];
	CCSpriteBatchNode* batchNode = [CCSpriteBatchNode batchNodeWithTexture:frame.texture capacity:numberOfSprites];
	[spriteContainer addChild:batchNode];
	
	return batchNode;
}

-(CCSprite*) createNextSpriteFromList
{
	NSString* imageName = [imageNames objectAtIndex:currentImageName];
	currentImageName++;
	if (currentImageName >= [imageNames count])
	{
		currentImageName = 0;
	}
	
	CCSprite* sprite = nil;
	
	if (currentMode == kSpriteBatchModeNoSpriteBatch)
	{
		sprite = [CCSprite spriteWithFile:imageName];
	}
	else
	{
		sprite = [CCSprite spriteWithSpriteFrameName:imageName];
	}
	
	return sprite;
}

-(void) nextMode
{
	currentMode++;
	if (currentMode >= kSpriteBatchModes_Count)
	{
		currentMode = 0;

		increaseSpritesCounter++;
		numberOfSprites *= increaseNumberOfSpritesByFactor;
		
		if (increaseSpritesCounter >= increaseNumberOfSpritesThisManyTimes)
		{
			increaseSpritesCounter = 0;
			numberOfSprites = numberOfSpritesToStartWith;
		}
	}
	
	CCDirector* director = [CCDirector sharedDirector];
	[spriteContainer removeAllChildrenWithCleanup:YES];

	// define the area where the sprites should be displayed
	CGSize drawArea = director.screenSize;
	drawArea.width *= 0.98f;
	drawArea.height *= 0.82f;
	
	CCNode* currentContainer = spriteContainer;
	if (currentMode != kSpriteBatchModeNoSpriteBatch) 
	{
		currentContainer = [self addSpriteBatchNode];
	}
	
	// always seed the randomizer with the same seed so that results are comparable
	srandom(99989);
	currentImageName = 0;
	
	for (int i = 0; i < numberOfSprites; i++)
	{
		// alternate between one of two images (worst case scenario)
		CCSprite* sprite = [self createNextSpriteFromList];
		
		// make sure image fits entirely on screen
		float xRange = fmaxf(drawArea.width - sprite.contentSize.width, 0);
		float yRange = fmaxf(drawArea.height - sprite.contentSize.height, 0);
		
		CGPoint pos = director.screenCenter;
		pos.x += (CCRANDOM_0_1() * xRange) - (xRange * 0.5f);
		pos.y += (CCRANDOM_0_1() * yRange) - (yRange * 0.5f);
		sprite.position = pos;
		
		[currentContainer addChild:sprite z:CCRANDOM_0_1() * 100];
	}
	
	[self updateModeLabelString];
	
	NSString* string = [NSString stringWithFormat:@"Sprites: %4i", numberOfSprites];
	[numSpritesLabel setString:string];
	
	// reset update scheduling and delta counter
	// wait before rescheduling because after loading images the delta will be high the first few frames
	deltaTooHighCounter = 0;
	[self unscheduleUpdate];
	[self schedule:@selector(turnOnUpdate:) interval:0.1f];
}

-(void) turnOnUpdate:(ccTime)delta
{
	[self unschedule:_cmd];
	[self scheduleUpdate];
}

-(void) update:(ccTime)delta
{
	// monitor delta time ... if it goes too high (absolutely constant) abort the test
	if (delta >= 0.016666f && delta <= 0.016667f)
	{
		deltaTooHighCounter++;
		if (deltaTooHighCounter > 6)
		{
			deltaTooHighCounter = 0;
			// abort the test, delta was too high for too loong
			[spriteContainer removeAllChildrenWithCleanup:YES];
			
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"FPS too low to measure ..." fontName:@"Arial" fontSize:40];
			label.position = [[CCDirector sharedDirector] screenCenter];
			label.color = ccBLUE;
			[spriteContainer addChild:label z:123];
			
		}
	}
	else
	{
		deltaTooHighCounter = 0;
	}
}

#if KK_PLATFORM_IOS
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self nextMode];
}

#elif KK_PLATFORM_MAC
-(BOOL) ccMouseUp:(NSEvent*)event
{
	[self nextMode];
	return NO;
}
#endif

@end
