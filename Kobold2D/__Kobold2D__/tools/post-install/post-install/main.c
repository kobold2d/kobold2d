//
//  main.c
//  post-install
//
//  Created by Steffen Itterheim on 22.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

static NSMutableString* logOutput = nil;

void showAlertWithError(NSError* error);	// avoid warning
void showAlertWithError(NSError* error)
{
	NSLog(@"ERROR: %@", error);
	NSAlert* alert = [NSAlert alertWithError:error];
	[alert runModal];
	[logOutput appendFormat:@"ERROR: %@ (%@)", error, [error description]];
}

void writeLog(NSString* str, NSString* file);
void writeLog(NSString* str, NSString* file)
{
	//[str writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

int main (int argc, const char * argv[])
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	logOutput = [NSMutableString stringWithCapacity:1000];
	//NSString* logFile = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
	NSString* logFile = @"/depot-kobold2d/logFile.txt";
	NSLog(@"Logfile: %@", logFile);
	writeLog(@"logfile", logFile);

	NSError* error = nil;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSLog(@"username = %@ - %@", NSUserName(), NSFullUserName());

	for (int i = 0; i < argc; i++)
	{
		NSString* arg = [NSString stringWithCString:argv[i] encoding:NSASCIIStringEncoding];
		NSLog(@"arg %i = '%@'", i, arg);
	}
	
	NSString* koboldPath = nil;
	if (argc >= 2)
	{
		koboldPath = [NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding];
	}

// TEST
	if (koboldPath == nil)
	{
		koboldPath = @"/depot-kobold2d/Kobold2D-2.x-Master/Kobold2D";
	}
	
	if (koboldPath == nil)
	{
		NSLog(@"KoboldPath is nil");
		writeLog(@"kobold path is nil", logFile);
		return 1;
	}
	else if ([fileManager fileExistsAtPath:koboldPath] == NO)
	{
		NSLog(@"Path does not exist! Path: '%@'", koboldPath);
		writeLog([NSString stringWithFormat:@"path '%@' does not exist", koboldPath], logFile);
		return 2;
	}

	// ======================================================================================
	// Copying the File Templates to Xcode's file template folder
	// ======================================================================================
	{
		NSString* sourcePath = [NSString stringWithFormat:@"%@/__Kobold2D__/templates/File Templates/Kobold2D", koboldPath];
		NSString* targetPath = [NSString stringWithFormat:@"%@/Library/Developer/Xcode/Templates/File Templates/Kobold2D", NSHomeDirectory()];
		
		[fileManager createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:nil];
		if ([fileManager fileExistsAtPath:targetPath])
		{
			if ([fileManager removeItemAtPath:targetPath error:&error] == NO)
				showAlertWithError(error);
		}

		if ([fileManager copyItemAtPath:sourcePath toPath:targetPath error:&error] == NO)
			showAlertWithError(error);
	}

	// ======================================================================================
	// This is the part where the Xcode scheme is fixed so it won't show the library targets
	// ======================================================================================
	{
		NSString* koboldLibProject = nil;
		NSString* schemeManageFile = nil;
		koboldLibProject = [NSString stringWithFormat:@"%@/__Kobold2D__/Kobold2D-Libraries.xcodeproj", koboldPath];
		schemeManageFile = [NSString stringWithFormat:@"%@/__Kobold2D__/templates/workspace/xcschememanagement.plist", koboldPath];
		[logOutput appendString:@"checking...\n"];
		
		if ([fileManager fileExistsAtPath:koboldLibProject])
		{
			NSString* schemesPath = [NSString stringWithFormat:@"%@/xcuserdata/%@.xcuserdatad/xcschemes", koboldLibProject, [NSUserName() lowercaseString]];
			[logOutput appendFormat:@"schemesPath: %@\n", schemesPath];
			if ([fileManager fileExistsAtPath:schemesPath] == NO)
			{
				[logOutput appendFormat:@"trying to create schemesPath: %@\n", schemesPath];
				if ([fileManager createDirectoryAtPath:schemesPath
						   withIntermediateDirectories:YES
											attributes:nil
												 error:&error] == NO)
					showAlertWithError(error);
			}
			
			NSString* schemeManageTargetFile = [NSString stringWithFormat:@"%@/xcschememanagement.plist", schemesPath];
			[logOutput appendFormat:@"schemeManageTargetFile: %@\n", schemeManageTargetFile];
			if ([fileManager fileExistsAtPath:schemeManageTargetFile])
			{
				[logOutput appendFormat:@"removing schemeManageTargetFile: %@\n", schemeManageTargetFile];
				if ([fileManager removeItemAtPath:schemeManageTargetFile error:&error] == NO)
					showAlertWithError(error);
			}
			
			[logOutput appendFormat:@"copy schemeManageFile: %@\n", schemeManageFile];
			if ([fileManager copyItemAtPath:schemeManageFile toPath:schemeManageTargetFile error:&error] == NO)
				showAlertWithError(error);
		}
		else
		{
			writeLog(@"libproject doesn't exist\n", logFile);
		}
		
		[logOutput appendString:@"DONE!!\n"];
		writeLog(logOutput, logFile);
	}


	[pool release];
	pool = nil;
	
    return 0;
}
