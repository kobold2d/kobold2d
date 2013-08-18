/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

// Note: this project's code is slapped together as it serves a single purpose and is unlikely
// to require much attention in the future. It's a deliberate tradeoff of initial development speed
// vs. good coding style.

#import "MainWindowController.h"

#import "Constants.h"

@interface MainWindowController (PrivateMethods)
-(void) changePathToKobold2D:(NSString*)path;
@end

@implementation MainWindowController
@synthesize createProjectButton;
@synthesize templateDescription;
@synthesize autoOpenProject;
@synthesize workspaceList;
@synthesize pathToKobold2D;
@synthesize templatesList;
@synthesize createProjectName;

-(void) addLogLine:(NSString*)line
{
	[logOutput appendString:line];
}

-(NSInteger) numberOfRowsInTableView:(NSTableView*)aTableView
{
	return [templates count];
}

-(id) tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [templates objectAtIndex:row];
}

-(NSString*) comboBox:(NSComboBox*)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	return [workspaces objectAtIndex:index];
}

-(NSInteger) numberOfItemsInComboBox:(NSComboBox*)aComboBox
{
	return [workspaces count];
}

-(NSString*) comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
{
	NSString* found = nil;
	uncompletedString = [uncompletedString lowercaseString];
	
	for (NSUInteger i = 0; i < [workspaces count]; i++)
	{
		NSString* ws = [workspaces objectAtIndex:i];
		if ([[ws lowercaseString] hasPrefix:uncompletedString])
		{
			found = ws;
			break;
		}
	}
	
	return found;
}

-(NSUInteger) comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString
{
	NSUInteger index = NSNotFound;
	aString = [aString lowercaseString];
	
	for (NSUInteger i = 0; i < [workspaces count]; i++)
	{
		NSString* ws = [workspaces objectAtIndex:i];
		if ([[ws lowercaseString] isEqualToString:aString])
		{
			index = i;
			break;
		}
	}
	
	return index;
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) 
	{
		templates = [[NSMutableArray alloc] initWithCapacity:10];
		descriptions = [[NSMutableArray alloc] initWithCapacity:10];
		workspaces = [[NSMutableArray alloc] initWithCapacity:10];
	}
    
    return self;
}

- (void)dealloc
{
	[templates release];
	[descriptions release];
	[workspaces release];
	
    [super dealloc];
}

-(void) awakeFromNib
{
	[self tryFindPathToKobold2D];
}

-(NSString*) addTrailingSlash:(NSString*)path
{
	if ([path hasSuffix:@"/"] == NO)
	{
		path = [NSString stringWithFormat:@"%@/", path];
	}
	
	return path;
}

-(BOOL) kobold2DExistsAtPath:(NSString*)path
{
	NSString* k2libsproject = [NSString stringWithFormat:@"%@%@", path, kKobold2DLibrariesProject];
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:k2libsproject];
	[self addLogLine:[NSString stringWithFormat:@"Does Kobold2D-Libraries.xcodeproj exist at path '%@'? Result: %@", k2libsproject, exists ? @"YES" : @"NO"]];
	return exists;
}

-(void) tryFindPathToKobold2D
{
	NSString* workingDir = [[NSBundle mainBundle] bundlePath];
	[self addLogLine:[NSString stringWithFormat:@"Working Dir: %@", workingDir]];
	workingDir = [workingDir substringToIndex:[workingDir length] - [[workingDir lastPathComponent] length]];
	[self addLogLine:[NSString stringWithFormat:@"Kobold2D Base Dir: %@", workingDir]];
	
	// only for debugging
	NSRange buildoutput = [workingDir rangeOfString:@"_buildoutput"];
	if (buildoutput.location != NSNotFound)
	{
		debugging = YES;
		workingDir = [[NSFileManager defaultManager] currentDirectoryPath];
	}
	
	[pathToKobold2D setStringValue:workingDir];
	//[newProjectName setStringValue:workingDir];

	while (workingDir != nil && [workingDir length] > 0)
	{
		workingDir = [self addTrailingSlash:workingDir];
		NSLog(@"Trying path: %@", workingDir);
		[self addLogLine:[NSString stringWithFormat:@"Trying to locate Kobold2D at: %@", workingDir]];
		
		if ([self kobold2DExistsAtPath:workingDir])
		{
			[pathToKobold2D setStringValue:workingDir];
			[self changePathToKobold2D:workingDir];
			break;
		}
		else
		{
			NSString* lastPath = [workingDir lastPathComponent];
			NSInteger index = [workingDir length] - ([lastPath length] + 1);
			if (index <= 0) 
			{
				break;
			}
			
			workingDir = [workingDir substringToIndex:index];
		}
	}
	
	// if nothing found, assume development mode and try again
	if (debugging == NO && [templates count] == 0)
	{
		[self addLogLine:@"... did not find templates, switching to DEVELOPMENT MODE!"];
		debugging = YES;
		[createProjectName setBackgroundColor:[NSColor cyanColor]];
		[self tryFindPathToKobold2D];
	}
}

