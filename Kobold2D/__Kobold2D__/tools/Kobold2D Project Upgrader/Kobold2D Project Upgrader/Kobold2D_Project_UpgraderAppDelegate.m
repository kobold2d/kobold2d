//
//  Kobold2D_Project_UpgraderAppDelegate.m
//  Kobold2D Project Upgrader
//
//  Created by Steffen Itterheim on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Kobold2D_Project_UpgraderAppDelegate.h"

@implementation Kobold2D_Project_UpgraderAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end


/* Quick Design

 - scan own directory for existing workspaces and their projects
 - scan all "Kobold2D..." directories at same level, but ignore own directory
 - extract each Kobold2D's version number
	- collect the list of workspaces in that folder
	- collect the list of projects in that workspace
 - display tree: Kobold2D versions +> contained Workspaces +> Projects in Workspace
 - allow selection (checkbox?) of workspaces and projects individually
	- by default check all, except those that already exist at own directory
	- but ignore the kobold2d workspace (it usually exists)
	- warn if a project is checked that already exists in own dir
 - Upgrade button: upgrade selected workspaces and projects
 
 - upgrade process:
	- if workspace does not exist: create empty workspace file with same name in own directory
	- add to workspace all projects that should be migrated
	- copy the project directories that should be migrated

 
*/