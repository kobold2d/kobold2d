/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "GameLayer.h"

// To use audio with cocos2d seperate headers must be added. In this case I'll go with the SimpleAudioEngine.
#import "SimpleAudioEngine.h"

// By adding another @interface with the same name of the class but adding an identifier in brackets
// you can define private class methods. These are methods which are only used in this class and should
// not be used by other classes. Adding these method definitions gets rid of the "may not respond to selector"
// warning messages. The warning messages are not the problem, the problem is when the warning holds true
// and one of the selectors really can't respond. Typically due to a spelling mistake. In that case the App
// would simply crash. It's good practice to get rid of "may not respond to selector" warnings since they can
// be important indicators to potential crashes.
@interface GameLayer (PrivateMethods)
-(void) initSpiders;
-(void) resetSpiders;
-(void) spidersUpdate:(ccTime)delta;
-(void) runSpiderMoveSequence:(CCSprite*)spider;
-(void) runSpiderWiggleSequence:(CCSprite*)spider;
-(void) spiderDidDrop:(id)sender;
-(void) checkForCollision;
-(void) showGameOver;
-(void) resetGame;
@end


// These three values control how the player is moved. I call such values "design parameters" as they 
// need to be tweaked a lot and are critical for the game to "feel right".
// Sometimes, like in the case with deceleration and sensitivity, such values can affect one another.
// For example if you increase deceleration, the velocity will reach maxSpeed faster while the effect
// of sensitivity is reduced.

// this controls how quickly the velocity decelerates (lower = quicker to change direction)
const float deceleration = 0.4f;
// this determines how sensitive the accelerometer reacts (higher = more sensitive)
const float sensitivity = 6.0f;
// how fast the velocity can be at most
const float maxVelocity = 100.0f;
// constant keyboard acceleration value for Mac version
const float keyAcceleration = 0.3f;


@implementation GameLayer

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

		// Yes, we want to receive accelerometer input events.
		[KKInput sharedInput].accelerometerActive = YES;
		[KKInput sharedInput].acceleration.filteringFactor = 0.2f;
		
		// Create and add the player sprite.
		// The player variable does not need to be retained because cocos2d retains it as long as it is a child
		// of this layer. If you ever were to remove the player sprite from this layer you have to set the player
		// variable to nil because its memory will then be released.
		player = [CCSprite spriteWithFile:@"alien.png"];
		[self addChild:player z:0 tag:1];
		
		// Placing the sprite - it should start horizontally centered and with its feet on the ground (bottom of screen).
		// To place the player at the bottom of the screen we take the player's bounding box. Because the Player's
		// texture is centered on its position we need to lift it up by half the height.
		// This is preferable to modifying the anchorPoint because we use the player position for collision detection
		// so it should remain at the center of the texture.
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageHeight = [player texture].contentSize.height;
		player.position = CGPointMake(screenSize.width / 2, imageHeight / 2);
		
		[self initSpiders];
		
		// Add the score label with z value of -1 so it's drawn below everything else
		scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapfont.fnt"];
		scoreLabel.position = CGPointMake(screenSize.width / 2, screenSize.height);
		// Adjust the label's anchorPoint's y position to make it align with the top.
		scoreLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
		[self addChild:scoreLabel z:-1];
		
		// Play the background music in an endless loop.
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"blues.mp3" loop:YES];
		
		// Preload the sound effect into memory so there's no delay when playing it the first time.
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"alien-sfx.caf"];
		
		// Seed the randomizer once with the current time. This way the game doesn't start with the same sequence
		// of spiders dropping every time it is started.
		srandom((UInt32)time(NULL));
		
		// start with game over first
		[self showGameOver];
	}

	return self;
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	// The spiders array must be released because it was created using [CCArray alloc]
	[spiders release];
	[super dealloc];
#endif // KK_ARC_ENABLED
}

#pragma mark Spiders

