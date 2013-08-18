/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

@interface HelloWorldLayer (PrivateMethods)
@end

@implementation HelloWorldLayer

@synthesize helloWorldString, helloWorldFontName;
@synthesize helloWorldFontSize;

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@ init", NSStringFromClass([self class]));
		
		CCDirector* director = [CCDirector sharedDirector];
		
		CCSprite* sprite = [CCSprite spriteWithFile:@"ship.png"];
		sprite.position = director.screenCenter;
		sprite.scale = 0;
		[self addChild:sprite];
		
		id scale = [CCScaleTo actionWithDuration:1.0f scale:1.6f];
		[sprite runAction:scale];
		id move = [CCMoveBy actionWithDuration:1.0f position:CGPointMake(0, -120)];
		[sprite runAction:move];

		// get the hello world string from the config.lua file
		[KKConfig injectPropertiesFromKeyPath:@"HelloWorldSettings" target:self];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:helloWorldString 
											   fontName:helloWorldFontName 
											   fontSize:helloWorldFontSize];
		label.position = director.screenCenter;
		label.color = ccGREEN;
		[self addChild:label];

		// print out which platform we're on
		NSString* platform = @"(unknown platform)";
		
		if (director.currentPlatformIsIOS)
		{
			// add code 
			platform = @"iPhone/iPod Touch";
			
			if (director.currentDeviceIsIPad)
				platform = @"iPad";

			if (director.currentDeviceIsSimulator)
				platform = [NSString stringWithFormat:@"%@ Simulator", platform];
		}
		else if (director.currentPlatformIsMac)
		{
			platform = @"Mac OS X";
		}
		
		CCLabelTTF* platformLabel = nil;
		if (director.currentPlatformIsIOS) 
		{
			// how to add custom ttf fonts to your app is described here:
			// http://tetontech.wordpress.com/2010/09/03/using-custom-fonts-in-your-ios-application/
			float fontSize = (director.currentDeviceIsIPad) ? 48 : 28;
			platformLabel = [CCLabelTTF labelWithString:platform 
											   fontName:@"Ubuntu Condensed"
											   fontSize:fontSize];
		}
		else if (director.currentPlatformIsMac)
		{
			// Mac builds have to rely on fonts installed on the system.
			platformLabel = [CCLabelTTF labelWithString:platform 
											   fontName:@"Zapfino" 
											   fontSize:32];
		}

		platformLabel.position = director.screenCenter;
		platformLabel.color = ccYELLOW;
		[self addChild:platformLabel];
		
		id movePlatform = [CCMoveBy actionWithDuration:0.2f 
											  position:CGPointMake(0, 50)];
		[platformLabel runAction:movePlatform];

		glClearColor(0.2f, 0.2f, 0.4f, 1.0f);

		// play sound with CocosDenshion's SimpleAudioEngine
		[[SimpleAudioEngine sharedEngine] playEffect:@"Pow.caf"];
	}

	return self;
}

@end
