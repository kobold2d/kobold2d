/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

/*
 * License for original source:
 *
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "KKAppDelegate.h"

#import "kobold2d_version.h"
#import "KKStartupConfig.h"
#import "KKHitTest.h"
#import "KKInput.h"
#import "kkTypes.h"

#import "JRSwizzle.h"
#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import <objc/runtime.h>


#if KK_PLATFORM_IOS

@implementation KKNavigationController

-(NSUInteger) supportedInterfaceOrientations
{
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
	KKStartupConfig* config = appDelegate.config;
	
	return ((config.supportsInterfaceOrientationPortrait ? UIInterfaceOrientationMaskPortrait : 0) |
			(config.supportsInterfaceOrientationPortraitUpsideDown ? UIInterfaceOrientationMaskPortraitUpsideDown : 0) |
			(config.supportsInterfaceOrientationLandscapeLeft ? UIInterfaceOrientationMaskLandscapeLeft : 0) |
			(config.supportsInterfaceOrientationLandscapeRight ? UIInterfaceOrientationMaskLandscapeRight : 0));
}

// Supported orientations. Customize it for your own needs
// Only for iOS 4 & 5. Not used by iOS 6 and newer.
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
	KKStartupConfig* config = appDelegate.config;
	switch (interfaceOrientation)
	{
		case UIInterfaceOrientationPortrait:
			return config.supportsInterfaceOrientationPortrait;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			return config.supportsInterfaceOrientationPortraitUpsideDown;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			return config.supportsInterfaceOrientationLandscapeLeft;
			break;
		case UIInterfaceOrientationLandscapeRight:
			return config.supportsInterfaceOrientationLandscapeRight;
			break;
			
		default:
			break;
	}
	
	return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if (director.runningScene == nil)
	{
		[[KKInput sharedInput] resetInputStates];
		
		KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
		[appDelegate initializationComplete];
		[appDelegate tryToRunFirstScene];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:KTDirectorDidReshapeProjectionNotification object:nil];
}
@end
#endif


@implementation KKAppDelegate

@synthesize director;

/* ********************************************************************************************************************* */
// AppDelegate code for both iOS & Mac OS X targets
/* ********************************************************************************************************************* */

-(void) performMethodSwizzling
{
	// swizzle some Cocos2D methods to Kobold2D extensions
	NSError* error;
	
#if KK_PLATFORM_IOS
	if ([CCDirectorDisplayLink jr_swizzleMethod:@selector(mainLoop:) 
									 withMethod:@selector(mainLoopReplacement:) error:&error] == NO) {
		NSAssert1(nil, @"Method swizzling error: %@", error);
	}
#elif KK_PLATFORM_MAC
	if ([CCDirectorDisplayLink jr_swizzleMethod:@selector(drawScene) 
									 withMethod:@selector(mainLoopReplacement) error:&error] == NO) {
		NSAssert1(nil, @"Method swizzling error: %@", error);
	}
#endif
	if ([CCDirector jr_swizzleMethod:@selector(replaceScene:) 
						  withMethod:@selector(replaceSceneReplacement:) error:&error] == NO) {
		NSAssert1(nil, @"Method swizzling error: %@", error);
	}
	if ([CCDirector jr_swizzleMethod:@selector(runWithScene:) 
						  withMethod:@selector(runWithSceneReplacement:) error:&error] == NO) {
		NSAssert1(nil, @"Method swizzling error: %@", error);
	}
	if ([CCDirector jr_swizzleMethod:@selector(pushScene:) 
						  withMethod:@selector(pushSceneReplacement:) error:&error] == NO) {
		NSAssert1(nil, @"Method swizzling error: %@", error);
	}
	if ([CCDirector jr_swizzleMethod:@selector(popScene) 
						  withMethod:@selector(popSceneReplacement) error:&error] == NO) {
		NSAssert1(nil, @"Method swizzling error: %@", error);
	}
	if ([CCScheduler jr_swizzleMethod:@selector(update:) 
						   withMethod:@selector(tickReplacement:) error:&error] == NO) {
		NSAssert1(nil, @"Method swizzling error: %@", error);
	}
}

-(void) initializationComplete
{
	// does nothing, supposed to be overridden
}

-(id) alternateView
{
	// does nothing, supposed to be overridden
	return nil;
}

