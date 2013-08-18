/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Copyright (c) 2011 Simon Jewell (http://blog.sygem.com)
 * Ad Provider Autorotation by Tomohisa: http://cocos2d-central.com/topic/614-second-admob-not-showing/
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Availability.h>
#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import "kkUserConfig.h"

#ifdef KK_PLATFORM_IOS
#import <iAd/iAd.h>
#import <UIKit/UIKit.h>
//#import "GADBannerView.h"

/** Singleton wrapper for ADBannerView class */
@interface KKAdBanner : NSObject 
#if KK_ADMOB_SUPPORT_ENABLED
	<ADBannerViewDelegate>
#else
	<ADBannerViewDelegate>
#endif // KK_ADMOB_SUPPORT_ENABLED
{
@protected
	ADBannerView* iAdBannerView;
#if KK_ADMOB_SUPPORT_ENABLED
	GADBannerView* adMobBannerView;
    NSTimer* adMobTimer;
    double lastAdMobRequestTime;
#endif

	NSTimer* adLoadFailRetryTimer;

	BOOL isVeryFirstAd;
	BOOL isIAdEnabled;
	BOOL isAdMobEnabled;
	
	BOOL bannerOnBottom;
	BOOL isAdShowing;
}

/** returns the singleton object, like this: [KKAdBanner sharedAdBanner] */
+(KKAdBanner*) sharedAdBanner;

/** Gives access to the single iAd ADBannerView managed by KKAdBanner */
@property (nonatomic, readonly) ADBannerView* iAdBannerView;

/** Gives access to the single AdMob GADBannerView managed by KKAdBanner */
#if KK_ADMOB_SUPPORT_ENABLED
@property (nonatomic, readonly) GADBannerView* adMobBannerView;
#endif

/** Returns if iAd is supported on the current device */
@property (nonatomic, readonly) BOOL iAdSupported;

/** Load the Ad Banner, by default called by KKRootViewController to initialize iAd based on the startup-config.lua settings */
-(void) loadBanner;

// internal use only
-(void) loadBanner:(UIInterfaceOrientation)interfaceOrientation;

/** Removes the banner and frees memory */
-(void) unloadBanner;

@end

#endif