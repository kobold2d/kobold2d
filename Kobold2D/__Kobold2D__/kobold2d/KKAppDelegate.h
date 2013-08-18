/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Availability.h>
#import "cocos2d.h"
#import "cocos2d-extensions.h"

#import "KKStartupConfig.h"

/** Performs common UIApplicationDelegate methods. You're supposed to subclass from it in your own project. Unless you need to react to
 any UIApplicationDelegate event, you only need to implement the initializationComplete method. Everything else is handled in this class.
 When subclassing and overriding UIApplicationDelegate methods you should also call the [super ..] implementation. */

#ifdef KK_PLATFORM_IOS
// Added only for iOS 6 support
@interface KKNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface KKAppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
@protected
	UIWindow* window;
	KKNavigationController* navController;
	KKStartupConfig* config;
	CCDirectorIOS* __unsafe_unretained director;
}

/** The App's UIWindow object. */
@property (nonatomic, retain) UIWindow* window;
/** Gives you access to the root view controller object (since cocos2d 2.0 that's CCDirectorIOS) */
@property (nonatomic, readonly) UIViewController* rootViewController;
/** Returns the navication controller */
@property (nonatomic, readonly) KKNavigationController* navController;
/** Gives you access to the startup properties defined in startup-config.lua */
@property (nonatomic, readonly) KKStartupConfig* config;
/** returns the iOS director which double acts as root view controller */
@property (unsafe_unretained, readonly) CCDirectorIOS* director;

// internal use only
-(void) tryToRunFirstScene;

#else // Mac OS AppDelegate
@interface KKAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow* window;
	CCGLView* glView;
	KKStartupConfig* config;
	CCDirectorMac* __unsafe_unretained director;
}

/** The App's NSWindow object */
@property (assign) IBOutlet NSWindow* window;
/** The MacGLView */
@property (assign) IBOutlet CCGLView* glView;
/** returns the Mac director */
@property (unsafe_unretained, readonly) CCDirectorMac* director;

/** Call this to enter or leave fullscreen mode. */
-(IBAction) toggleFullScreen:(id)sender;

#endif

/** Called when Cocos2D is initialized and the App is ready to run the first scene. 
 You should override this method in your AppDelegate implementation. */
-(void) initializationComplete;

/** Called before the (root ViewController's) view is initialized. Override and return a UIView to use a different
 view for the root ViewController instead of the Director's glView. If you use an alternate view, you are responsible
 for adding the glView somewhere to the view hierarchy. Primarily used for integration with UIKit/AppKit views to change the
 view hierarchy from: window -> glView to window -> overarching view -> subviews (glView plus n UIKit/AppKit views).*/
-(id) alternateView;

@end