// dummy selector
+(id) scene
{
	[NSException raise:@"don't call scene on appdelegate" format:@""];
	return nil;
}

-(void) tryToRunFirstScene
{
	// try to run first scene
	if (director.isSceneStackEmpty)
	{
		Class firstSceneClass = NSClassFromString(config.firstSceneClassName);
		if (firstSceneClass)
		{
			Class sceneClass = [CCScene class];
			Class superClass = class_getSuperclass(firstSceneClass);
			
			if (sceneClass == superClass)
			{
				id scene = [[[firstSceneClass alloc] init] autorelease];
#if KK_PLATFORM_IOS
				[director pushScene:scene];
#elif KK_PLATFORM_MAC
				[director runWithScene:scene];
#endif
			}
			else
			{
				CCScene* dummyScene = nil;
				if ([firstSceneClass respondsToSelector:@selector(scene)])
				{
					dummyScene = [firstSceneClass performSelector:@selector(scene)];
				}
				else
				{
					id layer = [[[firstSceneClass alloc] init] autorelease];
					dummyScene = [CCScene node];
					[dummyScene addChild:layer];
				}
				
#if KK_PLATFORM_IOS
				[director pushScene:dummyScene];
#elif KK_PLATFORM_MAC
				[director runWithScene:dummyScene];
#endif
			}
		}
	}
	
	// if still empty, create a dummy scene
	if (director.isSceneStackEmpty)
	{
		CCLOG(@"Unable to run first scene! Check that in config.lua FirstSceneClassName matches with the name of a class inherited from CCScene.");
		CGSize screenSize = director.winSize;
		CCScene* dummyScene = [CCScene node];
		NSString* string = [NSString stringWithFormat:@"ERROR in config.lua\n\nFirstSceneClassName = '%@'\n\nThis class does not exist or\ndoes not inherit from CCScene!", config.firstSceneClassName];
		CCLabelTTF* label = [CCLabelTTF labelWithString:string 
											   fontName:@"Arial"
											   fontSize:24
											 dimensions:screenSize
											 hAlignment:kCCTextAlignmentCenter 
										  lineBreakMode:kCCLineBreakModeWordWrap];
		label.position = CGPointMake(screenSize.width / 2, screenSize.height / 4);
		label.color = ccRED;
		[dummyScene addChild:label];
		[director runWithScene:dummyScene];
		glClearColor(1, 1, 1, 1);
	}
}

/* ********************************************************************************************************************* */
// iOS AppDelegate
/* ********************************************************************************************************************* */
#ifdef KK_PLATFORM_IOS

#import <UIKit/UIKit.h>

#pragma mark iOS AppDelegate

@synthesize window, config, navController;
@dynamic rootViewController;

-(UIViewController*) rootViewController
{
	return director;
}

-(BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	config = [[KKStartupConfig config] retain];
	[self performMethodSwizzling];

	if ([application respondsToSelector:@selector(setStatusBarHidden:withAnimation:)])
	{
        [application setStatusBarHidden:!config.enableStatusBar withAnimation:UIStatusBarAnimationFade];
	}
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30200
    else
	{
        [application setStatusBarHidden:!config.enableStatusBar animated:YES];
	}
#endif
	
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	NSString* colorFormat = nil;
	switch (config.gLViewColorFormat)
	{
		default:
			CCLOG(@"invalid color format specified, using default RGBA8");
		case 8888:
			colorFormat = kEAGLColorFormatRGBA8;
			break;
		case 565:
			colorFormat = kEAGLColorFormatRGB565;
			break;
	}
	
	// Create an EAGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	CCGLView* glView = [CCGLView viewWithFrame:window.bounds
								   pixelFormat:colorFormat
								   depthFormat:config.gLViewDepthFormat
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:config.gLViewMultiSampling
							   numberOfSamples:config.gLViewNumberOfSamples];

	[glView setUserInteractionEnabled:config.enableUserInteraction];
	[glView setMultipleTouchEnabled:config.enableMultiTouch];

	CCLOG(@"%@", kobold2dVersion());

	// Setup director
	director = (CCDirectorIOS*)[CCDirector sharedDirector];
	director.wantsFullScreenLayout = !config.enableStatusBar;
	director.displayStats = config.displayFPS;
	director.animationInterval = 1.0f / config.maxFrameRate;
	
	// attach the OpenGLView
	director.view = glView;
	
	// required for cc_vertexz property to work properly (if not set, cc_vertexz layers will be zoomed out!)
	if (config.enable2DProjection)
	{
		[director setProjection:kCCDirectorProjection2D];
	}
	
	// this must be called right AFTER the glView has been attached to the director!
	BOOL usesRetina = [director enableRetinaDisplay:config.enableRetinaDisplaySupport];
	NSLog(@"Retina Display enabled: %@", usesRetina ? @"YES" : @"NO");
	LOG_EXPR(isWidescreenEnabled());
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	[CCTexture2D setDefaultAlphaPixelFormat:config.defaultTexturePixelFormat];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	navController = [[KKNavigationController alloc] initWithRootViewController:director];
	navController.navigationBarHidden = YES;
	director.delegate = navController;
	
	// set the Navigation Controller as the root view controller
	window.rootViewController = navController;
	[window makeKeyAndVisible];
	
	[KKHitTest sharedHitTest].isHitTesting = config.enableGLViewNodeHitTesting;
	
	LOG_EXPR(director.winSize);
	
	return YES;
}

