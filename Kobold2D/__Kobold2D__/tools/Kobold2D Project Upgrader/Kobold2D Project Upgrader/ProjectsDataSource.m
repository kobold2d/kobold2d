//
//  ProjectsDataSource.m
//  Kobold2D Project Upgrader
//
//  Created by Steffen Itterheim on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProjectsDataSource.h"

#import "KoboldVersion.h"
#import "XcodeProject.h"

@interface ProjectsDataSource (PrivateMethods)
-(void) findKoboldInstallDir;
-(void) loadKoboldVersions;
@end

@implementation ProjectsDataSource 
@synthesize noProjectsLabel;
@synthesize tableView;
@synthesize notesText;
@synthesize previousVersions;
@synthesize previousVersionProjects;
@synthesize currentVersionLabel;
@synthesize upgradeButton;
@synthesize progressIndicator;

static ProjectsDataSource* instance = nil;

+(ProjectsDataSource*) sharedDataSource
{
	NSAssert(instance, @"ProjectsDataSource instance is nil");
	return instance;
}

-(void) addLogLine:(NSString*)line
{
	[logOutput appendFormat:@"%@\n", line];
}

-(NSInteger) numberOfRowsInTableView:(NSTableView*)aTableView
{
	return [[selectedVersion projects] count];
}

-(id) tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id value = nil;
	
	XcodeProject* project = [[selectedVersion projects] objectAtIndex:row];
	if (project)
	{
		if ([tableColumn.identifier isEqualToString:@"projectsColumn"]) 
		{
			value = [project.name stringByReplacingOccurrencesOfString:@".xcodeproj" withString:@""];
		}
		else
		{
			value = [project.workspaceName stringByReplacingOccurrencesOfString:@".xcworkspace" withString:@""];
		}
	}
	
	return value;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSIndexSet* indexes = [previousVersionProjects selectedRowIndexes];
	[upgradeButton setEnabled:([indexes count] > 0)];
}


-(NSString*) comboBox:(NSComboBox*)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	return [[versions objectAtIndex:index] name];
}

-(NSInteger) numberOfItemsInComboBox:(NSComboBox*)aComboBox
{
	return [versions count];
}

-(NSString*) comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
{
	NSString* found = nil;
	uncompletedString = [uncompletedString lowercaseString];
	
	for (NSUInteger i = 0; i < [versions count]; i++)
	{
		KoboldVersion* ver = [versions objectAtIndex:i];
		if ([[[ver name] lowercaseString] hasPrefix:uncompletedString])
		{
			found = [ver name];
			break;
		}
	}
	
	return found;
}

-(NSUInteger) comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString
{
	NSUInteger index = NSNotFound;
	aString = [aString lowercaseString];
	
	for (NSUInteger i = 0; i < [versions count]; i++)
	{
		KoboldVersion* ver = [versions objectAtIndex:i];
		if ([[[ver name] lowercaseString] isEqualToString:aString])
		{
			index = i;
			break;
		}
	}
	
	return index;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
	selectedVersion = [versions objectAtIndex:[previousVersions indexOfSelectedItem]];
	[previousVersionProjects reloadData];
	[previousVersionProjects selectAll:self];
}

- (id)init
{
    self = [super init];
    if (self) 
	{
		instance = self;
		versions = [[NSMutableArray alloc] initWithCapacity:10];
		logOutput = [[NSMutableString alloc] initWithCapacity:1000];
    }
    
    return self;
}

-(void) dealloc
{
	[versions release];
	[currentVersion release];
	[logOutput release];
	instance = nil;
	[super dealloc];
}