-(void) initSpiders
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	// Creating a temporary spider sprite because its the easiest way to get the image's size
	CCSprite* tempSpider = [CCSprite spriteWithFile:@"spider.png"];
	float imageWidth = [tempSpider texture].contentSize.width;
	// Note: by not adding the tempSpider as child its memory will be freed automatically!
	
	// There should be as many spiders as can fit next to each other over the whole screen width.
	// The number of spiders will automatically scale depending on the device's screen size.
	int numSpiders = screenSize.width / imageWidth;

	// Initialize the spiders array. Make sure it hasn't been initialized before.
	NSAssert1(spiders == nil, @"%@: spiders array is already initialized!", NSStringFromSelector(_cmd));
	spiders = [[CCArray alloc] initWithCapacity:numSpiders];
	
	for (int i = 0; i < numSpiders; i++)
	{
		// Creating a spider sprite, positioning will be done later
		CCSprite* spider = [CCSprite spriteWithFile:@"spider.png"];
		[self addChild:spider z:0 tag:2];
		
		// Also add the spider to the spiders array so it can be accessed more easily.
		[spiders addObject:spider];
	}
	
	[self resetSpiders];
}

// Positioning the Spiders is seperated into another method because Spiders will need to be re-positioned
// after game over. This is more effective than throwing away all spider CCSprites and re-creating them.
-(void) resetSpiders
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	// Get any spider to get its image width
	CCSprite* tempSpider = [spiders lastObject];
	CGSize imageSize = [tempSpider texture].contentSize;

	// Cache [spiders count] for the duration of the loop to avoid repetitive and unnecessary calls to [spiders count].
	NSUInteger numSpiders = [spiders count];
	for (NSUInteger i = 0; i < numSpiders; i++)
	{
		// Adjust each spider's horizontal position to be spread across the screen width, one next to the other.
		// The vertical position will be just above the upper screen edge so that the spiders are all off-screen.
		CCSprite* spider = [spiders objectAtIndex:i];
		spider.position = CGPointMake(imageSize.width * i + imageSize.width * 0.5f, screenSize.height + imageSize.height);
		spider.scale = 1;
		
		// It might still be moving, it'll have to stop.
		[spider stopAllActions];
	}
	
	// Unschedule the selector just in case. If it isn't scheduled it won't do anything.
	[self unschedule:@selector(spidersUpdate:)];
	// Schedule the spider update logic to run at the given interval.
	[self schedule:@selector(spidersUpdate:) interval:0.6f];
	
	// reset the moved spiders counter and spider move duration (affects spider's speed)
	numSpidersMoved = 0;
	spiderMoveDuration = 8.0f;
}

-(void) spidersUpdate:(ccTime)delta
{
	// Try to find a spider which isn't currently moving for an arbitrary number of times.
	// If one isn't found within 10 tries we'll just try again next time spidersUpdate is called.
	for (int i = 0; i < 10; i++)
	{
		int randomSpiderIndex = CCRANDOM_0_1() * [spiders count];
		CCSprite* spider = [spiders objectAtIndex:randomSpiderIndex];
		
		// If the spider isn't moving it should have no running actions, in that case it's ready to go.
		if ([spider numberOfRunningActions] == 0)
		{
			// If you're curious how often the for i < 10 loop is actually run ...
			if (i > 0)
			{
				CCLOG(@"Dropping a Spider after %i retries.", i);
			}

			[self runSpiderMoveSequence:spider];
			
			// We only want one spider to start moving at a time, so we'll end the for loop by using the break statement.
			break;
		}
	}
}

-(void) runSpiderMoveSequence:(CCSprite*)spider
{
	// By keeping track of the spiders which started moving we can slowly increase their speed over time.
	// In this case after every 4th spider the move duration will be decreased down to a minimum of 1 second.
	numSpidersMoved++;
	if (numSpidersMoved % 4 == 0 && spiderMoveDuration > 2.0f)
	{
		spiderMoveDuration -= 0.1f;
	}

	// This is the sequence which controls the spiders' movement. A CCCallFuncN is used to reset the
	// spider once it has moved outside the lower border of the screen, which is when it can be re-used.
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CGPoint hangInTherePosition = CGPointMake(spider.position.x, screenSize.height - 3 * [spider texture].contentSize.height);
	CGPoint belowScreenPosition = CGPointMake(spider.position.x, -(3 * [spider texture].contentSize.height));
	CCMoveTo* moveHang = [CCMoveTo actionWithDuration:4 position:hangInTherePosition];
	CCEaseElasticOut* easeHang = [CCEaseElasticOut actionWithAction:moveHang period:0.8f];
	CCMoveTo* moveEnd = [CCMoveTo actionWithDuration:spiderMoveDuration position:belowScreenPosition];
	CCEaseBackInOut* easeEnd = [CCEaseBackInOut actionWithAction:moveEnd];
	CCCallFuncN* callDidDrop = [CCCallFuncN actionWithTarget:self selector:@selector(spiderDidDrop:)];
	CCSequence* sequence = [CCSequence actions:easeHang, easeEnd, callDidDrop, nil];
	[spider runAction:sequence];
	
	// For some reason this interferes with gameplay ... if enabled, spiders will drop only once!
	//[self runSpiderWiggleSequence:spider];
}

