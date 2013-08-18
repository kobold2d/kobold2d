/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCDirectorExtensions.h"
#import "ccMoreMacros.h"
#import "KKInput.h"

static NSUInteger CCDirectorExtensionFrameCounter = 0;

@implementation CCDirector (KoboldExtensions)

-(CGPoint) screenCenter
{
	CGSize screenSize = [self winSize];
	return CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
}

-(CGPoint) screenCenterInPixels
{
	CGSize screenSize = [self winSizeInPixels];
	return CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
}

-(CGRect) screenRect
{
	CGSize screenSize = [self winSize];
	return CGRectMake(0, 0, screenSize.width, screenSize.height);
}

-(CGRect) screenRectInPixels
{
	CGSize screenSize = [self winSizeInPixels];
	return CGRectMake(0, 0, screenSize.width, screenSize.height);
}

-(CGSize) screenSize
{
	return [self winSize];
}

-(CGSize) screenSizeInPixels
{
	return [self winSizeInPixels];
}

-(CGPoint) screenSizeAsPoint
{
	CGSize winSize = [self winSize];
	return CGPointMake(winSize.width, winSize.height);
}

-(CGPoint) screenSizeAsPointInPixels
{
	CGSize winSizeInPixels = [self winSizeInPixels];
	return CGPointMake(winSizeInPixels.width, winSizeInPixels.height);
}

-(BOOL) isSceneStackEmpty
{
	return ([_scenesStack count] == 0);
}

-(BOOL) currentPlatformIsIOS
{
#if KK_PLATFORM_IOS
	return YES;
#endif
	return NO;
}

-(BOOL) currentPlatformIsMac
{
#if KK_PLATFORM_MAC
	return YES;
#endif
	return NO;
}

-(BOOL) currentDeviceIsSimulator
{
#if KK_PLATFORM_IOS_SIMULATOR
	return YES;
#else
	return NO;
#endif
}

-(BOOL) currentDeviceIsIPad
{
#ifdef KK_PLATFORM_IOS
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
	return NO;
}

@dynamic frameCount;
-(NSUInteger) frameCount
{
	return CCDirectorExtensionFrameCounter;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(BOOL) isRetinaDisplayEnabled
{
	return (CC_CONTENT_SCALE_FACTOR() == 2.0f);
}

-(float) contentScaleFactorInverse
{
	return (1.0f / CC_CONTENT_SCALE_FACTOR());
}

-(float) contentScaleFactorHalved
{
	return (CC_CONTENT_SCALE_FACTOR() * 0.5f);
}
#endif

@end


@implementation CCDirector (SwizzledMethods)

-(void) mainLoopReplacement
{
	// call original implementation
	[self mainLoopReplacement];
	// important: frame counter must be increased at end of main loop otherwise touchBeganThisFrame may not become true
	CCDirectorExtensionFrameCounter++;
}
-(void) mainLoopReplacement:(id)sender
{
	// call original implementation
	[self mainLoopReplacement:sender];
	// important: frame counter must be increased at end of main loop otherwise touchBeganThisFrame may not become true
	CCDirectorExtensionFrameCounter++;
}

-(void) replaceSceneReplacement:(CCScene*)scene
{
	[[KKInput sharedInput] resetInputStates];
	
	// call original implementation - if this look wrong to you, read up on Method Swizzling: http://www.cocoadev.com/index.pl?MethodSwizzling)
	[self replaceSceneReplacement:scene];
}
-(void) runWithSceneReplacement:(CCScene*)scene
{
	[[KKInput sharedInput] resetInputStates];
	
	// call original implementation - if this look wrong to you, read up on Method Swizzling: http://www.cocoadev.com/index.pl?MethodSwizzling)
	[self runWithSceneReplacement:scene];
}
-(void) pushSceneReplacement:(CCScene*)scene
{
	[[KKInput sharedInput] resetInputStates];
	
	// call original implementation - if this look wrong to you, read up on Method Swizzling: http://www.cocoadev.com/index.pl?MethodSwizzling)
	[self pushSceneReplacement:scene];
}
-(void) popSceneReplacement
{
	[[KKInput sharedInput] resetInputStates];
	
	// call original implementation - if this look wrong to you, read up on Method Swizzling: http://www.cocoadev.com/index.pl?MethodSwizzling)
	[self popSceneReplacement];
}

@end

#ifdef KK_PLATFORM_IOS
@implementation CCDirectorDisplayLink (KoboldExtensions)
-(CADisplayLink*) displayLink
{
	return _displayLink;
}
@end
#endif
