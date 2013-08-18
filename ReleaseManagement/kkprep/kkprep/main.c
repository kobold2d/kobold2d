//
//  main.c
//  kkprep
//
//  Created by Steffen Itterheim on 19.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

//NSString* kobold2dVersion();
#import "kobold2d_version.h"

// strings defined in Kobold2D Project Starter tool
#import "Constants.h"


// IMPORTANT notice if only for the sake of my dignity: this code is CRAP! :)
// I was unfamiliar with bash and simply preferred to write what could have been a bash script
// in Objective-C simply because I can work in that environment faster and it's well documented.
// The resulting code is more like a sloppy script that does its job. It's most certainly not
// good code for a truly Object-Oriented, extensible, maintainable program.
// Ie it's a good example for code that doesn't have to be good code but code that simply does the job.


// ******************************************
// TEST MODE FLAG FOR FASTER PACKAGE CREATION
// ******************************************
const BOOL isTestMode = NO;
const BOOL dontCreateDocs = NO;


void showAlertWithError(NSError* error);	// avoid warning
void showAlertWithError(NSError* error)
{
	NSLog(@"ERROR: %@", error);
	NSAlert* alert = [NSAlert alertWithError:error];
	[alert runModal];
}

int main (int argc, const char * argv[])
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSError* error = nil;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSString* koboldVersion = [kobold2dVersion() stringByReplacingOccurrencesOfString:@"Kobold2D™ v" withString:@""];
	NSString* sourceDir = @"Kobold2D";
	NSString* targetDir = [NSString stringWithFormat:@"%@-%@", sourceDir, koboldVersion];
	NSString* startDir = [[fileManager currentDirectoryPath] stringByDeletingLastPathComponent];
	startDir = [startDir stringByAppendingString:@"/Kobold2D_Packages"];
	NSString* sourcePath = [NSString stringWithFormat:@"%@/%@", [fileManager currentDirectoryPath], sourceDir];
	NSString* targetPath = [NSString stringWithFormat:@"%@/%@", startDir, targetDir];

	NSLog(@"Kobold2D version string: '%@'", koboldVersion);
	NSLog(@"Source Path: '%@'", sourcePath);
	NSLog(@"Target Path: '%@'", targetPath);

	if (isTestMode || dontCreateDocs)
	{
		NSLog(@"**********************************************************");
		NSLog(@"*************** TEST MODE ENABLED !!! ********************");
		NSLog(@"**********************************************************");
	}

	if ([fileManager fileExistsAtPath:targetPath]) 
	{
		NSLog(@"removing existing '%@'", targetPath);
		if ([fileManager removeItemAtPath:targetPath error:&error] == NO)
			showAlertWithError(error);
	}

	// copy Kobold2D to Kobold2D-x.y
	// if this step fails, open the scheme and set custom working directory to: $(SOURCE_ROOT)/../../
	NSLog(@"copying '%@' to '%@' ... please be patient", sourcePath, targetPath);
	if ([fileManager copyItemAtPath:sourcePath toPath:targetPath error:&error] == NO)
		showAlertWithError(error);
	
	NSString* relManPath = [NSString stringWithFormat:@"%@/ReleaseManagement", [fileManager currentDirectoryPath]];
	NSString* relManTargetPath = [NSString stringWithFormat:@"%@/ReleaseManagement", startDir];
	if ([fileManager fileExistsAtPath:relManTargetPath])
		[fileManager removeItemAtPath:relManTargetPath error:nil];
	if ([fileManager copyItemAtPath:relManPath toPath:relManTargetPath error:&error] == NO)
		showAlertWithError(error);

	[fileManager changeCurrentDirectoryPath:targetPath];
	NSString* currentDir = [fileManager currentDirectoryPath];

	// move project templates to templates folder
	{
		NSArray* contents = [fileManager contentsOfDirectoryAtPath:currentDir error:nil];
		
		for (NSString* item in contents)
		{
			if ([item hasPrefix:kTemplateFolderPrefix] && [item hasSuffix:kTemplateFolderSuffix])
			{
				BOOL isDirectory = NO;
				NSString* templatePath = [NSString stringWithFormat:@"%@/%@", currentDir, item];
				BOOL exists = [fileManager fileExistsAtPath:templatePath isDirectory:&isDirectory];
				
				if (exists && isDirectory)
				{
					[fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/__Kobold2D__/templates/project", currentDir]
							   withIntermediateDirectories:YES attributes:nil error:nil];
					
					NSLog(@"Moving Template: '%@'", item);
					NSString* toPath = [NSString stringWithFormat:@"%@/__Kobold2D__/templates/project/%@", currentDir, item];
					if ([fileManager moveItemAtPath:templatePath toPath:toPath error:&error] == NO)
						showAlertWithError(error);
					
					NSString* descFile = [NSString stringWithFormat:@"%@/_description_", toPath];
					if ([fileManager fileExistsAtPath:descFile] == NO) 
						NSLog(@"ERROR: template project without description: %@", item);
				}
			}
		}
	}

	// remove github readme
	{
		NSString* readme = [NSString stringWithFormat:@"%@/README", currentDir];
		[fileManager removeItemAtPath:readme error:nil];
	}
	
	// remove templates from Kobold2D.xcworkspace
	{
		// replace Kobold2D.xcworkspace with the template workspace
		NSString* xcworkspace = [NSString stringWithFormat:@"%@/%@", currentDir, kKobold2DWorkspace];
		
		NSString* defaultWorkspaceDir = [NSString stringWithFormat:@"%@/__Kobold2D__/templates/workspace", currentDir];
		NSString* defaultWorkspace = [NSString stringWithFormat:@"%@/%@", defaultWorkspaceDir, kKobold2DWorkspace];

		// remove the existing workspace contents file
		[fileManager removeItemAtPath:xcworkspace error:nil];

		if ([fileManager copyItemAtPath:defaultWorkspace toPath:xcworkspace error:&error] == NO)
			showAlertWithError(error);
	}

	NSString* docsDir = [NSString stringWithFormat:@"%@/__Kobold2D__/docs", currentDir];
	
	// remove the folders in the docs directory to "clean" the docs
	{
		NSArray* contents = [fileManager contentsOfDirectoryAtPath:docsDir error:nil];
		
		for (NSString* item in contents)
		{
			BOOL isDirectory = NO;
			NSString* dir = [NSString stringWithFormat:@"%@/%@", docsDir, item];
			BOOL exists = [fileManager fileExistsAtPath:dir isDirectory:&isDirectory];
			
			if (exists && isDirectory)
			{
				NSLog(@"Deleting from docs: '%@'", item);
				[fileManager removeItemAtPath:dir error:nil];
			}
		}
	}

	// generate the docs
	{
		[fileManager changeCurrentDirectoryPath:docsDir];
		NSLog(@"docsDir: %@", docsDir);

		if (isTestMode == NO && dontCreateDocs == NO)
		{
			NSLog(@"Making docs ... please be very patient!");
			NSTask* task1 = [NSTask launchedTaskWithLaunchPath:@"./make-all-docs.sh" arguments:[NSArray array]];
			[task1 waitUntilExit];

			/*
			NSLog(@"Making docsets ... please be patient!");
			NSTask* task2 = [NSTask launchedTaskWithLaunchPath:@"./make-all-docsets.sh" arguments:[NSArray array]];
			[task2 waitUntilExit];
			 */
		}
		else
		{
			NSLog(@"Test Mode enabled: NOT making doxygen docs ...");
		}

		[fileManager changeCurrentDirectoryPath:currentDir];
	}

	// run package maker
	{
		[fileManager changeCurrentDirectoryPath:startDir];

		NSString* packageDir = [NSString stringWithFormat:@"%@/!makepackage-%@", startDir, koboldVersion];
		NSString* buildDir = [NSString stringWithFormat:@"%@/Kobold2D", packageDir];
		NSString* pkgContentsDir = [NSString stringWithFormat:@"%@/ReleaseManagement/packagecontents", startDir];
		NSString* resDir = [NSString stringWithFormat:@"%@/Resources", pkgContentsDir];
		NSString* enlprojDir = [NSString stringWithFormat:@"%@/en.lproj", resDir];
		NSString* licenseDir = [NSString stringWithFormat:@"%@/__Kobold2D__", currentDir];

		// copy license
		NSString* licenseSourceFile = [NSString stringWithFormat:@"%@/LICENSE-Kobold2D.txt", licenseDir];
		NSString* licenseTargetFile = [NSString stringWithFormat:@"%@/License", enlprojDir];
		[fileManager removeItemAtPath:licenseTargetFile error:nil];
		if ([fileManager copyItemAtPath:licenseSourceFile toPath:licenseTargetFile error:&error] == NO)
			showAlertWithError(error);
		
		// delete package dir just in case
		[fileManager removeItemAtPath:packageDir error:nil];

		if ([fileManager createDirectoryAtPath:buildDir withIntermediateDirectories:YES attributes:nil error:&error] == NO)
			showAlertWithError(error);

		NSString* buildTargetDir = [NSString stringWithFormat:@"%@/%@", buildDir, targetDir];
		if ([fileManager moveItemAtPath:targetDir toPath:buildTargetDir error:&error] == NO)
			showAlertWithError(error);
		
		NSString* pkgFile = [NSString stringWithFormat:@"Kobold2D_v%@.pkg", koboldVersion];
		if (isTestMode) {
			pkgFile = [NSString stringWithFormat:@"Kobold2D_TESTMODE_v%@.pkg", koboldVersion];
		}
		else if (dontCreateDocs) {
			pkgFile = [NSString stringWithFormat:@"Kobold2D_NODOCS_v%@.pkg", koboldVersion];
		}
		
		NSString* maker = @"/Applications/PackageMaker.app/Contents/MacOS/PackageMaker";
		//NSString* maker = @"/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker";
		
		assert([fileManager fileExistsAtPath:resDir] && "resDir path does not exist!");
		
		NSString* rootArg = [NSString stringWithFormat:@"--root %@", packageDir];
		NSString* outArg = [NSString stringWithFormat:@"--out %@/%@", startDir, pkgFile];
		NSString* versionArg = [NSString stringWithFormat:@"--version %@", koboldVersion];
		NSString* titleArg = [NSString stringWithFormat:@"--title %@", targetDir];
		NSString* resArg = [NSString stringWithFormat:@"--resources %@", resDir];
		NSString* idArg = [NSString stringWithFormat:@"--id com.kobold2d.%@", koboldVersion];
		//NSString* idArg = [NSString stringWithFormat:@"--info %@/Kobold2D_PackageInfo", pkgContentsDir];
		NSString* filterArg = @"--filter '/CVS$' --filter '/.git*' --filter '/.DS_Store$' --filter '/.svn*' --filter '/xcuserdata$' --filter '/.idea$'";
		NSString* generalArgs = @"--no-relocate --target 10.5 --domain user"; // --verbose --root-volume-only
		if (isTestMode) 
		{
			generalArgs = [NSString stringWithFormat:@"%@ --no-recommend", generalArgs];
		}
		
		NSString* script = [NSString stringWithFormat:@"#!/bin/bash\n%@ %@ %@ %@ %@ %@ %@ %@ %@", 
							maker, rootArg, outArg, versionArg, titleArg, idArg, generalArgs, filterArg, resArg];
		NSLog(@"PackageMaker command line:\n%@", script);
		
		// have to create a bash script, otherwise the PackageMaker GUI would open
		NSString* scriptFile = @"make-package.sh";
		if ([script writeToFile:scriptFile atomically:YES encoding:NSASCIIStringEncoding error:&error] == NO)
			showAlertWithError(error);

		NSString* chmodArgs = [NSString stringWithFormat:@"%@/%@", startDir, scriptFile];
		NSTask* task0 = [NSTask launchedTaskWithLaunchPath:@"/bin/chmod" arguments:[NSArray arrayWithObjects:@"+x", chmodArgs, nil]];
		[task0 waitUntilExit];
		
		NSLog(@"Making package ... please be excrutiatingly patient!");
		NSTask* task1 = [NSTask launchedTaskWithLaunchPath:@"./make-package.sh" arguments:[NSArray array]];
		[task1 waitUntilExit];

	
		
		// extract & modify the package
		NSString* extractDir = [NSString stringWithFormat:@"%@/packageextraction", packageDir];
		NSString* extractFile = [NSString stringWithFormat:@"%@/%@", extractDir, pkgFile];
		
		if ([fileManager createDirectoryAtPath:extractDir withIntermediateDirectories:YES attributes:nil error:&error] == NO)
			showAlertWithError(error);

		if ([fileManager moveItemAtPath:pkgFile toPath:extractFile error:&error] == NO)
			showAlertWithError(error);
		
		[fileManager changeCurrentDirectoryPath:extractDir];

		NSString* pkgExtractedDir = @"pkgExtracted";
		NSTask* task2 = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/pkgutil" arguments:[NSArray arrayWithObjects:@"--expand", pkgFile, pkgExtractedDir, nil]];
		[task2 waitUntilExit];
		
		
		// open Distribution file for modification
		NSString* partialFile = [NSString stringWithFormat:@"%@/Distribution-partial", pkgContentsDir];
		NSString* partial = [NSString stringWithContentsOfFile:partialFile encoding:NSASCIIStringEncoding error:&error];
		if (partial == nil)
			showAlertWithError(error);
		
		NSString* distroFile = [NSString stringWithFormat:@"%@/%@/Distribution", extractDir, pkgExtractedDir];
		NSString* distro = [NSString stringWithContentsOfFile:distroFile encoding:NSASCIIStringEncoding error:&error];
		if (distro == nil)
			showAlertWithError(error);
		
		NSString* searchStr = @"<domains enable_currentUserHome=\"true\"/>";
		distro = [distro stringByReplacingOccurrencesOfString:searchStr withString:partial];
		
		
		// add the postflight file
		NSString* postflightFile = [NSString stringWithFormat:@"%@/kobold2dPostflight.pkg", pkgContentsDir];
		NSString* postflightTargetFile = [NSString stringWithFormat:@"%@/%@/kobold2dPostflight.pkg", extractDir, pkgExtractedDir];
		if ([fileManager copyItemAtPath:postflightFile toPath:postflightTargetFile error:&error] == NO)
			showAlertWithError(error);

		// modify the postflight script
		NSString* postflightScriptFile = [NSString stringWithFormat:@"%@/Scripts/postflight", postflightTargetFile];
		NSString* postflightScript = [NSString stringWithContentsOfFile:postflightScriptFile encoding:NSASCIIStringEncoding error:&error];
		if (postflightScript == nil)
			showAlertWithError(error);
		
		postflightScript = [postflightScript stringByReplacingOccurrencesOfString:@"___KOBOLD2D-VERSION___" withString:targetDir];
		[postflightScript writeToFile:postflightScriptFile atomically:YES encoding:NSASCIIStringEncoding error:&error];

		if ([distro writeToFile:distroFile atomically:YES encoding:NSASCIIStringEncoding error:&error] == NO)
			showAlertWithError(error);

		// substring replace the Distribution file
		searchStr = @"</choices-outline>";
		NSString* replaceStr = [NSString stringWithFormat:@"<line choice=\"choice5\"/>\n%@", searchStr];
		distro = [distro stringByReplacingOccurrencesOfString:searchStr withString:replaceStr];

		if ([distro writeToFile:distroFile atomically:YES encoding:NSASCIIStringEncoding error:&error] == NO)
			showAlertWithError(error);

		searchStr = [NSString stringWithFormat:@"<pkg-ref id=\"com.kobold2d.%@\" installKBytes=", koboldVersion];
		replaceStr = [NSString stringWithFormat:@"<choice id=\"choice5\" title=\"Kobold2D Postflight\" start_visible=\"false\">\n<pkg-ref id=\"com.kobold2d.kobold2d.postflight.pkg\"/>\n</choice>\n%@", searchStr];
		distro = [distro stringByReplacingOccurrencesOfString:searchStr withString:replaceStr];

		if ([distro writeToFile:distroFile atomically:YES encoding:NSASCIIStringEncoding error:&error] == NO)
			showAlertWithError(error);

		searchStr = @"</installer-script>";
		replaceStr = [NSString stringWithFormat:@"<pkg-ref id=\"com.kobold2d.kobold2d.postflight.pkg\" installKBytes=\"0\" version=\"1.0\" auth=\"Root\">#kobold2dPostflight.pkg</pkg-ref>\n%@", searchStr];
		distro = [distro stringByReplacingOccurrencesOfString:searchStr withString:replaceStr];

		if ([distro writeToFile:distroFile atomically:YES encoding:NSASCIIStringEncoding error:&error] == NO)
			showAlertWithError(error);

		
		// re-package installer package
		NSTask* task3 = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/pkgutil" arguments:[NSArray arrayWithObjects:@"--flatten", pkgExtractedDir, pkgFile, nil]];
		[task3 waitUntilExit];

		NSString* pkgFileSigned = [NSString stringWithFormat:@"%@/%@", packageDir, pkgFile];
		NSString* pkgFileUnsigned = [NSString stringWithFormat:@"%@/%@_unsigned.pkg", packageDir, pkgFile];
		if ([fileManager moveItemAtPath:pkgFile toPath:pkgFileUnsigned error:&error] == NO)
			showAlertWithError(error);
		
		// cleanup
		// keep package dir in case the docs are needed
		//[fileManager removeItemAtPath:packageDir error:nil];
		[fileManager removeItemAtPath:scriptFile error:nil];
		[fileManager removeItemAtPath:relManTargetPath error:nil];
		
		
		// code sign package installer
		NSLog(@"Begin Code Signing ...");
		// productsign --sign "Developer ID Installer" Kobold2D_NODOCS_v2.0.4.pkg Kobold2D_NODOCS_v2.0.4_signed.pkg
		NSArray* args = [NSArray arrayWithObjects:@"--sign", @"Developer ID Installer", pkgFileUnsigned, pkgFileSigned, nil];
		NSTask* task5 = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/productsign" arguments:args];
		[task5 waitUntilExit];
		
		// and verify it just in case
		//spctl -a -v --type install Kobold2D_NODOCS_v2.0.4_signed.pkg
		args = [NSArray arrayWithObjects:@"-a", @"-v", @"--type", @"install", pkgFileSigned, nil];
		NSTask* task6 = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/spctl" arguments:args];
		[task6 waitUntilExit];

		[fileManager removeItemAtPath:pkgFileUnsigned error:nil];
	}
	
	NSLog(@"\n\nKobold2D packaging complete!\n");
	
	[pool release];
	pool = nil;
	
    return 0;
}

