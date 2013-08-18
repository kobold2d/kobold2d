/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "HelloWorldLayer.h"

#import "HelloWorldLayer.h"

@interface HelloWorldLayer (PrivateMethods)
-(void) addSomeCocoaTouch;
@end

@implementation HelloWorldLayer

-(id) init
{
	if ((self = [super init])) 
	{
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:88];
		CGSize size = [[CCDirector sharedDirector] winSize];
		LOG_EXPR(size);
		
		label.position = CGPointMake(size.width / 2, size.height);
		label.color = ccGREEN;
		[self addChild:label];
		
		id move1 = [CCMoveTo actionWithDuration:4 position:CGPointMake(size.width / 2, 0)];
		id move2 = [CCMoveTo actionWithDuration:4 position:label.position];
		id sequence = [CCSequence actions:move1, move2, nil];
		id repeat = [CCRepeatForever actionWithAction:sequence];
		[label runAction:repeat];
		
		id rotate = [CCRotateBy actionWithDuration:10 angle:360];
		id repeat2 = [CCRepeatForever actionWithAction:rotate];
		[label runAction:repeat2];
		
		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:64];
		label2.position = CGPointMake(310, 270);
		label2.color = ccMAGENTA;
		[self addChild:label2];
		
#if KK_PLATFORM_IOS		
		[self addSomeCocoaTouch];
#endif
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED

#if KK_PLATFORM_IOS
	[myViewController release];
	myViewController = nil;
#endif
	
	[super dealloc];
#endif
}

#if KK_PLATFORM_IOS

-(void) addSomeCocoaTouch
{
	CCLOG(@"Creating Cocoa Touch view ...");
	
	// get the cocos2d view (it's the EAGLView class which inherits from UIView)
	UIView* glView = [CCDirector sharedDirector].view;
	// The dummy UIView you created in the App delegate is the superview of the glView
	UIView* dummyView = glView.superview;
	
	// regular text field with rounded corners
	UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 20, 200, 24)];
	textField.text = @"  Behind Cocos2D View";
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = self;
	
	// text field that uses an image as background (aka "skinning")
	UITextField* textFieldSkinned = [[UITextField alloc] initWithFrame:CGRectMake(40, 60, 200, 24)];
	textFieldSkinned.text = @"  With background image";
	textFieldSkinned.delegate = self;
	
	// load and assign the UIImage as background of the text field
	NSString* imageFile = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"Default.png"];
	CCLOG(@"imageFile with path = %@", imageFile);
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:imageFile];
	textFieldSkinned.background = image;
	
	
	// add the text fields to the dummy view
	[dummyView addSubview:textField];
	[dummyView addSubview:textFieldSkinned];
	
#ifndef KK_ARC_ENABLED
	[textField release];
	[textFieldSkinned release];
	[image release];
#endif // KK_ARC_ENABLED
	
	// send the cocos2d view to the front so it is in front of the other views
	[dummyView bringSubviewToFront:glView];
	
	
	// make the cocos2d view transparent
	// IMPORTANT: transparent cocos2d view requires EAGLView pixelFormat set to kEAGLColorFormatRGBA8 (not the default)
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glView.opaque = NO;
	
	
	// Allow touches to be ignored by cocos2d view and passed through to the text fields.
	// This will disable all touch events for cocos2d view however, so it's only useful in some cases.
	//glView.userInteractionEnabled = NO;
	
	
	// just for kicks, add another text field which is still in front of cocos2d
	UITextField* textFieldFront = [[UITextField alloc] initWithFrame:CGRectMake(280, 40, 200, 24)];
	textFieldFront.text = @"  Above Cocos2D View";
	textFieldFront.borderStyle = UITextBorderStyleRoundedRect;
	textFieldFront.delegate = self;
	
	[glView addSubview:textFieldFront];
	// send to back if you want to
	//[glView sendSubviewToBack:textFieldFront]; 
	
	
	// add a Interface Builder view
	myViewController = [[MyView alloc] initWithNibName:@"MyView" bundle:nil];
	[dummyView addSubview:myViewController.view];
	[dummyView sendSubviewToBack:myViewController.view]; // optional

#ifndef KK_ARC_ENABLED
	[textFieldFront release];
#endif // KK_ARC_ENABLED
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
	// only by calling this method will the keyboard be dismissed when tapping the RETURN key
	[textField resignFirstResponder];
	
	// if the text is empty, remove the text field
	if ([textField.text length] == 0) 
	{
		[textField removeFromSuperview];
	}
	
	return YES;
}

#elif KK_PLATFORM_MAC

// ... add NSViews (currently not possible, see the comments in AppDelegate).

#endif

-(void) colorizeNodeThatContainsPoint:(CGPoint)point
{
	CCNode* node = nil;
	CCARRAY_FOREACH([self children], node)
	{
		if ([node containsPoint:point] && [node conformsToProtocol:@protocol(CCRGBAProtocol)])
		{
			ccColor3B randomColor = ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255);
			CCNode<CCRGBAProtocol>* nodeWithColor = (CCNode<CCRGBAProtocol>*)node;
			[nodeWithColor setColor:randomColor];
		}
	}
}

-(void) update:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];
	
	KKTouch* touch;
	CCARRAY_FOREACH(input.touches, touch)
	{
		if (touch.phase == KKTouchPhaseBegan)
		{
			[self colorizeNodeThatContainsPoint:touch.location];
		}
	}
	
	if (input.isAnyMouseButtonDownThisFrame)
	{
		[self colorizeNodeThatContainsPoint:input.mouseLocation];
	}
}

@end