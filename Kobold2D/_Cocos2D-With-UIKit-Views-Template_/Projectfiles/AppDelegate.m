/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "AppDelegate.h"

@implementation AppDelegate

-(void) initializationComplete
{
#ifdef KK_ARC_ENABLED
	CCLOG(@"ARC is enabled");
#else
	CCLOG(@"ARC is either not available or not enabled");
#endif
	
	// The target info pane forces the app to launch in LandscapeRight orientation.
	// After initialization is complete you can then allow rotation to all orientations.
	config.supportsInterfaceOrientationPortrait = YES;
	config.supportsInterfaceOrientationPortraitUpsideDown = YES;
	config.supportsInterfaceOrientationLandscapeLeft = YES;
	config.supportsInterfaceOrientationLandscapeRight = YES;
}

-(id) alternateView
{
#if KK_PLATFORM_IOS
	// =======================================================================================
	// --- WARNING --- WARNING --- WARNING --- WARNING --- WARNING --- WARNING --- WARNING ---
	// =======================================================================================
	// If you do need UIKit views both behind and in front of the cocos2d view, you can uncomment the following code.
	// However this solution will create a framebuffer twice the usual size for no apparent reason. 
	// It may have other side-effects, too. Test thoroughly!

	// no dummy view, just return nil
	//return nil;

	// we want to be a dummy view the self.view to which we add the glView plus all other UIKit views
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;

	// add a dummy UIView to the view controller, which in turn will have the glView and later other UIKit views added to it
	CGRect bounds = [appDelegate.window bounds];
	UIView* dummyView = [[UIView alloc] initWithFrame:bounds];
#ifndef KK_ARC_ENABLED
	[dummyView autorelease];
#endif // KK_ARC_ENABLED
	
	[dummyView addSubview:[CCDirector sharedDirector].view];

	return dummyView;

#elif KK_PLATFORM_MAC

	// Adding NSView objects to Cocos2D Mac has unresolved issues, it's not working.
	// If you want to help out, or know the solution, please contact: steffen@learn-cocos2d.com
	// Please read the remainder to get more clues about what is known and has been tried.
	
	// Problem: adding subviews crashes in drawScene, or rendering is corrupt.
	
	// The recommended solution should be to call setWantsLayer:YES (see this demo project: http://developer.apple.com/library/mac/#samplecode/LayerBackedOpenGLView/Introduction/Intro.html)
	// However it appears that the Cocos2D OpenGL View is not cooperative and violates at least one of the principles described
	// in NSView setWantsLayer: http://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSView_Class/Reference/NSView.html#//apple_ref/occ/instm/NSView/setWantsLayer:
	// The alternative solution (http://stackoverflow.com/questions/2221442/nstextfield-over-nsopenglview/2221515#2221515)
	// was unsuccessful as well. It has also been discussed in the cocos2d forum: http://www.cocos2d-iphone.org/forum/topic/12077

	// If you manage to render NSView on top of the cocos2d OpenGL view please let me know!

	// both layer hosted and layer backed approaches crash in drawScene when calling glClear
	//CALayer* layer = [[[CALayer alloc] init] autorelease];
	//[[CCDirector sharedDirector].openGLView setLayer:layer];
	
	// layer backed (comment out the above 2 lines)
	//[[CCDirector sharedDirector].openGLView setWantsLayer:YES];
	//[[CCDirector sharedDirector].openGLView reshape];
	
	return nil;
#endif
}

@end