- (IBAction)helpClicked:(id)sender 
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.kobold2d.com/x/XwMO"]];
}

-(void) addTemplate:(NSString*)templateName
{
	// beautify name
	NSString* name = [templateName substringFromIndex:1];
	name = [name substringToIndex:[name length] - [kTemplateFolderSuffix length]];
	//name = [name stringByReplacingOccurrencesOfString:@"-" withString:@" "];
	[templates addObject:name];
	
	NSString* path = [pathToKobold2D stringValue];
	NSString* descFile = [NSString stringWithFormat:@"%@%@%@/%@", path, kTemplatesSubDir, templateName, kDescriptionFile];
	if (debugging)
	{
		descFile = [NSString stringWithFormat:@"%@%@/%@", path, templateName, kDescriptionFile];
	}

	// load description
	NSString* description = @"[no description available]";
	NSFileManager* fileManager = [[NSFileManager alloc] init];
	if ([fileManager fileExistsAtPath:descFile])
	{
		description = [NSString stringWithContentsOfFile:descFile encoding:NSUTF8StringEncoding error:nil];
	}
	[fileManager release];
	fileManager = nil;
	
	[descriptions addObject:description];
}

-(void) updateTemplatesListFromPath:(NSString*)path
{
	[templates removeAllObjects];
	[templatesList reloadData];
	
	[descriptions removeAllObjects];
	[templateDescription setStringValue:@""];
	
	if (debugging == NO)
	{
		path = [NSString stringWithFormat:@"%@%@", path, kTemplatesSubDir];
	}
	NSLog(@"Looking for project templates in: %@", path);
	[self addLogLine:[NSString stringWithFormat:@"Reading template projects in path: %@", path]];

	NSFileManager* fileManager = [[NSFileManager alloc] init];
	NSArray* contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
	
	for (NSString* item in contents)
	{
		NSLog(@"Trying: %@", item);
		[self addLogLine:[NSString stringWithFormat:@"Testing if '%@' is a template project.", item]];
		
		if ([item hasPrefix:kTemplateFolderPrefix] && [item hasSuffix:kTemplateFolderSuffix])
		{
			BOOL isDirectory = NO;
			NSString* templatePath = [NSString stringWithFormat:@"%@%@", path, item];
			BOOL exists = [fileManager fileExistsAtPath:templatePath isDirectory:&isDirectory];
			
			if (exists && isDirectory)
			{
				NSLog(@"Found Template: %@", item);
				[self addLogLine:[NSString stringWithFormat:@"Found template project: %@", item]];
				[self addTemplate:item];
			}
		}
	}

	[fileManager release];
	fileManager = nil;

	[templatesList reloadData];
}

-(void) updateWorkspacesListFromPath:(NSString*)path
{
	[workspaces removeAllObjects];
	[workspaceList reloadData];

	NSLog(@"Looking for workspaces in: %@", path);
	[self addLogLine:[NSString stringWithFormat:@"Looking for .xcworkspace files in: %@", path]];
	
	NSFileManager* fileManager = [[NSFileManager alloc] init];
	NSArray* contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
	
	for (NSString* item in contents)
	{
		if ([item hasSuffix:@".xcworkspace"])
		{
			[self addLogLine:[NSString stringWithFormat:@"Found a .xcworkspace file at: %@", item]];
			
			BOOL isDirectory = NO;
			NSString* templatePath = [NSString stringWithFormat:@"%@%@", path, item];
			BOOL exists = [fileManager fileExistsAtPath:templatePath isDirectory:&isDirectory];
			
			if (exists && isDirectory)
			{
				NSLog(@"Found Workspace: %@", item);
				[self addLogLine:[NSString stringWithFormat:@"Confirmed that .xcworkspace is an Xcode workspace: %@", item]];
				[workspaces addObject:item];
			}
		}
	}
	
	[workspaceList reloadData];
}


-(void) changePathToKobold2D:(NSString*)path
{
	// verify path correct
	if ([self kobold2DExistsAtPath:path]) 
	{
		[templatesList setEnabled:YES];
		[workspaceList setEnabled:YES];
		[createProjectName setEnabled:YES];

		// search for templates
		[self updateTemplatesListFromPath:path];
		
		// search for workspaces
		[self updateWorkspacesListFromPath:path];
	}
	else
	{
		// reset everything
		[descriptions removeAllObjects];
		[templateDescription setStringValue:@""];
		
		[templates removeAllObjects];
		[templatesList reloadData];
		[templatesList setEnabled:NO];
		
		[workspaces removeAllObjects];
		[workspaceList reloadData];
		[workspaceList setEnabled:NO];
		
		[createProjectName setEnabled:NO];
		[createProjectButton setEnabled:NO];
	}
}

