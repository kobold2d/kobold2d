//
//  XcodeProject.h
//  Kobold2D Project Upgrader
//
//  Created by Steffen Itterheim on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XcodeProject : NSObject
{
	NSString* name;
	NSString* path;
	NSString* workspaceName;
	NSString* workspacePath;
	NSString* pathRelativeToWorkspacePath;
	NSString* fileRefLocation;
}

@property (copy) NSString* name;
@property (copy) NSString* path;
@property (copy) NSString* workspaceName;
@property (copy) NSString* workspacePath;
@property (copy) NSString* pathRelativeToWorkspacePath;
@property (copy) NSString* fileRefLocation;

-(id) initWithWorkspacePath:(NSString*)aWorkspacePath projectPath:(NSString*)aProjectPath;

-(NSComparisonResult) compareWith:(id)object;

@end