-(void) runSpiderWiggleSequence:(CCSprite*)spider
{
	// Do something icky with the spiders ...
	CCScaleTo* scaleUp = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:1.05f];
	CCEaseBackInOut* easeUp = [CCEaseBackInOut actionWithAction:scaleUp];
	CCScaleTo* scaleDown = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:0.95f];
	CCEaseBackInOut* easeDown = [CCEaseBackInOut actionWithAction:scaleDown];
	CCSequence* scaleSequence = [CCSequence actions:easeUp, easeDown, nil];
	CCRepeatForever* repeatScale = [CCRepeatForever actionWithAction:scaleSequence];
	[spider runAction:repeatScale];
}


// Called by CCCallFuncN whenever a spider has ended its sequence of actions. It means at this time the spider will be
// outside the bottom of the screen and can be moved back to outside the top of the screen.
-(void) spiderDidDrop:(id)sender
{
	// Make sure sender is actually of the right class.
	NSAssert([sender isKindOfClass:[CCSprite class]], @"sender is not of class CCSprite!");
	CCSprite* spider = (CCSprite*)sender;
	
	// move the spider back up outside the top of the screen
	CGPoint pos = spider.position;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	pos.y = screenSize.height + [spider texture].contentSize.height;
	spider.position = pos;
}

// #pragma mark statements are a nice way to categorize your code and to use them as "bookmarks"
#pragma mark Player Movement

-(void) acceleratePlayerWithX:(double)xAcceleration
{
	// adjust velocity based on current accelerometer acceleration
	playerVelocity.x = (playerVelocity.x * deceleration) + (xAcceleration * sensitivity);
	
	// we must limit the maximum velocity of the player sprite, in both directions (positive & negative values)
	if (playerVelocity.x > maxVelocity)
	{
		playerVelocity.x = maxVelocity;
	}
	else if (playerVelocity.x < -maxVelocity)
	{
		playerVelocity.x = -maxVelocity;
	}
	
	// Alternatively, the above if/else if block can be rewritten using fminf and fmaxf more neatly like so:
	// playerVelocity.x = fmaxf(fminf(playerVelocity.x, maxVelocity), -maxVelocity);
}

#pragma mark update

-(void) update:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];
	if (isGameOver)
	{
		if (input.anyTouchEndedThisFrame || [input isKeyDown:KKKeyCode_Space] || [input isKeyDown:KKKeyCode_Return])
		{
			[self resetGame];
		}
	}
	else
	{
		[self acceleratePlayerWithX:input.acceleration.smoothedX];
		
		if ([input isKeyDown:KKKeyCode_LeftArrow])
		{
			[self acceleratePlayerWithX:-keyAcceleration];
		}
		else if ([input isKeyDown:KKKeyCode_RightArrow])
		{
			[self acceleratePlayerWithX:keyAcceleration];
		}
		
		// Keep adding up the playerVelocity to the player's position
		// This requires a temporary variable because you can't modify player.position.x directly. Objective-C properties
		// work a little different than what you may be used to from other languages. The problem is that player.position
		// actually is a method call [player position] and you simply can't change a member ".x" of that method. In other words,
		// you can't change members of struct properties like CGPoint, CGRect, CGSize directly through a property getter method.
		CGPoint pos = player.position;
		pos.x += playerVelocity.x;
		
		// The seemingly obvious alternative won't work in Objective-C! It'll give you the following error.
		// ERROR: lvalue required as left operand of assignment
		// player.position.x += playerVelocity.x;
		
		// The Player should also be stopped from going outside the screen
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageWidthHalved = [player texture].contentSize.width * 0.5f;
		float leftBorderLimit = imageWidthHalved;
		float rightBorderLimit = screenSize.width - imageWidthHalved;
		
		// the left/right border check is performed against half the player image's size so that the sides of the actual
		// sprite are blocked from going outside the screen because the player sprite's position is at the center of the image
		if (pos.x < leftBorderLimit)
		{
			pos.x = leftBorderLimit;
			
			// also set velocity to zero because the player is still accelerating towards the border
			playerVelocity = CGPointZero;
		}
		else if (pos.x > rightBorderLimit)
		{
			pos.x = rightBorderLimit;
			
			// also set velocity to zero because the player is still accelerating towards the border
			playerVelocity = CGPointZero;
		}
		
		// Alternatively, the above if/else if block can be rewritten using fminf and fmaxf more neatly like so:
		// pos.x = fmaxf(fminf(pos.x, rightBorderLimit), leftBorderLimit);
		
		player.position = pos;
		
		// Do the collision checks
		[self checkForCollision];
		
		// Update the Score (Timer) once per second. If you'd do it more often, especially every frame, this
		// will easily drag the framerate down. Updating a CCLabel's strings is slow!
		totalTime += delta;
		int currentTime = (int)totalTime;
		if (score < currentTime)
		{
			score = currentTime;
			[scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
		}
	}
}