-(void) tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSUInteger row = [templatesList selectedRow];
	if ([descriptions count] > row)
	{
		NSString* desc = [descriptions objectAtIndex:row];
		[templateDescription setStringValue:desc];

		[createProjectButton setEnabled:YES];
	}
	else
	{
		[templateDescription setStringValue:@""];
		[createProjectButton setEnabled:NO];
	}
}

-(void) showAlertWithError:(NSError*)error
{
	NSAlert* alert = [NSAlert alertWithError:error];
	[alert runModal];
}

-(void) createProjectWithName:(NSString*)projectName fromTemplate:(NSString*)templateName intoWorkspace:(NSString*)workspaceName
{
	NSError* error = nil;

	NSString* rootPath = [pathToKobold2D stringValue];
	NSString* fullTemplateName = [NSString stringWithFormat:@"%@%@%@", kTemplateFolderPrefix, templateName, kTemplateFolderSuffix];
	NSString* sourcePath = [NSString stringWithFormat:@"%@%@%@", rootPath, kTemplatesSubDir, fullTemplateName];
	NSString* targetPath = [NSString stringWithFormat:@"%@%@", rootPath, projectName];
	
	NSFileManager* fileManager = [NSFileManager defaultManager];

	// make sure we don't overwrite anything
	if ([fileManager fileExistsAtPath:targetPath])
	{
		NSString* msg = [NSString stringWithFormat:@"A project with the name '%@' already exists!\n\nIf you want to create a project with the same name you will have to rename or remove this folder:\n\n%@", projectName, targetPath];
		NSAlert* alert = [NSAlert alertWithMessageText:msg defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
		[alert runModal];
		return;
	}

	NSLog(@"Copying template...\nFrom: %@\nTo: %@", sourcePath, targetPath);
	
	// copy the template to a new folder in the root of Kobold2D-x.y
	if ([fileManager copyItemAtPath:sourcePath toPath:targetPath error:&error] == NO)
		[self showAlertWithError:error];

	// remove template description file
	NSString* descriptionFile = [NSString stringWithFormat:@"%@/%@", targetPath, kDescriptionFile];
	if ([fileManager removeItemAtPath:descriptionFile error:&error] == NO)
		[self showAlertWithError:error];

	// rename the Xcode project file
	NSString* projOld = [NSString stringWithFormat:@"%@/%@.xcodeproj", targetPath, fullTemplateName];
	NSString* projNew = [NSString stringWithFormat:@"%@/%@.xcodeproj", targetPath, projectName];
	NSLog(@"copy project\nfrom: %@\nto: %@", projOld, projNew);
	if ([fileManager moveItemAtPath:projOld toPath:projNew error:&error] == NO)
		[self showAlertWithError:error];

	// moving inside the .xcodeproj package
	{
		// replace template name with project name
		NSString* pbxproj = [NSString stringWithFormat:@"%@/project.pbxproj", projNew];
		NSString* projContent = [NSString stringWithContentsOfFile:pbxproj encoding:NSUTF8StringEncoding error:&error];
		if (projContent == nil)
			[self showAlertWithError:error];
		
		projContent = [projContent stringByReplacingOccurrencesOfString:fullTemplateName withString:projectName];
		if ([projContent writeToFile:pbxproj atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO)
			[self showAlertWithError:error];
	}

	// now we move inside the .xcodeproj's workspace
	{
		// replace template name with project name
		NSString* wsdata = [NSString stringWithFormat:@"%@/project.xcworkspace/contents.xcworkspacedata", projNew];
		NSString* projContent = [NSString stringWithContentsOfFile:wsdata encoding:NSUTF8StringEncoding error:&error];
		if (projContent == nil)
			[self showAlertWithError:error];

		projContent = [projContent stringByReplacingOccurrencesOfString:fullTemplateName withString:projectName];
		if ([projContent writeToFile:wsdata atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO)
			[self showAlertWithError:error];
	}

	// any schemes saved in the project's xcshareddata must also be renamed
	{
		NSString* schemePath = [NSString stringWithFormat:@"%@/xcshareddata/xcschemes", projNew];
		NSArray* schemes = [fileManager contentsOfDirectoryAtPath:schemePath error:&error];
		if (schemes == nil)
			[self showAlertWithError:error];
		
		for (NSString* schemeFileName in schemes)
		{
			if ([schemeFileName hasSuffix:@".xcscheme"])
			{
				// replace the scheme file's contents
				NSString* schemeFile = [NSString stringWithFormat:@"%@/%@", schemePath, schemeFileName];
				NSString* content = [NSString stringWithContentsOfFile:schemeFile encoding:NSUTF8StringEncoding error:&error];
				if (content == nil)
					[self showAlertWithError:error];
				
				content = [content stringByReplacingOccurrencesOfString:fullTemplateName withString:projectName];
				if ([content writeToFile:schemeFile atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO)
					[self showAlertWithError:error];

				// rename the file
				NSString* renamed = [schemeFile stringByReplacingOccurrencesOfString:fullTemplateName withString:projectName];
				[fileManager moveItemAtPath:schemeFile toPath:renamed error:&error];
			}
		}
	}

	// add project to the xcworkspace
	{
		NSString* workspaceWithPath = [NSString stringWithFormat:@"%@%@", rootPath, workspaceName];
		
		// create the workspace if it doesn't exist
		if ([fileManager fileExistsAtPath:workspaceWithPath] == NO)
		{
			NSString* workspaceTemplate = [NSString stringWithFormat:@"%@/%@%@", rootPath, kWorkspaceTemplatesSubDir, kKobold2DWorkspace];
			if ([fileManager copyItemAtPath:workspaceTemplate toPath:workspaceWithPath error:&error] == NO)
				[self showAlertWithError:error];
		}
		
		// read the contents.xcworkspacedata and insert the new project at the beginning
		NSString* contentsFile = [NSString stringWithFormat:@"%@/contents.xcworkspacedata", workspaceWithPath];
		NSString* workspace = [NSString stringWithContentsOfFile:contentsFile encoding:NSUTF8StringEncoding error:&error];
		if (workspace == nil)
			[self showAlertWithError:error];
		
		// create the new entry
		NSString* insert = [NSString stringWithFormat:@"<FileRef\n      location = \"group:%@/%@.xcodeproj\">\n   </FileRef>\n   ",
							projectName, projectName];

		// if for whatever reason this entry already exists, remove it
		workspace = [workspace stringByReplacingOccurrencesOfString:insert withString:@""];
		
		// find the insertion point
		NSRange insertPoint = [workspace rangeOfString:@"<FileRef"];
		NSString* front = [workspace substringToIndex:insertPoint.location];
		NSString* back = [workspace substringFromIndex:insertPoint.location];
		
		// construct the new string with the new FileRef inserted
		workspace = [NSString stringWithFormat:@"%@%@%@", front, insert, back];
		if ([workspace writeToFile:contentsFile atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO)
			[self showAlertWithError:error];
	}
	
	// open the workspace
	if (autoOpenProject.state)
	{
		NSString* workspaceWithPath = [NSString stringWithFormat:@"%@%@", rootPath, workspaceName];
		[[NSWorkspace sharedWorkspace] openFile:workspaceWithPath];
	}
}

-(NSString*) sanitizeFileNameString:(NSString*)fileName
{
	NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:"];
	fileName = [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
	return [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(IBAction) createProject:(id)sender 
{
	NSString* templateName = @"";
	if ([templates count] > (NSUInteger)templatesList.selectedRow)
	{
		templateName = [templates objectAtIndex:templatesList.selectedRow];
	}
	
	NSString* workspaceName = kKobold2DWorkspace;
	if ([[workspaceList stringValue] length] > 0)
	{
		workspaceName = [workspaceList stringValue];
		if ([workspaceName hasSuffix:@".xcworkspace"] == NO)
		{
			workspaceName = [NSString stringWithFormat:@"%@.xcworkspace", workspaceName];
		}
	}
	
	if ([templateName length] > 0)
	{
		NSString* projectName = [createProjectName stringValue];
		projectName = [self sanitizeFileNameString:projectName];

		NSMutableCharacterSet* cleanSet = [[[NSMutableCharacterSet alloc] init] autorelease];
		[cleanSet addCharactersInString:@"!#+."];
		[cleanSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
		[cleanSet invert];
		//projectName = [[projectName componentsSeparatedByCharactersInSet:cleanSet] componentsJoinedByString:@"_"];
		//projectName = [projectName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];

		if ([projectName length] == 0)
		{
			projectName = [NSString stringWithFormat:@"My-%@-Project", templateName];
		}
		
		NSLog(@"Create new project '%@' from template '%@' into workspace '%@' open: %li", projectName, templateName, workspaceName, (long)autoOpenProject.state);

		[self createProjectWithName:projectName fromTemplate:templateName intoWorkspace:workspaceName];
		
		[NSApp terminate:nil];
	}
}

@end
