//
//  XcodeProject.m
//  Kobold2D Project Upgrader
//
//  Created by Steffen Itterheim on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XcodeProject.h"
#import "ProjectsDataSource.h"

@implementation XcodeProject

@synthesize name, path, workspaceName, workspacePath, pathRelativeToWorkspacePath, fileRefLocation;

-(id) initWithWorkspacePath:(NSString*)aWorkspacePath projectPath:(NSString*)aProjectPath
{
    self = [super init];
    if (self) 
	{
		self.workspacePath = [aWorkspacePath substringToIndex:[aWorkspacePath length] - [[aWorkspacePath lastPathComponent] length] - 1];
		self.workspaceName = [aWorkspacePath lastPathComponent];
		self.path = [aProjectPath substringToIndex:[aProjectPath length] - [[aProjectPath lastPathComponent] length] - 1];
		self.name = [aProjectPath lastPathComponent];
		
		self.pathRelativeToWorkspacePath = [path stringByReplacingOccurrencesOfString:workspacePath withString:@""];
		[[ProjectsDataSource sharedDataSource] addLogLine:[NSString stringWithFormat:@"Found possibly upgradeable Xcode workspace: %@", [self description]]];
    }
    
    return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ workspaceName: %@, workspacePath: %@, projectName: %@, projectPath: %@", [super description], workspaceName, workspacePath, name, path];
}

-(NSComparisonResult) compareWith:(id)object
{
	NSComparisonResult result = NSOrderedSame;
	
	if ([object isKindOfClass:[XcodeProject class]])
	{
		XcodeProject* other = (XcodeProject*)object;
		result = [workspaceName compare:other.workspaceName];
		if (result == NSOrderedSame)
		{
			result = [name compare:other.name];
		}
	}
	
	return result;
}

@end