#pragma mark Collision Checks

-(void) checkForCollision
{
	// Assumption: both player and spider images are squares.
	float playerImageSize = [player texture].contentSize.width;
	float spiderImageSize = [[spiders lastObject] texture].contentSize.width;
	// If you adjust the factors make sure you also change them in the -(void) draw method.
	float playerCollisionRadius = playerImageSize * 0.4f;
	float spiderCollisionRadius = spiderImageSize * 0.4f;
	
	// This collision distance will roughly equal the image shapes.
	float maxCollisionDistance = playerCollisionRadius + spiderCollisionRadius;
	
	// Cache [spiders count] for the duration of the loop to avoid repetitive and unnecessary calls to [spiders count].
	NSUInteger numSpiders = [spiders count];
	for (NSUInteger i = 0; i < numSpiders; i++)
	{
		CCSprite* spider = [spiders objectAtIndex:i];
		
		if ([spider numberOfRunningActions] == 0)
		{
			// This spider isn't even moving so we can skip checking it.
			continue;
		}

		// Get the distance between player and spider. Here's where it's great that the images are centered
		// on the node positions, you don't need to take into account any offsets which you would have if the
		// position would coincide with the image's lower left corner for example.
		float actualDistance = ccpDistance(player.position, spider.position);
		
		// Are the two objects closer than allowed?
		if (actualDistance < maxCollisionDistance)
		{
			[[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];
			
			[self showGameOver];
			break;
		}
	}
}

#pragma mark Reset Game

// On iOS the game is played only using the accelerometer. The screen may go dark while playing because the player
// won't touch the screen. This method allows the screensaver to be disabled during gameplay.
-(void) setScreenSaverEnabled:(bool)enabled
{
#if KK_PLATFORM_IOS
	UIApplication *thisApp = [UIApplication sharedApplication];
	thisApp.idleTimerDisabled = !enabled;
#endif
}

-(void) showGameOver
{
	isGameOver = YES;
	currentKeyAcceleration = 0;

	// stop the scheduled selectors
	[self unscheduleAllSelectors];
	// except for update
	[self scheduleUpdate];

	// Re-enable screensaver, to prevent battery drain in case the user puts the device aside without turning it off.
	[self setScreenSaverEnabled:YES];

	// have everything stop
	CCNode* node;
	CCARRAY_FOREACH([self children], node)
	{
		[node stopAllActions];
	}

	// I do want the spiders to keep wiggling so I simply restart this here
	CCSprite* spider;
	CCARRAY_FOREACH(spiders, spider)
	{
		[self runSpiderWiggleSequence:spider];
	}
	
	// add the labels shown during game over
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	CCLabelTTF* gameOver = [CCLabelTTF labelWithString:@"GAME OVER!" fontName:@"Marker Felt" fontSize:60];
	gameOver.position = CGPointMake(screenSize.width / 2, screenSize.height / 3);
	[self addChild:gameOver z:100 tag:100];
	
	// game over label runs 3 different actions at the same time to create the combined effect
	// 1) color tinting
	CCTintTo* tint1 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:0];
	CCTintTo* tint2 = [CCTintTo actionWithDuration:2 red:255 green:255 blue:0];
	CCTintTo* tint3 = [CCTintTo actionWithDuration:2 red:0 green:255 blue:0];
	CCTintTo* tint4 = [CCTintTo actionWithDuration:2 red:0 green:255 blue:255];
	CCTintTo* tint5 = [CCTintTo actionWithDuration:2 red:0 green:0 blue:255];
	CCTintTo* tint6 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:255];
	CCSequence* tintSequence = [CCSequence actions:tint1, tint2, tint3, tint4, tint5, tint6, nil];
	CCRepeatForever* repeatTint = [CCRepeatForever actionWithAction:tintSequence];
	[gameOver runAction:repeatTint];
	
	// 2) rotation with ease
	CCRotateTo* rotate1 = [CCRotateTo actionWithDuration:2 angle:3];
	CCEaseBounceInOut* bounce1 = [CCEaseBounceInOut actionWithAction:rotate1];
	CCRotateTo* rotate2 = [CCRotateTo actionWithDuration:2 angle:-3];
	CCEaseBounceInOut* bounce2 = [CCEaseBounceInOut actionWithAction:rotate2];
	CCSequence* rotateSequence = [CCSequence actions:bounce1, bounce2, nil];
	CCRepeatForever* repeatBounce = [CCRepeatForever actionWithAction:rotateSequence];
	[gameOver runAction:repeatBounce];
	
	// 3) jumping
	CCJumpBy* jump = [CCJumpBy actionWithDuration:3 position:CGPointZero height:screenSize.height / 3 jumps:1];
	CCRepeatForever* repeatJump = [CCRepeatForever actionWithAction:jump];
	[gameOver runAction:repeatJump];

	NSString* toPlayAgain = @"tap screen to play again";
	if ([CCDirector sharedDirector].currentPlatformIsMac)
	{
		toPlayAgain = @"press Return or Space to play again";
	}
	
	// touch to continue label
	CCLabelTTF* touch = [CCLabelTTF labelWithString:toPlayAgain fontName:@"Arial" fontSize:20];
	touch.position = CGPointMake(screenSize.width / 2, screenSize.height / 4);
	[self addChild:touch z:100 tag:101];
	
	// did you try turning it off and on again?
	CCBlink* blink = [CCBlink actionWithDuration:10 blinks:20];
	CCRepeatForever* repeatBlink = [CCRepeatForever actionWithAction:blink];
	[touch runAction:repeatBlink];
}

