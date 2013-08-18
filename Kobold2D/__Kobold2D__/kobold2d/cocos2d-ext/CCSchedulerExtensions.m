//
//  CCSchedulerExtensions.m
//  Kobold2D-Libraries
//
//  Created by Steffen Itterheim on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCSchedulerExtensions.h"
#import "KKInput.h"

@implementation CCScheduler (KoboldExtensions)

-(void) tickReplacement:(ccTime)delta
{
	// call original implementation
	[self tickReplacement:delta];

	// update KKInput last
	[[KKInput sharedInput] tick:delta];
}

@end
