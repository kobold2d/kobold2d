/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import "KKStartupConfig.h"
#import "KKConfig.h"

@implementation KKStartupConfig

@synthesize gLViewColorFormat, gLViewDepthFormat, gLViewNumberOfSamples, maxFrameRate;
@synthesize defaultTexturePixelFormat;
@synthesize gLViewMultiSampling, displayFPS, enableStatusBar;
@synthesize enableUserInteraction, enableMultiTouch, enable2DProjection, enableRetinaDisplaySupport, enableGLViewNodeHitTesting;
@synthesize supportsInterfaceOrientationPortrait, supportsInterfaceOrientationPortraitUpsideDown, supportsInterfaceOrientationLandscapeLeft, supportsInterfaceOrientationLandscapeRight;

// Ad stuff
@synthesize enableAdBanner, loadOnlyPortraitBanners, loadOnlyLandscapeBanners, placeBannerOnBottom;
@synthesize adProviders, adMobPublisherID, adMobFirstAdDelay, adMobRefreshRate, adMobTestMode;

// first scene
@synthesize firstSceneClassName;

// Mac OS specific
@synthesize autoScale, acceptsMouseMovedEvents, enableFullScreen;

-(id) init
{
	if ((self = [super init]))
	{
		// in case anything goes wrong with enum values set them to safe defaults here:
		adProviders = @"iAd, AdMob";

		id orientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
		if (orientations && [orientations isKindOfClass:[NSArray class]])
		{
			NSArray* supportedInterfaceOrientations = (NSArray*)orientations;
			LOG_EXPR(supportedInterfaceOrientations);
			supportsInterfaceOrientationPortrait = [supportedInterfaceOrientations containsObject:@"UIInterfaceOrientationPortrait"];
			supportsInterfaceOrientationPortraitUpsideDown = [supportedInterfaceOrientations containsObject:@"UIInterfaceOrientationPortraitUpsideDown"];
			supportsInterfaceOrientationLandscapeLeft = [supportedInterfaceOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"];
			supportsInterfaceOrientationLandscapeRight = [supportedInterfaceOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"];
		}

		[KKConfig injectPropertiesFromKeyPath:NSStringFromClass([self class]) target:self];
		
#if NDEBUG
		adMobTestMode = NO;
#endif
	}
	return self;
}

+(id) config
{
	return [[[self alloc] init] autorelease];
}

-(void) dealloc
{
	[firstSceneClassName release]; firstSceneClassName = nil;
	
	[super dealloc];
}

@end