-(void) awakeFromNib
{
	[self findKoboldInstallDir];
	[self loadKoboldVersions];

	NSString* workdir = [[NSBundle mainBundle] bundlePath];
	workdir = [workdir substringToIndex:[workdir length] - [[workdir lastPathComponent] length] - 1];
	NSString* logFile = [NSString stringWithFormat:@"%@/Kobold2D Project Upgrader Log.txt", workdir];
	[logOutput writeToFile:logFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
	[logOutput release];
	logOutput = nil;

	[currentVersionLabel setStringValue:currentVersion.name];

	[previousVersions reloadData];
	
	if ([versions count] > 0)
	{
		[previousVersions selectItemAtIndex:0];
	}
	else
	{
		[tableView setHidden:YES];
		[previousVersions setHidden:YES];
		[previousVersionProjects setHidden:YES];
		[noProjectsLabel setHidden:NO];

		[upgradeButton setEnabled:YES];
		[upgradeButton setTitle:@"Quit"];
		upgradeComplete = YES;
	}
}

-(void) findKoboldInstallDir
{
	NSString* workingDir = [[NSBundle mainBundle] bundlePath];
	NSLog(@"working dir: %@", workingDir);
	[self addLogLine:[NSString stringWithFormat:@"Current Working Dir: %@", workingDir]];

	workingDir = [workingDir substringToIndex:[workingDir length] - [[workingDir lastPathComponent] length] - 1];
	NSLog(@"working dir: %@", workingDir);
	[self addLogLine:[NSString stringWithFormat:@"Going up one directory (base dir): %@", workingDir]];
	
	// only for debugging
	NSRange buildoutput = [[[NSBundle mainBundle] bundlePath] rangeOfString:@"_buildoutput"];
	if (buildoutput.location != NSNotFound)
	{
		debugging = YES;
		workingDir = [[NSFileManager defaultManager] currentDirectoryPath];
		[self addLogLine:@"SWITCHING TO DEVELOPMENT MODE"];
	}

	
	[self addLogLine:@"Creating CURRENT Kobold2D version (destination path is nil on purpose)"];
	[currentVersion release];
	currentVersion = [[KoboldVersion alloc] initWithPath:workingDir destinationPath:nil];
	
	workingDir = [workingDir substringToIndex:[workingDir length] - [currentVersion.name length] - 1];
	NSLog(@"working dir: %@", workingDir);
	[self addLogLine:[NSString stringWithFormat:@"Possible Kobold2D Base Dir: %@", workingDir]];

	koboldInstallDir = workingDir;
	NSLog(@"Kobold2D Install dir: %@", koboldInstallDir);
	NSLog(@"Current Version: %@", currentVersion);
}

-(void) loadKoboldDir:(NSString*)dir
{
	NSLog(@"Loading Kobold dir: %@", dir);
	KoboldVersion* newVersion = [[[KoboldVersion alloc] initWithPath:dir destinationPath:currentVersion.path] autorelease];
	
	if ([newVersion.projects count] > 0)
	{
		[versions addObject:newVersion];
	}
}

-(void) loadKoboldVersions
{
	NSLog(@"Looking for Kobold2D folders in: %@", koboldInstallDir);
	[self addLogLine:[NSString stringWithFormat:@"Looking for Kobold2D versions in: %@", koboldInstallDir]];
	
	NSFileManager* fileManager = [[NSFileManager alloc] init];
	NSArray* contents = [fileManager contentsOfDirectoryAtPath:koboldInstallDir error:nil];
	
	for (NSString* item in contents)
	{
		[self addLogLine:[NSString stringWithFormat:@"Considering: %@", item]];
		BOOL isDirectory = NO;
		NSString* checkDir = [NSString stringWithFormat:@"%@/%@", koboldInstallDir, item];
		BOOL exists = [fileManager fileExistsAtPath:checkDir isDirectory:&isDirectory];
		
		if (exists && isDirectory)
		{
			[self addLogLine:[NSString stringWithFormat:@"%@ exists and is a directory, checking if it contains __Kobold2D__ folder...", item]];
			
			NSString* koboldDir = [NSString stringWithFormat:@"%@/__Kobold2D__", checkDir];
			exists = [fileManager fileExistsAtPath:koboldDir isDirectory:&isDirectory];
			
			if (exists && isDirectory)
			{
				if ([checkDir isEqualToString:currentVersion.path] == NO)
				{
					[self addLogLine:[NSString stringWithFormat:@"CONFIRMED: %@ is a Kobold2D folder", item]];
					// this is a Kobold2D version folder
					[self loadKoboldDir:checkDir];
				}
				else
				{
					[self addLogLine:[NSString stringWithFormat:@"IGNORED: %@ is a Kobold2D folder BUT it is the current version", item]];
				}
			}
			else
			{
				[self addLogLine:[NSString stringWithFormat:@"IGNORED: %@ does not contain the __Kobold2D__ subfolder", item]];
			}
		}
	}
	
	[fileManager release];
	fileManager = nil;

	[versions sortUsingSelector:@selector(compareWith:)];
}

-(void) performUpgradeForSelection
{
	/*
	- upgrade process:
		- if workspace does not exist: create empty workspace file with same name in destination directory
		- add to workspace all projects that should be migrated
		- copy the project directories that should be migrated
	 */


	NSLog(@"versions count: %lu", [selectedVersion.projects count]);
	NSIndexSet* indexes = [previousVersionProjects selectedRowIndexes];
	[selectedVersion.projects enumerateObjectsAtIndexes:indexes options:0 usingBlock:^(id object, NSUInteger index, BOOL* stop)
	 {
		 NSFileManager* fileManager = [[NSFileManager alloc] init];
		 XcodeProject* project = (XcodeProject*)object;
		 NSError* error = nil;

		 NSLog(@"Upgrading Project: %@ ('%@')", project.name, project.fileRefLocation);

		 // copy the project folder to its new location
		 NSString* destinationProjectPath = [NSString stringWithFormat:@"%@%@", currentVersion.path, project.pathRelativeToWorkspacePath];
		 if ([fileManager fileExistsAtPath:destinationProjectPath] == YES)
		 {
			 NSLog(@"Can't copy project folder, same folder (file?) exists in destination: %@", error);
			 *stop = YES;
			 return;
		 }
		 
		 if ([fileManager copyItemAtPath:project.path toPath:destinationProjectPath error:&error] == NO)
		 {
			 NSLog(@"Error copying project folder: %@", error);
			 *stop = YES;
			 return;
		 }
		 
		 // modify build settings if necessary
		 {
			 NSString* buildSettingsPath = [NSString stringWithFormat:@"%@/BuildSettings", destinationProjectPath];
			 NSString* buildSettingsIOS = [NSString stringWithFormat:@"%@/BuildSettings-iOS.xcconfig", buildSettingsPath];
			 NSString* settings = [NSString stringWithContentsOfFile:buildSettingsIOS encoding:NSUTF8StringEncoding error:&error];
			 if (settings)
			 {
				 NSString* replaceBefore = @"OTHER_LDFLAGS = $(inherited) $(LINK_WITH_ZLIB) $(FORCE_LOAD_KOBOLD2D) $(FORCE_LOAD_COCOS3D)";
				 NSString* replaceAfter = [NSString stringWithFormat:@"%@ $(KKLIBROOT)/GoogleAdMobAdsSDK/libGoogleAdMobAds.a -framework SystemConfiguration -framework CoreMotion", replaceBefore];
				 settings = [settings stringByReplacingOccurrencesOfString:replaceBefore withString:replaceAfter];
				 [settings writeToFile:buildSettingsIOS atomically:YES encoding:NSUTF8StringEncoding error:&error];
			 }
		 }

		 // create the destination workspace if it doesn't exist
		 NSString* destinationWorkspacePath = [NSString stringWithFormat:@"%@/%@", currentVersion.path, project.workspaceName];
		 if ([fileManager fileExistsAtPath:destinationWorkspacePath] == NO)
		 {
			 // first copy the workspace file entirely to keep userdata intact
			 NSString* sourceWorkspacePath = [NSString stringWithFormat:@"%@/%@", project.workspacePath, project.workspaceName];
			 if ([fileManager copyItemAtPath:sourceWorkspacePath toPath:destinationWorkspacePath error:&error] == NO)
			 {
				 NSLog(@"Error copying workspace: %@", error);
				 *stop = YES;
				 return;
			 }

			 // then replace its contents file because it may reference other projects
			 NSString* defaultWorkspaceContentsPath = [NSString stringWithFormat:@"%@/__Kobold2D__/templates/workspace/Kobold2D.xcworkspace/contents.xcworkspacedata", currentVersion.path];
			 NSString* destinationWorkspaceContentsPath = [NSString stringWithFormat:@"%@/contents.xcworkspacedata", destinationWorkspacePath];
			 [fileManager removeItemAtPath:destinationWorkspaceContentsPath error:nil];
			 if ([fileManager copyItemAtPath:defaultWorkspaceContentsPath toPath:destinationWorkspaceContentsPath error:&error] == NO)
			 {
				 NSLog(@"Error copying default workspace contents file: %@", error);
				 *stop = YES;
				 return;
			 }
		 }
		 
		 // read the contents.xcworkspacedata and insert the new project at the beginning
		 NSString* contentsFile = [NSString stringWithFormat:@"%@/contents.xcworkspacedata", destinationWorkspacePath];
		 NSString* contents = [NSString stringWithContentsOfFile:contentsFile encoding:NSUTF8StringEncoding error:&error];
		 if (contents == nil)
		 {
			 NSLog(@"Error reading destination workspace contents file: %@", error);
			 *stop = YES;
			 return;
		 }
			 
		 // create the new entry
		 NSString* insert = [NSString stringWithFormat:@"<FileRef\n      location = \"%@\">\n   </FileRef>\n   ", project.fileRefLocation];
		 
		 // if for whatever reason this entry already exists, remove it
		 contents = [contents stringByReplacingOccurrencesOfString:insert withString:@""];
		 
		 // find the insertion point
		 NSRange insertPoint = [contents rangeOfString:@"<FileRef"];
		 NSString* front = [contents substringToIndex:insertPoint.location];
		 NSString* back = [contents substringFromIndex:insertPoint.location];
		 
		 // construct the new string with the new FileRef inserted
		 contents = [NSString stringWithFormat:@"%@%@%@", front, insert, back];
		 if ([contents writeToFile:contentsFile atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO)
		 {
			 NSLog(@"Error writing destination workspace contents file: %@", error);
			 *stop = YES;
			 return;
		 }
		 
		 [fileManager release];
		 fileManager = nil;
	 }];
}

- (IBAction)upgradeClicked:(id)sender 
{
	if (upgradeComplete)
	{
		[[NSApplication sharedApplication] terminate:self];
		return;
	}
	
	[upgradeButton setHidden:YES];
	[upgradeButton drawCell:[upgradeButton cell]]; // update immediately
	[previousVersions setEnabled:NO];
	[previousVersions drawCell:[previousVersions cell]];
	
	[progressIndicator setHidden:NO];
	[progressIndicator setUsesThreadedAnimation:YES];
	[progressIndicator startAnimation:self];

	[self performUpgradeForSelection];
	
	[progressIndicator stopAnimation:self];
	[progressIndicator setHidden:YES];
	
	[upgradeButton setTitle:@"Quit"];
	[upgradeButton setHidden:NO];
	upgradeComplete = YES;
	
	[tableView setHidden:YES];
	[notesText setHidden:NO];
	[previousVersionProjects setHidden:YES];
}

- (IBAction)helpClicked:(id)sender 
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.kobold2d.com/x/QAUO"]];
}
@end