-(void) applicationWillResignActive:(UIApplication *)application 
{
	if (navController.visibleViewController == director)
	{
		[director pause];
	}
}

-(void) applicationDidBecomeActive:(UIApplication *)application 
{
	if (navController.visibleViewController == director)
	{
		[director resume];
	}
}

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
	if (navController.visibleViewController == director)
	{
		[director stopAnimation];
	}
}

-(void) applicationWillEnterForeground:(UIApplication*)application 
{
	if (navController.visibleViewController == director)
	{
		[director startAnimation];
	}
}

-(void) applicationWillTerminate:(UIApplication *)application 
{
	CC_DIRECTOR_END();
}

-(void) applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationSignificantTimeChange:(UIApplication *)application 
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

/** Note: dealloc of the AppDelegate is never called!
 This is normal behavior, see: http://stackoverflow.com/questions/2075069/iphone-delegate-controller-dealloc
 The App's memory is wiped anyway so the App doesn't go through to effort to call object's dealloc on App terminate.
 */

/* ********************************************************************************************************************* */
#elif KK_PLATFORM_MAC // Mac AppDelegate
/* ********************************************************************************************************************* */

#pragma mark Mac AppDelegate

@synthesize window, glView;

-(void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	config = [[KKStartupConfig config] retain];
	[self performMethodSwizzling];

	director = (CCDirectorMac*)[CCDirector sharedDirector];
	[director setDisplayStats:config.displayFPS];
	[director setView:glView];
	
	CCLOG(@"%@", kobold2dVersion());

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	if (config.autoScale == YES)
	{
		NSLog(@"WARNING: Mac OS X autoscale is enabled - THIS IS AN EXPERIMENTAL FEATURE, USE AT YOUR OWN RISK!");
		[director setResizeMode:kCCDirectorResize_AutoScale];
	}
	else
	{
		[director setResizeMode:kCCDirectorResize_NoScale];
	}

	// required for cc_vertexz property to work properly (if not set, cc_vertexz layers will be zoomed out!)
	if (config.enable2DProjection)
	{
		[director setProjection:kCCDirectorProjection2D];
	}

	[window setAcceptsMouseMovedEvents:config.acceptsMouseMovedEvents];

	NSWindow* alternateView = [[self alternateView] retain];
	if (alternateView)
	{
		[window addChildWindow:alternateView ordered:NSWindowAbove];
		[alternateView release];
	}

	[(CCDirectorMac*)[CCDirector sharedDirector] setFullScreen:config.enableFullScreen];

	CCLOG(@"cocos2d: window frame: origin {%.0f, %.0f}, size {%.0f, %.0f}", 
		  [window frame].origin.x, [window frame].origin.y, [window frame].size.width, [window frame].size.height);

	[[KKInput sharedInput] resetInputStates];
	[self initializationComplete];
	[self tryToRunFirstScene];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication
{
	return YES;
}

-(void) dealloc
{
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

-(IBAction) toggleFullScreen:(id)sender
{
	director.fullScreen = !director.isFullScreen;
}

#endif

@end
