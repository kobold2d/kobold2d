/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"

#if KK_PLATFORM_IOS
#import "MyView.h"
#endif

@interface HelloWorldLayer : CCLayer 
#if KK_PLATFORM_IOS
	<UITextFieldDelegate>
#endif
{
#if KK_PLATFORM_IOS
	MyView* myViewController;
#endif
}

@end