-(void) resetGame
{
	isGameOver = NO;
	
	// prevent screensaver from darkening the screen while the game is played
	[self setScreenSaverEnabled:NO];
	
	// remove game over label & touch to continue label
	[self removeChildByTag:100 cleanup:YES];
	[self removeChildByTag:101 cleanup:YES];
	
	// put all spiders back to top
	[self resetSpiders];
	
	// reset score
	score = 0;
	totalTime = 0;
	[scoreLabel setString:@"0"];
}

-(void) draw
{
#if DEBUG
	/*
	// Only draw this debugging information in, well, debug builds.
	// Iterate through all nodes of the layer.
	CCNode* node;
	CCARRAY_FOREACH([self children], node)
	{
		// Make sure the node is a CCSprite and has the right tags.
		if ([node isKindOfClass:[CCSprite class]] && (node.tag == 1 || node.tag == 2))
		{
			// The sprite's collision radius is a percentage of its image width. Use that to draw a circle
			// which represents the sprite's collision radius.
			CCSprite* sprite = (CCSprite*)node;
			float radius = [sprite texture].contentSize.width * 0.4f;
			float angle = 0;
			int numSegments = 10;
			bool drawLineToCenter = NO;
			ccDrawCircle(sprite.position, radius, angle, numSegments, drawLineToCenter);
		}
	}
	 */
#endif

	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	// always keep variables you have to calculate only once outside the loop
	float threadCutPosition = screenSize.height * 0.75f;

	// Draw a spider thread using OpenGL
	// CCARRAY_FOREACH is a bit faster than regular for loop
	CCSprite* spider;
	CCARRAY_FOREACH(spiders, spider)
	{
		// only draw thread up to a certain point
		if (spider.position.y > threadCutPosition)
		{
			// vary thread position a little so it looks a bit more dynamic
			float threadX = spider.position.x + (CCRANDOM_0_1() * 2.0f - 1.0f);

			ccDrawColor4F(1.0f, 1.0f, 1.0f, 0.3f);
			ccDrawLine(spider.position, CGPointMake(threadX, screenSize.height));
		}
	}
}

@end
